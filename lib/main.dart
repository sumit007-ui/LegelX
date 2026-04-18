import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:legalx/core/app_theme.dart';
import 'package:legalx/features/contract/presentation/screens/upload_contract_screen.dart';
import 'package:legalx/features/analysis/presentation/screens/processing_screen.dart';
import 'package:legalx/features/analysis/presentation/screens/summary_screen.dart';
import 'package:legalx/features/analysis/presentation/screens/risk_heatmap_screen.dart';
import 'package:legalx/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:legalx/features/dashboard/presentation/screens/map_risk_screen.dart';
import 'package:legalx/features/analysis/presentation/screens/simulation_screen.dart';
import 'package:legalx/features/analysis/presentation/screens/score_dashboard_screen.dart';
import 'package:legalx/features/analysis/presentation/screens/clause_detail_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  debugPrint('LEGALX: Starting system boot...');
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('LEGALX: Flutter initialized');
  
  /*
  try {
    debugPrint('LEGALX: Connecting to cloud ledger...');
    await Supabase.initialize(
      url: 'https://sxfnjcgrwrljffnjtdcd.supabase.co',
      anonKey: 'sb_publishable_Z-cy6Uj3a3iOKkpY-kMykg_s_pwkBfM',
    );
    debugPrint('LEGALX: Cloud connection established');
  } catch (e) {
    debugPrint('LEGALX: Cloud bypass active - Supabase offline: $e');
  }
  */

  debugPrint('LEGALX: Launching UI (SIMULATED MODE)...');
  runApp(
    const ProviderScope(
      child: LegalXApp(),
    ),
  );
}

class LegalXApp extends ConsumerWidget {
  const LegalXApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/upload',
          builder: (context, state) => const UploadContractScreen(),
        ),
        GoRoute(
          path: '/processing',
          builder: (context, state) {
            final filePath = state.extra as String?;
            return ProcessingScreen(filePath: filePath);
          },
        ),
        GoRoute(
          path: '/summary',
          builder: (context, state) {
            final data = state.extra as Map<String, dynamic>?;
            return SummaryScreen(analysisData: data);
          },
        ),
        GoRoute(
          path: '/risk-heatmap',
          builder: (context, state) => const RiskHeatmapScreen(),
        ),
        GoRoute(
          path: '/map-risk',
          builder: (context, state) => const MapRiskScreen(),
        ),
        GoRoute(
          path: '/simulation',
          builder: (context, state) => const SimulationScreen(),
        ),
        GoRoute(
          path: '/score-dashboard',
          builder: (context, state) => const ScoreDashboardScreen(),
        ),
        GoRoute(
          path: '/clause-detail',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>;
            return ClauseDetailScreen(
              clauseTitle: extra['title'],
              clauseText: extra['text'],
              explanation: extra['explanation'],
              riskScore: extra['score'],
            );
          },
        ),
      ],
    );

    return MaterialApp.router(
      title: 'LegalX AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        context.go('/dashboard');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: const Icon(Icons.security_rounded, size: 64, color: Colors.white),
            ),
            const SizedBox(height: 32),
            Text(
              'LEGALX',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: Colors.white,
                letterSpacing: 4,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'PRECISION INTELLIGENCE',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Colors.white.withOpacity(0.5),
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 64),
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
