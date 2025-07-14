// lib/screens/videocall_contacts_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'videocall_screen.dart'; // Asegúrate de importar la pantalla de videollamada
import 'package:mychatme/l10n/app_localizations.dart';

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
              final receiverName = userData['name'] ?? t.user;

              return ListTile(
                leading: CircleAvatar(
                  child: Text(receiverName[0]),
                ),
                title: Text(receiverName),
                subtitle: Text(userData['email'] ?? ''),
                trailing: IconButton(
                  icon: const Icon(Icons.video_call, color: Colors.green),
                  onPressed: () {
                    final callId = '${DateTime.now().millisecondsSinceEpoch}-${_auth.currentUser?.uid}-$receiverId';

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VideoCallScreen(
                          callId: callId,
                          receiverId: receiverId,
                          receiverName: receiverName,
                        ),
                      ),
                    );
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