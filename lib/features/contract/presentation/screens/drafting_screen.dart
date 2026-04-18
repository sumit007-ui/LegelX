import 'package:flutter/material.dart';
import 'package:legalx/core/app_theme.dart';
import 'package:legalx/core/services/gemini_service.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class DraftingScreen extends StatefulWidget {
  const DraftingScreen({super.key});

  @override
  State<DraftingScreen> createState() => _DraftingScreenState();
}

class _DraftingScreenState extends State<DraftingScreen> {
  final TextEditingController _controller = TextEditingController();
  final GeminiService _geminiService = GeminiService();
  String? _draftResult;
  bool _isLoading = false;

  Future<void> _generateDraft() async {
    if (_controller.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _draftResult = null;
    });

    try {
      // Custom prompt for drafting
      final prompt = "Write a professional legal document for: ${_controller.text}. Include standard clauses, placeholders for names/dates, and make it legally sound.";
      final result = await _geminiService.simplifyLegalText(prompt); // Reusing the simplify method for now
      
      setState(() {
        _draftResult = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _draftResult = "Error: Could not generate draft. Please check your API key.";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('AI DRAFTING AGENCY', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 14)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded), onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What do you want to create?',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text('Describe the agreement or legal paper you need (e.g., Rent agreement for 11 months in Punjab).', style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            TextField(
              controller: _controller,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'e.g. Service agreement for a software freelancer...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.secondary)),
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ActionChip(
                    label: const Text('Try: Startup Co-Founder'),
                    onPressed: () {
                      _controller.text = "Draft a strict Co-Founder agreement between Saiyam and John for DataCorp. Include a 4-year vesting schedule, 1-year cliff, and if someone leaves early, they lose their shares.";
                    },
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: AppColors.outlineVariant),
                  ),
                  const SizedBox(width: 8),
                  ActionChip(
                    label: const Text('Try: Freelance Web Dev'),
                    onPressed: () {
                      _controller.text = "Write a freelance contract for a web developer building a website for \$5000. 50% upfront, 50% on completion. Developer retains copyright until full payment.";
                    },
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: AppColors.outlineVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _generateDraft,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 64),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _isLoading 
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('GENERATE PROFESSIONAL DRAFT', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
            if (_draftResult != null) ...[
              const SizedBox(height: 40),
              const Text('PROVISIONAL DRAFT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: AppColors.secondary, letterSpacing: 1.5)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
                ),
                child: MarkdownBody(
                  data: _draftResult!,
                  styleSheet: MarkdownStyleSheet(
                    p: const TextStyle(fontSize: 15, height: 1.6),
                    h1: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    h2: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    h3: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () {}, 
                icon: const Icon(Icons.copy), 
                label: const Text('COPY TO CLIPBOARD'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
