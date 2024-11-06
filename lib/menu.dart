import 'package:flutter/material.dart';
import 'package:mfu_dorm/login.dart';
import 'package:mfu_dorm/profile.dart';
import 'package:mfu_dorm/staff.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MenuPage extends StatelessWidget {
  final VoidCallback onClose;
  final String userId;
  final String studentId;
  final bool isAdmin;
  final GlobalKey<LoginPageState> _loginPageKey = GlobalKey<LoginPageState>();

  MenuPage({
    Key? key,
    required this.onClose,
    required this.userId,
    required this.studentId,
    required this.isAdmin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double menuWidth = getResponsiveWidth(screenWidth);

    return Stack(
      children: [
        GestureDetector(
          onTap: onClose,
          child: Container(
            color: const Color.fromARGB(0, 0, 0, 0),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            width: menuWidth,
            height: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 6,
                  spreadRadius: 3,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _MenuItem(
                    label: 'My Profile',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserProfilePage(
                            userId: userId,
                            studentId: studentId,
                          ),
                        ),
                      );
                    },
                  ),
                  _MenuItem(
                    label: 'Staff',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StaffPage(
                            userId: userId,
                            studentId: studentId,
                          ),
                        ),
                      );
                    },
                  ),
                  _MenuItem(
                    label: 'Log Out',
                    onTap: () async {
                      try {
                        await FirebaseAuth.instance.signOut();

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginPage(
                              key: _loginPageKey,
                              onLogin: (context, isAdmin, userId, studentId) {
                                // Callback for successful login
                              },
                            ),
                          ),
                        );

                        _loginPageKey.currentState?.clearFields();
                      } catch (e) {
                        print("Error logging out: $e");
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  double getResponsiveWidth(double screenWidth) {
    if (screenWidth > 600) {
      return screenWidth * 0.75;
    } else if (screenWidth > 400) {
      return screenWidth * 0.7;
    } else {
      return screenWidth * 0.85;
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
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Text(
          label,
          style: const TextStyle(fontSize: 18),
          semanticsLabel: label,
        ),
      ),
    );
  }
}
