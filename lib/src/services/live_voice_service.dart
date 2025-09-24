import 'dart:async';
import 'dart:developer' as developer;
import 'dart:typed_data';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:mic_stream/mic_stream.dart' as mic;
import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

enum VoiceSessionState {
  idle,
  connecting,
  listening,
  processing,
  speaking,
  error,
}

class LiveVoiceService {
  static final LiveVoiceService _instance = LiveVoiceService._internal();
  factory LiveVoiceService() => _instance;
  LiveVoiceService._internal();

  LiveSession? _session;
  StreamSubscription? _micSubscription;
  final AudioPlayer _audioPlayer = AudioPlayer();

  VoiceSessionState _state = VoiceSessionState.idle;
  String? _currentTranscript;
  String? _errorMessage;

  final _stateController = StreamController<VoiceSessionState>.broadcast();
  final _transcriptController = StreamController<String>.broadcast();
  final _audioDataController = StreamController<Uint8List>.broadcast();

  Stream<VoiceSessionState> get stateStream => _stateController.stream;
  Stream<String> get transcriptStream => _transcriptController.stream;
  Stream<Uint8List> get audioDataStream => _audioDataController.stream;

  VoiceSessionState get state => _state;
  String? get currentTranscript => _currentTranscript;
  String? get errorMessage => _errorMessage;

  Future<void> startConversation({String? systemPrompt}) async {
    if (_session != null) {
      await stopConversation();
    }

    // Check if running on web platform
    if (kIsWeb) {
      _updateState(VoiceSessionState.error);
      _errorMessage = 'Voice chat is not supported on web platform. Please use the mobile or desktop app.';
      developer.log('Firebase AI Live API does not support web platform', name: 'LiveVoiceService');
      return;
    }

    try {
      _updateState(VoiceSessionState.connecting);

      final model = FirebaseAI.googleAI().liveGenerativeModel(
        model: 'gemini-2.5-flash-exp-0827',
        liveGenerationConfig: LiveGenerationConfig(
          responseModalities: [ResponseModalities.audio],
        ),
        systemInstruction: Content.text(systemPrompt ?? _getDefaultSystemPrompt()),
      );

      _session = await model.connect();

      _session!.receive().listen(
        (response) => _handleServerResponse(response),
        onError: (error) {
          developer.log('Server response error', name: 'LiveVoiceService', error: error);
          _updateState(VoiceSessionState.error);
          _errorMessage = error.toString();
        },
      );

      await _startMicrophone();
      _updateState(VoiceSessionState.listening);

      developer.log('Voice conversation started', name: 'LiveVoiceService');
    } catch (e, stackTrace) {
      developer.log(
        'Error starting conversation',
        name: 'LiveVoiceService',
        error: e,
        stackTrace: stackTrace,
      );
      _updateState(VoiceSessionState.error);
      _errorMessage = e.toString();
      rethrow;
    }
  }

  Future<void> _startMicrophone() async {
    try {
      final micStream = mic.MicStream.microphone(
        audioSource: mic.AudioSource.DEFAULT,
        sampleRate: 16000,
        channelConfig: mic.ChannelConfig.CHANNEL_IN_MONO,
        audioFormat: mic.AudioFormat.ENCODING_PCM_16BIT,
      );

      final mediaChunkStream = micStream.map((data) {
        _audioDataController.add(Uint8List.fromList(data));
        return InlineDataPart('audio/pcm', Uint8List.fromList(data));
      });

      await _session!.sendMediaStream(mediaChunkStream);

      developer.log('Microphone started streaming', name: 'LiveVoiceService');
    } catch (e) {
      developer.log('Error starting microphone', name: 'LiveVoiceService', error: e);
      rethrow;
    }
  }

