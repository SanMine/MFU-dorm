import 'package:flutter/material.dart';
import 'style.dart'; // Import your style.dart file
import 'qr.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MFU Dormitory', style: TextStyleComponent.heading),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            // Handle hamburger menu action
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Colors.yellow,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x40000000),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
                borderRadius: BorderRadius.all(
                    Radius.circular(20)), // Border radius applied here
              ),
              width: 366.45947,
              height: 150,
              child: const Center(
                child: Text(
                  'IMPORTANT ANNOUNCEMENT!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                children: [
                  FunctionContainer(
                      label: 'My Room',
                      onTap: () {
                        // Navigate to My Room page
                      },
                      icon: Icons.bed_rounded),
                  FunctionContainer(
                      label: 'Map',
                      onTap: () {
                        // Navigate to Map page
                      },
                      icon: Icons.map),
                  FunctionContainer(
                      label: 'Canteen',
                      onTap: () {
                        // Navigate to Canteen page
                      },
                      icon: Icons.restaurant),
                  FunctionContainer(
                      label: 'Services',
                      onTap: () {
                        // Navigate to Services page
                      },
                      icon: Icons.build),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.blue), // Color added to icon
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon:
                Icon(Icons.qr_code, color: Colors.green), // Color added to icon
            label: 'QR Code',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat, color: Colors.orange), // Color added to icon
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications,
                color: Colors.red), // Color added to icon
            label: 'Notifications',
          ),
        ],
        // Add navigation handling
        onTap: (index) {
          if (index == 1) {
            // Navigate to QR Page
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      QRPage()), // Push QRPage when QR icon is clicked
            );
          }
        },
      ),
    );
  }
}

class FunctionContainer extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const FunctionContainer(
      {Key? key, required this.label, required this.icon, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x40000000),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
          borderRadius: BorderRadius.all(
              Radius.circular(20)), // Border radius applied here
        ),
        width: 150,
        height: 150,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Add your icons or images here with color
            Icon(icon, size: 40, color: Colors.blueAccent), // Icon with color
            SizedBox(height: 10),
            Text(label, style: TextStyleComponent.bodyText),
          ],
        ),
      ),
    );
  }
}
