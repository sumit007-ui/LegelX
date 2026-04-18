import 'package:flutter/material.dart';
import 'package:legalx/core/app_theme.dart';
import 'package:go_router/go_router.dart';

class RiskHeatmapScreen extends StatelessWidget {
  const RiskHeatmapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'SURFACE MAP',
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
              'Intelligence Heatmap',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 32,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Tap clauses to see detailed precision analysis and risk mitigation strategies.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            
            // Map Legend
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                   _LegendItem(color: Color(0xFFC62828), label: 'CRITICAL'),
                   _LegendItem(color: Color(0xFFEF6C00), label: 'WARNING'),
                   _LegendItem(color: Color(0xFF2E7D32), label: 'OPTIMAL'),
                ],
              ),
            ),
            
            const SizedBox(height: 32),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 15,
              itemBuilder: (context, index) {
                return _HeatmapTile(
                  index: index,
                  title: _getClauseTitle(index),
                );
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  String _getClauseTitle(int index) {
    List<String> titles = [
      'Scope of Services',
      'Term and Termination',
      'Payment Terms',
      'Confidentiality',
      'Indemnification',
      'Liability Limits',
      'Force Majeure',
      'Governing Law',
      'Dispute Resolution',
      'Amendments',
      'Severability',
      'Assignment',
      'Notices',
      'Entire Agreement',
      'Signatures',
    ];
    return titles[index % titles.length];
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
      ],
    );
  }
}

class _HeatmapTile extends StatelessWidget {
  final int index;
  final String title;

  const _HeatmapTile({
    required this.index,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCritical = index == 4 || index == 5;
    final bool isWarning = index == 1 || index == 6;
    
    final Color badgeColor = isCritical 
        ? const Color(0xFFC62828) 
        : (isWarning ? const Color(0xFFEF6C00) : const Color(0xFF2E7D32));
    
    final String riskTag = isCritical ? 'CRITICAL' : (isWarning ? 'WARNING' : 'OPTIMAL');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          context.push(
            '/clause-detail',
            extra: {
              'title': title,
              'text': 'The parties agree to indemnify and hold harmless the other party from and against any and all claims, damages, liabilities...',
              'explanation': isCritical 
                  ? 'This clause is extremely broad and may expose you to unlimited liability. Recommend adding a liability cap of 1x annual fees.' 
                  : 'Standard clause alignment verified.',
              'score': isCritical ? 0.9 : (isWarning ? 0.5 : 0.1),
            },
          );
        },
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: badgeColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'AI Sector Analysis Active',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  riskTag,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
