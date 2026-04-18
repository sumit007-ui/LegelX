import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:legalx/core/app_theme.dart';
import 'package:go_router/go_router.dart';

class UploadContractScreen extends StatefulWidget {
  const UploadContractScreen({super.key});

  @override
  State<UploadContractScreen> createState() => _UploadContractScreenState();
}

class _UploadContractScreenState extends State<UploadContractScreen> {
  bool _isUploading = false;
  String? _fileName;
  String? _filePath;

  Future<void> _pickFile() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result != null) {
      setState(() {
        _fileName = result.files.single.name;
        _filePath = result.files.single.path;
      });
    }
  }

  void _processContract() {
    if (_fileName == null) return;
    
    setState(() {
      _isUploading = true;
    });

    // Simulate upload and transition to processing
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        context.push('/processing', extra: _filePath);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'DOCUMENT INGESTION',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Precision Analysis',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 32,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Upload your legal data assets for end-to-end ledger validation and risk surface mapping.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 48),
              
              // Upload Area
              Expanded(
                child: GestureDetector(
                  onTap: _pickFile,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: AppColors.outlineVariant,
                        width: 2,
                        style: BorderStyle.solid, // Custom dashed border would need a painter
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _fileName == null ? Icons.cloud_upload_rounded : Icons.description_rounded,
                            size: 48,
                            color: AppColors.secondary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          _fileName ?? 'Drop your document here',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _fileName != null ? 'Ready for AI processing' : 'Supported formats: PDF, DOCX, TXT',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Options/Info
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHighest.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified_user_rounded, color: AppColors.secondary),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'End-to-End Encryption',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          Text(
                            'Your data assets are encrypted before analysis.',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 48),
              
              ElevatedButton(
                onPressed: _fileName != null && !_isUploading ? _processContract : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 72),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  elevation: 0,
                ),
                child: _isUploading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'START PRECISION ANALYSIS',
                            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5),
                          ),
                          SizedBox(width: 12),
                          Icon(Icons.bolt_rounded, size: 20),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
