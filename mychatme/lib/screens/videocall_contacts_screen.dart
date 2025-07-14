// lib/screens/videocall_contacts_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'videocall_real_screen.dart';
import 'package:mychatme/l10n/app_localizations.dart';
import '../services/videocall_service.dart';

class VideoCallContactsScreen extends StatelessWidget {
  const VideoCallContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.selectContactForVideoCall),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final currentUserId = _auth.currentUser?.uid;
          final users = snapshot.data!.docs.where((doc) => doc.id != currentUserId).toList();

          if (users.isEmpty) {
            return Center(
              child: Text(
                t.noContactsAvailable,
                style: const TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final userData = user.data() as Map<String, dynamic>;
              final receiverId = user.id;
              final receiverName = userData['name'] ?? userData['email'] ?? t.user;

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.purple,
                  child: Text(
                    receiverName[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(
                  receiverName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(userData['email'] ?? ''),
                trailing: IconButton(
                  icon: const Icon(Icons.video_call, color: Colors.green, size: 30),
                  onPressed: () async {
                    // Mostrar loading
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );

                    // Crear la videollamada en Firestore
                    final callId = await VideoCallService.startVideoCall(
                      receiverId: receiverId,
                      receiverName: receiverName,
                    );

                    // Cerrar loading
                    Navigator.pop(context);

                    if (callId != null) {
                      // Ir a la pantalla de videollamada
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VideoCallRealScreen(
                            callId: callId,
                            receiverId: receiverId,
                            receiverName: receiverName,
                            isIncoming: false, // Es llamada saliente
                          ),
                        ),
                      );
                    } else {
                      // Error creando la llamada
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Error al iniciar la videollamada'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}