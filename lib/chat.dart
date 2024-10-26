import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student List')),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection('students').get(), // Fetching the student data
        builder: (context, snapshot) {
          // Show loading indicator while fetching data
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          // Check for errors
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // Extracting student data from snapshot
          final students = snapshot.data!.docs;

          // Check if there are any students
          if (students.isEmpty) {
            return Center(child: Text('No student data found.'));
          }

          // Displaying the student data in a list
          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index].data() as Map<String, dynamic>;

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text('${student['firstName']} ${student['lastName']}'), // Display name
                  subtitle: Text(
                    'ID: ${student['id']}\n'
                    'Phone: ${student['phone']}\n'
                    'Dormitory: ${student['dormitory']}\n' // Make sure to have 'dormitory' in Firestore
                    'Room: ${student['room']}',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
