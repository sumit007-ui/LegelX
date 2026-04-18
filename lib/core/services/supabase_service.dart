import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // Authentication
  Future<AuthResponse> signUp(String email, String password) async {
    return await _client.auth.signUp(email: email, password: password);
  }

  Future<AuthResponse> signIn(String email, String password) async {
    return await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // Document Operations
  Future<List<Map<String, dynamic>>> getDocuments() async {
    final response = await _client
        .from('documents')
        .select()
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> uploadDocument(String userId, String fileName, String fileUrl) async {
    final response = await _client.from('documents').insert({
      'user_id': userId,
      'file_name': fileName,
      'file_url': fileUrl,
    }).select().single();
    return Map<String, dynamic>.from(response);
  }

  // Analysis Operations
  Future<List<Map<String, dynamic>>> getClauses(String documentId) async {
    final response = await _client
        .from('clauses')
        .select()
        .eq('document_id', documentId);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> getAnalysis(String documentId) async {
    final response = await _client
        .from('analysis')
        .select()
        .eq('document_id', documentId)
        .single();
    return Map<String, dynamic>.from(response);
  }
}
