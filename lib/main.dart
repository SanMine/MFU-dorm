import 'package:flutter/material.dart';
import 'home.dart'; // Import your home.dart file

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My App',
      home: HomePage(),  // Call HomePage from home.dart
    );
  }
}