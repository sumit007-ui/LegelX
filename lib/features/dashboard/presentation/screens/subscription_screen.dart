import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:legalx/core/app_theme.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool _isYearly = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Premium Dark Navy
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            const Icon(Icons.auto_awesome_rounded, color: Colors.amber, size: 64),
            const SizedBox(height: 16),
            const Text(
              'ELITE LEGALX PRO',
              style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 2),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your digital defense is now on-device.',
              style: TextStyle(color: Colors.white60, fontSize: 14),
            ),
            
            const SizedBox(height: 40),

            // Pricing Toggle
            _buildToggle(),

            const SizedBox(height: 40),

            // Main Plans
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildProCard(),
                  const SizedBox(height: 24),
                  _buildFreeCard(),
                ],
              ),
            ),

            const SizedBox(height: 48),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline_rounded, color: Colors.white30, size: 14),
                SizedBox(width: 8),
                Text('SECURED BY STRIPE & SSL', style: TextStyle(color: Colors.white30, fontSize: 10, letterSpacing: 1.5)),
              ],
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _toggleBtn('Monthly', !_isYearly),
          _toggleBtn('Yearly (Save 20%)', _isYearly),
        ],
      ),
    );
  }

  Widget _toggleBtn(String text, bool active) {
    return GestureDetector(
      onTap: () => setState(() => _isYearly = text.contains('Yearly')),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(text, style: TextStyle(color: active ? Colors.black : Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
      ),
    );
  }

  Widget _buildProCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFFA855F7)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: Colors.purple.withOpacity(0.3), blurRadius: 40, spreadRadius: 5)],
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('PRO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 28, letterSpacing: 1)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), borderRadius: BorderRadius.circular(12)),
                child: const Text('MOST POPULAR', style: TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(_isYearly ? '₹6,999' : '₹799', style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w900)),
              Padding(
                padding: const EdgeInsets.only(bottom: 12, left: 4),
                child: Text(_isYearly ? '/year' : '/mo', style: const TextStyle(color: Colors.white60)),
              ),
            ],
          ),
          const Divider(height: 48, color: Colors.white24),
          _featureRow('Truly Offline AI (Ollama)', true),
          _featureRow('Professional PDF Reports', true),
          _featureRow('Visual Evidence Engine', true),
          _featureRow('Multi-Agent Courtroom', true),
          _featureRow('Unlimited Batch Audits', true),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.indigo,
              minimumSize: const Size(double.infinity, 64),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('START 7-DAY FREE TRIAL', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  Widget _buildFreeCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(32)),
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('BASIC', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20)),
          const SizedBox(height: 12),
          const Text('₹0', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 24),
          _featureRow('3 Scans per day', false),
          _featureRow('Cloud Gemini Flash AI', false),
          _featureRow('No Offline Support', false, isX: true),
        ],
      ),
    );
  }

  Widget _featureRow(String text, bool isPro, {bool isX = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(
            isX ? Icons.close_rounded : Icons.check_circle_rounded, 
            color: isX ? Colors.redAccent : (isPro ? Colors.white : Colors.white60), 
            size: 20
          ),
          const SizedBox(width: 12),
          Text(text, style: TextStyle(color: isPro ? Colors.white : Colors.white60, fontSize: 13, fontWeight: isPro ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
