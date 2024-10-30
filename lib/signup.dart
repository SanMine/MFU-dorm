import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupPage extends StatefulWidget {
  final String userId; // This is the userId for the current user.
  final String studentId; // This is the student ID to be used for validation.

  SignupPage({Key? key, required this.userId, required this.studentId}) : super(key: key);

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;

 Future<void> _signup() async {
  String studentID = _studentIdController.text.trim();
  String password = _passwordController.text.trim();
  String confirmPassword = _confirmPasswordController.text.trim();

  // Check if password and confirm password match
  if (password != confirmPassword) {
    setState(() {
      _errorMessage = 'Passwords do not match';
    });
    return;
  }

  setState(() => _isLoading = true);

  try {
    // Log the userId and studentID being used
    print("Current User ID: ${widget.userId}");
    print("Student ID being checked: $studentID");

    // Directly check if the student ID document exists
    DocumentSnapshot studentDoc = await FirebaseFirestore.instance
        .collection('user')
        .doc(widget.userId) // Use the current user's ID
        .collection('ID')
        .doc(studentID) // Use studentID as document ID
        .get();

    // Log the result of the document retrieval
    print("Student document exists: ${studentDoc.exists}");

    if (!studentDoc.exists) {
      setState(() {
        _errorMessage = 'Student ID not found. Please check and try again.';
        _isLoading = false;
      });
      return;
    }

    // Now we can safely access the userid field
    String firestoreId = studentDoc.get('userid');
    print("ID from Firestore: $firestoreId");

    // Check if the entered student ID matches the Firestore ID
    if (studentID == firestoreId) {
      // Save the user credentials to Firestore
      await FirebaseFirestore.instance
          .collection('user')
          .doc(widget.userId)
          .collection('ID')
          .doc(studentID)
          .collection('accounts')
          .doc(widget.userId) // Save under the userId
          .set({
        'id': firestoreId, // Saving the user ID from Firestore
        'password': password, // Ensure you hash the password before saving in production
      });

      // Navigate back to login page or main page after signup
      Navigator.pop(context);
    } else {
      setState(() {
        _errorMessage = 'Student ID does not match the provided user ID.';
        _isLoading = false;
      });
    }
  } catch (e) {
    print("Error occurred: ${e.toString()}");
    setState(() {
      _errorMessage = 'An error occurred. Please try again.';
    });
  } finally {
    setState(() => _isLoading = false);
  }
}


  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF7EB4FF), Color(0xFFA77AFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: screenHeight * 0.05),
                Text(
                  'Sign Up',
                  style: TextStyle(
                    fontSize: screenHeight * 0.04,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: screenHeight * 0.05),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      _buildTextField(_studentIdController, 'Student ID', Icons.person),
                      SizedBox(height: screenHeight * 0.02),
                      _buildTextField(_passwordController, 'Password', Icons.lock, obscureText: true),
                      SizedBox(height: screenHeight * 0.02),
                      _buildTextField(_confirmPasswordController, 'Confirm Password', Icons.lock, obscureText: true),
                      SizedBox(height: screenHeight * 0.03),
                      _isLoading
                          ? CircularProgressIndicator()
                          : _buildSignUpButton(screenHeight, screenWidth),
                      if (_errorMessage != null)
                        Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red),
                        ),
                      SizedBox(height: screenHeight * 0.02),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Already have an account? Login',
                          style: TextStyle(color: Colors.white, fontSize: screenHeight * 0.02),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TextField _buildTextField(TextEditingController controller, String label, IconData icon, {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black54),
        prefixIcon: Icon(icon, color: Colors.black54),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  SizedBox _buildSignUpButton(double screenHeight, double screenWidth) {
    return SizedBox(
      width: screenWidth * 0.6,
      height: screenHeight * 0.07,
      child: ElevatedButton(
        onPressed: _signup, // Call the _signup method
        child: Text(
          'Sign Up',
          style: TextStyle(fontSize: screenHeight * 0.025),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFA07AFF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }
}
