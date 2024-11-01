import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({Key? key}) : super(key: key);

  @override
  _ScannerPageState createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  String scanResult = "";
  String checkInOrOut = "Check In"; // Default option

  void _processScanResult(String result) async {
    // Assuming the QR code returns JSON data
    Map<String, dynamic> data = {}; // Parse the result into a Map

    // Collect data
    String? firstName = data['firstName'];
    String? lastName = data['lastName'];
    String? id = data['id'];
    String? phone = data['phone'];
    String? email = data['email'];
    String? dormitory = data['dormitory'];
    String? room = data['room'];
    DateTime now = DateTime.now();

    // Save to Firestore
    await FirebaseFirestore.instance.collection('checkins').add({
      'firstName': firstName,
      'lastName': lastName,
      'id': id,
      'phone': phone,
      'email': email,
      'dormitory': dormitory,
      'room': room,
      'date': now.toIso8601String(),
      'checkInTime': checkInOrOut == "Check In" ? now.toIso8601String() : null,
      'checkOutTime': checkInOrOut == "Check Out" ? now.toIso8601String() : null,
    });

    // Show a snackbar or alert to confirm success
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Data saved successfully!"),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("QR Code Scanner"),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: MobileScanner(
              onDetect: (BarcodeCapture capture) {
                final String? code = capture.barcodes.first.rawValue;
                if (code != null) {
                  setState(() {
                    scanResult = code;
                    _processScanResult(scanResult);
                  });
                }
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      checkInOrOut = "Check In";
                    });
                  },
                  child: const Text("Check In"),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      checkInOrOut = "Check Out";
                    });
                  },
                  child: const Text("Check Out"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
