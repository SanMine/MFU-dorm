import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mfu_dorm/signup.dart';

class LoginPage extends StatefulWidget {
  final Function(BuildContext, bool, String, String) onLogin; // Updated callback to include userId and studentId

  const LoginPage({Key? key, required this.onLogin}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String _message = '';

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    String inputId = _idController.text.trim();
    String inputPassword = _passwordController.text.trim();
    bool isAdmin = false;
    String userId = ''; // Initialize userId
    String studentId = ''; // Initialize studentId

    try {
      // First check if the inputId corresponds to an admin
      QuerySnapshot adminQuerySnapshot = await FirebaseFirestore.instance
          .collection('adminAccounts')
          .where('id', isEqualTo: inputId)
          .get();

      if (adminQuerySnapshot.docs.isNotEmpty) {
        // Check admin password
        DocumentSnapshot adminSnapshot = adminQuerySnapshot.docs.first;
        String firestorePassword = adminSnapshot.get('password');
        if (inputPassword == firestorePassword) {
          isAdmin = true; // User is admin
          userId = adminSnapshot.id; // Get admin userId
          // Show Snackbar for admin login
          _showSnackbar('Logged in as Admin');
        } else {
          setState(() {
            _message = 'Login unsuccessful. Check your ID and password.';
          });
        }
      } else {
        // If not admin, check the user account
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('user')
            .doc('userId') // Use the inputId directly
            .collection('ID')
            .doc(inputId)
            .collection('accounts')
            .doc('userId') // Use the inputId here as well
            .get();

        if (userSnapshot.exists) {
          String firestorePassword = userSnapshot.get('password');

          if (inputPassword == firestorePassword) {
            // Successful login as student
            isAdmin = false; // User is a student
            userId = inputId; // Get student userId
            studentId = inputId; // Assuming studentId is the same as inputId
            // Show Snackbar for student login
            _showSnackbar('Logged in as Student');
          } else {
            setState(() {
              _message = 'Login unsuccessful. Check your ID and password.';
            });
          }
        } else {
          setState(() {
            _message = 'User does not exist.';
          });
        }
      }

      // Navigate to home page if login was successful
      if (_message.isEmpty) {
        widget.onLogin(context, isAdmin, userId, studentId); // Pass the isAdmin status and IDs to MainPage
      }
    } catch (e) {
      setState(() {
        _message = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Function to show snackbar
  void _showSnackbar(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: Duration(seconds: 2),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
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
                    'MFU\nDormitory',
                    style: TextStyle(
                      fontSize: screenHeight * 0.05,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: screenHeight * 0.1),
                  _buildTextField(
                    controller: _idController,
                    labelText: 'Student/Admin ID',
                    icon: Icons.person,
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  _buildTextField(
                    controller: _passwordController,
                    labelText: 'Password',
                    icon: Icons.lock,
                    obscureText: true,
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  _buildActionButton(
                    text: 'Login',
                    color: const Color(0xFF4B7BFA),
                    onPressed: _isLoading ? null : _login, // Disable if loading
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  _buildActionButton(
                    text: 'Sign Up',
                    color: const Color(0xFF4B7BFA),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SignupPage(
                            // Update this with actual userId and studentId if necessary
                            userId: 'userId', 
                            studentId: 'studentId',
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Text(
                    _message,
                    style: TextStyle(
                      color: _message == 'Login successful!' ? Colors.green : Colors.red,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  TextButton(
                    onPressed: () {
                      // Implement password recovery
                    },
                    child: Text(
                      'Forgot your password?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenHeight * 0.02,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool obscureText = false,
  }) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.black54),
        prefixIcon: Icon(icon, color: Colors.black54),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(
          vertical: screenHeight * 0.02,
          horizontal: screenWidth * 0.05,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      width: screenWidth * 0.6,
      height: screenHeight * 0.07,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: screenHeight * 0.025),
        ),
      ),
    );
  }
}
