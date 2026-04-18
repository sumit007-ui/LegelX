import 'package:flutter/material.dart';
import 'package:legalx/core/app_theme.dart';
import 'package:go_router/go_router.dart';

class SimulationScreen extends StatefulWidget {
  const SimulationScreen({super.key});

  @override
  State<SimulationScreen> createState() => _SimulationScreenState();
}

class _SimulationScreenState extends State<SimulationScreen> {
  String _selectedScenario = 'Early Termination';
  String _simulationResult = 'Select a scenario to project potential outcomes based on ingested contract parameters.';
  bool _isLoading = false;

  void _runSimulation() {
    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
        if (_selectedScenario == 'Early Termination') {
          _simulationResult = 'PROJECTED IMPACT: Termination triggers \$50,000 liquidated damages liability. Notice required: 90 days. Recommended action: Renegotiate Clause 4.2.';
        } else if (_selectedScenario == 'Breach of Warranty') {
          _simulationResult = 'PROJECTED IMPACT: Liability exposure capped at \$120k (12 months trailing fees). Low probability of systemic contagion.';
        } else {
          _simulationResult = 'PROJECTED IMPACT: IP retention remains optimal due to "Sovereign Clause" protection in Section 8.';
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'WAR ROOM',
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
              'Scenario Workshop',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 32,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Execute high-fidelity AI simulations to predict legal and financial consequences.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            
            Text(
              'Vector Selection',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedScenario,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  items: ['Early Termination', 'Breach of Warranty', 'IP Dispute']
                      .map((s) => DropdownMenuItem(
                            value: s,
                            child: Text(
                              s,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedScenario = val!),
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _runSimulation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _isLoading 
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                    : const Text('EXECUTE SIMULATION', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
              ),
            ),
            
            const SizedBox(height: 48),
            Text(
              'Outcome Projection',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: _simulationResult.contains('IMPACT') ? AppColors.primary.withOpacity(0.05) : Colors.white,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: _simulationResult.contains('IMPACT') 
                      ? AppColors.primary.withOpacity(0.2) 
                      : AppColors.outlineVariant.withOpacity(0.5)
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    _simulationResult.contains('IMPACT') ? Icons.analytics_rounded : Icons.hourglass_empty_rounded,
                    color: AppColors.primary,
                    size: 48,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _simulationResult,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
