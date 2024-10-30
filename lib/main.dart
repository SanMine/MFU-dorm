import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mfu_dorm/signup.dart';
import 'home.dart';
import 'login.dart'; // User LoginPage
import 'qr.dart'; // QR code page
import 'chat.dart'; // Chat page
import 'noti.dart'; // Notifications page

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MFU Dormitory App',
      initialRoute: '/login',
      routes: {
       '/login': (context) => LoginPage(), // Regular user login route
        '/home': (context) => const MainPage(isAdmin: false), // Home page for regular users
      
      },
    );
  }
}

class MainPage extends StatefulWidget {
  final bool isAdmin;

  const MainPage({Key? key, required this.isAdmin}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _initializePages();
  }

  void _initializePages() {
    _pages = [
      HomePage(
        isAdmin: widget.isAdmin,
        onPageSelected: _onPageSelected,
      ),
      QrPage(studentId: ''),
      const ChatPage(),
      const NotiPage(),
    ];
  }

  void _onPageSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onBottomNavigationTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
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
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        onTap: _onBottomNavigationTapped,
      ),
    );
  }
}
