import 'package:flutter/material.dart';
import 'package:legalx/core/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PitchScreen extends StatefulWidget {
  const PitchScreen({super.key});

  @override
  State<PitchScreen> createState() => _PitchScreenState();
}

class _PitchScreenState extends State<PitchScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<PitchSlide> _slides = [
    PitchSlide(
      title: 'THE LEGAL GAP',
      subtitle: '\$1.2 Trillion in annual contract leakages globally.',
      content: '90% of SMEs cannot afford high-end legal review, leading to critical risk exposure.',
      icon: Icons.warning_amber_rounded,
    ),
    PitchSlide(
      title: 'LEGALX AI',
      subtitle: 'Precision Intelligence. Forensic Ledger.',
      content: 'A high-speed forensic suite that uses Multi-Agent AI to analyze, debate, and verify legal safety.',
      icon: Icons.security_rounded,
    ),
    PitchSlide(
      title: 'MULTI-AGENT ORCHESTRATION',
      subtitle: 'The AI Courtroom.',
      content: 'Chaining specialized agents (Prosecutor, Defender, Judge) to find vulnerabilities that single-model chatbots miss.',
      icon: Icons.gavel_rounded,
    ),
    PitchSlide(
      title: '3D JURISDICTION MAPPING',
      subtitle: 'Spatial Risk Intelligence.',
      content: 'Visualizing legal risk across geographic and digital boundaries using photorealistic 3D engines.',
      icon: Icons.view_in_ar_rounded,
    ),
    PitchSlide(
      title: 'PRIVACY SHIELD',
      subtitle: '100% Local Processing.',
      content: 'Zero-knowledge architecture. All sensitive legal analysis happens on the device hardware.',
      icon: Icons.vpn_lock_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (idx) => setState(() => _currentPage = idx),
            itemCount: _slides.length,
            itemBuilder: (context, index) {
              final slide = _slides[index];
              return _buildSlide(slide);
            },
          ),
          
          // Navigation Overlay
          Positioned(
            bottom: 64,
            left: 24,
            right: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentPage > 0)
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white54),
                    onPressed: () => _pageController.previousPage(duration: 400.ms, curve: Curves.easeOut),
                  )
                else
                  const SizedBox(width: 48),
                
                Row(
                  children: List.generate(_slides.length, (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: index == _currentPage ? 12 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: index == _currentPage ? AppColors.secondary : Colors.white24,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  )),
                ),

                if (_currentPage < _slides.length - 1)
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white),
                    onPressed: () => _pageController.nextPage(duration: 400.ms, curve: Curves.easeOut),
                  )
                else
                  TextButton(
                    onPressed: () => context.go('/dashboard'),
                    child: const Text('LAUNCH SYSTEM', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                  ),
              ],
            ),
          ),

          // Close Button
          Positioned(
            top: 64,
            right: 24,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white54),
              onPressed: () => context.go('/dashboard'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlide(PitchSlide slide) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.black,
            AppColors.primary.withOpacity(0.3),
            Colors.black,
          ],
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(slide.icon, size: 80, color: AppColors.secondary)
            .animate()
            .scale(duration: 600.ms, curve: Curves.elasticOut)
            .shimmer(delay: 800.ms, duration: 2.seconds),
          const SizedBox(height: 48),
          Text(
            slide.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              height: 1.1,
            ),
          ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.2),
          const SizedBox(height: 16),
          Text(
            slide.subtitle,
            style: TextStyle(
              color: AppColors.secondary.withOpacity(0.8),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ).animate(delay: 200.ms).fadeIn().slideX(begin: -0.1),
          const SizedBox(height: 32),
          Container(
            height: 2,
            width: 64,
            color: AppColors.secondary,
          ).animate(delay: 400.ms).scaleX(begin: 0, alignment: Alignment.centerLeft),
          const SizedBox(height: 32),
          Text(
            slide.content,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 16,
              height: 1.6,
            ),
          ).animate(delay: 500.ms).fadeIn(),
        ],
      ),
    );
  }
}

class PitchSlide {
  final String title;
  final String subtitle;
  final String content;
  final IconData icon;

  PitchSlide({required this.title, required this.subtitle, required this.content, required this.icon});
}
