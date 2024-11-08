import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';

class NotiPage extends StatefulWidget {
  final bool isAdmin;
  final String userId;
  final String studentId;

  const NotiPage({
    super.key,
    required this.isAdmin,
    required this.userId,
    required this.studentId,
  });

  @override
  _NotiPageState createState() => _NotiPageState();
}

class _NotiPageState extends State<NotiPage> {
  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  late CollectionReference _notificationCollection;
  int _previousNotificationCount = 0;

  @override
  void initState() {
    super.initState();
    _initializeNotificationCollection();
    _initializeNotifications();
  }

  void _initializeNotificationCollection() {
    _notificationCollection = FirebaseFirestore.instance.collection('noti');
  }

  void _initializeNotifications() {
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _showNotification(String message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'default_channel',
      'General Notifications',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await _flutterLocalNotificationsPlugin.show(
      0,
      'New Notification',
      message,
      platformChannelSpecifics,
    );
  }

  void _detectNewNotifications(List<QueryDocumentSnapshot> notifications) {
    if (notifications.length > _previousNotificationCount) {
      final newNotification = notifications.first;
      _showNotification(newNotification['message']);
    }
    _previousNotificationCount = notifications.length;
  }

  Future<void> _addNotification(String message) async {
    if (message.isNotEmpty) {
      await _notificationCollection.add({
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
      });
      Navigator.of(context).pop();
    }
  }

  void _showAddNotificationDialog() {
    TextEditingController _messageController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Notify'),
          content: TextField(
            controller: _messageController,
            decoration: const InputDecoration(hintText: 'Your message...'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _addNotification(_messageController.text);
              },
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Unknown time';
    DateTime dateTime = timestamp.toDate();
    DateTime now = DateTime.now();
    if (now.year == dateTime.year && now.month == dateTime.month && now.day == dateTime.day) {
      return DateFormat.jm().format(dateTime);
    } else if (now.difference(dateTime).inDays == 1) {
      return 'Yesterday';
    } else {
      return DateFormat.yMMMd().format(dateTime);
    }
  }

  Future<void> _deleteNotification(String id) async {
    await _notificationCollection.doc(id).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notification deleted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF7EB4FF), Color.fromARGB(255, 255, 255, 255)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: const Text(
                'Notification',
                style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _notificationCollection.orderBy('timestamp', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final notifications = snapshot.data!.docs;
                  _detectNewNotifications(notifications);

                  return ListView.builder(
                    padding: const EdgeInsets.all(20.0),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      return _buildNotificationCard(
                        notification['message'],
                        _formatTimestamp(notification['timestamp']),
                        notification.id,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton(
              onPressed: _showAddNotificationDialog,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildNotificationCard(String message, String timestamp, String id) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 6,
              backgroundColor: Colors.purple,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: const TextStyle(color: Colors.black, fontSize: 16),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    timestamp,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
            if (widget.isAdmin) // Show delete icon only if isAdmin is true
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  _deleteNotification(id);
                },
              ),
          ],
        ),
      ),
    );
  }
}
