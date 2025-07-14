import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mychatme/l10n/app_localizations.dart';

class VideoCallScreen extends StatefulWidget {
  final String callId;
  final String receiverName;
  final String receiverId;

  const VideoCallScreen({
    Key? key,
    required this.callId,
    required this.receiverName,
    required this.receiverId,
  }) : super(key: key);

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  late RtcEngine _engine;
  int? _remoteUid;
  bool _isJoined = false;
  bool _isMuted = false;
  bool _isVideoEnabled = true;
  bool _isFrontCamera = true;
  bool _isConnecting = true;
  String? _errorMessage;

  // IMPORTANTE: Reemplaza estos valores con los tuyos
  final String appId = '25a7c674122049319ac0b42da4b9541e'; 
  // Para producción, deberías generar tokens dinámicamente desde tu servidor
  // Este token puede expirar, considera implementar renovación automática
  final String token = '007eJxTYLiu9fMY473pa6IrJ51w9TNyclZgPdJ5PK6xZKOL61EZRT4FBiPTRPNkM3MTQyMjAxNLY0PLxGSDJBOjlESTJEtTE8NUybKSjIZARoY4p5mMjAwQCOKzMRQUlaYmJTIwAAAIbh2i';

  @override
  void initState() {
    super.initState();
    _initAgora();
  }

