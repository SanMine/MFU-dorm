import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChangePasswordPage extends StatefulWidget {
  final String userId;
  final String studentId;
  final bool isAdmin;

  const ChangePasswordPage({
    Key? key,
    required this.userId,
    required this.studentId,
    required this.isAdmin,
  }) : super(key: key);

  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
        backgroundColor: Color(0xFF7EB4FF),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF7EB4FF), Color.fromARGB(255, 255, 255, 255)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _oldPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Old Password',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your old password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a new password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm New Password',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value != _newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              Center(
                child: ElevatedButton(
                  onPressed: _changePassword,
                  child: const Text('Change Password'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _changePassword() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        // Get the user data to check the old password
        final userDoc = widget.isAdmin
            ? FirebaseFirestore.instance.collection('admin').doc(widget.userId).collection('account').doc(widget.userId)
            : FirebaseFirestore.instance
                 .collection('user')
                  .doc('userId')
                  .collection('ID')
                  .doc(widget.studentId)
                  .collection('accounts')
                  .doc(widget.studentId);
          

        final docSnapshot = await userDoc.get();
        final userData = docSnapshot.data();

        if (userData != null && userData['password'] == _oldPasswordController.text) {
          // If old password matches, update with the new password
          await userDoc.set(
            {'password': _newPasswordController.text},
            SetOptions(merge: true),
          );

          // Show success message and navigate back
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password changed successfully')),
          );
          Navigator.pop(context); // Navigate back to the profile page
        } else {
          // Show error if old password doesn't match
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Old password is incorrect')),
          );
        }
      } catch (e) {
        // Show error message if something went wrong
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error changing password')),
        );
      }
    }
  }
}
