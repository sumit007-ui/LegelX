import 'package:flutter/material.dart';
import 'package:legalx/core/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:legalx/core/services/gemini_service.dart';
import 'dart:typed_data';

class ProcessingScreen extends StatefulWidget {
  final Map<String, dynamic>? fileData;
  const ProcessingScreen({super.key, this.fileData});

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  double _progress = 0.0;
  String _statusMessage = 'Initializing Ledger Validation...';
  final GeminiService _geminiService = GeminiService();

  @override
  void initState() {
    super.initState();
    _startAnalysis();
  }

  void _startAnalysis() async {
    if (widget.fileData == null || widget.fileData!['bytes'] == null) {
       // Fallback immediately
       context.go('/summary');
       return;
    }

    if (mounted) setState(() { _progress = 0.2; _statusMessage = 'Parsing precision data assets...'; });
    
    Map<String, dynamic>? results;
    try {
      if (mounted) setState(() { _progress = 0.5; _statusMessage = 'AI assessing risk surfaces (Images/PDFs)...'; });
      
      final bytes = widget.fileData!['bytes'] as Uint8List;
      final ext = widget.fileData!['extension'] as String;
      
      results = await _geminiService.analyzeFileBytes(bytes, ext);
      
      if (mounted) setState(() { _progress = 0.9; _statusMessage = 'Finalizing intelligence matrix...'; });
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      debugPrint('Analysis Error: $e');
      if (mounted) setState(() { _progress = 1.0; _statusMessage = 'Failed to load intelligence. Using fallbacks...'; });
      await Future.delayed(const Duration(seconds: 1));
    }

    if (mounted) setState(() { _progress = 1.0; _statusMessage = 'Ledger score synchronized.'; });
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      context.pushReplacement('/summary', extra: {
        'analysisData': results,
        'fileBytes': widget.fileData!['bytes'],
        'extension': widget.fileData!['extension'],
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.security_rounded, color: AppColors.primary, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    'SECURE DOCUMENT LEDGER',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 240,
                    height: 240,
                    child: CircularProgressIndicator(
                      value: _progress,
                      strokeWidth: 4,
                      backgroundColor: AppColors.surfaceContainerHighest,
                      color: AppColors.secondary,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${(_progress * 100).toInt()}%',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 64,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        'VALIDATION',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.textSecondary,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 48),
              Text(
                'Data Validation in Progress',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _statusMessage,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: _StatusCard(
                      icon: Icons.dataset_rounded,
                      title: 'Precision Data',
                      subtitle: 'Ready for mapping',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatusCard(
                      icon: Icons.verified_user_rounded,
                      title: 'Secure Ledger',
                      subtitle: 'Audit active',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _StatusCard({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }
}
