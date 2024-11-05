import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class UserProfilePage extends StatefulWidget {
  final String userId;
  final String studentId;
  final bool isAdmin; // Add isAdmin parameter

  const UserProfilePage({Key? key, required this.userId, required this.studentId, required this.isAdmin}) : super(key: key);

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  Map<String, dynamic>? userData;
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
      DocumentSnapshot snapshot;

      // Check admin status to decide on the collection path
      if (widget.isAdmin) {
        snapshot = await FirebaseFirestore.instance
            .collection('admin')
            .doc(widget.userId)
            .get();
      } else {
        snapshot = await FirebaseFirestore.instance
            .collection('user')
            .doc('userId')
            .collection('ID')
            .doc(widget.studentId)
            .get();
      }

      if (snapshot.exists) {
        setState(() {
          userData = snapshot.data() as Map<String, dynamic>;
          profileImageUrl = userData?['profileImage']; // Assuming field name
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
            .ref('profile_images/$fileName')
            .putFile(file);

        // Get download URL
        String downloadUrl = await snapshot.ref.getDownloadURL();

        // Update Firestore with the new image URL
        if (widget.isAdmin) {
          await FirebaseFirestore.instance
              .collection('admin')
              .doc(widget.userId)
              .update({'profileImage': downloadUrl});
        } else {
          await FirebaseFirestore.instance
              .collection('user')
              .doc(widget.userId)
              .collection('ID')
              .doc(widget.studentId)
              .update({'profileImage': downloadUrl});
        }

        setState(() {
          profileImageUrl = downloadUrl;
        });
      } catch (e) {
        print("Error uploading image: $e");
      }
    }
  }

  void _navigateToChangePassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChangePasswordPage(userId: widget.userId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('User Profile'),
        leading: const BackButton(color: Colors.black),
      ),
      body: userData == null
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
                        backgroundImage: profileImageUrl != null ? NetworkImage(profileImageUrl!) : null,
                        child: profileImageUrl == null ? const Icon(Icons.person, size: 50) : null,
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
                  
                  const SizedBox(height: 20),
                  ElevatedButton(
                  onPressed: _navigateToChangePassword,
                  child: const Text(
                    'Change Password',
                    style: TextStyle(fontSize: 15, color: Colors.white), // Set font size and color here
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                  ),
                ),
                ],
              ),
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
