import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart'; // For toast notifications

class UserProfilePage extends StatefulWidget {
  final String userId;
  final String studentId;
  final bool isAdmin;

  const UserProfilePage({
    Key? key,
    required this.studentId,
    required this.isAdmin,
    required this.userId,
  }) : super(key: key);

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  Map<String, dynamic>? userData;
  Map<String, dynamic>? adminData;
  final ImagePicker _picker = ImagePicker();
  String? profileImageUrl;
  bool _isPickingImage = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      setState(() {
        _isLoading = true;
      });
      if (widget.isAdmin) {
        // Fetch admin data
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('admin')
            .doc(widget.userId)
            .get();

        setState(() {
          adminData = snapshot.exists ? snapshot.data() as Map<String, dynamic> : null;
        });
      } else {
        // Fetch user data and profile image
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('user')
            .doc('userId') // Use correct user ID here
            .collection('ID')
            .doc(widget.studentId)
            .get();

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
      _showErrorToast("Error fetching user profile: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _uploadProfileImage() async {
    if (_isPickingImage) return; // Prevent multiple calls
    _isPickingImage = true;

    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    _isPickingImage = false;

    if (pickedFile != null) {
      String fileName = pickedFile.name;

      // Validate file type
      if (!fileName.endsWith('.jpg') && !fileName.endsWith('.jpeg') && !fileName.endsWith('.png')) {
        _showErrorToast("Invalid file type. Please select a JPEG or PNG image.");
        return;
      }

      File file = File(pickedFile.path);

      try {
        // Upload the file to Firebase Storage
        TaskSnapshot snapshot = await FirebaseStorage.instance
            .ref('profile_images/userId/${widget.studentId}/$fileName')
            .putFile(file);

        // Get the download URL of the uploaded image
        String downloadUrl = await snapshot.ref.getDownloadURL();

        // Save the download URL in Firestore under the correct user and student ID
        await FirebaseFirestore.instance
            .collection('user')
            .doc('userId') // Correct usage of widget.userId
            .collection('ID')
            .doc(widget.studentId)
            .collection('accounts')
            .doc(widget.studentId)
            .collection('image')
            .doc(widget.studentId)
            .set({'url': downloadUrl});

        setState(() {
          profileImageUrl = downloadUrl;
        });

        _showSuccessToast("Profile image uploaded successfully!");
      } catch (e) {
        _showErrorToast("Error uploading image: $e");
      }
    } else {
      _showErrorToast("No image selected.");
    }
  }

  void _showErrorToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      toastLength: Toast.LENGTH_LONG,
    );
  }

  void _showSuccessToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      toastLength: Toast.LENGTH_SHORT,
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : widget.isAdmin
              ? _buildAdminProfile()
              : _buildUserProfile(),
    );
  }

  Widget _buildUserProfile() {
    return userData == null
        ? const Center(child: Text("No user data available"))
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
                      backgroundImage: profileImageUrl != null
                          ? NetworkImage(profileImageUrl!)
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
        ? const Center(child: Text("No admin data available"))
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
                      backgroundImage: profileImageUrl != null
                          ? NetworkImage(profileImageUrl!)
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

// Placeholder for ChangePasswordPage class
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
