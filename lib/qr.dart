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
  String? profileImageUrl;

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
          .get();

      DocumentSnapshot imageDoc = await FirebaseFirestore.instance
          .collection('user')
          .doc('userId')
          .collection('ID')
          .doc(widget.studentId)
          .collection('image')
          .doc(widget.studentId)
          .get();

      setState(() {
        studentData = studentDoc.exists ? studentDoc.data() as Map<String, dynamic>? : null;
        profileImageUrl = imageDoc.exists ? imageDoc['url'] as String : null;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        studentData = null;
        profileImageUrl = null;
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
      body: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF7EB4FF), Color.fromARGB(255, 255, 255, 255)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30), // Custom Back Button spacing
                Expanded(
                  child: Center(
                    child: isLoading
                        ? const CircularProgressIndicator()
                        : studentData == null
                            ? const Text("No student data available.")
                            : _buildQrCodeContainer(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrCodeContainer() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.yellow[100],
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Conditionally display the profile image or "No image" text
          profileImageUrl != null
              ? CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(profileImageUrl!),
                )
              : const Text("No image", style: TextStyle(fontSize: 16)),
          const SizedBox(height: 10),
          // User Name
          Text(
            "${studentData?['firstName']} ${studentData?['lastName']}",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          // QR Code
          QrImageView(
            data: _generateQrData(),
            version: QrVersions.auto,
            size: 200.0,
          ),
          const SizedBox(height: 10),
          // Student Information
          Text(
            "Student ID - ${studentData?['id']}\nDormitory - ${studentData?['dormitory']}\nRoom - ${studentData?['room']}",
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
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
