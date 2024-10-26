import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'dart:convert';

Future<void> importCSVToFirestore() async {
  // Step 1: Pick the CSV file
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['csv'],
  );

  if (result != null) {
    File file = File(result.files.single.path!);

    // Step 2: Read and parse the CSV file
    final input = file.openRead();
    final fields = await input
        .transform(utf8.decoder)
        .transform(const CsvToListConverter())
        .toList();

    // Step 3: Convert each row to a map and add it to Firestore
    for (var i = 1; i < fields.length; i++) {
      if (fields[i].length >= 10) {
        Map<String, dynamic> studentData = {
          "firstName": fields[i][0],
          "lastName": fields[i][1],
          "id": fields[i][2],
          "phone": fields[i][3],
          "email": fields[i][4],
          "dormitory": fields[i][5],
          "room": fields[i][6],
          "password": fields[i][7],
          // "checkIn": fields[i][7],
          // "checkOut": fields[i][8],
          // "date": fields[i][9],
        };

        // Debug print
        print("Adding student: $studentData");

        // Add the student data to Firestore
        await FirebaseFirestore.instance.collection('students').add(studentData);
      } else {
        print("Row $i does not have enough columns: ${fields[i]}");
      }
    }
  } else {
    print("No file selected");
  }
}
