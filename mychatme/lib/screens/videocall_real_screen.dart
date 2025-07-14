import 'dart:async';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mychatme/l10n/app_localizations.dart';
import '../services/videocall_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VideoCallRealScreen extends StatefulWidget {
  final String callId;
  final String receiverName;
  final String receiverId;
  final bool isIncoming; // Nueva propiedad

  const VideoCallRealScreen({
    Key? key,
    required this.callId,
    required this.receiverName,
    required this.receiverId,
    this.isIncoming = false, // Por defecto es llamada saliente
  }) : super(key: key);

  @override
  State<VideoCallRealScreen> createState() => _VideoCallRealScreenState();
}

class _VideoCallRealScreenState extends State<VideoCallRealScreen> {
  late RtcEngine _engine;
  int? _remoteUid;
  bool _isJoined = false;
  bool _isMuted = false;
  bool _isVideoEnabled = true;
  bool _isConnecting = true;
  String? _errorMessage;
  bool _localUserJoined = false;
  Timer? _timeoutTimer;
  Timer? _waitingTimer;
  int _waitingSeconds = 0;
  bool _isWaitingForAnswer = false;

  // Tu configuración real de Agora
  final String appId = '687f4d62e66f488da21b78026e07b150'; 
  // Token RTC temporal para el canal 'pruebapia2'
  final String token = '007eJxTYJBoa7qmuyFr//5Pda5blLnaGlaaTuAXDhKbtM4gMY/JIFqBwczCPM0kxcwo1cwszcTCIiXRyDDJ3MLAyCzVwDzJ0NRAZ1dJRkMgI8MhpSUsjAwQCOJzMRQUlaYmJRZkJhoxMAAAM0wegg==';

  @override
  void initState() {
    super.initState();
    _initAgora();
    _listenToCallStatus();
    _startTimeoutTimer(); // Iniciar timer de timeout
  }

  /// Configuraciones adicionales después de unirse al canal
  Future<void> _configureAfterJoin() async {
    try {
      // Forzar que el video y audio estén activos
      await _engine.enableLocalVideo(true);
      await _engine.enableLocalAudio(true);
      
      // Asegurar que el preview esté activo
      await _engine.startPreview();
      
      print('✅ Configuración post-conexión completada');
    } catch (e) {
      print('⚠️ Error en configuración post-conexión: $e');
    }
  }

