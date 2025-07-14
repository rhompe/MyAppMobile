// lib/screens/videocall_contacts_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../screens/videocall_screen.dart';

class VideoCallContactsScreen extends StatefulWidget {
  const VideoCallContactsScreen({super.key});

  @override
  _VideoCallContactsScreenState createState() => _VideoCallContactsScreenState();
}

class _VideoCallContactsScreenState extends State<VideoCallContactsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar contacto para videollamada'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final currentUserId = _auth.currentUser?.uid;
          final users = snapshot.data!.docs.where((doc) => doc.id != currentUserId).toList();

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final userData = user.data() as Map<String, dynamic>;

              return ListTile(
                leading: CircleAvatar(
                  child: Text(userData['name']?[0] ?? '?'),
                ),
                title: Text(userData['name'] ?? 'Usuario sin nombre'),
                subtitle: Text(userData['email'] ?? ''),
                trailing: IconButton(
                  icon: const Icon(Icons.video_call, color: Colors.green),
                  onPressed: () {
                    // Aquí implementarías la lógica para iniciar la videollamada
                    _startVideoCall(context, user.id, userData['name'] ?? 'Usuario');
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _startVideoCall(BuildContext context, String receiverId, String receiverName) {
    // Implementa la lógica para iniciar la videollamada
    // Esto podría incluir:
    // 1. Crear un ID único para la llamada
    // 2. Guardar la información de la llamada en Firebase
    // 3. Navegar a la pantalla de videollamada

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoCallScreen(
          callId: 'unique_call_id_$receiverId',
          receiverId: receiverId,
          receiverName: receiverName,
        ),
      ),
    );
  }
}