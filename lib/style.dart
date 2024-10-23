import 'package:flutter/material.dart';

// TextStyleComponent for reusable text styles
class TextStyleComponent {
  static const TextStyle heading = TextStyle(
    fontSize: 24.0,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  static const TextStyle subHeading = TextStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.w600,
    color: Colors.grey,
  );

  static const TextStyle bodyText = TextStyle(
    fontSize: 14.0,
    color: Colors.black87,
  );

  // Add more styles if needed
}

// BackgroundColorComponent for reusable background color settings
class BackgroundColorComponent extends StatelessWidget {
  final Color color;
  final Widget child;

  const BackgroundColorComponent({
    Key? key,
    required this.color,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      child: child,
    );
  }
}



// ColorComponent for reusable color palette
class ColorComponent {
  static const Color primary = Colors.blue;
  static const Color secondary = Colors.green;
  static const Color accent = Colors.orange;

  static const Color background = Colors.white;
  static const Color textPrimary = Colors.black;
  static const Color textSecondary = Colors.grey;
}


