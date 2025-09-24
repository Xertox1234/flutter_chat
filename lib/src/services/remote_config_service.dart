import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigService {
  static final RemoteConfigService _instance = RemoteConfigService._internal();
  factory RemoteConfigService() => _instance;
  RemoteConfigService._internal();

  FirebaseRemoteConfig? _remoteConfig;
  bool _isInitialized = false;

  FirebaseRemoteConfig get remoteConfig {
    if (_remoteConfig == null) {
      throw Exception('RemoteConfigService not initialized. Call initialize() first.');
    }
    return _remoteConfig!;
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _remoteConfig = FirebaseRemoteConfig.instance;

      await _remoteConfig!.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 1),
      ));

      await _remoteConfig!.setDefaults({
        'openai_api_key': '',
        'openai_model': 'gpt-3.5-turbo',
        'max_tokens': 150,
        'temperature': 0.7,
        'system_prompt': 'You are a helpful AI assistant for seniors. Be patient, clear, and friendly in your responses.',
      });

      await _remoteConfig!.fetchAndActivate();
      _isInitialized = true;

      print('RemoteConfigService: Initialized successfully');
    } catch (e) {
      print('RemoteConfigService: Error during initialization: $e');
      rethrow;
    }
  }

  String getOpenAIApiKey() {
    return remoteConfig.getString('openai_api_key');
  }

  String getOpenAIModel() {
    return remoteConfig.getString('openai_model');
  }

  int getMaxTokens() {
    return remoteConfig.getInt('max_tokens');
  }

  double getTemperature() {
    return remoteConfig.getDouble('temperature');
  }

  String getSystemPrompt() {
    return remoteConfig.getString('system_prompt');
  }

  Future<void> refresh() async {
    if (!_isInitialized) {
      throw Exception('RemoteConfigService not initialized');
    }

    try {
      await _remoteConfig!.fetchAndActivate();
      print('RemoteConfigService: Configuration refreshed');
    } catch (e) {
      print('RemoteConfigService: Error refreshing configuration: $e');
      rethrow;
    }
  }

  Map<String, dynamic> getAllConfigs() {
    if (!_isInitialized) {
      throw Exception('RemoteConfigService not initialized');
    }

    return {
      'openai_api_key': getOpenAIApiKey(),
      'openai_model': getOpenAIModel(),
      'max_tokens': getMaxTokens(),
      'temperature': getTemperature(),
      'system_prompt': getSystemPrompt(),
    };
  }
}