  /// Escuchar el estado de la videollamada en Firestore
  void _listenToCallStatus() {
    VideoCallService.listenToCallStatus(widget.callId).listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        final status = data['status'] as String;
        
        print('📊 Estado de llamada: $status');
        
        switch (status) {
          case 'accepted':
            print('🎉 ¡Llamada aceptada! Ambos usuarios deberían conectarse ahora');
            _stopWaitingTimer(); // Detener timer de espera
            break;
          case 'rejected':
            _showSnackBar('Llamada rechazada');
            Navigator.pop(context);
            break;
          case 'ended':
            _showSnackBar('Llamada terminada');
            Navigator.pop(context);
            break;
        }
      }
    });
  }

  /// Iniciar timer de timeout para llamadas sin respuesta
  void _startTimeoutTimer() {
    // Timer de timeout principal (60 segundos)
    _timeoutTimer = Timer(const Duration(seconds: 60), () {
      if (mounted && _remoteUid == null) {
        print('⏰ Timeout: No hay respuesta después de 60 segundos');
        _handleCallTimeout();
      }
    });

    // Timer de contador para mostrar tiempo de espera
    _waitingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _waitingSeconds++;
        });
        
        // Mostrar estados diferentes según el tiempo
        if (_waitingSeconds == 30) {
          _showSnackBar('Aún esperando respuesta...');
        } else if (_waitingSeconds == 45) {
          _showSnackBar('La llamada terminará pronto sin respuesta');
        }
      }
    });
    
    // Marcar que estamos esperando respuesta si no es llamada entrante
    if (!widget.isIncoming) {
      setState(() {
        _isWaitingForAnswer = true;
      });
    }
  }

  /// Detener timer de espera cuando se acepta la llamada
  void _stopWaitingTimer() {
    _timeoutTimer?.cancel();
    _waitingTimer?.cancel();
    setState(() {
      _isWaitingForAnswer = false;
    });
  }

  /// Manejar timeout de llamada
  void _handleCallTimeout() {
    _stopWaitingTimer();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('⏰ Sin respuesta'),
        content: Text('${widget.receiverName} no contestó la llamada.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cerrar diálogo
              _endCall(); // Terminar llamada
            },
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  Future<void> _initAgora() async {
    try {
      print('🔄 Iniciando videollamada REAL...');
      
      // Verificar permisos
      final cameraStatus = await Permission.camera.status;
      final micStatus = await Permission.microphone.status;
      
      print('📷 Estado cámara: $cameraStatus');
      print('🎤 Estado micrófono: $micStatus');
      
      if (cameraStatus != PermissionStatus.granted) {
        final cameraPermission = await Permission.camera.request();
        if (cameraPermission != PermissionStatus.granted) {
          setState(() {
            _errorMessage = 'Se requiere permiso de cámara';
            _isConnecting = false;
          });
          return;
        }
      }

      if (micStatus != PermissionStatus.granted) {
        await Permission.microphone.request();
      }

      print('✅ Permisos obtenidos, inicializando Agora...');
      
      // Inicializar Agora
      _engine = createAgoraRtcEngine();
      
      await _engine.initialize(RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
        audioScenario: AudioScenarioType.audioScenarioDefault,
      ));

      print('✅ Agora inicializado');

      // Registrar event handlers ANTES de configurar
      _registerEventHandlers();

      // Configurar calidad de video
      await _engine.setVideoEncoderConfiguration(
        const VideoEncoderConfiguration(
          dimensions: VideoDimensions(width: 640, height: 480),
          frameRate: 30,
          bitrate: 800,
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
      
      // Habilitar video y audio
      await _engine.enableVideo();
      await _engine.enableAudio();
      await _engine.startPreview();
      print('✅ Preview iniciado');
      
      // Esperar un poco antes de unirse al canal
      await Future.delayed(const Duration(milliseconds: 1000));
      
      // Usar el canal fijo para el cual se generó el token
      final channelName = 'pruebapia2'; // Canal fijo que coincide con el token
      
      print('🔗 Uniéndose al canal SIMPLE: $channelName');
      
      // Usar el token real de Agora configurado arriba
      final String testToken = token; // Token real de Agora
      
      await _engine.joinChannel(
        token: testToken,
        channelId: channelName,
        uid: 0,
        options: ChannelMediaOptions(
          channelProfile: ChannelProfileType.channelProfileCommunication,
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
        ),
      );
      
      print('✅ JoinChannel ejecutado correctamente');
      
      // Configuraciones adicionales después de unirse
      await _engine.enableLocalVideo(true);
      await _engine.enableLocalAudio(true);
      
      print('✅ Video y audio local habilitados');
        
    } catch (e) {
      print('❌ Error inicializando videollamada: $e');
      setState(() {
        _errorMessage = 'Error: $e';
        _isConnecting = false;
      });
    }
  }

  void _registerEventHandlers() {
    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          print('✅ ¡CONECTADO AL CANAL SIMPLE! UID: ${connection.localUid}');
          setState(() {
            _localUserJoined = true;
            _isJoined = true;
            _isConnecting = false;
          });
          
          // Forzar configuraciones después de conectarse
          _configureAfterJoin();
          
          _showSnackBar('Conectado - Esperando al otro usuario...');
        },
        
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          print('🎉 ¡USUARIO REAL SE CONECTÓ! UID: $remoteUid');
          print('  - Canal: ${connection.channelId}');
          print('  - Mi UID: ${connection.localUid}');
          print('  - Remote UID: $remoteUid');
          
          setState(() {
            _remoteUid = remoteUid;
          });
          
          // Forzar actualización del video remoto
          Future.delayed(const Duration(milliseconds: 500), () {
            setState(() {});
          });
          
          _showSnackBar('¡${widget.receiverName} se unió a la llamada!');
        },
        
        onUserOffline: (RtcConnection connection, int uid, UserOfflineReasonType reason) {
          print('👋 Usuario se desconectó: $uid, razón: $reason');
          setState(() {
            _remoteUid = null;
          });
          _showSnackBar('${widget.receiverName} se desconectó');
        },
        
        onRemoteVideoStateChanged: (RtcConnection connection, int uid, 
            RemoteVideoState state, RemoteVideoStateReason reason, int elapsed) {
          print('📹 Estado de video remoto cambió:');
          print('  - UID: $uid');
          print('  - Estado: $state');
          print('  - Razón: $reason');
          print('  - Canal: ${connection.channelId}');
          
          if (state == RemoteVideoState.remoteVideoStateStarting) {
            print('✅ ¡Video remoto iniciando!');
          } else if (state == RemoteVideoState.remoteVideoStateDecoding) {
            print('✅ ¡Video remoto decodificando - deberías verlo ahora!');
          }
        },
        
        onConnectionStateChanged: (RtcConnection connection, 
            ConnectionStateType state, ConnectionChangedReasonType reason) {
          print('🔗 Estado de conexión: $state, razón: $reason');
          
          if (state == ConnectionStateType.connectionStateConnected) {
            _showSnackBar('Conexión establecida exitosamente');
          } else if (state == ConnectionStateType.connectionStateFailed) {
            setState(() {
              _errorMessage = 'Falló la conexión a Agora';
              _isConnecting = false;
            });
          }
        },
        
        onError: (ErrorCodeType err, String msg) {
          print('❌ Error de Agora: $err - $msg');
          setState(() {
            _errorMessage = 'Error: $msg (Código: $err)';
          });
        },
        
        onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
          print('⚠️ Token expirará pronto');
          _showSnackBar('Token expirará - La llamada puede desconectarse');
        },
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.purple,
      ),
    );
  }

  Future<void> _toggleMute() async {
    try {
      setState(() {
        _isMuted = !_isMuted;
      });
      await _engine.muteLocalAudioStream(_isMuted);
      _showSnackBar(_isMuted ? 'Micrófono silenciado' : 'Micrófono activado');
    } catch (e) {
      print('Error toggle mute: $e');
    }
  }

  Future<void> _toggleVideo() async {
    try {
      setState(() {
        _isVideoEnabled = !_isVideoEnabled;
      });
      await _engine.muteLocalVideoStream(!_isVideoEnabled);
      _showSnackBar(_isVideoEnabled ? 'Cámara activada' : 'Cámara desactivada');
    } catch (e) {
      print('Error toggle video: $e');
    }
  }

  Future<void> _switchCamera() async {
    try {
      await _engine.switchCamera();
      _showSnackBar('Cámara cambiada');
    } catch (e) {
      print('Error switch camera: $e');
      _showSnackBar('Error al cambiar cámara');
    }
  }

  Future<void> _endCall() async {
    try {
      print('📞 Terminando llamada...');
      
      // Notificar en Firestore que la llamada terminó
      await VideoCallService.endVideoCall(widget.callId);
      
      // Salir del canal de Agora
      await _engine.leaveChannel();
      
      // ARREGLADO: Solo cerrar la pantalla de videollamada, no toda la sesión
      if (mounted) {
        Navigator.pop(context); // Solo cierra esta pantalla
      }
    } catch (e) {
      print('Error end call: $e');
      // ARREGLADO: Solo cerrar la pantalla, no toda la app
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  Widget _buildVideoViews() {
    return Stack(
      children: [
        // Video remoto (pantalla completa)
        Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black87,
          child: _remoteUid != null
              ? Stack(
                  children: [
                    // Video remoto
                    AgoraVideoView(
                      controller: VideoViewController.remote(
                        rtcEngine: _engine,
                        canvas: VideoCanvas(
                          uid: _remoteUid!,
                          renderMode: RenderModeType.renderModeHidden,
                        ),
                        connection: RtcConnection(
                          channelId: 'pruebapia2', // Usar el mismo canal del token
                        ),
                      ),
                    ),
                    // Indicador de que el video está funcionando
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'UID: $_remoteUid',
                          style: const TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ),
                    ),
                  ],
                )
              : _buildWaitingForUserView(),
        ),
        
        // Video local (esquina superior derecha)
        Positioned(
          top: 50,
          right: 20,
          child: Container(
            width: 160,
            height: 200,
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
                  ? AgoraVideoView(
                      controller: VideoViewController(
                        rtcEngine: _engine,
                        canvas: const VideoCanvas(
                          uid: 0,
                          renderMode: RenderModeType.renderModeHidden,
                        ),
                      ),
                    )
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

        // Indicador de estado
        Positioned(
          top: 50,
          left: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _isJoined 
                  ? (_remoteUid != null ? Colors.green : Colors.orange)
                  : Colors.red,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isJoined ? Icons.videocam : Icons.videocam_off,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  _remoteUid != null 
                      ? 'EN LLAMADA' 
                      : _isJoined 
                          ? 'ESPERANDO...' 
                          : 'CONECTANDO...',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWaitingForUserView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 60,
            backgroundColor: Colors.white24,
            child: Icon(Icons.person, size: 80, color: Colors.white),
          ),
          const SizedBox(height: 24),
          Text(
            _isWaitingForAnswer 
                ? 'Llamando a ${widget.receiverName}...'
                : 'Esperando a ${widget.receiverName}...',
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          
          // Contador de tiempo
          if (_waitingSeconds > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _waitingSeconds > 45 ? Colors.red.shade600 : Colors.orange.shade600,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _isWaitingForAnswer 
                    ? 'Esperando respuesta: ${_waitingSeconds}s'
                    : 'Tiempo conectado: ${_waitingSeconds}s',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          
          const SizedBox(height: 16),
          Text(
            'Canal: ${widget.callId}',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          const CircularProgressIndicator(color: Colors.white),
          const SizedBox(height: 16),
          
          // Información de estado
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              color: _isWaitingForAnswer ? Colors.orange.shade600 : Colors.blue.shade600,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Icon(
                  _isWaitingForAnswer ? Icons.access_time : Icons.info_outline, 
                  color: Colors.white, 
                  size: 20
                ),
                const SizedBox(height: 4),
                Text(
                  _isWaitingForAnswer 
                      ? 'Llamada Saliente'
                      : 'Videollamada Real Activa',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
                Text(
                  _isWaitingForAnswer 
                      ? 'La llamada se cancelará en ${60 - _waitingSeconds}s si no contesta'
                      : 'Esperando conexión del otro usuario',
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          // Botón para cancelar llamada saliente
          if (_isWaitingForAnswer && _waitingSeconds > 5)
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: ElevatedButton(
                onPressed: _endCall,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Cancelar llamada'),
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
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 12),
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
            'Conectando a Agora...',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            'Canal: ${widget.callId}',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 24),
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
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _errorMessage = null;
                        _isConnecting = true;
                      });
                      _initAgora();
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Preguntar antes de salir
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('¿Terminar videollamada?'),
            content: const Text('¿Estás seguro de que quieres terminar la videollamada?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Terminar'),
              ),
            ],
          ),
        );
        
        if (shouldExit == true) {
          await _endCall();
          return false; // Ya manejamos la navegación en _endCall
        }
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text('${widget.receiverName}'),
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
          automaticallyImplyLeading: false,
          actions: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'REAL',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        body: (_isConnecting && _errorMessage == null)
            ? _buildConnectingView()
            : _buildVideoViews(),
      ),
    );
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    _waitingTimer?.cancel();
    _engine.leaveChannel();
    _engine.release();
    super.dispose();
  }
}
