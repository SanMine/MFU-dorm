import 'package:flutter/material.dart';

class MemberDetailPage extends StatelessWidget {
  final Map<String, dynamic> member;

  const MemberDetailPage({Key? key, required this.member}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String firstLetter = member['firstName'] != null && member['firstName'].isNotEmpty
        ? member['firstName'][0].toUpperCase()
        : "?";

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF7EB4FF), Color.fromARGB(255, 255, 255, 255)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 50), // Space for the AppBar
                  
                  // App Bar Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const Spacer(),
                    
                    ],
                  ),
                  
                  // Dormitory and Room Number
                  Text(
                    "Dormitory: ${member['dormitory'] ?? 'N/A'}",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 255, 255, 255)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Room Number: ${member['room'] ?? 'N/A'}",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 255, 255, 255)),
                  ),
                  const SizedBox(height: 20),

                  // User Initial in Circle Avatar
                  Center(
                    child: CircleAvatar(
                      radius: 50, // Increased size
                      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                      child: Text(
                        firstLetter,
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7EB4FF),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Member Details Container
                  Container(
                    padding: const EdgeInsets.all(24), // Increased padding
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Name: ${member['firstName']} ${member['lastName']}",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          "Student ID: ${member['id']}",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          "Contact No: ${member['phone']}",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          "Email: ${member['email']}",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(), // Spacer to push the logo to the bottom
                ],
              ),
            ),
          ),
          
          // App Logo as Watermark at the Bottom
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Opacity(
              opacity: 0.5, // Set the opacity to make it subtle
              child: Center(
                child: Image.asset(
                  'images/watermark.png',
                  width: 100, // Adjust size as needed
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
