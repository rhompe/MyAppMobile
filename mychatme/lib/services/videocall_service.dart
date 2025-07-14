// lib/services/videocall_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VideoCallService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Iniciar una videollamada
  static Future<String?> startVideoCall({
    required String receiverId,
    required String receiverName,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return null;

      // Generar un callId único y persistente
      final callId = 'call_${DateTime.now().millisecondsSinceEpoch}_${currentUser.uid}_$receiverId';
      
      // Crear documento de videollamada en Firestore
      final callDoc = {
        'callId': callId,
        'callerId': currentUser.uid,
        'callerName': currentUser.displayName ?? currentUser.email ?? 'Usuario',
        'receiverId': receiverId,
        'receiverName': receiverName,
        'status': 'calling', // calling, accepted, rejected, ended
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'video',
      };

      await _firestore.collection('videocalls').doc(callId).set(callDoc);
      
      print('✅ Videollamada creada: $callId');
      return callId;
    } catch (e) {
      print('❌ Error creando videollamada: $e');
      return null;
    }
  }

  /// Aceptar una videollamada
  static Future<bool> acceptVideoCall(String callId) async {
    try {
      await _firestore.collection('videocalls').doc(callId).update({
        'status': 'accepted',
        'acceptedAt': FieldValue.serverTimestamp(),
      });
      
      print('✅ Videollamada aceptada: $callId');
      return true;
    } catch (e) {
      print('❌ Error aceptando videollamada: $e');
      return false;
    }
  }

  /// Rechazar una videollamada
  static Future<bool> rejectVideoCall(String callId) async {
    try {
      await _firestore.collection('videocalls').doc(callId).update({
        'status': 'rejected',
        'rejectedAt': FieldValue.serverTimestamp(),
      });
      
      print('✅ Videollamada rechazada: $callId');
      return true;
    } catch (e) {
      print('❌ Error rechazando videollamada: $e');
      return false;
    }
  }

  /// Terminar una videollamada
  static Future<bool> endVideoCall(String callId) async {
    try {
      await _firestore.collection('videocalls').doc(callId).update({
        'status': 'ended',
        'endedAt': FieldValue.serverTimestamp(),
      });
      
      print('✅ Videollamada terminada: $callId');
      return true;
    } catch (e) {
      print('❌ Error terminando videollamada: $e');
      return false;
    }
  }

  /// Escuchar videollamadas entrantes
  static Stream<QuerySnapshot> listenForIncomingCalls() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('videocalls')
        .where('receiverId', isEqualTo: currentUser.uid)
        .where('status', isEqualTo: 'calling')
        .snapshots();
  }

  /// Escuchar el estado de una videollamada específica
  static Stream<DocumentSnapshot> listenToCallStatus(String callId) {
    return _firestore.collection('videocalls').doc(callId).snapshots();
  }

  /// Limpiar videollamadas antigas (opcional)
  static Future<void> cleanOldCalls() async {
    try {
      final oneDayAgo = DateTime.now().subtract(const Duration(days: 1));
      
      final oldCalls = await _firestore
          .collection('videocalls')
          .where('timestamp', isLessThan: Timestamp.fromDate(oneDayAgo))
          .get();

      for (var doc in oldCalls.docs) {
        await doc.reference.delete();
      }
      
      print('✅ Videollamadas antigas limpiadas');
    } catch (e) {
      print('❌ Error limpiando videollamadas: $e');
    }
  }
}
