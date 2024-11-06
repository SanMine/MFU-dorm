import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';

class ServiceRequestPage extends StatefulWidget {
  final String userId;
  final String studentId;
  final bool isAdmin;

  ServiceRequestPage({required this.userId, required this.studentId, required this.isAdmin});

  @override
  _ServiceRequestPageState createState() => _ServiceRequestPageState();
}

class _ServiceRequestPageState extends State<ServiceRequestPage> {
  String dormitoryName = '';
  final _formKeyFixService = GlobalKey<FormState>();
  final _formKeyStayOutside = GlobalKey<FormState>();

  // Fix Service Request Variables
  String? materialType, condition;
  int? quantity;
  DateTime? requestTimeFix;

  // Stay Outside Request Variables
  String? reason;
  DateTime? leaveDate, returnDate, requestTimeStay;

  // Show the submitted request for either Fix Service or Stay Outside
  Map<String, dynamic>? submittedFixServiceRequest;
  Map<String, dynamic>? submittedStayOutsideRequest;

  @override
  void initState() {
    super.initState();
    _initializeDormitory();
  }

  Future<void> _initializeDormitory() async {
    try {
      DocumentSnapshot dormitoryDoc;

      if (widget.isAdmin) {
        dormitoryDoc = await FirebaseFirestore.instance
            .collection('admin')
            .doc(widget.userId)
            .get();
      } else {
        dormitoryDoc = await FirebaseFirestore.instance
            .collection('user')
            .doc('userId')
            .collection('ID')
            .doc(widget.studentId)
            .get();
      }

      if (dormitoryDoc.exists) {
        setState(() {
          dormitoryName = dormitoryDoc['dormitory'];
        });
      } else {
        _showSnackbar('Dormitory data not found.');
      }
    } catch (e) {
      _showSnackbar('Error fetching dormitory data: $e');
    }
  }

