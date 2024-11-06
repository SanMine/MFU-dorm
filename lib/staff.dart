import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StaffPage extends StatefulWidget {
  final String userId; // Current user ID
  final String studentId; // Current student ID

  const StaffPage({
    Key? key,
    required this.userId,
    required this.studentId,
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
      // Fetch the dormitory of the current user
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
    } catch (e) {
      print("Error fetching staff members: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine the screen width and set crossAxisCount based on screen size
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth < 400 ? 1 : (screenWidth < 900 ? 2 : 3);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Staff Members"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
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
    Key? key,
    required this.member,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        maxHeight: 150, // Reduced max height for a more compact layout
      ),
      decoration: BoxDecoration(
        color: Colors.orange[300],
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16), // Adjusted padding
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
          const SizedBox(height: 4), // Reduced spacing
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
    );
  }
}
