import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final String _baseUrl = 'http://localhost:8000'; // Update with actual server URL

  /// For non-web platforms: send file via its local path
  Future<Map<String, dynamic>> analyzeDocumentPath(String filePath) async {
    if (kIsWeb) {
      // Should never be called on web, but guard anyway
      throw UnsupportedError('analyzeDocumentPath is not supported on web.');
    }
    // Use a dynamic import trick: build multipart request using filePath as string
    // We avoid dart:io at the top level; http package handles the path internally.
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_baseUrl/analyze-document'),
    );
    request.files.add(await http.MultipartFile.fromPath('file', filePath));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to analyze document: ${response.statusCode}');
    }
  }
}