  void _handleServerResponse(LiveServerResponse response) {
    developer.log(
      'Received server response: ${response.message.runtimeType}',
      name: 'LiveVoiceService',
    );

    switch (response.message) {
      case LiveServerContent(:final modelTurn, :final turnComplete, :final interrupted):
        developer.log(
          'Content received - turnComplete: $turnComplete, interrupted: $interrupted, parts: ${modelTurn?.parts.length ?? 0}',
          name: 'LiveVoiceService',
        );

        if (modelTurn != null) {
          for (final part in modelTurn.parts) {
            if (part is TextPart) {
              _currentTranscript = part.text;
              _transcriptController.add(part.text);
              developer.log('Transcript: ${part.text}', name: 'LiveVoiceService');
            }

            if (part is InlineDataPart && part.mimeType.contains('audio')) {
              _updateState(VoiceSessionState.speaking);
              _playAudioResponse(part.bytes);
            }
          }
        }

        if (turnComplete == true) {
          _updateState(VoiceSessionState.listening);
          developer.log('Turn complete, listening again', name: 'LiveVoiceService');
        }

      case LiveServerToolCall(:final functionCalls):
        developer.log('Tool call received: ${functionCalls?.length ?? 0} calls', name: 'LiveVoiceService');

      case LiveServerToolCallCancellation(:final functionIds):
        developer.log('Tool call cancellation: ${functionIds?.length ?? 0} ids', name: 'LiveVoiceService');

      default:
        developer.log('Received other message type: ${response.message.runtimeType}', name: 'LiveVoiceService');
    }
  }

  Future<void> _playAudioResponse(Uint8List audioData) async {
    try {
      await _audioPlayer.setAudioSource(
        _PCMAudioSource(audioData, sampleRate: 24000),
      );
      await _audioPlayer.play();

      _audioPlayer.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          _updateState(VoiceSessionState.listening);
        }
      });
    } catch (e) {
      developer.log('Error playing audio', name: 'LiveVoiceService', error: e);
    }
  }

  Future<void> sendTextMessage(String message) async {
    if (_session == null) {
      throw Exception('No active session');
    }

    try {
      _updateState(VoiceSessionState.processing);
      await _session!.send(
        input: Content.text(message),
        turnComplete: true,
      );
      developer.log('Sent text message: $message', name: 'LiveVoiceService');
    } catch (e) {
      developer.log('Error sending message', name: 'LiveVoiceService', error: e);
      _updateState(VoiceSessionState.error);
      _errorMessage = e.toString();
      rethrow;
    }
  }

  Future<void> stopConversation() async {
    try {
      await _micSubscription?.cancel();
      _micSubscription = null;

      await _audioPlayer.stop();
      await _session?.close();
      _session = null;

      _currentTranscript = null;
      _errorMessage = null;
      _updateState(VoiceSessionState.idle);

      developer.log('Voice conversation stopped', name: 'LiveVoiceService');
    } catch (e) {
      developer.log('Error stopping conversation', name: 'LiveVoiceService', error: e);
    }
  }

  void _updateState(VoiceSessionState newState) {
    _state = newState;
    _stateController.add(newState);
  }

  String _getDefaultSystemPrompt() {
    return '''You are a helpful AI companion for seniors.

Your role is to:
- Speak clearly and at a moderate pace
- Be patient and understanding
- Help with medication reminders
- Assist with scheduling appointments
- Provide companionship and conversation
- Answer questions in simple, easy-to-understand language

Always be warm, friendly, and supportive.''';
  }

  void dispose() {
    stopConversation();
    _stateController.close();
    _transcriptController.close();
    _audioDataController.close();
    _audioPlayer.dispose();
  }
}

class _PCMAudioSource extends StreamAudioSource {
  final Uint8List _audioData;
  final int sampleRate;

  _PCMAudioSource(this._audioData, {required this.sampleRate});

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    start ??= 0;
    end ??= _audioData.length;

    return StreamAudioResponse(
      sourceLength: _audioData.length,
      contentLength: end - start,
      offset: start,
      stream: Stream.value(_audioData.sublist(start, end)),
      contentType: 'audio/pcm',
    );
  }
}