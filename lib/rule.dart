import 'package:flutter/material.dart';

class RulePage extends StatelessWidget {
  const RulePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dormitory Rules"),
        backgroundColor: const Color(0xFF7EB4FF),
      ),
      body: Container(
        color: const Color(0xFFF0F4FF), // Light background color
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Title Section
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Welcome to the Dormitory. Please adhere to the following rules for a harmonious living environment.",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              // Dormitory Rules Section
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RuleItem(rule: "1. Keep noise to a minimum after 10:00 PM."),
                    RuleItem(rule: "2. Visitors are only allowed during the day. No overnight guests."),
                    RuleItem(rule: "3. Maintain cleanliness in your room and the common areas."),
                    RuleItem(rule: "4. Smoking is strictly prohibited in all areas of the dormitory."),
                    RuleItem(rule: "5. Use of electrical appliances is not allowed without prior approval."),
                    RuleItem(rule: "6. Report any damage to the facilities to the dormitory manager immediately."),
                    RuleItem(rule: "7. Respect the privacy and personal space of others."),
                    RuleItem(rule: "8. No pets are allowed in the dormitory."),
                  ],
                ),
              ),
              
              // Image Section for Posters or Illustrations
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Column(
                  children: [
                    const Text(
                      "Important Notices",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Sample Image for Posters
                    Image.asset(
                      'images/1.png',
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 10),
                    Image.asset(
                      'images/2.png',
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
              ),
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