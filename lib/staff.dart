import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StaffPage extends StatefulWidget {
  final String userId; // Current user ID
  final String studentId; // Current student ID
  final bool isAdmin; // Flag to determine if the user is an admin

  const StaffPage({
    Key? key,
    required this.userId,
    required this.studentId,
    required this.isAdmin, // Default to false if not provided
  }) : super(key: key);

  @override
  _StaffPageState createState() => _StaffPageState();
}

class _StaffPageState extends State<StaffPage> {
  List<Map<String, dynamic>> staffMembers = [];
  String? dormitory;

  @override
  void initState() {
    super.initState();
    _fetchUserDormitoryAndStaffMembers();
  }

  Future<void> _fetchUserDormitoryAndStaffMembers() async {
    try {
      if (widget.isAdmin) {
        // Fetch dormitory for the admin user from 'admin/userId'
        DocumentSnapshot adminDoc = await FirebaseFirestore.instance
            .collection('admin')
            .doc(widget.userId) // Fetch admin data by userId
            .get();

        if (adminDoc.exists) {
          dormitory = adminDoc['dormitory'];

          // Fetch admin members where dormitory matches
          QuerySnapshot staffSnapshot = await FirebaseFirestore.instance
              .collection('admin')
              .where('dormitory', isEqualTo: dormitory)
              .get();

          List<Map<String, dynamic>> members = staffSnapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();

          setState(() {
            staffMembers = members;
          });
        }
      } else {
        // Fetch the dormitory of the current student from 'user/userId/ID/studentId'
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('user')
            .doc('userId')
            .collection('ID')
            .doc(widget.studentId)
            .get();

        if (userDoc.exists) {
          dormitory = userDoc['dormitory'];

          // Fetch admin members where dormitory matches
          QuerySnapshot staffSnapshot = await FirebaseFirestore.instance
              .collection('admin')
              .where('dormitory', isEqualTo: dormitory)
              .get();

          List<Map<String, dynamic>> members = staffSnapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();

          setState(() {
            staffMembers = members;
          });
        }
      }
    } catch (e) {
      print("Error fetching staff members: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth < 400 ? 1 : (screenWidth < 900 ? 2 : 3);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Staff Members"),
        centerTitle: true,
        backgroundColor: const Color(0xFF7EB4FF),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF7EB4FF), Color.fromARGB(255, 255, 255, 255)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "$dormitory staff",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 255, 255, 255),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount:  1,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 2.0, // Adjust aspect ratio for a more compact look
                ),
                itemCount: staffMembers.length,
                itemBuilder: (context, index) {
                  final member = staffMembers[index];
                  return StaffContainer(
                    member: member,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StaffContainer extends StatelessWidget {
  final Map<String, dynamic> member;

  const StaffContainer({
    super.key,
    required this.member,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0), // Padding around the container
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 300, // Adjust maxWidth to control the width of each container
        ),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 255, 255),
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
              color: Color(0x40000000),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20), // Padding inside the container
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Name: ${member['firstName']} ${member['lastName']}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              "Contact No: ${member['phone'] ?? 'N/A'}",
              style: const TextStyle(fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              "Email: ${member['email'] ?? 'N/A'}",
              style: const TextStyle(fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              "Dormitory: ${member['dormitory'] ?? 'N/A'}",
              style: const TextStyle(fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              "Room: ${member['room'] ?? 'N/A'}",
              style: const TextStyle(fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
