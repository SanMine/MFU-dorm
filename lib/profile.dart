import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class UserProfilePage extends StatefulWidget {
  final String userId;
  final String studentId;
  final bool isAdmin; // Add this flag to check if the user is an admin

  const UserProfilePage({
    Key? key,
    required this.userId,
    required this.studentId,
    required this.isAdmin,
  }) : super(key: key);

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  Map<String, dynamic>? userData;
  Map<String, dynamic>? adminData; // Variable to store admin data
  final ImagePicker _picker = ImagePicker();
  String? profileImageUrl;
  bool _isPickingImage = false; // Flag to prevent multiple picker calls

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      // If user is an admin, fetch from the admin collection
      if (widget.isAdmin) {
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('admin')
            .doc(widget.userId) // Fetch from admin collection using userId
            .get();

        setState(() {
          adminData = snapshot.exists ? snapshot.data() as Map<String, dynamic> : null;
        });
      } else {
        // Fetch user data if the user is not an admin
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('user')
            .doc('userId')
            .collection('ID')
            .doc(widget.studentId)
            .get();

        // Fetch profile image URL from the image sub-collection
        DocumentSnapshot imageSnapshot = await FirebaseFirestore.instance
            .collection('user')
            .doc('userId')
            .collection('ID')
            .doc(widget.studentId)
            .collection('accounts')
            .doc(widget.studentId)
            .collection('image')
            .doc(widget.studentId)
            .get();

        setState(() {
          userData = snapshot.exists ? snapshot.data() as Map<String, dynamic> : null;
          profileImageUrl = imageSnapshot.exists ? imageSnapshot['url'] as String : null;
        });
      }
    } catch (e) {
      print("Error fetching user profile: $e");
    }
  }

  Future<void> _uploadProfileImage() async {
    if (_isPickingImage) return; // Prevent multiple calls
    _isPickingImage = true;

    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    _isPickingImage = false; // Reset the flag after picking

    if (pickedFile != null) {
      String fileName = pickedFile.name; // Use the name property
      File file = File(pickedFile.path);

      try {
        // Upload to Firebase Storage
        TaskSnapshot snapshot = await FirebaseStorage.instance
            .ref('profile_images/${widget.userId}/${widget.studentId}/$fileName')
            .putFile(file);

        // Get download URL
        String downloadUrl = await snapshot.ref.getDownloadURL();

        // Update Firestore with the new image URL in the image sub-collection
        await FirebaseFirestore.instance
            .collection('user')
            .doc(widget.userId)
            .collection('ID')
            .doc(widget.studentId)
            .collection('accounts')
            .doc(widget.studentId)
            .collection('image')
            .doc(widget.studentId)
            .set({'url': downloadUrl});

        // Update profileImageUrl to reflect the new image
        setState(() {
          profileImageUrl = downloadUrl;
        });
      } catch (e) {
        print("Error uploading image: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('User Profile'),
        leading: const BackButton(color: Colors.black),
      ),
      body: widget.isAdmin
          ? _buildAdminProfile() // If the user is an admin, show admin profile
          : _buildUserProfile(), // Otherwise, show regular user profile
    );
  }

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
                    onTap: _uploadProfileImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage:
                          profileImageUrl != null ? NetworkImage(profileImageUrl!) : null,
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
                Text('Student Id: ${userData!['id']}'),
                const SizedBox(height: 8),
                Text('Phone: ${userData!['phone']}'),
                const SizedBox(height: 8),
                Text('Email: ${userData!['email']}'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _navigateToChangePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                  ),
                  child: const Text(
                    'Change Password',
                    style: TextStyle(fontSize: 15, color: Colors.white),
                  ),
                ),
              ],
            ),
          );
  }

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
                    onTap: _uploadProfileImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage:
                          profileImageUrl != null ? NetworkImage(profileImageUrl!) : null,
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
                Text('Admin Id: ${adminData!['id']}'),
                const SizedBox(height: 8),
                Text('Phone: ${adminData!['phone']}'),
                const SizedBox(height: 8),
                Text('Email: ${adminData!['email']}'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _navigateToChangePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                  ),
                  child: const Text(
                    'Change Password',
                    style: TextStyle(fontSize: 15, color: Colors.white),
                  ),
                ),
              ],
            ),
          );
  }

  void _navigateToChangePassword() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangePasswordPage(userId: widget.userId),
      ),
    );
  }
}

// Placeholder for ChangePasswordPage
class ChangePasswordPage extends StatelessWidget {
  final String userId;

  const ChangePasswordPage({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Change Password"),
      ),
      body: const Center(
        child: Text("Change Password Functionality Goes Here"),
      ),
    );
  }
}
