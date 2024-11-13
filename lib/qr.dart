import 'dart:async';
import 'dart:convert';
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
  int countdown = 30;
  String qrData = '';

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
        _generateQrData();
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
        _generateQrData();
        setState(() {
          countdown = 30;
        });
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
           Positioned.fill(
        child: Image.asset(
          'images/dormbg.jpg',
          fit: BoxFit.cover, // Makes the image cover the entire screen
        ),
      ),
          // Container(
          //   decoration: const BoxDecoration(
          //     gradient: LinearGradient(
          //       colors: [Color(0xFF7EB4FF), Color.fromARGB(255, 255, 255, 255)],
          //       begin: Alignment.topCenter,
          //       end: Alignment.bottomCenter,
          //     ),
          //   ),
          // ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
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

          const SizedBox(height: 10),
          Text(
            "${studentData?['firstName']} ${studentData?['lastName']}",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          QrImageView(
            data: qrData,
            version: QrVersions.auto,
            size: 200.0,
          ),
          const SizedBox(height: 10),
          Text(
            "Refresh in: $countdown seconds",
            style: TextStyle(
              fontSize: 16,
              color: countdown <= 5 ? Colors.red : Colors.black,
            ),
          ),
          const SizedBox(height: 10),
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

  void _generateQrData() async {
    if (studentData != null) {
      int currentTimestamp = DateTime.now().millisecondsSinceEpoch;

      final qrDataMap = {
        'name': "${studentData!['firstName']} ${studentData!['lastName']}",
        'id': studentData!['id'],
        'dormitory': studentData!['dormitory'],
        'room': studentData!['room'],
        'phone': studentData!['phone'],
        'email': studentData!['email'],
        'timestamp': currentTimestamp,
      };

      qrData = jsonEncode(qrDataMap);

      // Update Firestore with the latest timestamp for this user
      await FirebaseFirestore.instance
          .collection('user')
          .doc('userId')
          .collection('ID')
          .doc(widget.studentId)
          .update({'latestTimestamp': currentTimestamp});

      print("Generated QR Data: $qrData");
    }
  }
}
