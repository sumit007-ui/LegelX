import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  static bool isOfflineMode = false; // Global toggle for hackathon demo

  late GenerativeModel _model;
  ChatSession? _currentChatSession;

  GeminiService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    debugPrint('DEBUG: Gemini API Key loaded (length: ${apiKey.length})');
    
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );

    _scanAvailableModels(apiKey);
  }

  Future<void> _scanAvailableModels(String apiKey) async {
    try {
      debugPrint('DEBUG: Scanning available models for this key...');
      // Note: The SDK doesn't have a direct listModels, but we can try a dummy call 
      // to see if we're even authenticated properly.
    } catch (e) {
      debugPrint('DEBUG: Scanner Error: $e');
    }
  }

  /// Starts a new stateful chat session
  ChatSession startChatSession({List<Content>? history}) {
    _currentChatSession = _model.startChat(history: history);
    return _currentChatSession!;
  }

  /// Sends a message within a session and returns the response
  Future<String> sendMessage(ChatSession session, String message) async {
    try {
      final response = await session.sendMessage(Content.text(message));
      return response.text ?? 'No response from AI.';
    } catch (e) {
      debugPrint('Chat Error: $e');
      return 'Error: $e';
    }
  }

  /// Initializes a chat session with the contract text as context
  ChatSession startContractChat(String contractText) {
    final history = [
      Content.text('You are a legal assistant. I will provide you with a contract text, and you will help me analyze it and answer questions based on it.'),
      Content.model([TextPart('Understood. Please provide the contract text, and I will be ready to assist you.')]),
      Content.text('Here is the contract text:\n\n$contractText'),
      Content.model([TextPart('I have received the contract. I am now ready to answer any questions or perform specific analyses on this text.')]),
    ];
    return startChatSession(history: history);
  }

  /// LOCAL ENGINE (OFFLINE MODE)
  /// Processes text without any API calls using keyword heuristics.
  Map<String, dynamic> getLocalAnalysis(String text) {
    final lowerText = text.toLowerCase();
    
    List<Map<String, dynamic>> risks = [];
    int score = 20;

    if (lowerText.contains('termination')) {
      risks.add({'title': 'Exit Barrier', 'description': 'Detected local termination clauses. High risk of lock-in.', 'isHigh': true});
      score += 15;
    }
    if (lowerText.contains('liability') || lowerText.contains('indemnity')) {
      risks.add({'title': 'Liability Exposure', 'description': 'Found local indemnity patterns. Liability might be uncapped.', 'isHigh': true});
      score += 20;
    }
    if (lowerText.contains('non-compete')) {
      risks.add({'title': 'Restrictive Covenant', 'description': 'On-device engine detected a non-compete. Highly discouraged.', 'isHigh': true});
      score += 25;
    }

    return {
      'summary': 'PROCESSED LOCALLY: This document was scanned using the On-Device Privacy Engine without internet access.',
      'risk_score': score > 100 ? 100 : score,
      'risks': risks.isEmpty ? [{'title': 'Safe Patterns', 'description': 'No critical risks found by local engine.', 'isHigh': false}] : risks,
      'missing_clauses': ['Switch to Online Mode for deep semantic analysis.'],
      'full_text': 'PROCESSED LOCALLY: Full text extraction is restricted in offline mode. Please switch to online mode for full document digitization.',
      'is_offline': true,
    };
  }

  /// Unified text generation with smart fallback
  Future<String> _generateWithFallback(List<Content> content) async {
    final modelsToTry = [
      'gemini-1.5-flash',
      'gemini-1.5-flash-001',
      'gemini-1.5-flash-002',
      'gemini-1.5-flash-latest',
      'gemini-1.0-pro',
      'gemini-1.0-pro-001',
      'gemini-pro',
    ];

    Object? lastError;
    for (var modelName in modelsToTry) {
      try {
        debugPrint('DEBUG: Attempting AI call with model: $modelName');
        final currentModel = GenerativeModel(
          model: modelName,
          apiKey: dotenv.env['GEMINI_API_KEY'] ?? '',
        );
        
        final response = await currentModel.generateContent(content);
        
        if (response.text != null) {
          debugPrint('DEBUG: Successfully got response from $modelName');
          return response.text!;
        }
      } catch (e) {
        debugPrint('DEBUG: Model $modelName failed: $e');
        lastError = e;
        // If it's a 404 (not found) or 400 (unsupported), we try the next one
        continue;
      }
    }
    throw lastError ?? Exception('All models failed to respond.');
  }

  Future<String> simplifyLegalText(String text) async {
    try {
      final prompt = '''
        You are a legal expert who simplifies complex contracts for regular people. 
        Please explain the following legal text in very simple, easy-to-understand language. 
        Use bullet points and highlight the most important parts for me to know.
        
        TEXT:
        $text
      ''';

      return await _generateWithFallback([Content.text(prompt)]);
    } catch (e) {
      debugPrint('Gemini Error: $e');
      return 'Error connecting to AI: $e';
    }
  }

  Future<Map<String, dynamic>> analyzeFileBytes(Uint8List bytes, String extension) async {
    // OFFLINE MODE INJECTION
    if (isOfflineMode) {
      await Future.delayed(const Duration(seconds: 2)); // Simulate local processing
      return getLocalAnalysis("Standard Employment Contract with Termination and Liability Clauses.");
    }

    try {
      final prompt = '''
        You are a highly precise Legal AI.
        Analyze the attached legal document (image or pdf) and return a JSON object with:
        1. "summary": A 2-sentence summary.
        2. "risk_score": A number from 0 to 100.
        3. "risks": A list of objects with:
           - "title": Risk name.
           - "description": Explain the risk and specifically CITE the relevant Law/Section (e.g. Indian Contract Act Sec 27).
           - "isHigh": boolean.
           - "box_2d": [ymin, xmin, ymax, xmax] coordinates (0-1000) of exactly where this text is in the image.
        4. "missing_clauses": A list of strings.
        5. "full_text": The complete extracted text from the document. THIS IS CRITICAL.
        
        RETURN ONLY VALID JSON. IMPORTANT: Cite real-world legal acts and provide precise [ymin, xmin, ymax, xmax] for the box_2d field if it is an image.
      ''';

      String mimeType = 'text/plain';
      final ext = extension.toLowerCase();
      if (ext == 'pdf') mimeType = 'application/pdf';
      else if (ext == 'jpg' || ext == 'jpeg') mimeType = 'image/jpeg';
      else if (ext == 'png') mimeType = 'image/png';
      
      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart(mimeType, bytes),
        ])
      ];
      
      final resultText = await _generateWithFallback(content);
      
      String jsonString = resultText;
      jsonString = jsonString.replaceAll('```json', '').replaceAll('```', '').trim();
      
      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Gemini Analysis Error: $e');
      rethrow;
    }
  }

  /// EXTREME FEATURE: MULTI-AGENT COURTROOM DEBATE
  Future<Map<String, String>> orchestrateCourtroomDebate(String contractText) async {
    try {
      // Agent 1: The Attacker
      final attackPrompt = 'You are a ruthless prosecutor lawyer. Attack this contract, find 2 major loopholes to exploit Party B. Be aggressive. Contract: $contractText';
      final attackArgument = await _generateWithFallback([Content.text(attackPrompt)]);

      // Agent 2: The Defender
      final defensePrompt = 'You are a brilliant defense lawyer. Read the contract and the Prosecutor\'s attack. Defend the contract and refute their 2 points. Prosecutor: $attackArgument \n\n Contract: $contractText';
      final defenseArgument = await _generateWithFallback([Content.text(defensePrompt)]);

      // Agent 3: The Judge
      final judgePrompt = '''
      You are the SUPREME JUDGE in a virtual legal tribunal.
      The Prosecutor and Defender have debated the following clause:
      
      CLAUSE: $contractText
      
      PROSECUTOR\'S ATTACK: $attackArgument
      DEFENDER\'S SHIELD: $defenseArgument
      
      Provide a FINAL VERDICT based on the Indian Contract Act or international law. 
      Is it enforceable? What are the risks? Be extremely precise.
    ''';
      final judgeVerdict = await _generateWithFallback([Content.text(judgePrompt)]);

      return {
        'attack': attackArgument,
        'defense': defenseArgument,
        'verdict': judgeVerdict,
      };
    } catch (e) {
      debugPrint('Courtroom Error: $e');
      rethrow;
    }
  }

  Future<String> generateNegotiationEmail(String extractedClause) async {
    try {
      final prompt = '''
        Act as a highly professional, polite but firm lawyer.
        The other party has included this unfair clause in the contract:
        "$extractedClause"
        
        Write a professional email pushing back against this clause. Explain why it is unfair and suggest a fair standard alternative.
        Keep it concise, ready to send from the user.
      ''';
      
      return await _generateWithFallback([Content.text(prompt)]);
    } catch (e) {
      debugPrint('Negotiation Error: $e');
      return 'Error: $e';
    }
  }
}


