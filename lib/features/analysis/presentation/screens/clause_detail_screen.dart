import 'package:flutter/material.dart';
import 'package:legalx/core/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:go_router/go_router.dart';
import 'package:legalx/core/services/gemini_service.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class ClauseDetailScreen extends StatefulWidget {
  final String clauseTitle;
  final String clauseText;
  final String explanation;
  final double riskScore;

  const ClauseDetailScreen({
    super.key,
    required this.clauseTitle,
    required this.clauseText,
    required this.explanation,
    required this.riskScore,
  });

  @override
  State<ClauseDetailScreen> createState() => _ClauseDetailScreenState();
}

class _ClauseDetailScreenState extends State<ClauseDetailScreen> {
  final GeminiService _geminiService = GeminiService();
  final FlutterTts _flutterTts = FlutterTts();
  
  String? _simplifiedText;
  bool _isSimplifying = false;
  bool _isRedlineMode = true; // Default to showing comparison
  bool _isSpeaking = false;

  Future<void> _speak(String text) async {
    if (_isSpeaking) {
      await _flutterTts.stop();
      setState(() => _isSpeaking = false);
    } else {
      setState(() => _isSpeaking = true);
      
      // Storyteller settings
      await _flutterTts.setPitch(1.2); // Cheerful voice
      await _flutterTts.setSpeechRate(0.4); // Slow and clear
      await _flutterTts.setVolume(1.0);
      
      await _flutterTts.speak(text);
      _flutterTts.setCompletionHandler(() {
        setState(() => _isSpeaking = false);
      });
    }
  }

  Future<void> _handleSimplify() async {
    setState(() {
      _isSimplifying = true;
    });

    final result = await _geminiService.simplifyLegalText(widget.clauseText);

    if (mounted) {
      setState(() {
        _simplifiedText = result;
        _isSimplifying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'PRECISION VIEW',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(_isSpeaking ? Icons.stop_circle_rounded : Icons.face_retouching_natural_rounded, color: Colors.orange),
            onPressed: () async {
               if (_isSpeaking) {
                 await _flutterTts.stop();
                 setState(() => _isSpeaking = false);
                 return;
               }
               
               // First, get the kid-friendly text if not already simplified
               if (_simplifiedText == null) {
                 await _handleSimplify();
               }
               
               if (_simplifiedText != null) {
                 _speak(_simplifiedText!);
               }
            },
            tooltip: 'Explain like a child',
          ),
          IconButton(
            icon: Icon(_isSpeaking ? Icons.stop_circle_rounded : Icons.volume_up_rounded, color: AppColors.primary),
            onPressed: () => _speak(widget.explanation),
          ),
          const SizedBox(width: 8),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.clauseTitle,
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 32,
              ),
            ),
            const SizedBox(height: 32),

            // Original Clause Container
            _DetailSection(
              title: 'EXTRACTED PROVISION',
              content: widget.clauseText,
              icon: Icons.article_outlined,
              isOriginal: true,
            ),
            
            const SizedBox(height: 24),

            // AI Explanation Container
            _DetailSection(
              title: 'AI DEFICIT ANALYSIS',
              content: widget.explanation,
              icon: Icons.psychology_outlined,
              isOriginal: false,
              accentColor: AppColors.primary,
            ),

            if (_simplifiedText != null) ...[
              const SizedBox(height: 24),
              _DetailSection(
                title: 'AI SIMPLIFICATION (EASY READ)',
                content: _simplifiedText!,
                icon: Icons.auto_awesome_rounded,
                isOriginal: false,
                accentColor: Colors.purple,
              ),
            ],
            
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isSimplifying ? null : _handleSimplify,
                    icon: _isSimplifying 
                      ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.auto_awesome_rounded, size: 16),
                    label: Text(_isSimplifying ? 'SIMPLIFYING...' : 'SIMPLIFY FOR ME'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            Text(
              'LEGAL REDLINE (BEFORE vs AFTER)',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.remove_circle_outline_rounded, color: Colors.redAccent, size: 16),
                      const SizedBox(width: 8),
                      Text('ORIGINAL (DELETED)', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Colors.redAccent)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.clauseText,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      decoration: TextDecoration.lineThrough,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Divider(height: 1, color: AppColors.outlineVariant),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 16),
                      const SizedBox(width: 8),
                      Text('PROPOSED FIX (ADDED)', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Colors.green)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Neither party shall be liable for indirect, incidental, or consequential damages, except in cases of gross negligence. Liability is strictly capped at 2x annual recurring fees.',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                         showModalBottomSheet(
                           context: context,
                           isScrollControlled: true,
                           backgroundColor: Colors.transparent,
                           builder: (context) => _NegotiationSheet(clauseText: widget.clauseText),
                         );
                    },
                    icon: const Icon(Icons.mark_email_read_rounded, size: 16),
                    label: const Text('NEGOTIATE THIS FIX'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11),
                      minimumSize: const Size(double.infinity, 56),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;
  final bool isOriginal;
  final Color? accentColor;

  const _DetailSection({
    required this.title,
    required this.content,
    required this.icon,
    required this.isOriginal,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: accentColor ?? AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 10,
                letterSpacing: 1,
                color: accentColor ?? AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
          ),
          child: MarkdownBody(
            data: content,
            styleSheet: MarkdownStyleSheet(
              p: TextStyle(
                fontWeight: isOriginal ? FontWeight.w400 : FontWeight.w600,
                fontSize: 15,
                height: 1.6,
                fontStyle: isOriginal ? FontStyle.italic : FontStyle.normal,
              ),
              h1: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              h2: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              h3: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              listBullet: const TextStyle(color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }
}

class _NegotiationSheet extends StatefulWidget {
  final String clauseText;
  const _NegotiationSheet({required this.clauseText});

  @override
  State<_NegotiationSheet> createState() => _NegotiationSheetState();
}

class _NegotiationSheetState extends State<_NegotiationSheet> {
  final GeminiService _geminiService = GeminiService();
  String? _result;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _negotiate();
  }

  Future<void> _negotiate() async {
    final res = await _geminiService.generateNegotiationEmail(widget.clauseText);
    if (mounted) {
      setState(() {
        _result = res;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('PUSHBACK EMAIL GENERATOR', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 12, color: Colors.blue)),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: _loading 
              ? const Center(child: CircularProgressIndicator(color: Colors.blue))
              : Markdown(
                  data: _result ?? 'Generation failed.',
                  styleSheet: MarkdownStyleSheet(
                    p: const TextStyle(fontSize: 16, height: 1.6),
                    h1: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue),
                    h2: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                    listBullet: const TextStyle(color: Colors.blue),
                  ),
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.copy_rounded),
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            label: const Text('COPY AND CLOSE', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}


