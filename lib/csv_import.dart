import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';

Future<void> importCSVToFirestore(String userId) async {
  try {
    // Step 1: Pick the CSV file
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);

      // Step 2: Read and parse the CSV file
      final input = file.openRead();
      final fields = await input
          .transform(utf8.decoder)
          .transform(const CsvToListConverter())
          .toList();

      WriteBatch batch = FirebaseFirestore.instance.batch();
      bool hasError = false;

      // Step 3: Validate and add each row to Firestore
      for (var i = 1; i < fields.length; i++) { // Start from 1 to skip header
        if (fields[i].length >= 10) {
          try {
            String studentId = fields[i][2]?.toString() ?? '';
            Map<String, dynamic> studentData = {
              "firstName": fields[i][0]?.toString() ?? '',
              "lastName": fields[i][1]?.toString() ?? '',
              "id": studentId,
              "phone": fields[i][3]?.toString() ?? '',
              "email": fields[i][4]?.toString() ?? '',
              "dormitory": fields[i][5]?.toString() ?? '',
              "room": fields[i][6]?.toString() ?? '',
              // "password": fields[i][7]?.toString() ?? '',
            };

            // Create a reference for each student using their studentId
            var studentDocRef = FirebaseFirestore.instance
                .collection('user')
                .doc(userId)
                .collection('ID')
                .doc(studentId)
                .collection('accounts')
                .doc(userId)
                .collection('students')
                .doc(studentId); // Use studentId as the document ID

            // Add the student data to the batch
            batch.set(studentDocRef, studentData);

            // Save student ID in the user ID collection
            var idDocRef = FirebaseFirestore.instance
                .collection('user')
                .doc(userId)
                .collection('ID')
                .doc(studentId); // Use studentId as the document ID

            batch.set(idDocRef, {"userid": studentId}); // Add user ID document
          } catch (e) {
            print("Error processing row $i: $e");
            hasError = true;
          }
        } else {
          print("Row $i does not have enough columns: ${fields[i]}");
        }
      }

      // Step 4: Commit batch write
      await batch.commit();
      print("CSV import completed${hasError ? " with some errors." : "."}");
    } else {
      print("No file selected");
    }
  } catch (e) {
    print("Error importing CSV: $e");
  }
}
