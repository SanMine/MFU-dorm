import 'dart:async'; // Import for Timer
import 'package:flutter/material.dart';
import 'package:mfu_dorm/rule.dart';
import 'canteen.dart'; // Import your CanteenPage
import 'csv_import.dart'; // Import CSV import function
import 'map.dart'; // Import your MapPage
import 'menu.dart'; // Import your MenuPage
import 'room.dart'; // Import your RoomPage
import 'service.dart'; // Import your ServicePage
import 'style.dart'; // Import your style.dart file

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
    required this.userId,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _menuController; // Animation controller for menu
  late Animation<Offset> _menuAnimation; // Animation for sliding the menu
  late PageController _pageController; // Controller for the PageView
  int _currentIndex = 0; // Current image index
  Timer? _timer; // Timer for automatic image switching

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

    _pageController = PageController(); // Initialize PageController
    _startImageTimer(); // Start the timer for auto-swiping images
  }

  @override
  void dispose() {
    _menuController.dispose();
    _pageController.dispose(); // Dispose the PageController
    _timer?.cancel(); // Cancel the timer
    super.dispose();
  }

  void _toggleMenu() {
    if (_menuController.isDismissed) {
      _menuController.forward();
    } else {
      _menuController.reverse();
    }
  }

  void _startImageTimer() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_currentIndex < 2) {
        _currentIndex++;
      } else {
        _currentIndex = 0;
      }
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
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
            
            backgroundColor: const Color.fromARGB(255, 255, 255, 255), // Set transparency
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
    Positioned.fill(
      child: ColorFiltered(
        colorFilter: ColorFilter.mode(
          Colors.black.withOpacity(0.0), 
          BlendMode.srcOver, 
        ),
        child: Image.asset(
          'images/dormbg.jpg',
          fit: BoxFit.cover, 
        ),
      ),
    ),

        
          Padding(
            padding: const EdgeInsets.all(0.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                _buildImageCarousel(), // Image Carousel Section
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

 Widget _buildImageCarousel() {
  return SizedBox(
    height: 200, // Set a fixed height for the carousel container
    child: PageView(
      controller: _pageController,
      children: [
        // Ensure the images fit the container fully while maintaining their aspect ratio
        Image.asset(
          'images/a1.jpg',
          fit: BoxFit.fill, // BoxFit.fill will make the image fully fit in the container
        ),
        Image.asset(
          'images/a2.jpg',
          fit: BoxFit.fill,
        ),
        Image.asset(
          'images/a3.png',
          fit: BoxFit.fill,
        ),
      ],
    ),
  );
}



  Widget _buildFeatureGrid(double screenWidth) {
    return Expanded(
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: screenWidth < 600 ? 3 : 3,
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
                  Navigator.push(context, MaterialPageRoute(builder: (context) => CanteenPage()));
                  break;
                case 3:
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ServiceRequestPage(studentId: widget.studentId, userId: widget.userId, isAdmin: widget.isAdmin,)));
                  break;
                case 4: 
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const RulePage()));
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
  {'label': 'Rules', 'icon': Icons.rule},
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
            Icon(icon, size: 40, color: const Color.fromARGB(255, 0, 119, 255)),
            const SizedBox(height: 10),
            Text(label, style: TextStyleComponent.bodyText),
          ],
        ),
      ),
    );
  }
}
