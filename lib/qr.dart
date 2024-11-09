import 'dart:async';
import 'dart:convert'; // Import for JSON encoding
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
  Timer? timer;
  int countdown = 30; // Countdown timer in seconds
  String qrData = ''; // Store the current QR code data

  @override
  void initState() {
    super.initState();
    _fetchStudentData();
    _startTimer();
  }

  Future<void> _fetchStudentData() async {
    try {
      DocumentSnapshot studentDoc = await FirebaseFirestore.instance
          .collection('user')
          .doc('userId') // 'userId' is a document string name 
          .collection('ID')
          .doc(widget.studentId)
          .get();

      DocumentSnapshot imageDoc = await FirebaseFirestore.instance
          .collection('user')
          .doc('userId') // 'userId' is a document string name 
          .collection('ID')
          .doc(widget.studentId)
          .collection('image')
          .doc(widget.studentId)
          .get();

      setState(() {
        studentData = studentDoc.exists ? studentDoc.data() as Map<String, dynamic>? : null;
        profileImageUrl = imageDoc.exists ? imageDoc['url'] as String : null;
        isLoading = false;
        _generateQrData(); // Generate initial QR data after loading student data
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

  void _startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (countdown > 0) {
        setState(() {
          countdown--;
        });
      } else {
        _generateQrData(); // Regenerate QR data every 30 seconds
        setState(() {
          countdown = 30; // Reset countdown
        });
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
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
            data: qrData, // Use the current QR data
            version: QrVersions.auto,
            size: 200.0,
          ),
          const SizedBox(height: 10),
          // Countdown timer with color
          Text(
            "Refresh in: $countdown seconds",
            style: TextStyle(
              fontSize: 16,
              color: countdown <= 5 ? Colors.red : Colors.black, // Change to red when <= 5 seconds
            ),
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

  void _generateQrData() {
    // Use JSON encoding for QR data generation
    if (studentData != null) {
      final qrDataMap = {
        'name': "${studentData!['firstName']} ${studentData!['lastName']}",
        'id': studentData!['id'],
        'timestamp': DateTime.now().millisecondsSinceEpoch
      };
      
      // Encode the map as a JSON string for QR data
      qrData = jsonEncode(qrDataMap);
      
      // Log the QR data for debugging
      print("Generated QR Data: $qrData");
    }
  }
}
