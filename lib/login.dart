import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mfu_dorm/signup.dart';

class LoginPage extends StatefulWidget {
  final Function(BuildContext, bool, String, String) onLogin;

  const LoginPage({Key? key, required this.onLogin}) : super(key: key);

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String _message = '';

  // Initializes default values and resets states on widget load
  @override
  void initState() {
    super.initState();
    _isLoading = false;
    _message = '';
  }
  void clearFields() {
    _idController.clear();
    _passwordController.clear();
  }
  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    String inputId = _idController.text.trim();
    String inputPassword = _passwordController.text.trim();
    bool isAdmin = false;
    String userId = '';
    String studentId = '';

    try {
      // Check if inputId is an admin
      DocumentSnapshot adminSnapshot = await FirebaseFirestore.instance
          .collection('admin')
          .doc(inputId)
          .collection('account')
          .doc(inputId)
          .get();

      if (adminSnapshot.exists) {
        String firestorePassword = adminSnapshot.get('password');
        if (inputPassword == firestorePassword) {
          isAdmin = true;
          userId = adminSnapshot.id;
          _showSnackbar('Logged in as Admin');
        } else {
          setState(() {
            _message = 'Invalid ID or password.';
          });
          return;
        }
      } else {
        // Check if inputId is a student
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('user')
            .doc('userId')
            .collection('ID')
            .doc(inputId)
            .collection('accounts')
            .doc(inputId)
            .get();

        if (userSnapshot.exists) {
          String firestorePassword = userSnapshot.get('password');
          if (inputPassword == firestorePassword) {
            isAdmin = false;
            userId = userSnapshot.id;
            studentId = inputId;
            _showSnackbar('Logged in as Student');
          } else {
            setState(() {
              _message = 'Invalid ID or password.';
            });
            return;
          }
        } else {
          setState(() {
            _message = 'User does not exist.';
          });
          return;
        }
      }

      // If login is successful, proceed with the provided callback
      if (_message.isEmpty) {
        widget.onLogin(context, isAdmin, userId, studentId);
      }
    } catch (e) {
      setState(() {
        _message = 'Input ID and password';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Function to show snackbar
  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: Duration(seconds: 2)),
    );
  }

  // UI layout
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
             // colors: [Color(0xFF7EB4FF), Color(0xFFA77AFF)],
             colors: [Color(0xFF7EB4FF), Color.fromARGB(255, 255, 255, 255)],
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
                  Image.asset(
                    'images/M3.png',
                    height: screenHeight * 0.3, // Adjust height as needed
                    width: screenWidth * 0.5,   // Adjust width as needed
                  ),

                  SizedBox(height: screenHeight * 0.01),
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
                  SizedBox(height: screenHeight * 0.05),
                  _buildActionButton(
                    text: _isLoading ? 'Logging in...' : 'Login', 
                    color: const Color.fromARGB(255, 111, 149, 255),
                    onPressed: _isLoading ? null : _login,
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  _buildActionButton(
                    text: _isLoading? 'Sign Up...': 'Sign Up',
                    color: const Color.fromARGB(255, 115, 148, 241),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SignupPage(
                            userId: 'userId',
                            studentId: 'studentId',
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  if (_message.isNotEmpty)
                    Text(
                      _message,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 14,
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
                        color: const Color.fromARGB(255, 97, 121, 255),
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

  // Function for text field widget
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
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: const Color.fromARGB(255, 255, 255, 255),
        contentPadding: EdgeInsets.symmetric(
          vertical: screenHeight * 0.02,
          horizontal: screenWidth * 0.05,
        ),
      ),
    );
  }

  // Function for action button widget
Widget _buildActionButton({
  required String text,
  required Color color,
  required VoidCallback? onPressed,
}) {
  double screenHeight = MediaQuery.of(context).size.height;
  double screenWidth = MediaQuery.of(context).size.width;

  return SizedBox(
    width: screenWidth * 0.5,
    height: screenHeight * 0.07,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15), // Set radius to 15
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: screenHeight * 0.025,
          color: Colors.white, // Change text color to white
        ),
      ),
    ),
  );
}

  }

