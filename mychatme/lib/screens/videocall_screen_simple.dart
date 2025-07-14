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
  bool _isConnecting = true;
  String? _errorMessage;

  // Tu configuración de Agora
  final String appId = '25a7c674122049319ac0b42da4b9541e'; 
  final String token = '007eJxTYLiu9fMY473pa6IrJ51w9TNyclZgPdJ5PK6xZKOL61EZRT4FBiPTRPNkM3MTQyMjAxNLY0PLxGSDJBOjlESTJEtTE8NUybKSjIZARoY4p5mMjAwQCOKzMRQUlaYmJTIwAAAIbh2i';

  @override
  void initState() {
    super.initState();
    _initAgora();
  }

  Future<void> _initAgora() async {
    try {
      // Verificar permisos primero
      final cameraPermission = await Permission.camera.request();
      final micPermission = await Permission.microphone.request();
      
      if (cameraPermission != PermissionStatus.granted || 
          micPermission != PermissionStatus.granted) {
        setState(() {
          _errorMessage = 'Se requieren permisos de cámara y micrófono';
          _isConnecting = false;
        });
        return;
      }

      // Crear engine con configuración básica
      _engine = createAgoraRtcEngine();
      
      await _engine.initialize(RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ));

      // Configurar callbacks
      _engine.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
            print('✅ Canal unido exitosamente');
            setState(() {
              _isJoined = true;
              _isConnecting = false;
            });
          },
          onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
            print('✅ Usuario remoto conectado: $remoteUid');
            setState(() {
              _remoteUid = remoteUid;
            });
          },
          onUserOffline: (RtcConnection connection, int uid, UserOfflineReasonType reason) {
            print('❌ Usuario desconectado: $uid');
            setState(() {
              _remoteUid = null;
            });
          },
          onError: (ErrorCodeType err, String msg) {
            print('❌ Error Agora: $err - $msg');
            setState(() {
              _errorMessage = 'Error de conexión: $msg';
              _isConnecting = false;
            });
          },
        ),
      );

      // Habilitar video y audio
      await _engine.enableVideo();
      await _engine.enableAudio();
      await _engine.startPreview();

      // Usar un canal simple y limpio
      final channelName = 'test-${DateTime.now().millisecondsSinceEpoch % 1000000}';
      
      print('🔗 Intentando unirse al canal: $channelName');
      
      await _engine.joinChannel(
        token: token,
        channelId: channelName,
        uid: 0,
        options: const ChannelMediaOptions(
          channelProfile: ChannelProfileType.channelProfileCommunication,
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
        ),
      );

    } catch (e) {
      print('❌ Error en initAgora: $e');
      setState(() {
        _errorMessage = 'Error de inicialización: ${e.toString()}';
        _isConnecting = false;
      });
    }
  }

  Future<void> _toggleMute() async {
    try {
      setState(() {
        _isMuted = !_isMuted;
      });
      await _engine.muteLocalAudioStream(_isMuted);
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
    } catch (e) {
      print('Error toggle video: $e');
    }
  }

  Future<void> _switchCamera() async {
    try {
      await _engine.switchCamera();
    } catch (e) {
      print('Error switch camera: $e');
    }
  }

  Future<void> _endCall() async {
    try {
      await _engine.leaveChannel();
      Navigator.pop(context);
    } catch (e) {
      print('Error end call: $e');
      Navigator.pop(context);
    }
  }

  Widget _buildVideoViews() {
    return Stack(
      children: [
        // Video remoto o pantalla de espera
        Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black87,
          child: _remoteUid != null
              ? AgoraVideoView(
                  controller: VideoViewController.remote(
                    rtcEngine: _engine,
                    canvas: VideoCanvas(uid: _remoteUid!),
                    connection: RtcConnection(channelId: widget.callId),
                  ),
                )
              : Center(
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
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
        ),
        
        // Video local
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
                        child: Icon(Icons.videocam_off, color: Colors.white, size: 30),
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
      ],
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
          ),
          _buildControlButton(
            icon: _isVideoEnabled ? Icons.videocam : Icons.videocam_off,
            onTap: _toggleVideo,
            backgroundColor: !_isVideoEnabled ? Colors.red : Colors.white24,
          ),
          _buildControlButton(
            icon: Icons.cameraswitch,
            onTap: _switchCamera,
            backgroundColor: Colors.white24,
          ),
          _buildControlButton(
            icon: Icons.call_end,
            onTap: _endCall,
            backgroundColor: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color backgroundColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Error de conexión',
              style: const TextStyle(fontSize: 18, color: Colors.white),
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
              child: const Text('Intentar nuevamente'),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.purple),
          const SizedBox(height: 24),
          Text(
            'Conectando...',
            style: const TextStyle(fontSize: 18, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            'Llamando a ${widget.receiverName}',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _endCall();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text('Videollamada con ${widget.receiverName}'),
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
          automaticallyImplyLeading: false,
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
