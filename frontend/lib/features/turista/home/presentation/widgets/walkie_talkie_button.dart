import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class WalkieTalkieButton extends StatefulWidget {
  final String tripId;
  const WalkieTalkieButton({super.key, required this.tripId});

  @override
  State<WalkieTalkieButton> createState() => _WalkieTalkieButtonState();
}

class _WalkieTalkieButtonState extends State<WalkieTalkieButton> {
  late io.Socket socket;
  final record = AudioRecorder();
  final _player = FlutterSoundPlayer();

  StreamSubscription<Uint8List>? _micSubscription;
  bool isRecording = false;
  bool isChannelBusy = false;

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
    _initSocket();
  }

  Future<void> _initAudioPlayer() async {
    // Abrimos la sesión de audio
    await _player.openPlayer();
    // Configuramos el reproductor para que espere un flujo constante de bytes (PCM)
    await _player.startPlayerFromStream(
      codec: Codec.pcm16,
      numChannels: 1,
      sampleRate: 16000,
      interleaved: true,
      bufferSize: 4096,
    );
  }

  void _initSocket() {
    String serverIp =
        Platform.isAndroid
            ? 'http://192.168.100.108:3000'
            : 'http://192.168.100.108:3000';
    socket = io.io(serverIp, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    socket.onConnect((_) => socket.emit('joinTrip', widget.tripId));

    // Control de canal
    socket.on('estadoCanal', (data) {
      if (mounted) setState(() => isChannelBusy = data['ocupado']);
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

    // --- RECEPCIÓN EN TIEMPO REAL ---
    socket.on('audioStream', (chunk) {
      // Recibimos los bytes del servidor e inmediatamente los inyectamos a la bocina
      if (_player.isOpen()) {
        Uint8List bytes;
        if (chunk is Uint8List) {
          bytes = chunk;
        } else if (chunk is List) {
          bytes = Uint8List.fromList(chunk.cast<int>());
        } else {
          return;
        }
        _player.feedUint8FromStream(bytes);
      }
    });
  }

  Future<void> _requestToSpeak() async {
    if (isChannelBusy) return;
    if (await record.hasPermission()) {
      socket.emit('solicitarCanal', widget.tripId);
    }
  }

  Future<void> _startStreaming() async {
    // En lugar de guardar en un archivo, abrimos un stream de bytes PCM
    final stream = await record.startStream(
      const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: 16000,
        numChannels: 1,
      ),
    );

    if (mounted) setState(() => isRecording = true);

    // Escuchamos el micrófono y aventamos cada pedacito de voz al backend inmediatamente
    _micSubscription = stream.listen((data) {
      socket.emit('audioStream', {'tripId': widget.tripId, 'chunk': data});
    });
  }

  Future<void> _stopStreaming() async {
    if (!isRecording) return;

    await record.stop();
    await _micSubscription?.cancel();
    if (mounted) setState(() => isRecording = false);

    socket.emit('liberarCanal', widget.tripId);
  }

  @override
  void dispose() {
    socket.dispose();
    record.dispose();
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
            color:
                isChannelBusy
                    ? Colors.grey
                    : (isRecording ? Colors.red : Colors.orange),
            shape: BoxShape.circle,
            boxShadow:
                isRecording
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