  Future<void> _initAgora() async {
    try {
      // Solicitar permisos
      final permissions = await _requestPermissions();
      if (!permissions) {
        setState(() {
          _errorMessage = AppLocalizations.of(context)!.permissionDenied;
          _isConnecting = false;
        });
        return;
      }

      // Crear engine de Agora
      _engine = createAgoraRtcEngine();
      await _engine.initialize(RtcEngineContext(appId: appId));

      // Registrar event handlers
      _registerEventHandlers();

      // Configurar video
      await _engine.enableVideo();
      await _engine.enableAudio();
      await _engine.startPreview();

      // Unirse al canal
      await _joinChannel();

    } catch (e) {
      print('Error inicializando Agora: $e');
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.connectionFailed;
        _isConnecting = false;
      });
    }
  }

  Future<bool> _requestPermissions() async {
    final t = AppLocalizations.of(context)!;
    
    // Solicitar permiso de cámara
    final cameraStatus = await Permission.camera.request();
    if (cameraStatus != PermissionStatus.granted) {
      _showPermissionDialog(t.cameraPermissionRequired);
      return false;
    }

    // Solicitar permiso de micrófono
    final microphoneStatus = await Permission.microphone.request();
    if (microphoneStatus != PermissionStatus.granted) {
      _showPermissionDialog(t.microphonePermissionRequired);
      return false;
    }

    return true;
  }

  void _showPermissionDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.permissionDenied),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: Text(AppLocalizations.of(context)!.openSettings),
          ),
        ],
      ),
    );
  }

  void _registerEventHandlers() {
    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          setState(() {
            _isJoined = true;
            _isConnecting = false;
          });
          debugPrint('Canal unido exitosamente: ${connection.localUid}');
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          setState(() {
            _remoteUid = remoteUid;
          });
          debugPrint('Usuario remoto se unió: $remoteUid');
        },
        onUserOffline: (RtcConnection connection, int uid, UserOfflineReasonType reason) {
          setState(() {
            _remoteUid = null;
          });
          debugPrint('Usuario remoto se desconectó: $uid, motivo: $reason');
          
          // Mostrar mensaje si el usuario se fue
          if (reason == UserOfflineReasonType.userOfflineQuit) {
            _showSnackBar('El otro participante terminó la llamada');
          }
        },
        onConnectionStateChanged: (RtcConnection connection, 
            ConnectionStateType state, ConnectionChangedReasonType reason) {
          debugPrint('Estado de conexión cambió: $state, razón: $reason');
          
          if (state == ConnectionStateType.connectionStateFailed) {
            setState(() {
              _errorMessage = AppLocalizations.of(context)!.connectionFailed;
            });
          }
        },
        onError: (ErrorCodeType err, String msg) {
          debugPrint('Error de Agora: $err, mensaje: $msg');
          setState(() {
            _errorMessage = 'Error: $msg';
          });
        },
      ),
    );
  }

  Future<void> _joinChannel() async {
    try {
      await _engine.joinChannel(
        token: token,
        channelId: widget.callId,
        uid: 0,
        options: const ChannelMediaOptions(
          channelProfile: ChannelProfileType.channelProfileCommunication,
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
        ),
      );
    } catch (e) {
      print('Error uniéndose al canal: $e');
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.connectionFailed;
        _isConnecting = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _toggleMute() async {
    setState(() {
      _isMuted = !_isMuted;
    });
    await _engine.muteLocalAudioStream(_isMuted);
  }

  Future<void> _toggleVideo() async {
    setState(() {
      _isVideoEnabled = !_isVideoEnabled;
    });
    await _engine.muteLocalVideoStream(!_isVideoEnabled);
  }

  Future<void> _switchCamera() async {
    await _engine.switchCamera();
    setState(() {
      _isFrontCamera = !_isFrontCamera;
    });
  }

  Future<void> _endCall() async {
    try {
      await _engine.leaveChannel();
      Navigator.pop(context);
    } catch (e) {
      print('Error terminando llamada: $e');
      Navigator.pop(context);
    }
  }

  Widget _buildVideoViews() {
    return Stack(
      children: [
        // Video remoto (pantalla completa)
        Container(
          width: double.infinity,
          height: double.infinity,
          child: _remoteUid != null
              ? AgoraVideoView(
                  controller: VideoViewController.remote(
                    rtcEngine: _engine,
                    canvas: VideoCanvas(uid: _remoteUid!),
                    connection: RtcConnection(channelId: widget.callId),
                  ),
                )
              : Container(
                  color: Colors.black87,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white24,
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppLocalizations.of(context)!.waitingForOtherParticipant,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
        ),
        
        // Video local (esquina superior derecha)
        Positioned(
          top: 50,
          right: 20,
          child: Container(
            width: 120,
            height: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _isVideoEnabled
                  ? AgoraVideoView(
                      controller: VideoViewController(
                        rtcEngine: _engine,
                        canvas: const VideoCanvas(uid: 0),
                      ),
                    )
                  : Container(
                      color: Colors.black87,
                      child: const Center(
                        child: Icon(
                          Icons.videocam_off,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
            ),
          ),
        ),
        
        // Controles en la parte inferior
        Positioned(
          bottom: 80,
          left: 0,
          right: 0,
          child: _buildControlsPanel(),
        ),
      ],
    );
  }

  Widget _buildControlsPanel() {
    final t = AppLocalizations.of(context)!;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Botón de silenciar/activar audio
          _buildControlButton(
            icon: _isMuted ? Icons.mic_off : Icons.mic,
            label: _isMuted ? t.unmuteAudio : t.muteAudio,
            onTap: _toggleMute,
            backgroundColor: _isMuted ? Colors.red : Colors.white24,
          ),
          
          // Botón de video on/off
          _buildControlButton(
            icon: _isVideoEnabled ? Icons.videocam : Icons.videocam_off,
            label: _isVideoEnabled ? t.turnOffVideo : t.turnOnVideo,
            onTap: _toggleVideo,
            backgroundColor: !_isVideoEnabled ? Colors.red : Colors.white24,
          ),
          
          // Botón de cambiar cámara
          _buildControlButton(
            icon: Icons.cameraswitch,
            label: t.switchCamera,
            onTap: _switchCamera,
            backgroundColor: Colors.white24,
          ),
          
          // Botón de terminar llamada
          _buildControlButton(
            icon: Icons.call_end,
            label: t.endCall,
            onTap: _endCall,
            backgroundColor: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color backgroundColor,
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
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildErrorView() {
    final t = AppLocalizations.of(context)!;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? t.connectionFailed,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _errorMessage = null;
                  _isConnecting = true;
                });
                _initAgora();
              },
              child: Text(t.tryAgain),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: Text(t.cancel),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectingView() {
    final t = AppLocalizations.of(context)!;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
          ),
          const SizedBox(height: 24),
          Text(
            t.connectingToCall,
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 16),
          Text(
            'Llamando a ${widget.receiverName}...',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    
    return WillPopScope(
      onWillPop: () async {
        await _endCall();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text(t.videoCallWith(widget.receiverName)),
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
          automaticallyImplyLeading: false, // Removemos el botón de atrás por defecto
        ),
        body: _errorMessage != null
            ? _buildErrorView()
            : _isConnecting
                ? _buildConnectingView()
                : _buildVideoViews(),
      ),
    );
  }

  @override
  void dispose() {
    _engine.leaveChannel();
    _engine.release();
    super.dispose();
  }
}
