import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mychatme/l10n/app_localizations.dart';

class VideoCallEmulatorScreen extends StatefulWidget {
  final String callId;
  final String receiverName;
  final String receiverId;

  const VideoCallEmulatorScreen({
    Key? key,
    required this.callId,
    required this.receiverName,
    required this.receiverId,
  }) : super(key: key);

  @override
  State<VideoCallEmulatorScreen> createState() => _VideoCallEmulatorScreenState();
}

class _VideoCallEmulatorScreenState extends State<VideoCallEmulatorScreen> {
  late RtcEngine _engine;
  bool _isMuted = false;
  bool _isVideoEnabled = true;
  bool _isConnected = false;
  bool _isConnecting = true;
  bool _hasRemoteUser = false;
  bool _cameraInitialized = false;
  String? _errorMessage;

  // Tu configuración real de Agora
  final String appId = '25a7c674122049319ac0b42da4b9541e'; 
  final String token = '007eJxTYLiu9fMY473pa6IrJ51w9TNyclZgPdJ5PK6xZKOL61EZRT4FBiPTRPNkM3MTQyMjAxNLY0PLxGSDJBOjlESTJEtTE8NUybKSjIZARoY4p5mMjAwQCOKzMRQUlaYmJTIwAAAIbh2i';

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      print('🔄 Iniciando configuración de cámara...');
      
      // Verificar permisos más detalladamente
      final cameraStatus = await Permission.camera.status;
      final micStatus = await Permission.microphone.status;
      
      print('📷 Estado cámara: $cameraStatus');
      print('🎤 Estado micrófono: $micStatus');
      
      if (cameraStatus != PermissionStatus.granted) {
        final cameraPermission = await Permission.camera.request();
        if (cameraPermission != PermissionStatus.granted) {
          setState(() {
            _errorMessage = 'Se requiere permiso de cámara';
          });
          return;
        }
      }

      if (micStatus != PermissionStatus.granted) {
        await Permission.microphone.request();
      }

      print('✅ Permisos obtenidos, inicializando Agora...');
      
      // Inicializar Agora con configuración más básica
      _engine = createAgoraRtcEngine();
      
