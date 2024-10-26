import 'package:flutter/material.dart';
import 'canteen.dart';
import 'chat.dart';
import 'map.dart';
import 'noti.dart';
import 'qr.dart';
import 'room.dart';
import 'service.dart';
import 'style.dart'; // Import your style.dart file
import 'menu.dart'; // Import your MenuPage
import 'csv_import.dart'; // Import CSV import function

class HomePage extends StatefulWidget {
  final Function(int) onPageSelected; // Function to navigate

  const HomePage({Key? key, required this.onPageSelected}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  bool _isMenuVisible = false; // Track if the menu is visible
  late AnimationController _menuController; // Controller for the menu animation
  late Animation<Offset> _menuAnimation; // Animation for the menu slide

  @override
  void initState() {
    super.initState();
    _menuController = AnimationController(
      duration: const Duration(milliseconds: 500), // Set duration for opening and closing
      vsync: this,
    );

    _menuAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0), // Start off-screen to the left
      end: Offset.zero, // End at the normal position
    ).animate(CurvedAnimation(
      parent: _menuController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _menuController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isMenuVisible = !_isMenuVisible; // Toggle menu visibility
      if (_isMenuVisible) {
        _menuController.forward(); // Show the menu
      } else {
        _menuController.reverse(); // Hide the menu
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MFU Dormitory', style: TextStyleComponent.heading),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: _toggleMenu, // Toggle menu visibility
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.file_upload), // Icon for CSV import
            onPressed: () async {
              await importCSVToFirestore(); // Trigger the CSV import function
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('CSV data imported to Firestore')),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
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
                    borderRadius: BorderRadius.all(Radius.circular(20)), // Border radius applied here
                  ),
                  width: double.infinity, // Make it responsive
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
                      FunctionContainer(label: 'My Room', onTap: () {
                        widget.onPageSelected(0); // Navigate to My Room
                      }, icon: Icons.bed_rounded),
                      FunctionContainer(label: 'Map', onTap: () {
                        widget.onPageSelected(1); // Navigate to Map
                      }, icon: Icons.map),
                      FunctionContainer(label: 'Canteen', onTap: () {
                        widget.onPageSelected(2); // Navigate to Canteen
                      }, icon: Icons.restaurant),
                      FunctionContainer(label: 'Services', onTap: () {
                        widget.onPageSelected(3); // Navigate to Services
                      }, icon: Icons.build),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Overlay Menu
          SlideTransition(
            position: _menuAnimation,
            child: MenuPage(
              onClose: () {
                setState(() {
                  _isMenuVisible = false; // Set menu visibility to false
                });
                _menuController.reverse(); // Close the menu with animation
              },
            ),
          ),
        ],
      ),
    );
  }
}

class FunctionContainer extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const FunctionContainer({Key? key, required this.label, required this.icon, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x40000000),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
          borderRadius: BorderRadius.all(Radius.circular(20)), // Border radius applied here
        ),
        width: 150,
        height: 150,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.blueAccent), // Icon with color
            const SizedBox(height: 10),
            Text(label, style: TextStyleComponent.bodyText),
          ],
        ),
      ),
    );
  }
}
