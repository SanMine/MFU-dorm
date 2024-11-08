import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart'; // Import the intl package

class ScannerPage extends StatefulWidget {
  const ScannerPage({Key? key}) : super(key: key);

  @override
  _ScannerPageState createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  String scanResult = "";
  bool isCheckIn = true; // Default to Check In

  void _processScanResult(String result) async {
    // Here, parse the result into a Map.
    Map<String, dynamic> data = {}; // Replace with actual JSON parsing logic

    // Collect data
    String? firstName = data['firstName'];
    String? lastName = data['lastName'];
    String? id = data['id'];
    String? phone = data['phone'];
    String? email = data['email'];
    String? dormitory = data['dormitory'];
    String? room = data['room'];
    DateTime now = DateTime.now();

    // Format date and time
    String formattedDate = DateFormat('dd/MM/yyyy').format(now);
    String formattedTime = DateFormat('HH:mm').format(now);

    // Save to Firestore
    await FirebaseFirestore.instance.collection('checkins').add({
      'firstName': firstName,
      'lastName': lastName,
      'id': id,
      'phone': phone,
      'email': email,
      'dormitory': dormitory,
      'room': room,
      'date': formattedDate,
      'checkInTime': isCheckIn ? formattedTime : null,
      'checkOutTime': !isCheckIn ? formattedTime : null,
    });

    // Show a snackbar based on check-in or check-out
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(isCheckIn ? "Check In" : "Check Out"),
      backgroundColor: isCheckIn ? Colors.green : Colors.blue,
    ));
  }

  Future<void> downloadData() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('checkins').get();
      
      List<List<dynamic>> rows = [];
      List<String> headers = [
        "First Name",
        "Last Name",
        "ID",
        "Phone",
        "Email",
        "Dormitory",
        "Room",
        "Date",
        "Check In Time",
        "Check Out Time"
      ];
      rows.add(headers);

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        List<dynamic> row = [
          data['firstName'] ?? '',
          data['lastName'] ?? '',
          data['id'] ?? '',
          data['phone'] ?? '',
          data['email'] ?? '',
          data['dormitory'] ?? '',
          data['room'] ?? '',
          data['date'] ?? '',
          data['checkInTime'] ?? '',
          data['checkOutTime'] ?? '',
        ];
        rows.add(row);
      }

      // Convert rows to CSV format
      String csv = const ListToCsvConverter().convert(rows);

      // Get the directory to save the file
      Directory? directory = await getApplicationDocumentsDirectory();
      String path = '${directory.path}/checkins.csv';

      // Save the CSV file
      File file = File(path);
      await file.writeAsString(csv);

      // Share the CSV file
      XFile xfile = XFile(file.path);
      await Share.shareXFiles([xfile], text: 'Check-ins data downloaded');
    } catch (e) {
      print('Error downloading data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("QR Code Scanner"),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: downloadData,
          ),
        ],
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
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: const Text("Unsuccessful"),
                    backgroundColor: Colors.red,
                  ));
                }
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Switch(
                  value: isCheckIn,
                  onChanged: (value) {
                    setState(() {
                      isCheckIn = value;
                    });
                  },
                  activeColor: Colors.blue,
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: Colors.grey,
                ),
                Text(isCheckIn ? "Check In" : "Check Out"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