      await _engine.initialize(RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
        audioScenario: AudioScenarioType.audioScenarioDefault,
      ));

      print('✅ Agora inicializado');

      // Configuración paso a paso con verificaciones
      try {
        await _engine.enableVideo();
        print('✅ Video habilitado');
        
        // Configurar calidad de video después de habilitar
        await _engine.setVideoEncoderConfiguration(
          const VideoEncoderConfiguration(
            dimensions: VideoDimensions(width: 640, height: 480),
            frameRate: 15, // Reducir para mejor compatibilidad
            bitrate: 600,
            orientationMode: OrientationMode.orientationModeAdaptive,
          ),
        );
        print('✅ Configuración de video aplicada');
        
        // Configurar cámara
        await _engine.setCameraCapturerConfiguration(
          const CameraCapturerConfiguration(
            cameraDirection: CameraDirection.cameraFront,
          ),
        );
        print('✅ Configuración de cámara aplicada');
        
        // Esperar un poco antes del preview
        await Future.delayed(const Duration(milliseconds: 500));
        
        await _engine.startPreview();
        print('✅ Preview iniciado');
        
        setState(() {
          _cameraInitialized = true;
        });
        
        print('🎉 Cámara inicializada con éxito!');
        
      } catch (e) {
        print('❌ Error en configuración de video: $e');
        // Intentar configuración más básica
        try {
          await _engine.enableVideo();
          await _engine.startPreview();
          setState(() {
            _cameraInitialized = true;
          });
          print('✅ Configuración básica aplicada');
        } catch (e2) {
          print('❌ Error en configuración básica: $e2');
          setState(() {
            _cameraInitialized = false;
            _errorMessage = 'Error al inicializar cámara: $e2';
          });
        }
      }
        
    } catch (e) {
      print('❌ Error general inicializando cámara: $e');
      setState(() {
        _cameraInitialized = false;
        _errorMessage = 'Error: $e';
      });
    }

    // Simular proceso de conexión
    _simulateConnection();
  }

  void _simulateConnection() async {
    // Simular proceso de conexión
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      setState(() {
        _isConnecting = false;
        _isConnected = true;
      });
    }

    // Simular que se conecta otro usuario después de 4 segundos
    await Future.delayed(const Duration(seconds: 4));
    
    if (mounted) {
      setState(() {
        _hasRemoteUser = true;
      });
    }
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
    
    if (_cameraInitialized) {
      try {
        _engine.muteLocalAudioStream(_isMuted);
      } catch (e) {
        print('Error toggle mute: $e');
      }
    }
    
    _showSnackBar(_isMuted ? 'Micrófono silenciado' : 'Micrófono activado');
  }

  void _toggleVideo() {
    setState(() {
      _isVideoEnabled = !_isVideoEnabled;
    });
    
    if (_cameraInitialized) {
      try {
        _engine.muteLocalVideoStream(!_isVideoEnabled);
      } catch (e) {
        print('Error toggle video: $e');
      }
    }
    
    _showSnackBar(_isVideoEnabled ? 'Cámara activada' : 'Cámara desactivada');
  }

  void _switchCamera() {
    if (_cameraInitialized) {
      try {
        _engine.switchCamera();
        // Reconfigurar la calidad después de cambiar cámara
        _engine.setVideoEncoderConfiguration(
          const VideoEncoderConfiguration(
            dimensions: VideoDimensions(width: 640, height: 480),
            frameRate: 30,
            bitrate: 800,
            orientationMode: OrientationMode.orientationModeAdaptive,
          ),
        );
        _showSnackBar('Cámara cambiada - Calidad optimizada');
      } catch (e) {
        _showSnackBar('Error al cambiar cámara');
      }
    } else {
      _showSnackBar('Cámara no disponible en emulador');
    }
  }

  void _endCall() {
    Navigator.pop(context);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  Widget _buildVideoViews() {
    return Stack(
      children: [
        // Video remoto simulado
        Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black87,
          child: _hasRemoteUser
              ? _buildSimulatedRemoteVideo()
              : _buildWaitingView(),
        ),
        
        // Video local REAL - MÁS GRANDE Y MEJOR CALIDAD
        Positioned(
          top: 50,
          right: 20,
          child: Container(
            width: 160, // Más ancho
            height: 200, // Más alto
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: _isVideoEnabled
                  ? (_cameraInitialized 
                      ? _buildRealLocalVideo()
                      : _buildSimulatedLocalVideo())
                  : Container(
                      color: Colors.black87,
                      child: const Center(
                        child: Icon(Icons.videocam_off, color: Colors.white, size: 40),
                      ),
                    ),
            ),
          ),
        ),
        
        // Controles
        Positioned(
          bottom: 80,
          left: 0,
          right: 0,
          child: _buildControls(),
        ),

        // Indicador de estado con botón de reinicio
        Positioned(
          top: 50,
          left: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _isConnected ? Colors.green : Colors.orange,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _cameraInitialized ? Icons.videocam : Icons.videocam_off,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _hasRemoteUser ? 'CONECTADO' : 'ESPERANDO...',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              if (!_cameraInitialized) ...[
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    _initCamera();
                  },
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Reiniciar Cámara', style: TextStyle(fontSize: 10)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRealLocalVideo() {
    // Video real de la cámara usando Agora con configuración compatible
    return AgoraVideoView(
      controller: VideoViewController(
        rtcEngine: _engine,
        canvas: const VideoCanvas(
          uid: 0,
          renderMode: RenderModeType.renderModeHidden, // Mejor ajuste
        ),
      ),
    );
  }

  Widget _buildSimulatedLocalVideo() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade400, Colors.purple.shade400],
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person, color: Colors.white, size: 30),
            SizedBox(height: 4),
            Text(
              'TÚ',
              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 2),
            Text(
              'Sin cámara',
              style: TextStyle(color: Colors.white70, fontSize: 8),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimulatedRemoteVideo() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Colors.green.shade400, Colors.teal.shade400],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white24,
              child: Icon(Icons.person, size: 80, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              widget.receiverName,
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Usuario simulado',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaitingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white24,
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            'Esperando a ${widget.receiverName}...',
            style: const TextStyle(color: Colors.white, fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          const CircularProgressIndicator(color: Colors.white),
          const SizedBox(height: 16),
          Text(
            _cameraInitialized ? 'Tu cámara está activa' : 'Cámara no disponible',
            style: TextStyle(
              color: _cameraInitialized ? Colors.green.shade300 : Colors.orange.shade300,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildControlButton(
            icon: _isMuted ? Icons.mic_off : Icons.mic,
            onTap: _toggleMute,
            backgroundColor: _isMuted ? Colors.red : Colors.white24,
            label: _isMuted ? 'Activar' : 'Silenciar',
          ),
          _buildControlButton(
            icon: _isVideoEnabled ? Icons.videocam : Icons.videocam_off,
            onTap: _toggleVideo,
            backgroundColor: !_isVideoEnabled ? Colors.red : Colors.white24,
            label: _isVideoEnabled ? 'Apagar' : 'Encender',
          ),
          _buildControlButton(
            icon: Icons.cameraswitch,
            onTap: _switchCamera,
            backgroundColor: Colors.white24,
            label: 'Cambiar',
            isEnabled: _cameraInitialized,
          ),
          _buildControlButton(
            icon: Icons.call_end,
            onTap: _endCall,
            backgroundColor: Colors.red,
            label: 'Terminar',
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color backgroundColor,
    required String label,
    bool isEnabled = true,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: isEnabled ? onTap : null,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isEnabled ? backgroundColor : Colors.grey.shade600,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon, 
              color: isEnabled ? Colors.white : Colors.white54, 
              size: 28
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: isEnabled ? Colors.white : Colors.white54, 
            fontSize: 12
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildConnectingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.purple),
          const SizedBox(height: 24),
          const Text(
            'Conectando...',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            'Llamando a ${widget.receiverName}',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 32),
          if (_errorMessage != null)
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 40),
              decoration: BoxDecoration(
                color: Colors.red.shade600,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white, size: 24),
                  const SizedBox(height: 8),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _endCall();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text('Videollamada con ${widget.receiverName}'),
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
          automaticallyImplyLeading: false,
          actions: [
            if (!_cameraInitialized)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'SIM',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
        body: _isConnecting ? _buildConnectingView() : _buildVideoViews(),
      ),
    );
  }

  @override
  void dispose() {
    if (_cameraInitialized) {
      try {
        _engine.stopPreview();
        _engine.release();
      } catch (e) {
        print('Error disposing: $e');
      }
    }
    super.dispose();
  }
}
