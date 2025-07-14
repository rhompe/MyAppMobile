// lib/services/agora_service.dart
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

class AgoraService {
  static const String appId = '25a7c674122049319ac0b42da4b9541e';
  
  // IMPORTANTE: En producción, debes generar tokens dinámicamente desde tu servidor
  // Este es un token temporal que puede expirar
  static const String tempToken = '007eJxTYLiu9fMY473pa6IrJ51w9TNyclZgPdJ5PK6xZKOL61EZRT4FBiPTRPNkM3MTQyMjAxNLY0PLxGSDJBOjlESTJEtTE8NUybKSjIZARoY4p5mMjAwQCOKzMRQUlaYmJTIwAAAIbh2i';

  /// Verifica si los permisos necesarios están concedidos
  static Future<bool> checkPermissions() async {
    final cameraPermission = await Permission.camera.status;
    final microphonePermission = await Permission.microphone.status;
    
    return cameraPermission == PermissionStatus.granted && 
           microphonePermission == PermissionStatus.granted;
  }

  /// Solicita los permisos necesarios para videollamadas
  static Future<bool> requestPermissions() async {
    Map<Permission, PermissionStatus> permissions = await [
      Permission.camera,
      Permission.microphone,
    ].request();

    return permissions[Permission.camera] == PermissionStatus.granted &&
           permissions[Permission.microphone] == PermissionStatus.granted;
  }

  /// Genera un ID único para el canal de videollamada
  static String generateCallId(String userId1, String userId2) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final sortedUsers = [userId1, userId2]..sort();
    return '${timestamp}-${sortedUsers[0]}-${sortedUsers[1]}';
  }

  /// Configuración básica del engine de Agora
  static Future<RtcEngine> createEngine() async {
    final engine = createAgoraRtcEngine();
    await engine.initialize(RtcEngineContext(appId: appId));
    return engine;
  }

  /// Configuración de video optimizada
  static Future<void> setupVideoConfig(RtcEngine engine) async {
    await engine.enableVideo();
    await engine.enableAudio();
    
    // Configuración de calidad de video
    await engine.setVideoEncoderConfiguration(
      const VideoEncoderConfiguration(
        dimensions: VideoDimensions(width: 640, height: 480),
        frameRate: 15,
        bitrate: 400,
        orientationMode: OrientationMode.orientationModeAdaptive,
      ),
    );
  }

  /// Genera token temporal (en producción deberías usar tu servidor)
  static String getToken() {
    // TODO: En producción, implementa la generación de tokens desde tu servidor
    // Este token puede expirar y necesita renovación
    return tempToken;
  }

  /// Limpia y libera los recursos del engine
  static Future<void> disposeEngine(RtcEngine engine) async {
    try {
      await engine.leaveChannel();
      await engine.release();
    } catch (e) {
      print('Error disposing engine: $e');
    }
  }
}
