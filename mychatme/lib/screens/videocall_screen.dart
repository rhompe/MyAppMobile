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
  late final RtcEngine _engine;
  int? _remoteUid;
  bool _isJoined = false;

  final String appId = '7fb0465caf77436da6a8093a7f055927'; // Reemplaza con tu App ID real
  final String token = '007eJxTYHjj5SLwwO+f/d6DtjbLJ0X+mXV43x/LAtn900tacxcJmK5TYDBPSzIwMTNNTkwzNzcxNktJNEu0MLA0TjRPMzA1tTQyF8zMz2gIZGS4fk+dkZEBAkF8AYawzJTU/JycxNzElMRi10BDBgYAOPUkOQ==';  // Reemplaza con tu Token real

  @override
  void initState() {
    super.initState();
    _initAgora();
  }

  Future<void> _initAgora() async {
    await [Permission.camera, Permission.microphone].request();

    _engine = createAgoraRtcEngine();
    await _engine.initialize(RtcEngineContext(appId: appId));

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          setState(() {
            _isJoined = true;
          });
          debugPrint('Canal unido: ${connection.localUid}');
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          setState(() {
            _remoteUid = remoteUid;
          });
          debugPrint('Usuario remoto unido: $remoteUid');
        },
        onUserOffline: (RtcConnection connection, int uid, UserOfflineReasonType reason) {
          setState(() {
            _remoteUid = null;
          });
          debugPrint('Usuario remoto desconectado: $uid, motivo: $reason');
        },
      ),
    );

    await _engine.enableVideo();
    await _engine.startPreview();

    await _engine.joinChannel(
      token: token,
      channelId: widget.callId,
      uid: 0,
      options: const ChannelMediaOptions(),
    );
  }

  @override
  void dispose() {
    _engine.leaveChannel();
    _engine.release();
    super.dispose();
  }

  Widget _buildVideoViews() {
    final t = AppLocalizations.of(context)!;
    
    return Column(
      children: [
        Expanded(
          child: AgoraVideoView(
            controller: VideoViewController(
              rtcEngine: _engine,
              canvas: const VideoCanvas(uid: 0),
            ),
          ),
        ),
        Expanded(
          child: _remoteUid != null
              ? AgoraVideoView(
            controller: VideoViewController.remote(
              rtcEngine: _engine,
              canvas: VideoCanvas(uid: _remoteUid!),
              connection: RtcConnection(channelId: widget.callId),
            ),
          )
              : Center(
            child: Text(
              t.waitingForOtherParticipant,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(t.videoCallWith(widget.receiverName)),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: _isJoined
          ? _buildVideoViews()
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    t.connectingToCall,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context);
        },
        backgroundColor: Colors.red,
        child: const Icon(Icons.call_end, color: Colors.white),
      ),
    );
  }
}