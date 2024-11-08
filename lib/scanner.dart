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

  // This method processes the scan result, saves to Firestore, and manages the UI feedback
  Future<void> _processScanResult(String result) async {
    if (isProcessingScan) return; // Prevent multiple scans
    isProcessingScan = true;

    try {
      // Parse the result as JSON to get student data
      Map<String, dynamic> data = jsonDecode(result);

      // Collect necessary data from the parsed QR data
      String? firstName = data['name']?.split(" ")?.first;
      String? lastName = data['name']?.split(" ")?.last;
      String? id = data['id'];
      String? phone = data['phone'];
      String? email = data['email'];
      String? dormitory = data['dormitory'];
      String? room = data['room'];
      DateTime now = DateTime.now();

      // Format date and time
      String formattedDate = DateFormat('dd/MM/yyyy').format(now);
      String formattedTime = DateFormat('HH:mm').format(now);

      // Save to Firestore under the specified path `/checkins/{dormitory}/data`
      if (dormitory != null) {
        await FirebaseFirestore.instance
            .collection('checkins')
            .doc(dormitory)
            .collection('data')
            .add({
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

        // Show feedback on successful check-in/check-out
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(isCheckIn ? "Check-In Successful" : "Check-Out Successful"),
          backgroundColor: isCheckIn ? Colors.green : Colors.blue,
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Invalid data in QR code"),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error processing QR code: $e"),
        backgroundColor: Colors.red,
      ));
    } finally {
      // Reset the flag after processing completes
      isProcessingScan = false;
    }
  }

  // Download data method remains largely unchanged
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
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Unsuccessful scan"),
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
                Text(isCheckIn ? "Check-In" : "Check-Out"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
