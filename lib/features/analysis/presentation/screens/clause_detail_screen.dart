import 'package:flutter/material.dart';
import 'package:legalx/core/app_theme.dart';
import 'package:go_router/go_router.dart';

class ClauseDetailScreen extends StatelessWidget {
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
              clauseTitle,
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 32,
              ),
            ),
            const SizedBox(height: 32),

            // Original Clause Container
            _DetailSection(
              title: 'EXTRACTED PROVISION',
              content: clauseText,
              icon: Icons.article_outlined,
              isOriginal: true,
            ),
            
            const SizedBox(height: 24),

            // AI Explanation Container
            _DetailSection(
              title: 'AI DEFICIT ANALYSIS',
              content: explanation,
              icon: Icons.psychology_outlined,
              isOriginal: false,
              accentColor: AppColors.primary,
            ),
            
            const SizedBox(height: 32),
            Text(
              'MITIGATION STRATEGY',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'REVISED PROVISION (RECOMMENDED)',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 10,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Neither party shall be liable for indirect, incidental, or consequential damages, except in cases of gross negligence or willful misconduct. Liability is strictly capped at 2x annual recurring fees.',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.copy_rounded, size: 16),
                    label: const Text('COPY TO CLIPBOARD'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11),
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
          child: Text(
            content,
            style: TextStyle(
              fontWeight: isOriginal ? FontWeight.w400 : FontWeight.w600,
              fontSize: 15,
              height: 1.6,
              fontStyle: isOriginal ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ),
      ],
    );
  }
}
