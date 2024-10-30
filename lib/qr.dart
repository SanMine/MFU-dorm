import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrPage extends StatelessWidget {
  final String studentId;

  QrPage({required this.studentId});

  Future<Map<String, dynamic>?> fetchStudentData(String id) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('students')
          .doc(id)
          .get();

      if (snapshot.exists) {
        return snapshot.data() as Map<String, dynamic>?;
      } else {
        print("Student not found");
        return null;
      }
    } catch (e) {
      print("Error fetching student data: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student QR Code'),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: fetchStudentData(studentId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text("No student data found"));
          } else {
            final studentData = snapshot.data!;
            String qrData = 'firstName: ${studentData['firstName']}, '
                            'lastName: ${studentData['lastName']}, '
                            'id: ${studentData['id']}, '
                            'phone: ${studentData['phone']}, '
                            'email: ${studentData['email']}, '
                            'Dormitory: ${studentData['Dormitory']}, '
                            'room: ${studentData['room']}';

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // QrImage(
                  //   data: qrData,
                  //   version: QrVersions.auto,
                  //   size: 200.0,
                  // ),
                  SizedBox(height: 20),
                  Text(
                    'Scan the QR code above',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
