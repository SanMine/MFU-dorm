import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class ScannerPage extends StatefulWidget {
  const ScannerPage({Key? key}) : super(key: key);

  @override
  _ScannerPageState createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String scanResult = "";
  String checkInOrOut = "Check In"; // Default option

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    }
    controller?.resumeCamera();
  }

  void onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        scanResult = scanData.code!;
        _processScanResult(scanResult);
      });
    });
  }

  void _processScanResult(String result) async {
    // Assuming the QR code returns JSON data
    // Parse the result and save to Firestore
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
  void dispose() {
    controller?.dispose();
    super.dispose();
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
            child: QRView(
              key: qrKey,
              onQRViewCreated: onQRViewCreated,
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
