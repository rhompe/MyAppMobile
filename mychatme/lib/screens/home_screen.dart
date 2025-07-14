// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:mychatme/screens/change_password_screen.dart';
import 'package:mychatme/screens/contacts_screen.dart';
import 'package:mychatme/screens/videocall_contacts_screen.dart';
import 'package:mychatme/l10n/app_localizations.dart';

import 'device_contacts_screen.dart'; // Nueva pantalla para contactos de videollamada

class HomeScreen extends StatelessWidget {
  final String userName;
  final String userRole;

  const HomeScreen({
    super.key,
    required this.userName,
    required this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    String roleText = userRole == 'admin' ? t.administrator : t.user;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.welcome),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'logout') {
                Navigator.of(context).popUntil((route) => route.isFirst);
              } else if (value == 'settings') {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(t.openSettings)),
                );
              } else if (value == 'change_password') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
                );
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text(t.settings),
                ),
              ),
              PopupMenuItem(
                value: 'change_password',
                child: ListTile(
                  leading: Icon(Icons.lock_reset),
                  title: Text(t.changePassword),
                ),
              ),
              PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text(t.logout),
                ),
              ),
            ],
          ),
        ],
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Container(
        color: const Color(0xFFF9FAFB),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tarjeta superior con nombre e inicial
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.purple,
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      roleText,
                      style: const TextStyle(color: Colors.grey),
                    )
                  ],
                )
              ],
            ),

            const SizedBox(height: 24),
            Text(
              t.home,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Botones
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ContactsScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.purple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.message_rounded, size: 32),
                      SizedBox(height: 8),
                      Text(t.chat),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => VideoCallContactsScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.video_call_rounded, size: 32),
                      SizedBox(height: 8),
                      Text(t.videoCall),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DeviceContactsScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.orange, // Puedes elegir otro color si prefieres
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.contacts, size: 32),
                      SizedBox(height: 8),
                      Text(t.phoneContacts),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}