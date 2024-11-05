import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  final bool isAdmin;
  final String userId; // User ID of the current user
  final String studentId; // Student ID of the current user

  const ChatPage({
    Key? key,
    required this.isAdmin,
    required this.userId,
    required this.studentId,
  }) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  CollectionReference? _chatCollection; // Nullable collection reference
  String? errorMessage; // Error message for displaying issues
  String? dormitoryName; // Store the dormitory name

  @override
  void initState() {
    super.initState();
    _initializeChatCollection();
  }

  // Initialize the chat collection based on the user's role
  Future<void> _initializeChatCollection() async {
    try {
      DocumentSnapshot dormitoryDoc;

      if (widget.isAdmin) {
        dormitoryDoc = await FirebaseFirestore.instance
            .collection('admin')
            .doc(widget.userId)
            .get();
      } else {
        dormitoryDoc = await FirebaseFirestore.instance
            .collection('user')
            .doc('userId')
            .collection('ID')
            .doc(widget.studentId)
            .get();
      }

      if (dormitoryDoc.exists) {
        dormitoryName = dormitoryDoc['dormitory']; // Get the dormitory name
        _chatCollection = FirebaseFirestore.instance
            .collection('Chat')
            .doc(dormitoryName)
            .collection('messages'); // Save messages under the dormitory
        setState(() {});
      } else {
        setState(() {
          errorMessage = "Dormitory information not found.";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "An error occurred while fetching dormitory data: $e";
      });
    }
  }

  // Send a message to Firestore
  void _sendMessage() {
    if (_messageController.text.isNotEmpty && _chatCollection != null) {
      String inputId = widget.isAdmin ? widget.userId : widget.studentId; // Use userId for admin, studentId for students
      _chatCollection!.add({
        'message': _messageController.text,
        'sender': widget.isAdmin ? 'Admin' : 'Student',
        'userId': inputId, // Store the userId of the sender
        'timestamp': FieldValue.serverTimestamp(),
      }).then((_) {
        _messageController.clear();
      }).catchError((error) {
        setState(() {
          errorMessage = "Failed to send message: $error";
        });
      });
    }
  }

  // Format Firestore Timestamp to display in a readable format
  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Unknown time';

    DateTime dateTime = timestamp.toDate();
    DateTime now = DateTime.now();
    String formattedDate;

    if (now.year == dateTime.year && now.month == dateTime.month && now.day == dateTime.day) {
      formattedDate = DateFormat.jm().format(dateTime);
    } else if (now.difference(dateTime).inDays == 1) {
      formattedDate = 'Yesterday';
    } else {
      formattedDate = DateFormat.yMMMd().format(dateTime);
    }

    return formattedDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(dormitoryName ?? "Chat"), // Show dormitory name or default to "Chat"
      ),
      body: errorMessage != null
          ? Center(child: Text(errorMessage!))
          : Column(
              children: [
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _chatCollection?.orderBy('timestamp', descending: true).snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final messages = snapshot.data!.docs;
                      return ListView.builder(
                        reverse: true,
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];
                          final isMe = message['userId'] == (widget.isAdmin ? widget.userId : widget.studentId);
                          final messageText = message['message'] ?? '';
                          final timestamp = message['timestamp'] as Timestamp?;

                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                            child: Column(
                              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                              children: [
                                // Display sender's status above the message
                                Text(
                                  message['sender'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isMe ? Colors.blue : Colors.green,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // Message bubble with left-aligned timestamp for user and right-aligned for others
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    if (isMe) // Left-aligned timestamp for the user
                                      Text(
                                        _formatTimestamp(timestamp),
                                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                                      ),
                                    if (isMe) const SizedBox(width: 8), // Add space after timestamp if on the left
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: isMe ? Colors.blue[100] : (widget.isAdmin ? Colors.orange[100] : Colors.green[100]),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        messageText,
                                        style: const TextStyle(color: Colors.black),
                                      ),
                                    ),
                                    if (!isMe) const SizedBox(width: 8), // Add space before timestamp if on the right
                                    if (!isMe) // Right-aligned timestamp for others
                                      Text(
                                        _formatTimestamp(timestamp),
                                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: const InputDecoration(
                            hintText: 'Type your message...',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: _sendMessage,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
