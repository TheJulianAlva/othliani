import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:frontend/core/demo/demo_config.dart';

class WalkieTalkieButton extends StatefulWidget {
  final String tripId;
  const WalkieTalkieButton({super.key, required this.tripId});

  @override
  State<WalkieTalkieButton> createState() => _WalkieTalkieButtonState();
}

class _WalkieTalkieButtonState extends State<WalkieTalkieButton> {
  late io.Socket socket;
  final _recorder = AudioRecorder();
  final _player = FlutterSoundPlayer();

  StreamSubscription<Uint8List>? _micSubscription;

  // Buffer de chunks recibidos — se ensamblan en WAV al soltar el canal
  final List<int> _audioBuffer = [];

  bool isRecording = false;
  bool isChannelBusy = false;

  @override
  void initState() {
    super.initState();
    _player.openPlayer();
    _initSocket();
  }

  void _initSocket() {
    final serverUrl = kDemoMode ? kDemoServerUrl : 'http://10.170.6.0:3000';
    socket = io.io(serverUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    socket.onConnect((_) => socket.emit('joinTrip', widget.tripId));

    socket.on('estadoCanal', (data) async {
      final ocupado = data['ocupado'] as bool;
      if (mounted) setState(() => isChannelBusy = ocupado);

      // Canal liberado por el emisor → reproducir lo que se acumuló
      if (!ocupado && _audioBuffer.isNotEmpty && !isRecording) {
        await _playBuffer();
        _audioBuffer.clear();
      }
    });

    socket.on('canalDenegado', (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('El canal está ocupado...'),
            duration: Duration(milliseconds: 800),
          ),
        );
      }
    });

    socket.on('canalConcedido', (_) => _startStreaming());

    // Acumular chunks PCM en buffer — vienen como Base64 para evitar corrupción binaria
    socket.on('audioStream', (chunk) {
      try {
        final String b64 = chunk is String ? chunk : chunk.toString();
        final bytes = base64Decode(b64);
        _audioBuffer.addAll(bytes);
      } catch (e) {
        debugPrint('WalkieTalkie: decode error: $e');
      }
    });
  }

  // Ensambla el buffer PCM en un WAV válido y lo reproduce con la API estable de flutter_sound
  Future<void> _playBuffer() async {
    try {
      final wavBytes = _buildWav(Uint8List.fromList(_audioBuffer));
      await _player.startPlayer(
        fromDataBuffer: wavBytes,
        codec: Codec.pcm16WAV,
        whenFinished: () => debugPrint('WalkieTalkie: playback finished'),
      );
    } catch (e) {
      debugPrint('WalkieTalkie: playBuffer error: $e');
    }
  }

  // Construye cabecera WAV de 44 bytes + datos PCM
  Uint8List _buildWav(Uint8List pcm) {
    const sampleRate = 16000;
    const numChannels = 1;
    const bitsPerSample = 16;
    const byteRate = sampleRate * numChannels * bitsPerSample ~/ 8;
    const blockAlign = numChannels * bitsPerSample ~/ 8;
    final dataSize = pcm.length;

    final header = ByteData(44);
    void setStr(int offset, String s) {
      for (var i = 0; i < s.length; i++) {
        header.setUint8(offset + i, s.codeUnitAt(i));
      }
    }

    setStr(0, 'RIFF');
    header.setUint32(4, 36 + dataSize, Endian.little);
    setStr(8, 'WAVE');
    setStr(12, 'fmt ');
    header.setUint32(16, 16, Endian.little);
    header.setUint16(20, 1, Endian.little); // PCM
    header.setUint16(22, numChannels, Endian.little);
    header.setUint32(24, sampleRate, Endian.little);
    header.setUint32(28, byteRate, Endian.little);
    header.setUint16(32, blockAlign, Endian.little);
    header.setUint16(34, bitsPerSample, Endian.little);
    setStr(36, 'data');
    header.setUint32(40, dataSize, Endian.little);

    final result = Uint8List(44 + dataSize);
    result.setRange(0, 44, header.buffer.asUint8List());
    result.setRange(44, 44 + dataSize, pcm);
    return result;
  }

  Future<void> _requestToSpeak() async {
    if (isChannelBusy) return;
    try {
      if (await _recorder.hasPermission()) {
        socket.emit('solicitarCanal', widget.tripId);
      }
    } catch (e) {
      debugPrint('WalkieTalkie: requestToSpeak error: $e');
    }
  }

  Future<void> _startStreaming() async {
    try {
      final stream = await _recorder.startStream(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: 16000,
          numChannels: 1,
        ),
      );
      if (mounted) setState(() => isRecording = true);

      _micSubscription = stream.listen(
        (data) => socket.emit('audioStream', {'tripId': widget.tripId, 'chunk': base64Encode(data)}),
        onError: (e) => debugPrint('WalkieTalkie: mic error: $e'),
      );
    } catch (e) {
      debugPrint('WalkieTalkie: startStreaming error: $e');
      if (mounted) setState(() => isRecording = false);
    }
  }

  Future<void> _stopStreaming() async {
    if (!isRecording) return;
    try {
      await _recorder.stop();
      await _micSubscription?.cancel();
      _micSubscription = null;
      if (mounted) setState(() => isRecording = false);
      socket.emit('liberarCanal', widget.tripId);
    } catch (e) {
      debugPrint('WalkieTalkie: stopStreaming error: $e');
    }
  }

  @override
  void dispose() {
    socket.dispose();
    _recorder.dispose();
    _player.closePlayer();
    _micSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: _requestToSpeak,
      onLongPressEnd: (_) => _stopStreaming(),
      child: Material(
        elevation: isRecording ? 12 : 6,
        shape: const CircleBorder(),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: isChannelBusy
                ? Colors.grey
                : (isRecording ? Colors.red : Colors.orange),
            shape: BoxShape.circle,
            boxShadow: isRecording
                ? [
                    BoxShadow(
                      color: Colors.red.withValues(alpha: 0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: const Icon(Icons.radio, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}
