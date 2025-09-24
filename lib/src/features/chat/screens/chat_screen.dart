import 'package:flutter/material.dart';
import 'package:seniors_companion_app/src/features/authentication/screens/login_screen.dart';
import 'package:seniors_companion_app/src/features/authentication/services/auth_service.dart';
import 'package:seniors_companion_app/src/services/live_voice_service.dart';
import 'dart:typed_data';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with SingleTickerProviderStateMixin {
  final LiveVoiceService _voiceService = LiveVoiceService();
  final List<String> _transcript = [];
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _voiceService.transcriptStream.listen((text) {
      setState(() {
        if (_transcript.isEmpty || _transcript.last != text) {
          _transcript.add(text);
        }
      });
    });
  }

  @override
  void dispose() {
    _voiceService.stopConversation();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _toggleConversation() async {
    if (_voiceService.state == VoiceSessionState.idle) {
      await _voiceService.startConversation();
    } else {
      await _voiceService.stopConversation();
    }
    setState(() {});
  }

  Color _getStateColor(VoiceSessionState state) {
    switch (state) {
      case VoiceSessionState.idle:
        return Colors.grey;
      case VoiceSessionState.connecting:
        return Colors.orange;
      case VoiceSessionState.listening:
        return Colors.green;
      case VoiceSessionState.processing:
        return Colors.blue;
      case VoiceSessionState.speaking:
        return Colors.purple;
      case VoiceSessionState.error:
        return Colors.red;
    }
  }

  String _getStateText(VoiceSessionState state) {
    switch (state) {
      case VoiceSessionState.idle:
        return 'Tap to Start';
      case VoiceSessionState.connecting:
        return 'Connecting...';
      case VoiceSessionState.listening:
        return 'Listening...';
      case VoiceSessionState.processing:
        return 'Processing...';
      case VoiceSessionState.speaking:
        return 'Speaking...';
      case VoiceSessionState.error:
        return 'Error';
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Chat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<VoiceSessionState>(
              stream: _voiceService.stateStream,
              initialData: _voiceService.state,
              builder: (context, snapshot) {
                final state = snapshot.data ?? VoiceSessionState.idle;

                return Column(
                  children: [
                    const SizedBox(height: 40),

                    Center(
                      child: GestureDetector(
                        onTap: _toggleConversation,
                        child: AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            final isActive = state != VoiceSessionState.idle;
                            final scale = isActive
                                ? 1.0 + (_pulseController.value * 0.1)
                                : 1.0;

                            return Transform.scale(
                              scale: scale,
                              child: Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _getStateColor(state).withOpacity(0.2),
                                  border: Border.all(
                                    color: _getStateColor(state),
                                    width: 4,
                                  ),
                                  boxShadow: isActive
                                      ? [
                                          BoxShadow(
                                            color: _getStateColor(state).withOpacity(0.5),
                                            blurRadius: 20,
                                            spreadRadius: 5,
                                          ),
                                        ]
                                      : [],
                                ),
                                child: Icon(
                                  state == VoiceSessionState.idle
                                      ? Icons.mic
                                      : Icons.mic_off,
                                  size: 80,
                                  color: _getStateColor(state),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      _getStateText(state),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 40),

                    if (state == VoiceSessionState.error && _voiceService.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Error: ${_voiceService.errorMessage}',
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    Expanded(
                      child: _transcript.isEmpty
                          ? const Center(
                              child: Text(
                                'Start a conversation\nTap the microphone to begin',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _transcript.length,
                              itemBuilder: (context, index) {
                                final isUser = index % 2 == 0;
                                return Align(
                                  alignment: isUser
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(vertical: 8),
                                    padding: const EdgeInsets.all(16),
                                    constraints: BoxConstraints(
                                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isUser
                                          ? Colors.blue.shade100
                                          : Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      _transcript[index],
                                      style: const TextStyle(
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),

                    StreamBuilder<Uint8List>(
                      stream: _voiceService.audioDataStream,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || state != VoiceSessionState.listening) {
                          return const SizedBox(height: 60);
                        }

                        return Container(
                          height: 60,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: CustomPaint(
                            painter: WaveformPainter(snapshot.data!),
                            size: Size.infinite,
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class WaveformPainter extends CustomPainter {
  final Uint8List audioData;
  static const int maxBars = 50;

  WaveformPainter(this.audioData);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final barWidth = size.width / maxBars;
    final step = (audioData.length / maxBars).ceil();

    for (int i = 0; i < maxBars && i * step < audioData.length; i++) {
      final dataIndex = i * step;
      if (dataIndex >= audioData.length) break;

      final value = audioData[dataIndex] / 255.0;
      final barHeight = value * size.height * 0.8;
      final x = i * barWidth + barWidth / 2;
      final y1 = (size.height - barHeight) / 2;
      final y2 = y1 + barHeight;

      canvas.drawLine(
        Offset(x, y1),
        Offset(x, y2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(WaveformPainter oldDelegate) => true;
}