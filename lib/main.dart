import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'home.dart'; // Import your home.dart file
import 'canteen.dart'; // Import additional pages
import 'chat.dart';
import 'map.dart';
import 'noti.dart';
import 'qr.dart';
import 'room.dart';
import 'service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await Firebase.initializeApp(); // Initializes Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My App',
      home: MainPage(), // Use MainPage for navigation
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0; // Track the selected index
  late List<Widget> _pages; // Declare the pages variable

  @override
  void initState() {
    super.initState();
    // Initialize the pages list here
    _pages = [
      HomePage(onPageSelected: (index) {
        // Update the selected index based on the HomePage navigation
        setState(() {
          _selectedIndex = index;
        });
      }),
      const QRPage(),
      const ChatPage(),
      const NotiPage(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update the selected index
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // Display the selected page
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.blue),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code, color: Colors.green),
            label: 'QR Code',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat, color: Colors.orange),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications, color: Colors.red),
            label: 'Notifications',
          ),
        ],
        currentIndex: _selectedIndex, // Set the current index
        selectedItemColor: Colors.black, // Color for selected item
        unselectedItemColor: Colors.grey, // Color for unselected items
        onTap: _onItemTapped, // Handle tap event
      ),
    );
  }
}