  // Show the form selection buttons
  Widget _buildFormSelection() {
    return Column(
      children: [
        // Display requested data in a container
        Container(
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (submittedFixServiceRequest != null) ...[
                Text('Fix Service Request Details:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Material Type: ${submittedFixServiceRequest!['materialType']}'),
                Text('Condition: ${submittedFixServiceRequest!['condition']}'),
                Text('Quantity: ${submittedFixServiceRequest!['quantity']}'),
                Text('Request Time: ${submittedFixServiceRequest!['requestTime']}'),
                Text('Status: ${submittedFixServiceRequest!['status']}'),
              ],
              if (submittedStayOutsideRequest != null) ...[
                SizedBox(height: 16),
                Text('Stay Outside Request Details:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Leave Date: ${submittedStayOutsideRequest!['leaveDate']}'),
                Text('Return Date: ${submittedStayOutsideRequest!['returnDate']}'),
                Text('Reason: ${submittedStayOutsideRequest!['reason']}'),
                Text('Request Time: ${submittedStayOutsideRequest!['requestTime']}'),
                Text('Status: ${submittedStayOutsideRequest!['status']}'),
              ],
            ],
          ),
        ),
        Spacer(), // Push the buttons to the bottom
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () => _showRequestForm(true), // Fix Service Form
              child: Text('Fix Service Request'),
            ),
            ElevatedButton(
              onPressed: () => _showRequestForm(false), // Stay Outside Request Form
              child: Text('Stay Outside Request'),
            ),
          ],
        ),
        SizedBox(height: 20),
      ],
    );
  }

  // Show the requested form (Fix Service or Stay Outside)
  Future<void> _showRequestForm(bool isFixService) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isFixService ? 'Fix Service Request' : 'Stay Outside Request'),
          content: isFixService ? _buildFixServiceForm() : _buildStayOutsideForm(),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (isFixService) {
                  _sendFixServiceRequest();
                } else {
                  _sendStayOutsideRequest();
                }
              },
              child: Text('Send'),
            ),
          ],
        );
      },
    );
  }

  // Fix Service Form Widget
  Widget _buildFixServiceForm() {
    return Form(
      key: _formKeyFixService,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            decoration: InputDecoration(labelText: 'Type of Material'),
            onSaved: (value) => materialType = value,
            validator: (value) => value!.isEmpty ? 'Please enter material type' : null,
          ),
          TextFormField(
            decoration: InputDecoration(labelText: 'Condition'),
            onSaved: (value) => condition = value,
            validator: (value) => value!.isEmpty ? 'Please enter condition' : null,
          ),
          TextFormField(
            decoration: InputDecoration(labelText: 'Quantity'),
            keyboardType: TextInputType.number,
            onSaved: (value) => quantity = int.tryParse(value!),
            validator: (value) => value!.isEmpty ? 'Please enter quantity' : null,
          ),
        ],
      ),
    );
  }

  // Stay Outside Form Widget
  Widget _buildStayOutsideForm() {
    return Form(
      key: _formKeyStayOutside,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            decoration: InputDecoration(labelText: 'Leave Date'),
            readOnly: true,
            onTap: () {
              DatePicker.showDatePicker(context,
                  onConfirm: (date) {
                    setState(() {
                      leaveDate = date;
                    });
                  });
            },
            controller: TextEditingController(text: leaveDate != null ? leaveDate.toString().substring(0, 10) : ''),
          ),
          TextFormField(
            decoration: InputDecoration(labelText: 'Return Date'),
            readOnly: true,
            onTap: () {
              DatePicker.showDatePicker(context,
                  onConfirm: (date) {
                    setState(() {
                      returnDate = date;
                    });
                  });
            },
            controller: TextEditingController(text: returnDate != null ? returnDate.toString().substring(0, 10) : ''),
          ),
          TextFormField(
            decoration: InputDecoration(labelText: 'Reason'),
            onSaved: (value) => reason = value,
            validator: (value) => value!.isEmpty ? 'Please enter reason' : null,
          ),
        ],
      ),
    );
  }

  // Send Fix Service Request
  Future<void> _sendFixServiceRequest() async {
    if (_formKeyFixService.currentState!.validate() && dormitoryName.isNotEmpty) {
      _formKeyFixService.currentState!.save();

      requestTimeFix = DateTime.now();
      await FirebaseFirestore.instance
          .collection('service')
          .doc(dormitoryName)
          .collection('form')
          .doc(widget.studentId)
          .set({
        'studentId': widget.studentId,
        'materialType': materialType,
        'condition': condition,
        'quantity': quantity,
        'requestTime': requestTimeFix!.toString(),
        'status': 'pending',
        'userId': widget.userId,
        'dormitory': dormitoryName,
        'room': 'Room Number', // Replace with actual room number if available
      });

      setState(() {
        submittedFixServiceRequest = {
          'studentId': widget.studentId,
          'materialType': materialType,
          'condition': condition,
          'quantity': quantity,
          'requestTime': requestTimeFix!.toString(),
          'dormitory': dormitoryName,
          'room': 'Room Number', // Replace with actual room number if available
        };
      });

      Navigator.pop(context);
      _showSnackbar('Fix Service Request sent successfully.');
    } else {
      _showSnackbar('Dormitory name is empty. Cannot send request.');
    }
  }

  // Send Stay Outside Request
  Future<void> _sendStayOutsideRequest() async {
    if (_formKeyStayOutside.currentState!.validate() && dormitoryName.isNotEmpty) {
      _formKeyStayOutside.currentState!.save();

      requestTimeStay = DateTime.now();
      await FirebaseFirestore.instance
          .collection('service')
          .doc(dormitoryName)
          .collection('form')
          .doc(widget.studentId)
          .set({
        'studentId': widget.studentId,
        'leaveDate': leaveDate,
        'returnDate': returnDate,
        'reason': reason,
        'requestTime': requestTimeStay!.toString(),
        'status': 'pending',
        'userId': widget.userId,
        'dormitory': dormitoryName,
        'room': 'Room Number', // Replace with actual room number if available
      });

      setState(() {
        submittedStayOutsideRequest = {
          'studentId': widget.studentId,
          'leaveDate': leaveDate,
          'returnDate': returnDate,
          'reason': reason,
          'requestTime': requestTimeStay!.toString(),
          'dormitory': dormitoryName,
          'room': 'Room Number', // Replace with actual room number if available
        };
      });

      Navigator.pop(context);
      _showSnackbar('Stay Outside Request sent successfully.');
    } else {
      _showSnackbar('Dormitory name is empty. Cannot send request.');
    }
  }

  // Show Snackbar
  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Service Requests')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: widget.isAdmin ? _buildAdminView() : _buildFormSelection(),
      ),
    );
  }

  // Admin view for service requests
  Widget _buildAdminView() {
    return FutureBuilder(
      future: FirebaseFirestore.instance.collection('service').doc(dormitoryName).collection('form').get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No requests available.'));
        } else {
          var requests = snapshot.data!.docs;
          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              var request = requests[index];
              return ListTile(
                title: Text('Request from ${request['studentId']}'),
                subtitle: Text('Status: ${request['status']}'),
                trailing: request['status'] == 'pending'
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.check),
                            onPressed: () {
                              _approveRequest(request.id);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () {
                              _denyRequest(request.id);
                            },
                          ),
                        ],
                      )
                    : null,
              );
            },
          );
        }
      },
    );
  }

  // Admin approve request
  Future<void> _approveRequest(String requestId) async {
    await FirebaseFirestore.instance.collection('service').doc(dormitoryName).collection('form').doc(requestId).update({'status': 'approved'});
    _showSnackbar('Request approved');
  }

  // Admin deny request
  Future<void> _denyRequest(String requestId) async {
    await FirebaseFirestore.instance.collection('service').doc(dormitoryName).collection('form').doc(requestId).update({'status': 'denied'});
    _showSnackbar('Request denied');
  }
}
