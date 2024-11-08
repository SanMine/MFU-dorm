import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart'; // Correctly import share_plus
import 'package:csv/csv.dart'; // Correctly import csv package
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Import for XFile

// Show a dialog to choose which file to download
Future<void> showDownloadDialog(BuildContext context, CollectionReference serviceCollection) async {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Select Request Type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                downloadData(serviceCollection, 'Fix Service Requests');
              },
              child: const Text('Download Fix Service Requests'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                downloadData(serviceCollection, 'Stay Outside Requests');
              },
              child: const Text('Download Stay Outside Requests'),
            ),
          ],
        ),
      );
    },
  );
}

// Download data based on the selected request type
Future<void> downloadData(CollectionReference serviceCollection, String requestType) async {
  try {
    // Fetch the requests based on the request type
    QuerySnapshot snapshot;
    if (requestType == 'Fix Service Requests') {
      snapshot = await serviceCollection.where('type', isEqualTo: 'Fix Service Request').get();
    } else {
      snapshot = await serviceCollection.where('type', isEqualTo: 'Stay Outside Request').get();
    }

    // Prepare CSV data
    List<List<dynamic>> rows = [];
    List<String> headers = [];
    
    // Set headers based on request type
    if (requestType == 'Fix Service Requests') {
      headers = [
        "Type",
        "Student ID",
        "Dormitory",
        "Room",
        "Status",
        "Request Time",
        "Request Date",
        "Material Type",
        "Condition",
        "Quantity"
      ];
    } else {
      headers = [
        "Type",
        "Student ID",
        "Dormitory",
        "Room",
        "Status",
        "Request Time",
        "Request Date",
        "Leave Date",
        "Return Date",
        "Reason"
      ];
    }
    
    rows.add(headers);

    for (var doc in snapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      List<dynamic> row = [
        data['type'] ?? '',
        data['studentId'] ?? '',
        data['dormitory'] ?? '',
        data['room'] ?? '',
        data['status'] ?? '',
        data['requestTime'] ?? '',
        data['requestDate'] ?? '',
        if (requestType == 'Fix Service Requests') ...[
          data['materialType'] ?? '',
          data['condition'] ?? '',
          data['quantity'] ?? '',
        ] else ...[
          data['leaveDate'] ?? '',
          data['returnDate'] ?? '',
          data['reason'] ?? '',
        ],
      ];
      rows.add(row);
    }

    // Convert rows to CSV format
    String csv = const ListToCsvConverter().convert(rows); // Convert List to CSV

    // Get the directory to save the file
    Directory? directory = await getApplicationDocumentsDirectory(); // Use application documents directory
    String path = '${directory.path}/${requestType.replaceAll(' ', '')}.csv'; // Create filename based on request type

    // Save the CSV file
    File file = File(path);
    await file.writeAsString(csv);

    // Share the CSV file using XFile
    XFile xfile = XFile(file.path); // Create an XFile from the file path
    await Share.shareXFiles([xfile], text: '$requestType downloaded'); // Use shareXFiles
  } catch (e) {
    print('Error downloading data: $e');
  }
}
