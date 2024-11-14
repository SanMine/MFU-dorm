import 'package:flutter/material.dart';

class EmergencyPage extends StatelessWidget {
  EmergencyPage({Key? key}) : super(key: key);

  final List<Map<String, String>> emergencyContacts = [
    {'name': 'Ambulance', 'number': '1162'},
    {'name': 'Fire Department', 'number': '199'},
    {'name': 'Police', 'number': '191'},
    {'name': 'Medical Emergency', 'number': '1669'},
  
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Contacts'),
        centerTitle: true,
        backgroundColor: const Color(0xFF7EB4FF),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF7EB4FF), Color.fromARGB(255, 255, 255, 255)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView.builder(
          itemCount: emergencyContacts.length,
          itemBuilder: (context, index) {
            final contact = emergencyContacts[index];

            return Card(
              child: ListTile(
                leading: const Icon(Icons.local_phone, color: Colors.red),
                title: Text(contact['name']!),
                subtitle: Text(contact['number']!),
              ),
            );
          },
        ),
      ),
    );
  }
}
