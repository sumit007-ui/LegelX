import 'package:flutter/material.dart';
import 'package:legalx/core/app_theme.dart';
import 'package:go_router/go_router.dart';

class SummaryScreen extends StatelessWidget {
  final Map<String, dynamic>? analysisData;
  const SummaryScreen({super.key, this.analysisData});

  @override
  Widget build(BuildContext context) {
    // Extract data with fallbacks for demo
    final int score = analysisData?['risk_score'] ?? 82;
    final String summaryText = analysisData?['summary'] ?? 
        'This Service Agreement is generally favorable but contains specific risk vectors in liability and termination. Ledger synchronized.';
    final List<dynamic> risks = analysisData?['risks'] ?? [
      {'title': 'Indemnity Mismatch', 'description': 'Clause 4.2 requires uncapped liability.', 'isHigh': true},
      {'title': 'Automatic Renewal', 'description': '90-day cancellation notice required.', 'isHigh': false},
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'ANALYSIS SUMMARY',
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
            // Ledger Score Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 140,
                        height: 140,
                        child: CircularProgressIndicator(
                          value: score / 100,
                          strokeWidth: 8,
                          backgroundColor: AppColors.surfaceContainerHighest,
                          color: score > 70 ? AppColors.secondary : Colors.orange,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$score',
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                            ),
                          ),
                          Text(
                            'SCORE',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: AppColors.textSecondary,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Ledger Integrity: ${score > 75 ? 'High' : 'Moderate'}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Document verified and synchronized with precision matrix.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Text(
              'Quick Intelligence',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                summaryText,
                style: const TextStyle(fontSize: 15, height: 1.6, color: AppColors.textPrimary),
              ),
            ),
            const SizedBox(height: 40),
            Text(
              'Key Risk Vectors',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            ...risks.map((risk) => _RiskVectorTile(
              title: risk['title'] ?? 'Unknown Vector',
              description: risk['description'] ?? 'No data provided',
              isHigh: risk['isHigh'] ?? false,
            )).toList(),
            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.push('/risk-heatmap'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary, width: 2),
                      minimumSize: const Size(0, 64),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Text(
                      'SURFACE MAP',
                      style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => context.push('/score-dashboard'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 64),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 0,
                    ),
                    child: const Text(
                      'FULL LEDGER',
                      style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _RiskVectorTile extends StatelessWidget {
  final String title;
  final String description;
  final bool isHigh;

  const _RiskVectorTile({
    required this.title,
    required this.description,
    required this.isHigh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isHigh ? const Color(0xFFFFEBEE) : const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isHigh ? Icons.gpp_bad_rounded : Icons.info_outline_rounded,
              color: isHigh ? const Color(0xFFC62828) : const Color(0xFFEF6C00),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.outlineVariant),
        ],
      ),
    );
  }
}
