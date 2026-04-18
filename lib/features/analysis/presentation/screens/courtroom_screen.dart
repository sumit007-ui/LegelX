import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:legalx/core/app_theme.dart';
import 'package:legalx/core/services/gemini_service.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class CourtroomScreen extends StatefulWidget {
  const CourtroomScreen({super.key});

  @override
  State<CourtroomScreen> createState() => _CourtroomScreenState();
}

class _CourtroomScreenState extends State<CourtroomScreen> {
  final TextEditingController _controller = TextEditingController();
  final GeminiService _geminiService = GeminiService();
  
  bool _isDebating = false;
  Map<String, String>? _debateResults;

  Future<void> _startDebate() async {
    if (_controller.text.trim().isEmpty) return;
    
    setState(() {
      _isDebating = true;
      _debateResults = null;
    });

    try {
      final results = await _geminiService.orchestrateCourtroomDebate(_controller.text);
      if (mounted) {
        setState(() {
          _debateResults = results;
          _isDebating = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isDebating = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'AI COURTROOM',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                   Icon(Icons.gavel_rounded, color: Colors.redAccent),
                   SizedBox(width: 12),
                   Expanded(
                     child: Text(
                       'Extreme Feature: Multi-Agent LLM Orchestration. Watch 3 independent AI models debate a contract autonomously.',
                       style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.redAccent),
                     ),
                   ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _controller,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Paste a contract clause here to put it on trial...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ActionChip(
                    label: const Text('Try: Unfair Non-Compete'),
                    onPressed: () {
                      _controller.text = "The Employee agrees that upon termination, for any reason, they shall not work for any competitor globally for 10 years, and the company may terminate without notice.";
                    },
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: AppColors.outlineVariant),
                  ),
                  const SizedBox(width: 8),
                  ActionChip(
                    label: const Text('Try: Illegal Eviction Clause'),
                    onPressed: () {
                      _controller.text = "The Tenant agrees that the Landlord may enter the premises anytime without notice. If rent is delayed by 1 day, Landlord can seize all electronic goods without a court order.";
                    },
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: AppColors.outlineVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isDebating ? null : _startDebate,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 64),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: _isDebating 
                ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                    SizedBox(width: 16),
                    Text('VIRTUAL TRIAL IN PROGRESS...'),
                  ],
                )
                : const Text('COMMENCE TRIAL DEBATE', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
            ),
            const SizedBox(height: 40),
            
            if (_debateResults != null) ...[
               _buildAgentCard(
                 title: 'PROSECUTOR AGENT (ATTACK)',
                 content: _debateResults!['attack']!,
                 color: Colors.red,
                 icon: Icons.local_fire_department_rounded,
               ),
               _buildAgentCard(
                 title: 'DEFENDER AGENT (SHIELD)',
                 content: _debateResults!['defense']!,
                 color: Colors.blue,
                 icon: Icons.shield_rounded,
               ),
               _buildAgentCard(
                 title: 'SUPREME JUDGE AGENT (VERDICT)',
                 content: _debateResults!['verdict']!,
                 color: Colors.purple,
                 icon: Icons.balance_rounded,
               ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildAgentCard({required String title, required String content, required Color color, required IconData icon}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
        boxShadow: [BoxShadow(color: color.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(22), topRight: Radius.circular(22)),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 12),
                Text(title, style: TextStyle(fontWeight: FontWeight.w900, color: color, letterSpacing: 1.2)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: MarkdownBody(
               data: content,
               styleSheet: MarkdownStyleSheet(
                 p: const TextStyle(fontSize: 15, height: 1.6),
                 listBullet: TextStyle(color: color),
               ),
            ),
          ),
        ],
      ),
    );
  }
}
