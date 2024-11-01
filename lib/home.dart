import 'package:flutter/material.dart';
import 'canteen.dart';
import 'chat.dart';
import 'map.dart';
import 'noti.dart';
import 'qr.dart';
import 'room.dart';
import 'service.dart';
import 'style.dart'; // Import the style file for consistent styling
import 'menu.dart'; // Import MenuPage for the side menu
import 'csv_import.dart'; // Import the CSV import function

class HomePage extends StatefulWidget {
  final Function(int) onPageSelected; // Function to navigate between pages
  final bool isAdmin; // A flag to check if the user is an admin

  // Constructor to initialize the HomePage with necessary parameters
  const HomePage({Key? key, required this.onPageSelected, this.isAdmin = false}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _menuController; // Controller for menu animation
  late Animation<Offset> _menuAnimation; // Animation to slide the menu

  @override
  void initState() {
    super.initState();
    // Initialize the animation controller with a duration
    _menuController = AnimationController(
      duration: const Duration(milliseconds: 400), // Animation duration
      vsync: this, // Provide the TickerProvider
    );

    // Define the animation for sliding the menu
    _menuAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0), // Start off-screen to the left
      end: Offset.zero, // End at the original position
    ).animate(CurvedAnimation(
      parent: _menuController,
      curve: Curves.easeInOut, // Smooth easing animation
    ));
  }

  @override
  void dispose() {
    _menuController.dispose(); // Clean up the controller
    super.dispose();
  }

  // Function to toggle the menu (open/close)
  void _toggleMenu() {
    if (_menuController.isDismissed) {
      _menuController.forward(); // Open menu
    } else {
      _menuController.reverse(); // Close menu
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width; // Get screen width

    return Scaffold(
      appBar: AppBar(
        title: const Text('MFU Dormitory', style: TextStyleComponent.heading), // App title
        centerTitle: true, // Center the title
        leading: IconButton(
          icon: const Icon(Icons.menu), // Menu button
          onPressed: _toggleMenu, // Call toggle function when pressed
        ),
        actions: widget.isAdmin // Check if user is admin
            ? [
                // Only show CSV upload option if the user is an admin
                IconButton(
                  icon: const Icon(Icons.file_upload), // Upload icon
                  onPressed: _importCSV, // Call CSV import function
                ),
              ]
            : [], // If not admin, show nothing
      ),
      body: Stack(
        children: [
          // Main content area
          Padding(
            padding: const EdgeInsets.all(16.0), // Padding for content
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Align content to start
              children: [
                _buildAnnouncementSection(), // Show announcement section
                const SizedBox(height: 20), // Space between sections
                _buildFeatureGrid(screenWidth), // Show features in grid
              ],
            ),
          ),
          _buildOverlayMenu(), // Overlay for the side menu
        ],
      ),
    );
  }

  // Function to build the announcement section
  Widget _buildAnnouncementSection() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.yellowAccent, // Background color
        borderRadius: BorderRadius.all(Radius.circular(20)), // Rounded corners
        boxShadow: [
          BoxShadow(
            color: Color(0x40000000), // Shadow color
            blurRadius: 4, // How blurry the shadow is
            spreadRadius: 1, // How much the shadow spreads
          ),
        ],
      ),
      width: double.infinity, // Full width
      height: 150, // Fixed height
      child: const Row(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0), // Padding around the icon
            child: Icon(Icons.announcement, size: 40, color: Colors.black54), // Announcement icon
          ),
          Expanded(
            child: Text(
              'IMPORTANT ANNOUNCEMENT!', // Announcement text
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // Text style
            ),
          ),
        ],
      ),
    );
  }

  // Function to build the grid of features
  Widget _buildFeatureGrid(double screenWidth) {
    return Expanded(
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: screenWidth < 600 ? 2 : 3, // Responsive layout based on screen width
          mainAxisSpacing: 20, // Space between rows
          crossAxisSpacing: 20, // Space between columns
        ),
        itemCount: _features.length, // Total number of features
        itemBuilder: (context, index) {
          final feature = _features[index]; // Get feature data
          return FunctionContainer(
            label: feature['label'], // Feature label
            icon: feature['icon'], // Feature icon
            onTap: () {
              // Check if the user is an admin and navigate appropriately
              if (widget.isAdmin) {
                // Admin can access all features
                widget.onPageSelected(index);
              } else {
                // Students can access specific features
                if (index < 4) { // Allow access to first four features (0-3)
                  widget.onPageSelected(index);
                } else {
                  // Students can't access CSV upload feature
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Access Denied: Students cannot access this feature.')),
                  );
                }
              }
            },
          );
        },
      ),
    );
  }

  // Function to build the overlay menu
  Widget _buildOverlayMenu() {
    return SlideTransition(
      position: _menuAnimation, // Animate the menu position
      child: MenuPage(
        onClose: _toggleMenu, // Close menu with animation
      ),
    );
  }

  // Function to import CSV data
  Future<void> _importCSV() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Importing CSV data...')), // Show import message
    );

    try {
      await importCSVToFirestore('userId'); // Call CSV import function with userId
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('CSV data imported to Firestore')), // Success message
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to import CSV: $e')), // Error message
      );
    }
  }
}

// List of features to display in the grid
const List<Map<String, dynamic>> _features = [
  {'label': 'My Room', 'icon': Icons.bed_rounded}, // Feature: My Room
  {'label': 'Map', 'icon': Icons.map}, // Feature: Map
  {'label': 'Canteen', 'icon': Icons.restaurant}, // Feature: Canteen
  {'label': 'Services', 'icon': Icons.build}, // Feature: Services
  // Add other features as needed, e.g. {'label': 'CSV Upload', 'icon': Icons.file_upload},
];

// Widget to represent each feature as a button
class FunctionContainer extends StatelessWidget {
  final String label; // Label for the feature
  final IconData icon; // Icon for the feature
  final VoidCallback onTap; // Callback function when the feature is tapped

  const FunctionContainer({Key? key, required this.label, required this.icon, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Call the onTap function when tapped
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, // Background color
          boxShadow: const [
            BoxShadow(
              color: Color(0x40000000), // Shadow color
              blurRadius: 4, // Blurriness of the shadow
              spreadRadius: 1, // How much the shadow spreads
            ),
          ],
          borderRadius: BorderRadius.circular(20), // Rounded corners
        ),
        width: 150, // Fixed width
        height: 150, // Fixed height
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center the content
          children: [
            Icon(icon, size: 40, color: Colors.blueAccent), // Feature icon
            const SizedBox(height: 10), // Space between icon and text
            Text(label, style: TextStyleComponent.bodyText), // Feature label
          ],
        ),
      ),
    );
  }
}
