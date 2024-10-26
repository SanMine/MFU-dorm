import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  // Method to delete a single document
  Future<void> _deleteStudent(String docId) async {
    await FirebaseFirestore.instance.collection('students').doc(docId).delete();
  }

  // Method to delete all documents in the 'students' collection
  Future<void> _deleteAllStudents() async {
    final batch = FirebaseFirestore.instance.batch();
    final snapshots = await FirebaseFirestore.instance.collection('students').get();
    
    for (var doc in snapshots.docs) {
      batch.delete(doc.reference);
    }
    
    await batch.commit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student List'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async {
              // Confirm deletion
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text("Delete All Students"),
                  content: Text("Are you sure you want to delete all student records?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text("Delete"),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await _deleteAllStudents();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('All student records deleted')),
                );
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection('students').get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final students = snapshot.data!.docs;
          if (students.isEmpty) {
            return Center(child: Text('No student data found.'));
          }

          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index].data() as Map<String, dynamic>;
              final docId = students[index].id; // Get the document ID for deletion

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text('${student['firstName']} ${student['lastName']}'),
                  subtitle: Text(
                    'ID: ${student['id']}\n'
                    'Phone: ${student['phone']}\n'
                    'Dormitory: ${student['dormitory']}\n'
                    'Room: ${student['room']}',
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await _deleteStudent(docId);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${student['firstName']} ${student['lastName']} deleted')),
                      );
                    },
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
