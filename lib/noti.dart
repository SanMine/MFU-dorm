import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';

class NotiPage extends StatefulWidget {
  final bool isAdmin;
  final String userId;
  final String studentId;

  const NotiPage({super.key, required this.isAdmin, required this.userId, required this.studentId});

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

  // Initialize Firestore collection reference based on user and student IDs
  void _initializeNotificationCollection() {
    _notificationCollection = FirebaseFirestore.instance.collection('noti');
  }

  // Initialize the local notifications plugin
  void _initializeNotifications() {
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Show a notification in the notification bar
 Future<void> _showNotification(String message) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'default_channel', // channel ID (should be unique within the app)
    'General Notifications', // channel name shown to the user
    //'This channel is used for general notifications', // channel description shown in settings
    importance: Importance.max,
    priority: Priority.high,
    showWhen: false,
  );
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
  await _flutterLocalNotificationsPlugin.show(
    0, // Notification ID (can use 0 if no specific ID management needed)
    'New Notification', // Notification title
    message, // Notification body text
    platformChannelSpecifics,
  );
}


  // Show a popup when a new notification is detected
  void _detectNewNotifications(List<QueryDocumentSnapshot> notifications) {
    if (notifications.length > _previousNotificationCount) {
      final newNotification = notifications.first;
      _showNotification(newNotification['message']);
    }
    _previousNotificationCount = notifications.length;
  }

  // Add notification to Firestore
  Future<void> _addNotification(String message) async {
    if (message.isNotEmpty) {
      await _notificationCollection.add({
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
      });
      Navigator.of(context).pop(); // Close the dialog
    }
  }

  // Show dialog to add notification
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
                Navigator.of(context).pop(); // Close the dialog
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

  // Format timestamp
  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Unknown time';
    DateTime dateTime = timestamp.toDate();
    DateTime now = DateTime.now();
    if (now.year == dateTime.year && now.month == dateTime.month && now.day == dateTime.day) {
      return DateFormat.jm().format(dateTime); // e.g., 2:30 PM
    } else if (now.difference(dateTime).inDays == 1) {
      return 'Yesterday';
    } else {
      return DateFormat.yMMMd().format(dateTime); // e.g., Jan 1, 2022
    }
  }

  // Delete notification
  Future<void> _deleteNotification(String id) async {
    await _notificationCollection.doc(id).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notification deleted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _notificationCollection.orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final notifications = snapshot.data!.docs;

          // Detect new notifications and show them as local notifications
          _detectNewNotifications(notifications);

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(notification['message']),
                  subtitle: Text(
                    _formatTimestamp(notification['timestamp']),
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  trailing: widget.isAdmin
                      ? IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            _deleteNotification(notification.id);
                          },
                        )
                      : null, // No icon for non-admin users
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton(
              onPressed: _showAddNotificationDialog,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
