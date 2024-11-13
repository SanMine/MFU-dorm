import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyPage extends StatelessWidget {
   EmergencyPage({Key? key}) : super(key: key);

  final List<Map<String, String>> emergencyContacts = [
    {'name': 'Ambulance', 'number': '1162'},
    {'name': 'Fire Department', 'number': '199'},
    {'name': 'Police', 'number': '191'},
    {'name': 'Medical Emergency', 'number': '1669'},
    {'name': 'Poison Control', 'number': '1800-222-1222'},
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Contacts'),
        backgroundColor: const Color(0xFF84A8B6),
      ),
      body: ListView.builder(
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
    );
  }
}
