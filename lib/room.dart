import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mfu_dorm/member.dart';

class RoomPage extends StatefulWidget {
  final String studentId;
  final String userId;
  final bool isAdmin;

  const RoomPage({
    Key? key,
    required this.studentId,
    required this.userId,
    required this.isAdmin,
  }) : super(key: key);

  @override
  _RoomPageState createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  List<Map<String, dynamic>> roomMembers = [];
  String? dormitory;
  String? roomNumber;

  @override
  void initState() {
    super.initState();
    _fetchUserDetailsAndRoomMembers();
  }

  Future<void> _fetchUserDetailsAndRoomMembers() async {
    try {
      // Fetch user details to determine dormitory and room based on admin status
      DocumentSnapshot userSnapshot;
      if (widget.isAdmin) {
        userSnapshot = await FirebaseFirestore.instance
            .collection('admin')
            .doc(widget.userId)
            .get(); // Fetch user details from admin collection if admin
      } else {
        userSnapshot = await FirebaseFirestore.instance
            .collection('user')
            .doc('userId')
            .collection('ID')
            .doc(widget.studentId)
            .get(); // Fetch user details from user collection if student
      }

      if (userSnapshot.exists) {
        final userData = userSnapshot.data() as Map<String, dynamic>?;
        dormitory = userData?['dormitory'];
        roomNumber = userData?['room'];

        // Fetch room members based on admin status
        QuerySnapshot membersSnapshot;
        if (widget.isAdmin) {
          // Fetch from admin collection if user is an admin
          membersSnapshot = await FirebaseFirestore.instance
              .collection('admin')
              .where('dormitory', isEqualTo: dormitory)
              .where('room', isEqualTo: roomNumber)
              .get();
        } else {
          // Fetch from user collection if user is a student
          membersSnapshot = await FirebaseFirestore.instance
              .collection('user')
              .doc('userId')
              .collection('ID')
              .where('dormitory', isEqualTo: dormitory)
              .where('room', isEqualTo: roomNumber)
              .get();
        }

        // Map the fetched members to a list
        List<Map<String, dynamic>> members = membersSnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();

        setState(() {
          roomMembers = members;
        });
      }
    } catch (e) {
      print("Error fetching room members: $e");
    }
  }

  void _showMemberDetails(Map<String, dynamic> member) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MemberDetailPage(member: member),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber[100],
        title: const Text('Room Details'),
        leading: const BackButton(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (dormitory != null && roomNumber != null) ...[
              Center(
                child: Column(
                  children: [
                    Text(
                      dormitory!,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Room $roomNumber',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Members',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: roomMembers.length,
                  itemBuilder: (context, index) {
                    final member = roomMembers[index];
                    return MemberContainer(
                      name: member['firstName'] ?? 'Unknown',
                      onTap: () => _showMemberDetails(member),
                    );
                  },
                ),
              ),
            ] else ...[
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        ),
      ),
    );
  }
}

class MemberContainer extends StatelessWidget {
  final String name;
  final VoidCallback onTap;

  const MemberContainer({
    Key? key,
    required this.name,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
