import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrPage extends StatefulWidget {
  final String userId;
  final String studentId;

  const QrPage({Key? key, required this.userId, required this.studentId}) : super(key: key);

  @override
  _QrPageState createState() => _QrPageState();
}

class _QrPageState extends State<QrPage> {
  Map<String, dynamic>? studentData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStudentData();
  }

  Future<void> _fetchStudentData() async {
    try {
      DocumentSnapshot studentDoc = await FirebaseFirestore.instance
          .collection('user')
          .doc('userId')
          .collection('ID')
          .doc(widget.studentId)
          .collection('accounts')
          .doc('userId')
          .collection('students')
          .doc(widget.studentId)
          .get();

      if (studentDoc.exists) {
        setState(() {
          studentData = studentDoc.data() as Map<String, dynamic>?;
          isLoading = false;
        });
      } else {
        setState(() {
          studentData = null;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        studentData = null;
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching student data: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student QR Code"),
        backgroundColor: Colors.blueAccent, // Set your desired color
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : studentData == null
                ? const Text("No student data available.")
                : _buildQrCodePage(),
      ),
    );
  }

  Widget _buildQrCodePage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Student Image (Placeholder)
          CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage("https://example.com/path/to/profile/image.jpg"), // Replace with actual image URL
          ),
          const SizedBox(height: 16),
          Text(
            "${studentData!['firstName']} ${studentData!['lastName']}",
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          QrImageView(
            data: _generateQrData(),
            version: QrVersions.auto,
            size: 200.0,
          ),
          const SizedBox(height: 20),
          Text("Student ID: ${studentData!['id']}", style: const TextStyle(fontSize: 16)),
          Text("Dormitory: ${studentData!['dormitory']}", style: const TextStyle(fontSize: 16)),
          Text("Room: ${studentData!['room']}", style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  String _generateQrData() {
    return studentData != null
        ? '{"name": "${studentData!['firstName']} ${studentData!['lastName']}", "id": "${studentData!['id']}", "email": "${studentData!['email']}", "phone": "${studentData!['phone']}", "dormitory": "${studentData!['dormitory']}", "room": "${studentData!['room']}"}'
        : 'No data available';
  }
}
