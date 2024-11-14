import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
      DocumentSnapshot userSnapshot;
      if (widget.isAdmin) {
        userSnapshot = await FirebaseFirestore.instance
            .collection('admin')
            .doc(widget.userId)
            .get();
      } else {
        userSnapshot = await FirebaseFirestore.instance
            .collection('user')
            .doc('userId')
            .collection('ID')
            .doc(widget.studentId)
            .get();
      }

      if (userSnapshot.exists) {
        final userData = userSnapshot.data() as Map<String, dynamic>?;
        dormitory = userData?['dormitory'];
        roomNumber = userData?['room'];

        QuerySnapshot membersSnapshot;
        if (widget.isAdmin) {
          membersSnapshot = await FirebaseFirestore.instance
              .collection('admin')
              .where('dormitory', isEqualTo: dormitory)
              .where('room', isEqualTo: roomNumber)
              .get();
        } else {
          membersSnapshot = await FirebaseFirestore.instance
              .collection('user')
              .doc('userId')
              .collection('ID')
              .where('dormitory', isEqualTo: dormitory)
              .where('room', isEqualTo: roomNumber)
              .get();
        }

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
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF7EB4FF), Color.fromARGB(255, 255, 255, 255)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppBar(
                    backgroundColor: const Color.fromARGB(0, 255, 236, 179),
                    title: const Text('My Room', style: TextStyle(color: Color.fromARGB(255, 255, 255, 255))),
                    leading: const BackButton(color: Colors.black),
                    centerTitle: true,
                  ), 
                  if (dormitory != null && roomNumber != null) ...[
                    Center(
                      child: Column(
                        children: [
                          Text(
                            dormitory!,
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 255, 255, 255)),
                          ),
                          Text(
                            'Room $roomNumber',
                            style: const TextStyle(fontSize: 18, color: Color.fromARGB(255, 254, 254, 254)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Roommate',
                      style: TextStyle(
                        fontSize: 18, 
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 255, 255, 255),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Remove unnecessary SizedBox or Padding widgets here
                    Expanded(
                      child: GridView.builder(
                        padding: EdgeInsets.zero, // Ensures no padding within the GridView itself
                        // ignore: prefer_const_constructors
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
          ),
          // Positioned(
          //   bottom: 20,
          //   left: 0,
          //   right: 0,
          //   child: Opacity(
          //     opacity: 0.5,
          //     child: Center(
          //       child: Image.asset(
          //         'images/watermark.png',
          //         width: 100,
          //         fit: BoxFit.contain,
          //       ),
          //     ),
          //   ),
          // ),
        ],
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
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF7EB4FF)),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
