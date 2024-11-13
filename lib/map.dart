import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class MapPage extends StatelessWidget {
  const MapPage({Key? key}) : super(key: key);

  void _showFullImage(BuildContext context, String imagePath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullImagePage(imagePath: imagePath),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mae Fah Luang University Map"),
        backgroundColor: const Color(0xFF7EB4FF),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                // First Image
                GestureDetector(
                  onTap: () => _showFullImage(context, 'images/mfumap.png'),
                  child: SizedBox(
                    height: 300,
                    width: screenWidth,
                    child: PhotoView(
                      imageProvider: const AssetImage('images/mfumap.png'),
                      minScale: PhotoViewComputedScale.contained,
                      maxScale: PhotoViewComputedScale.covered * 4,
                      backgroundDecoration:
                          const BoxDecoration(color: Colors.transparent),
                    ),
                  ),
                ),
                // Second Image
                GestureDetector(
                  onTap: () => _showFullImage(context, 'images/canteenmap.jpg'),
                  child: SizedBox(
                    height: 300,
                    width: screenWidth,
                    child: PhotoView(
                      imageProvider: const AssetImage('images/canteenmap.jpg'),
                      minScale: PhotoViewComputedScale.contained,
                      maxScale: PhotoViewComputedScale.covered * 4,
                      backgroundDecoration:
                          const BoxDecoration(color: Colors.transparent),
                    ),
                  ),
                ),
                // Third Image
                GestureDetector(
                  onTap: () => _showFullImage(context, 'images/mfu.jpeg'),
                  child: SizedBox(
                    height: 300,
                    width: screenWidth,
                    child: PhotoView(
                      imageProvider: const AssetImage('images/mfu.jpeg'),
                      minScale: PhotoViewComputedScale.contained,
                      maxScale: PhotoViewComputedScale.covered * 4,
                      backgroundDecoration:
                          const BoxDecoration(color: Colors.transparent),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// FullScreen Image Page
class FullImagePage extends StatelessWidget {
  final String imagePath;

  const FullImagePage({Key? key, required this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Full Image"),
        backgroundColor: const Color(0xFF7EB4FF),
      ),
      body: Center(
        child: PhotoView(
          imageProvider: AssetImage(imagePath),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 4,
          backgroundDecoration: const BoxDecoration(color: Colors.black),
        ),
      ),
    );
  }
}
