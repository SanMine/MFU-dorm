import 'package:flutter/material.dart';
import 'canteen.dart'; // Import your CanteenPage
import 'chat.dart'; // Import your ChatPage
import 'map.dart'; // Import your MapPage
import 'noti.dart'; // Import your NotificationPage
import 'qr.dart'; // Import your QRPage
import 'room.dart'; // Import your RoomPage
import 'service.dart'; // Import your ServicePage
import 'style.dart'; // Import your style.dart file
import 'menu.dart'; // Import your MenuPage
import 'csv_import.dart'; // Import CSV import function

class HomePage extends StatefulWidget {
  final Function(int) onPageSelected; // Function to navigate
  final bool isAdmin; // Flag to indicate if the user is an admin
  final String studentId;
  final String userId;

  const HomePage({
    Key? key,
    required this.onPageSelected,
    this.isAdmin = false,
    required this.studentId,
    required this.userId
  }) : super(key: key);

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
      duration: const Duration(milliseconds: 400), // Animation duration
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
      // The AppBar with gradient background
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF7EB4FF), Color(0xFF7EB4FF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent, // Set transparency
            elevation: 0,
            title: const Text('MFU Dormitory', style: TextStyleComponent.heading),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.menu),
              onPressed: _toggleMenu,
            ),
            actions: [
              if (widget.isAdmin) // Only show the upload button if the user is an admin
                IconButton(
                  icon: const Icon(Icons.file_upload),
                  onPressed: _importCSV,
                ),
            ],
          ),
        ),
      ),
      
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
          ),
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
      child: const Row(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
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
          crossAxisCount: screenWidth < 600 ? 2 : 3,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
        ),
        itemCount: _features.length,
        itemBuilder: (context, index) {
          final feature = _features[index];
          return FunctionContainer(
            label: feature['label'],
            icon: feature['icon'],
            onTap: () {
              switch (index) {
                case 0:
                  Navigator.push(context, MaterialPageRoute(builder: (context) => RoomPage(studentId: widget.studentId, userId: widget.userId, isAdmin: widget.isAdmin,)));
                  break;
                case 1:
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const MapPage()));
                  break;
                case 2:
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const CanteenPage()));
                  break;
                case 3:
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ServiceRequestPage(studentId: widget.studentId, userId: widget.userId, isAdmin: widget.isAdmin,)));
                  break;
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildOverlayMenu() {
    return SlideTransition(
      position: _menuAnimation,
      child: MenuPage(
        onClose: _toggleMenu,
        userId: widget.userId,
        studentId: widget.studentId,
        isAdmin: widget.isAdmin,
      ),
    );
  }

  Future<void> _importCSV() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please select a CSV file to import.')),
    );

    try {
      String? fileType = await _showCSVTypeSelectionDialog();
      if (fileType == null) return; // User canceled selection

      await importCSVToFirestore(widget.userId, fileType); // Pass userId and selected fileType

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('CSV data imported to Firestore')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to import CSV: $e')),
      );
    }
  }

  Future<String?> _showCSVTypeSelectionDialog() async {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select CSV Type'),
          content: const Text('Please choose the type of CSV file to import:'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'students'),
              child: const Text('Students'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'admins'),
              child: const Text('Admins'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, null), // Cancel
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
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
