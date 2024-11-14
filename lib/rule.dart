import 'package:flutter/material.dart';

class RulePage extends StatelessWidget {
  const RulePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dormitory Services & Rules",),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        centerTitle: true,
      ),
      body: Container(
        color: const Color.fromARGB(255, 255, 255, 255),
        child: SingleChildScrollView(
          child: Column(
            children: [
               Padding(
                padding: const EdgeInsets.symmetric(vertical: 0.0),
                child: Column(
                  children: [
                     Image.asset(
                      'images/list.png',
                      width: double.infinity,
                      height: 400,
                      fit: BoxFit.fill,
                    ),
                   // const SizedBox(height: 10),
                     Image.asset(
                      'images/yes.png',
                      width: double.infinity,
                      height: 400,
                      fit: BoxFit.fill,
                    ),
                  //  const SizedBox(height: 10),
                    Image.asset(
                      'images/no.png',
                      width: double.infinity,
                      height: 400,
                      fit: BoxFit.fill,
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Dormitory Services",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RuleItem(rule: "24-hour dormitory guardians."),
                    RuleItem(rule: "24-hour security officers."),
                    RuleItem(rule: "24-hour laundry."),
                    RuleItem(rule: "Wi-Fi Internet access."),
                  ],
                ),
              ),
              

              // Rules Section in Paragraph Format
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Dormitory Rules and Regulations",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "All students who reside in the dormitory shall strictly observe the following rules and regulations: Entering and leaving the dormitory.\n\n1.  Entering and leaving the dormitory.\na. The dormitory is open from 06.00 hrs to 22.00 hrs.\nb. If the student returns to the dormitory later than 22.00 hrs,the dormitory supervisor will deliver a warning or punishment in accordance with Student Regulations, unless the student has received prior permission.\nc. Students must present their student ID card to the dormitory security officer before entering the dormitory, which will be returned when the student exits the dormitory. Students must carry their student ID card with them at all times when outside of the dormitory.\nd. The common room television will be turned off at 23.00 hrs on weekdays and at 24.00 hrs on weekends.\n\n2. Visitors are allowed only in the authorized visiting areas, and are not allowed to enter the dormitory.\n\n3. Students are strictly forbidden to cause any disturbance or alarm to others in the vicinity: \na. Gambling of all types is forbidden.\nb. Alcoholic and narcotic substances are strictly forbidden.\nc. Weapons, explosives, and dangerous items of all types are forbidden.\nd. Pets may not be kept in the dormitory.\ne. Excessive noise and disruptive behavior is forbidden.\n\n4. Unauthorized electronic devices and appliances may not be brought into the dormitory, such as: televisions, electric kettles, electric stoves, rice steamers, microwaves, refrigerators, and toasters.\n\n5. Authorized electronic devices/appliances that may be brought into the dormitory include: radios (not stereos), hairdryers, electronic fans, and computers. Other items must be authorized by the Student Dormitory Office. If unauthorized items are found, they will be seized immediately.\n\n6. Dormitory appliances for shared use must not be moved or taken into rooms for personal use.\n\n7. Cooking is forbidden in the dormitory.\n\n8. All dormitory property and items must not be removed or modified in any way.\n\n9. Shoes must be removed before entering the dormitory.\n\n10. If a student receives consent to stay overnight elsewhere or to enter the dormitory after hours, such as in the case that a student returns home or has an extracurricular predicament, the student must return to the dormitory at the time and date specified.\n\n11. Parties and social meetings of all types are forbidden without permission from the university and dormitory supervisor.\n\n12. Students that do not follow dormitory rules and regulations be punished in accordance with the MFU Student Regulations.\n\n",
                  style: TextStyle(fontSize: 16, color: Colors.black),
                  textAlign: TextAlign.justify,
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Punishments",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
               const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RuleItems(rule: "Written warning."),
                    RuleItems(rule: "Put on probation."),
                    RuleItems(rule: "Suspended from all courses for a minimum of one academic year."),
                    RuleItems(rule: "Forced withdrawal from the university."),
                    RuleItems(rule: "Any other sanction according to MFU Regulations."),
                  ],
                ),
              ),
                const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Dormitory Checkout Procedure",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "Before leaving MFU at the end of the semester, students must:\n\n1. Inform the dormitory staff of the exact date of leaving, returning and home contact number seven days before the final examination.\n\n2. Collect all valuables, such as computers and money, which are not to be left in the dormitory.\n\n3. If the student wants to live in the dormitory the next semester, pack up belongings in the cupboard and lock it.\n\n4. If students wish to stay in the dormitory during summer, they have to contact the Student Development Affairs Division and place a booking seven days in advance.\n\n5. Drop off the room keys to dormitory staff; dormitory staff will check the room and the student will have to sign a confirmation saying that they have left the room.\n\n6. Students who stay in the dormitory after the last day of examinations must pay dormitory fees of 50 THB per night per person for F dormitories and 80 THB for all other dormitories. Students must inform the dormitory staff and contact the Student Development Affairs Division to complete the process.\n\n7. Students have to return their ID cards and keys back to the dormitory officer, otherwise, they will incur a fee of 50 THB per person.\n\nNote: For more information - dormitory.mfu.ac.th",
                  style: TextStyle(fontSize: 16, color: Colors.black),
                  textAlign: TextAlign.justify,
                ),
              ),
                const SizedBox(height: 10),
             
            ],
          ),
        ),
      ),
    );
  }
}

class RuleItem extends StatelessWidget {
  final String rule;

  const RuleItem({Key? key, required this.rule}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF7EB4FF), size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                rule,
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RuleItems extends StatelessWidget {
  final String rule;

  const RuleItems({Key? key, required this.rule}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.warning_rounded, color: Color.fromARGB(255, 255, 0, 0), size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                rule,
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}