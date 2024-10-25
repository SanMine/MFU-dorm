import 'package:flutter/material.dart';

class MenuPage extends StatelessWidget {
  final VoidCallback onClose; // Callback to close the menu

  const MenuPage({Key? key, required this.onClose}) : super(key: key); // Constructor with onClose

  @override
  Widget build(BuildContext context) {
    // Get the screen width to calculate responsive widths
    double screenWidth = MediaQuery.of(context).size.width;
    double menuWidth = getResponsiveWidth(screenWidth); // Get responsive width for menu

    return Stack(
      children: [
        GestureDetector(
          onTap: onClose, // Close the menu if tapped outside
          child: Container(
            color: const Color.fromARGB(0, 0, 0, 0), // Dim background
          ),
        ),
        Align(
          alignment: Alignment.centerLeft, // Align menu to the left
          child: Container(
            width: menuWidth, // Use responsive width
            height: double.infinity, // Make height responsive
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.white, // Menu background color
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2), // Optional shadow for depth
                  blurRadius: 6,
                  spreadRadius: 3,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0), // Apply padding
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Menu Header
                  Text(
                    'Menu',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Add your menu items here with semantic labels
                  _MenuItem(label: 'My Profile', onTap: () {
                    // Handle profile tap
                  }),
                  _MenuItem(label: 'Staff', onTap: () {
                    // Handle staff tap
                  }),
                  _MenuItem(label: 'Emergency', onTap: () {
                    // Handle emergency tap
                  }),
                  _MenuItem(label: 'Log Out', onTap: () {
                    // Handle logout tap
                  }),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Function to get the responsive width based on screen size
  double getResponsiveWidth(double screenWidth) {
    if (screenWidth > 600) {
      // Large screen
      return screenWidth * 0.75; // 75% of screen width for large screens
    } else if (screenWidth > 400) {
      // Medium screen
      return screenWidth * 0.7; // 70% of screen width for medium screens
    } else {
      // Small screen
      return screenWidth * 0.85; // 85% of screen width for small screens
    }
  }
}

class _MenuItem extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _MenuItem({Key? key, required this.label, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0), // Vertical padding for each menu item
        child: Text(
          label,
          style: const TextStyle(fontSize: 18), // Menu item text style
          semanticsLabel: label, // Add semantic label for accessibility
        ),
      ),
    );
  }
}
