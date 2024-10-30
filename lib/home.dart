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
  final bool isAdmin; // Flag to indicate if the user is an admin

  const HomePage({Key? key, required this.onPageSelected, this.isAdmin = false}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _menuController; // Animation controller for menu
  late Animation<Offset> _menuAnimation; // Animation for sliding the menu

  @override
  void initState() {
    super.initState();
    _menuController = AnimationController(
      duration: const Duration(milliseconds: 400), // Slightly faster for a smooth feel
      vsync: this,
    );

    _menuAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
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
    if (_menuController.isDismissed) {
      _menuController.forward();
    } else {
      _menuController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('MFU Dormitory', style: TextStyleComponent.heading),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: _toggleMenu,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_upload),
            onPressed: _importCSV,
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
                _buildAnnouncementSection(),
                const SizedBox(height: 20),
                _buildFeatureGrid(screenWidth),
              ],
            ),
          ),
          _buildOverlayMenu(),
        ],
      ),
    );
  }

  Widget _buildAnnouncementSection() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.yellowAccent,
        borderRadius: BorderRadius.all(Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      width: double.infinity,
      height: 150,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.announcement, size: 40, color: Colors.black54),
          ),
          Expanded(
            child: Text(
              'IMPORTANT ANNOUNCEMENT!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureGrid(double screenWidth) {
    return Expanded(
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: screenWidth < 600 ? 2 : 3, // Responsive layout
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
        ),
        itemCount: _features.length,
        itemBuilder: (context, index) {
          final feature = _features[index];
          return FunctionContainer(
            label: feature['label'],
            icon: feature['icon'],
            onTap: () => widget.onPageSelected(index),
          );
        },
      ),
    );
  }

  Widget _buildOverlayMenu() {
    return SlideTransition(
      position: _menuAnimation,
      child: MenuPage(
        onClose: _toggleMenu, // Close menu with animation
      ),
    );
  }

  Future<void> _importCSV() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Importing CSV data...')),
    );

    try {
      await importCSVToFirestore('userId'); // Make sure 'userId' is provided
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('CSV data imported to Firestore')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to import CSV: $e')),
      );
    }
  }
}

// Feature list for GridView
const List<Map<String, dynamic>> _features = [
  {'label': 'My Room', 'icon': Icons.bed_rounded},
  {'label': 'Map', 'icon': Icons.map},
  {'label': 'Canteen', 'icon': Icons.restaurant},
  {'label': 'Services', 'icon': Icons.build},
  // Add other features as needed
];

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
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              color: Color(0x40000000),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
          borderRadius: BorderRadius.circular(20),
        ),
        width: 150,
        height: 150,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.blueAccent),
            const SizedBox(height: 10),
            Text(label, style: TextStyleComponent.bodyText),
          ],
        ),
      ),
    );
  }
}
