import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:legalx/core/services/supabase_service.dart';
import 'package:legalx/core/services/api_service.dart';

final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService();
});

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

final authStateProvider = StreamProvider((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});
