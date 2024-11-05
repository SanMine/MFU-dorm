import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MemberDetailPage extends StatelessWidget {
  final Map<String, dynamic> member;

  const MemberDetailPage({Key? key, required this.member}) : super(key: key);

  Future<String?> _fetchImage() async {
    final studentId = member['id'];
    try {
      DocumentSnapshot imageDoc = await FirebaseFirestore.instance
          .collection('user')
          .doc('userId') 
          .collection('ID')
          .doc(studentId)
          .get();

      return imageDoc.exists ? imageDoc.get('url') : null;
    } catch (e) {
      print("Error fetching image: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Dormitory and Room Number
            Text(
              "Dormitory: ${member['dormitory'] ?? 'N/A'}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Room Number: ${member['room'] ?? 'N/A'}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Member Detail Label
          
            const SizedBox(height: 20),
            // User Image
            Center(
              child: FutureBuilder<String?>(
                future: _fetchImage(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasData && snapshot.data != null) {
                    return Container(
                      width: 150, // Increased size
                      height: 150, // Increased size
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: NetworkImage(snapshot.data!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  } else {
                    return Container(
                      width: 150, // Increased size
                      height: 150, // Increased size
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey,
                      ),
                      child: const Center(
                        child: Text(
                          'No Image Yet',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 20),
            // Member Details Container
            Container(
              padding: const EdgeInsets.all(24), // Increased padding
              decoration: BoxDecoration(
                color: Colors.orange[300],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Name: ${member['firstName']} ${member['lastName']}", style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 10),
                  Text("Student ID: ${member['id']}", style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 10),
                  Text("Contact No: ${member['phone']}", style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 10),
                  Text("Email: ${member['email']}", style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
