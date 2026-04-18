import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:go_router/go_router.dart';
import 'package:legalx/core/services/gemini_service.dart';
import 'package:legalx/core/app_theme.dart';

class MobileOfflineScanner extends StatefulWidget {
  const MobileOfflineScanner({super.key});

  @override
  State<MobileOfflineScanner> createState() => _MobileOfflineScannerState();
}

class _MobileOfflineScannerState extends State<MobileOfflineScanner> {
  CameraController? _controller;
  bool _isProcessing = false;
  final TextRecognizer _textRecognizer = TextRecognizer();
  final GeminiService _geminiService = GeminiService();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;
    
    _controller = CameraController(cameras.first, ResolutionPreset.high);
    await _controller!.initialize();
    if (mounted) setState(() {});
  }

  Future<void> _scanDocument() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    setState(() => _isProcessing = true);

    try {
      final image = await _controller!.takePicture();
      final inputImage = InputImage.fromFilePath(image.path);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      // Using our Local Privacy Engine from GeminiService
      final results = _geminiService.getLocalAnalysis(recognizedText.text);

      if (mounted) {
        context.pushReplacement('/summary', extra: {
          'analysisData': results,
          'fileBytes': await image.readAsBytes(),
          'extension': 'jpg',
          'offline_badge': true,
        });
      }
    } catch (e) {
      debugPrint('OCR Error: $e');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          CameraPreview(_controller!),
          
          // Scanning Overlay
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.cyanAccent.withOpacity(0.5), width: 2),
            ),
          ),

          Positioned(
            top: 60,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => context.pop(),
            ),
          ),

          if (_isProcessing)
            const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Colors.cyanAccent),
                  SizedBox(height: 16),
                  Text('LOCAL OCR SCANNING...', style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
                ],
              ),
            ),

          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _isProcessing ? null : _scanDocument,
                child: Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: const Icon(Icons.camera_alt, color: Colors.black),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
