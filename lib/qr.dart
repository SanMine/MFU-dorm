import 'package:flutter/material.dart';

class QRPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/dorm.png'), // Background image
                fit: BoxFit.cover,
                alignment:
                    Alignment.bottomRight, // Align the image to the bottom
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Custom Back Button
                const SizedBox(height: 30),
                Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow[200],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context); // Back action
                    },
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    label: const Text('Back',
                        style: TextStyle(color: Colors.black)),
                  ),
                ),
                const SizedBox(height: 30),
                // QR Code and Info
                Expanded(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: Colors.yellow[100],
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // User Image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: Image.asset(
                              'assets/images/mole.jpeg', // User's image
                              width: 80,
                              height: 80,
                            ),
                          ),
                          const SizedBox(height: 10),
                          // User Name
                          const Text(
                            'Miss Nang Ying Lao Hsaing',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 10),
                          // QR Code
                          Image.asset(
                            'assets/images/dorm.png', // QR image
                            width: 200,
                            height: 200,
                          ),
                          const SizedBox(height: 10),
                          // Student Information
                          const Text(
                            'Student ID - 6531503162\nDormitory - Sakhtong 1\nRoom 316',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
