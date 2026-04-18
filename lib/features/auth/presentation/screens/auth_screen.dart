import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:legalx/core/app_theme.dart';
import 'package:legalx/core/widgets/glass_container.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:legalx/core/providers/supabase_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _isLogin = true;
  bool _isLoading = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _handleAuth() async {
    setState(() => _isLoading = true);
    final supabase = ref.read(supabaseServiceProvider);
    
    try {
      if (_isLogin) {
        await supabase.signIn(_emailController.text, _passwordController.text);
      } else {
        await supabase.signUp(_emailController.text, _passwordController.text);
      }
      if (mounted) context.go('/dashboard');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background decoration
          Positioned(
            top: -100,
            right: -100,
            child: CircleAvatar(
              radius: 200,
              backgroundColor: AppColors.primary.withOpacity(0.05),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.gavel_rounded, size: 60, color: AppColors.primary),
                  const SizedBox(height: 24),
                  Text(
                    'Welcome to LegalX',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28),
                  ),
                  const SizedBox(height: 8),
                  const Text('Intelligent Contract Intelligence', style: TextStyle(color: AppColors.secondary)),
                  const SizedBox(height: 48),
                  GlassContainer(
                    child: Column(
                      children: [
                        TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: const Icon(Icons.email_outlined),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleAuth,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            minimumSize: const Size(double.infinity, 55),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _isLoading 
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : Text(_isLogin ? 'Login' : 'Sign Up'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () => setState(() => _isLogin = !_isLogin),
                    child: Text(_isLogin ? "Don't have an account? Sign Up" : "Already have an account? Login"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
