import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mychatme/l10n/app_localizations.dart';

class ChatScreen extends StatefulWidget {
  final String currentUserId;
  final String receiverId;
  final String receiverName;

  const ChatScreen({
    super.key,
    required this.currentUserId,
    required this.receiverId,
    required this.receiverName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();

   // Crea el ID único del chat entre dos usuarios
  String getChatId() {
    return widget.currentUserId.hashCode <= widget.receiverId.hashCode
        ? '${widget.currentUserId}_${widget.receiverId}'
        : '${widget.receiverId}_${widget.currentUserId}';
  }

  void sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    /*FirebaseFirestore.instance.collection('messages').add({
      'senderId': widget.currentUserId,
      'receiverId': widget.receiverId,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });*/
    final chatId = widget.currentUserId.hashCode <= widget.receiverId.hashCode
      ? '${widget.currentUserId}_${widget.receiverId}'
      : '${widget.receiverId}_${widget.currentUserId}';

    FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
      'senderId': widget.currentUserId,
      'receiverId': widget.receiverId,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final chatId = getChatId();//added

    return Scaffold(
      //appBar: AppBar(title: Text("Chat con ${widget.receiverName}")),
      appBar: AppBar(title: Text(t.chatWith(widget.receiverName))),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
                  /*.collection('messages')
                  .orderBy('timestamp', descending: true)
                  .where('senderId', whereIn: [widget.currentUserId, widget.receiverId])
                  .where('receiverId', whereIn: [widget.currentUserId, widget.receiverId])
                  .snapshots(),*/
              builder: (context, snapshot) {
                //added
                if (snapshot.hasError) {
                  //return Center(child: Text("Error: ${snapshot.error}"));
                  return Center(child: Text("${t.error}: ${snapshot.error}"));
                }//added

                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final messages = snapshot.data!.docs;

                //added
                 if (messages.isEmpty) {
                  //return const Center(child: Text("No hay mensajes aún."));
                  return Center(child: Text(t.noMessagesYet));
                }//added

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg['senderId'] == widget.currentUserId;
                    return ListTile(
                      title: Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.purple[100] : Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(msg['message']),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration:  InputDecoration(
                      //hintText: "Escribe un mensaje...",
                      hintText: t.typeMessage,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: sendMessage,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
