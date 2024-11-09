import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({Key? key}) : super(key: key);

  @override
  _ScannerPageState createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  String scanResult = "";
  bool isCheckIn = true; // Default to Check-In
  bool isProcessingScan = false; // Flag to prevent duplicate scans
  bool hasScanned = false; // Flag to track if the last scan is processed

  // Processes the scanned result
  Future<void> _processScanResult(String result) async {
    if (isProcessingScan || hasScanned) return; // Prevent multiple scans
    isProcessingScan = true;
    hasScanned = true; // Set hasScanned to true to prevent further processing

    try {
      // Decode the QR code data
      Map<String, dynamic> data = jsonDecode(result);

      // Validate the expected data
      if (data['id'] == null || data['dormitory'] == null) {
        throw Exception("Invalid data in QR code");
      }

      // Prepare the data for Firestore
      String formattedDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
      String formattedTime = DateFormat('HH:mm').format(DateTime.now());

      // Save to Firestore under the specified path `/checkins/{dormitory}/data`
      await FirebaseFirestore.instance
          .collection('checkins')
          .doc(data['dormitory'])
          .collection('data')
          .add({
        'firstName': data['name'].split(" ").first,
        'lastName': data['name'].split(" ").last,
        'id': data['id'],
        'phone': data['phone'],
        'email': data['email'],
        'dormitory': data['dormitory'],
        'room': data['room'],
        'date': formattedDate,
        'checkInTime': isCheckIn ? formattedTime : null,
        'checkOutTime': isCheckIn ? null : formattedTime,
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(isCheckIn ? "Check-In Successful" : "Check-Out Successful"),
        backgroundColor: isCheckIn ? Colors.green : Colors.blue,
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Error processing QR code"),
        backgroundColor: Colors.red,
      ));
    } finally {
      isProcessingScan = false; // Reset the flag after processing
      // Reset hasScanned after a short delay to allow for new scans
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          hasScanned = false; // Allow scanning again
        });
      });
    }
  }

  // Method to download the check-in data as a CSV file
  Future<void> downloadData() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collectionGroup('data').get();

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
      Directory directory = await getApplicationDocumentsDirectory();
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
                if (code != null && code.isNotEmpty) {
                  scanResult = code;
                  _processScanResult(scanResult);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Unsuccessful scan"),
                    backgroundColor: Colors.red,
                  ));
                }
              },
            ),
          ),
          _buildCheckInOutToggle(),
        ],
      ),
    );
  }

  Widget _buildCheckInOutToggle() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                isCheckIn = true;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              decoration: BoxDecoration(
                color: isCheckIn ? Colors.blue : Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.blue),
              ),
              child: Text(
                "Check In",
                style: TextStyle(
                  color: isCheckIn ? Colors.white : Colors.blue,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10), // Spacing between buttons
          GestureDetector(
            onTap: () {
              setState(() {
                isCheckIn = false;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              decoration: BoxDecoration(
                color: !isCheckIn ? Colors.blue : Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.blue),
              ),
              child: Text(
                "Check Out",
                style: TextStyle(
                  color: !isCheckIn ? Colors.white : Colors.blue,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
