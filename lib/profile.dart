import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  final String userId;
  final String studentId; // Not used for admin
  final bool isAdmin;

  const ProfilePage({
    Key? key,
    required this.userId,
    required this.studentId,
    required this.isAdmin,
  }) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? userData;
  Map<String, dynamic>? adminData;
  String? profileImageUrl;

  // List of available images in the assets folder
  final List<String> profileImages = [
    'images/1.png',
    'images/2.png',
    'images/3.png',
    'images/4.png',
    'images/5.png',
    'images/6.png',
  ];

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  // Fetch user or admin profile data based on the role
  Future<void> _fetchProfileData() async {
    try {
      if (widget.isAdmin) {
        // Fetch admin data from Firestore
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('admin')
            .doc(widget.userId)
            .get();

        setState(() {
          adminData = snapshot.exists ? snapshot.data() as Map<String, dynamic> : null;
          profileImageUrl = adminData?['image']; // Assume you store the image URL here
        });
      } else {
        // Fetch student data from Firestore
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('user')
            .doc('userId') // Use widget.userId here
            .collection('ID')
            .doc(widget.studentId)
            .get();

        setState(() {
          userData = snapshot.exists ? snapshot.data() as Map<String, dynamic> : null;
          profileImageUrl = userData?['image']; // Assume you store the image URL here
        });
      }
    } catch (e) {
      print("Error fetching profile data: $e");
    }
  }

  void _showImageSelectionDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Select Profile Image"),
        content: SingleChildScrollView(
          scrollDirection: Axis.horizontal, // Enable horizontal scrolling
          child: Row(
            children: profileImages.map((imagePath) {
              return GestureDetector(
                onTap: () {
                  _selectProfileImage(imagePath);
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipOval( // Make image circular
                    child: Image.asset(
                      imagePath,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            child: Text("Cancel"),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
        ],
      );
    },
  );
}


  // Function to handle image selection
  Future<void> _selectProfileImage(String imagePath) async {
  try {
    if (widget.isAdmin) {
      // Update the Firestore document for admin
      await FirebaseFirestore.instance
          .collection('admin')
          .doc(widget.userId) // Correctly reference admin document
          .set({'image': imagePath}, SetOptions(merge: true)); // Save image path in Firestore
    } else {
      // Update the Firestore document for user
      await FirebaseFirestore.instance
          .collection('user')
          .doc('userId') // Use widget.userId directly
          .collection('ID')
          .doc(widget.studentId)
          .set({'image': imagePath}, SetOptions(merge: true)); // Save image path in Firestore
    }

    setState(() {
      profileImageUrl = imagePath; // Update the local image URL
    });
  } catch (e) {
    print("Error updating profile image: $e");
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Profile'),
        leading: const BackButton(color: Colors.black),
      ),
      body: widget.isAdmin ? _buildAdminProfile() : _buildUserProfile(),
    );
  }

  // Build user profile UI
  Widget _buildUserProfile() {
    return userData == null
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: GestureDetector(
                    onTap: _showImageSelectionDialog, // Show image selection dialog
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: profileImageUrl != null
                          ? AssetImage(profileImageUrl!)
                          : null,
                      child: profileImageUrl == null
                          ? const Icon(Icons.person, size: 50)
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '${userData!['firstName']} ${userData!['lastName']}',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Student ID: ${userData!['id']}'),
                const SizedBox(height: 8),
                Text('Phone: ${userData!['phone']}'),
                const SizedBox(height: 8),
                Text('Email: ${userData!['email']}'),
                const SizedBox(height: 8),
                Text('Dormitory: ${userData!['dormitory']}'),
                const SizedBox(height: 8),
                Text('Room: ${userData!['room']}'),
              ],
            ),
          );
  }

  // Build admin profile UI
  Widget _buildAdminProfile() {
    return adminData == null
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: GestureDetector(
                    onTap: _showImageSelectionDialog, // Show image selection dialog
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: profileImageUrl != null
                          ? AssetImage(profileImageUrl!)
                          : null,
                      child: profileImageUrl == null
                          ? const Icon(Icons.person, size: 50)
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '${adminData!['firstName']} ${adminData!['lastName']}',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Admin ID: ${adminData!['id']}'),
                const SizedBox(height: 8),
                Text('Phone: ${adminData!['phone']}'),
                const SizedBox(height: 8),
                Text('Email: ${adminData!['email']}'),
              ],
            ),
          );
  }
}
