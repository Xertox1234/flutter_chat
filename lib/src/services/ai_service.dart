import 'dart:convert';
import 'dart:developer' as developer;
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:cross_file/cross_file.dart';
import '../services/remote_config_service.dart';

class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  final RemoteConfigService _remoteConfigService = RemoteConfigService();
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _remoteConfigService.initialize();
      _isInitialized = true;
      developer.log('Initialized successfully', name: 'AIService');
    } catch (e) {
      developer.log('Error during initialization', name: 'AIService', error: e);
      rethrow;
    }
  }

  Future<String> transcribeAudio(XFile audioFile) async {
    final bytes = await audioFile.readAsBytes();

    final apiKey = const String.fromEnvironment('GOOGLE_GENAI_API_KEY');
    final model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
    );

    final prompt = 'Listen to this audio and write down exactly what the person is saying. Return only the spoken words as text, nothing else.';
    final content = [
      Content.multi([
        TextPart(prompt),
        DataPart('audio/wav', bytes),
      ])
    ];

    final response = await model.generateContent(content);
    return response.text ?? '';
  }

  Future<Map<String, dynamic>> extractPrescriptionInfo(XFile imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();

      final apiKey = const String.fromEnvironment('GOOGLE_GENAI_API_KEY');
      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: apiKey,
      );

      final prompt = '''
Analyze this prescription image and extract the following information in JSON format:
{
  "medicationName": "Name of the medication",
  "dosage": "Dosage amount (e.g., 10mg, 2 tablets)",
  "timesPerDay": number (how many times per day),
  "instructions": "Any special instructions or notes",
  "scheduledTimes": ["time1", "time2", ...] (suggested times based on frequency, like ["08:00", "20:00"] for twice daily)
}

If any information is unclear or missing, use null for that field.
Return ONLY the JSON, no other text.
''';

      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', bytes),
        ])
      ];

      final response = await model.generateContent(content);
      final text = response.text ?? '{}';

      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(text);
      if (jsonMatch != null) {
        final jsonStr = jsonMatch.group(0)!;
        try {
          final decoded = jsonDecode(jsonStr);
          if (decoded is Map) {
            return Map<String, dynamic>.from(decoded);
          }
        } catch (parseError) {
          developer.log('JSON parse error', name: 'AIService.extractPrescriptionInfo', error: parseError);
        }
      }

      return {};
    } catch (e, stackTrace) {
      developer.log(
        'Error extracting prescription info',
        name: 'AIService.extractPrescriptionInfo',
        error: e,
        stackTrace: stackTrace,
      );
      return {};
    }
  }

  bool get isConfigured {
    return _isInitialized;
  }

  Map<String, dynamic> getConfiguration() {
    if (!_isInitialized) {
      return {'error': 'Service not initialized'};
    }

    return {
      'provider': 'Google Generative AI (Gemini)',
      'model': 'gemini-2.5-flash',
      'system_prompt': _remoteConfigService.getSystemPrompt(),
    };
  }
}