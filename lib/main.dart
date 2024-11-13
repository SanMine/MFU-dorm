import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mfu_dorm/scanner.dart';
import 'home.dart';
import 'login.dart'; // User LoginPage
import 'qr.dart'; // QR code page
import 'chat.dart'; // Chat page
import 'noti.dart'; // Notifications page
import 'map.dart';

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
      theme: ThemeData(
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color.fromARGB(255, 0, 179, 255), // Ensures color application
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(onLogin: _onLogin), // Pass login callback
        '/home': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          final bool isAdmin = args['isAdmin'];
          final String userId = args['userId'];
          final String studentId = args['studentId'];
        

          return MainPage(isAdmin: isAdmin, userId: userId, studentId: studentId,);
        },
      },
    );
  }

  void _onLogin(BuildContext context, bool isAdmin, String userId, String studentId) {
    Navigator.pushReplacementNamed(context, '/home', arguments: {
      'isAdmin': isAdmin,
      'userId': userId,
      'studentId': studentId,
    });
  }
}

class MainPage extends StatefulWidget {
  final bool isAdmin;
  final String userId; // Add userId
  final String studentId; // Add studentId
  

  const MainPage({Key? key, required this.isAdmin, required this.userId, required this.studentId,}) : super(key: key);

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
        onPageSelected: _onPageSelected, studentId: widget.studentId, userId: widget.userId,
      ),
      if (widget.isAdmin) const ScannerPage(), // Show ScannerPage for admin
      if (!widget.isAdmin) QrPage(userId: widget.userId, studentId: widget.studentId, ), // Show QR code for students
      ChatPage(isAdmin: widget.isAdmin, userId: widget.userId , studentId: widget.studentId,),
      NotiPage(isAdmin: widget.isAdmin, userId: widget.userId , studentId: widget.studentId,),
      
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
        backgroundColor: const Color.fromARGB(255, 0, 179, 255),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded, color: Colors.blue),
            label: 'Home',
          ),
          if (widget.isAdmin) // Show scanner for admin
            const BottomNavigationBarItem(
              icon: Icon(Icons.qr_code_scanner_rounded, color: Colors.green),
              label: 'QR Scanner',
            ),
          if (!widget.isAdmin) // Show QR Code button for students
            const BottomNavigationBarItem(
              icon: Icon(Icons.qr_code_rounded, color: Colors.green),
              label: 'QR Code',
            ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.chat_rounded, color: Colors.orange),
            label: 'Chat',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.announcement_rounded, color: Colors.red),
            label: 'Announcement',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          _onBottomNavigationTapped(index);
        },
      ),
    );
  }
}