import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:legalx/core/app_theme.dart';

import 'package:legalx/core/services/gemini_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _localMode = GeminiService.isOfflineMode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'LEGALX AI',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: AppColors.secondary,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Your Digital Lawyer',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildStatusBadge(),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () => context.push('/subscription'),
                        icon: const Icon(Icons.auto_awesome, size: 14, color: Colors.amber),
                        label: const Text('GO PRO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.amber)),
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.primary, 
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          minimumSize: const Size(0, 32),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 40),
              
              // Hero Section
              _buildHeroSection(context),

              const SizedBox(height: 24),

              // OFFLINE PRIVACY SHIELD (HACKATHON WINNER)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _localMode 
                      ? [Colors.blueGrey.shade900, Colors.black] 
                      : [Colors.indigo.shade50, Colors.white],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: _localMode ? Colors.cyanAccent : Colors.indigo.withOpacity(0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: _localMode ? Colors.cyanAccent.withOpacity(0.2) : Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      _localMode ? Icons.security_rounded : Icons.cloud_off_rounded, 
                      color: _localMode ? Colors.cyanAccent : Colors.indigo, 
                      size: 32
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _localMode ? 'PRIVACY SHIELD ACTIVE' : 'OFFLINE PRIVACY MODE',
                            style: TextStyle(
                              fontWeight: FontWeight.w900, 
                              fontSize: 14, 
                              color: _localMode ? Colors.cyanAccent : Colors.indigo,
                              letterSpacing: 1.2
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _localMode 
                              ? 'Running on local hardware. No cloud data leakage.' 
                              : 'Process legal docs 100% offline (Private).',
                            style: TextStyle(
                              fontSize: 11, 
                              color: _localMode ? Colors.white70 : Colors.black54
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _localMode,
                      activeColor: Colors.cyanAccent,
                      onChanged: (val) {
                        setState(() {
                          _localMode = val;
                          GeminiService.isOfflineMode = val;
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              Text(
                'Matrix Tools',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                'Explore different ways to analyze your legal safety.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 24),

              // Matrix Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.82,
                children: [
                  _MatrixCard(
                    title: 'Risk Heatmap',
                    subtitle: 'Find dangers in 1 second',
                    icon: Icons.grid_view_rounded,
                    color: Colors.redAccent,
                    onTap: () => context.push('/risk-heatmap'),
                  ),
                  _MatrixCard(
                    title: 'AI Drafting',
                    subtitle: 'Generate professional papers',
                    icon: Icons.edit_document,
                    color: Colors.deepPurpleAccent,
                    onTap: () => context.push('/drafting'),
                  ),
                  _MatrixCard(
                    title: 'AI Courtroom',
                    subtitle: 'Multi-Agent Trial',
                    icon: Icons.gavel_rounded,
                    color: Colors.orangeAccent,
                    onTap: () => context.push('/courtroom'),
                  ),
                  _MatrixCard(
                    title: 'Ledger Score',
                    subtitle: 'Your overall trust level',
                    icon: Icons.speed_rounded,
                    color: Colors.greenAccent,
                    onTap: () => context.push('/score-dashboard'),
                  ),
                  _MatrixCard(
                    title: 'Mobile Offline Scan',
                    subtitle: 'Scan without internet (Airplane Mode)',
                    icon: Icons.cell_tower_rounded,
                    color: Colors.cyanAccent,
                    onTap: () => context.push('/mobile-scanner'),
                  ),
                  _MatrixCard(
                    title: 'Pitch Deck',
                    subtitle: 'Present LegalX Vision',
                    icon: Icons.present_to_all_rounded,
                    color: Colors.blueAccent,
                    onTap: () => context.push('/pitch'),
                  ),
                ],
              ),

              
              const SizedBox(height: 48),

              // Simple Guide Section
              Text(
                'Quick Guide',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 20),
              _buildGuideCard(
                icon: Icons.lightbulb_outline_rounded,
                title: 'Risk Heatmap',
                desc: 'A visual overview of the document. Red areas highlight danger, while green areas indicate standard, safe terms.',
              ),
              _buildGuideCard(
                icon: Icons.gavel_rounded,
                title: 'AI Courtroom (Multi-Agent)',
                desc: 'An extreme hackathon feature: Watch 3 unique AI models (Prosecutor, Defender, Judge) autonomously debate your contract in real-time.',
              ),
              _buildGuideCard(
                icon: Icons.verified_rounded,
                title: 'Ledger Score',
                desc: 'An overall health rating of the contract. A score above 80 signifies a highly secure agreement.',
              ),
              
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(color: Color(0xFF2E7D32), shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          const Text(
            'SYSTEM LIVE',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(32),
        image: const DecorationImage(
          image: NetworkImage('https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&q=80&w=2070'),
          fit: BoxFit.cover,
          opacity: 0.15,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.security_rounded, color: Colors.white, size: 40),
          const SizedBox(height: 24),
          Text(
            'Analyze your\nlegal risks',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(color: Colors.white, height: 1.1),
          ),
          const SizedBox(height: 24),
          Text(
            'Upload your documents and let AI simplify the complex legal language for you.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white.withOpacity(0.7)),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => context.push('/upload'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('INGEST DOCUMENT', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                SizedBox(width: 12),
                Icon(Icons.arrow_forward_rounded, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideCard({required IconData icon, required String title, required String desc}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: AppColors.secondary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MatrixCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MatrixCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10, height: 1.2), maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

