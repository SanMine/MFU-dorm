import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'download.dart'; // Import the download functionality

class ServiceRequestPage extends StatefulWidget {
  final String userId;
  final String studentId;
  final bool isAdmin;

  ServiceRequestPage({
    required this.userId,
    required this.studentId,
    required this.isAdmin,
  });

  @override
  _ServiceRequestPageState createState() => _ServiceRequestPageState();
}

class _ServiceRequestPageState extends State<ServiceRequestPage> {
  late String dormitoryName;
  late String roomNumber;
  final _formKey = GlobalKey<FormState>();
  CollectionReference? _serviceCollection;
  bool _isLoading = true;

  // Variables to hold selected dates
  DateTime? _leaveDate;
  DateTime? _returnDate;

  // Toggle button state
  bool isFixServiceRequest = true;

  @override
  void initState() {
    super.initState();
    _initializeDormitory();
  }

  // Initialize dormitory information
  Future<void> _initializeDormitory() async {
    try {
      DocumentSnapshot dormitoryDoc;

      // Fetch dormitory data based on user type (admin or student)
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
          dormitoryName = dormitoryDoc['dormitory'] ?? 'Unknown';
          roomNumber = dormitoryDoc['room'] ?? 'Unknown';
          _serviceCollection = FirebaseFirestore.instance
              .collection('services')
              .doc(dormitoryName)
              .collection('requests');
        });
      }
    } catch (e) {
      _showSnackbar('Error fetching dormitory data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Fetch service requests based on user type
  Future<List<QueryDocumentSnapshot>> _fetchRequests() async {
    if (_serviceCollection == null) return [];

    try {
      QuerySnapshot snapshot;
      // Admin sees all requests
      if (widget.isAdmin) {
        snapshot = await _serviceCollection!.get();
      } else {
        // Students see only their requests
        snapshot = await _serviceCollection!.where('studentId', isEqualTo: widget.studentId).get();
      }
      return snapshot.docs;
    } catch (e) {
      _showSnackbar('Error fetching requests: $e');
      return [];
    }
  }

  // Format date to 'dd/MM/yyyy'
  String _formatDate(String dateString) {
    try {
      DateTime dateTime = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy').format(dateTime);
    } catch (e) {
      return 'Invalid Date';
    }
  }

  // Format time to 'HH:mm'
  String _formatTime(String timeString) {
    try {
      DateTime dateTime = DateTime.parse(timeString);
      return DateFormat('HH:mm').format(dateTime);
    } catch (e) {
      return 'Invalid Time';
    }
  }

  // Build individual request cards to display
  Widget _buildRequestCard(QueryDocumentSnapshot request) {
    final requestData = request.data() as Map<String, dynamic>;
    final requestType = requestData['type'] ?? 'Unknown';
    final status = requestData['status'] ?? 'Pending';

    Color statusColor;

    // Determine color based on status
    switch (status) {
      case 'Approved':
        statusColor = Colors.green;
        break;
      case 'Denied':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.blue;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$requestType', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                // Delete button for both student and admin
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteRequest(request.id),
                ),
              ],
            ),
            ..._buildRequestDetails(requestData, requestType),
            Text('Request by: ${requestData['studentId'] ?? 'N/A'}'),
            Text('Dormitory: ${requestData['dormitory'] ?? dormitoryName}'),
            Text('Room: ${requestData['room'] ?? roomNumber}'),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text('Status: ', style: TextStyle(color: Colors.black)),
                Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
              ],
            ),
            if (widget.isAdmin) ...[
              // Approve and Decline buttons for admin
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => _updateRequestStatus(request.id, 'Approved'),
                    child: const Text('Approve', style: TextStyle(color: Colors.green)),
                  ),
                  TextButton(
                    onPressed: () => _updateRequestStatus(request.id, 'Denied'),
                    child: const Text('Decline', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Update request status (Approve/Decline)
  Future<void> _updateRequestStatus(String requestId, String newStatus) async {
    try {
      await _serviceCollection!.doc(requestId).update({'status': newStatus});
      _showSnackbar('Request $newStatus successfully.');
    } catch (e) {
      _showSnackbar('Error updating request status: $e');
    }
  }

  // Build request details based on request type
  List<Widget> _buildRequestDetails(Map<String, dynamic> requestData, String requestType) {
    if (requestType == 'Fix Service Request') {
      return [
        Text('Material Type: ${requestData['materialType'] ?? 'N/A'}'),
        Text('Condition: ${requestData['condition'] ?? 'N/A'}'),
        Text('Quantity: ${requestData['quantity'] ?? 'N/A'}'),
        Text('Request Time: ${_formatTime(requestData['requestTime'] ?? 'N/A')}'),
        Text('Request Date: ${_formatDate(requestData['requestDate'] ?? 'N/A')}'),
      ];
    } else if (requestType == 'Stay Outside Request') {
      return [
        Text('Leave Date: ${_formatDate(requestData['leaveDate'] ?? 'N/A')}'),
        Text('Return Date: ${_formatDate(requestData['returnDate'] ?? 'N/A')}'),
        Text('Reason: ${requestData['reason'] ?? 'N/A'}'),
        Text('Request Time: ${_formatTime(requestData['requestTime'] ?? 'N/A')}'),
        Text('Request Date: ${_formatDate(requestData['requestDate'] ?? 'N/A')}'),
      ];
    }
    return [];
  }

  // Show a snackbar with a message
  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  // Delete a specific request
  Future<void> _deleteRequest(String requestId) async {
    try {
      await _serviceCollection!.doc(requestId).delete();
      _showSnackbar('Request deleted successfully.');
    } catch (e) {
      _showSnackbar('Error deleting request: $e');
    }
  }

  // Show the request form based on the request type
  void _showRequestForm() {
    // Create variables to hold the form input values
    String materialType = '';
    String condition = '';
    int quantity = 0;
    String reason = '';

    // Show a dialog for the request form
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isFixServiceRequest ? 'Fix Service Request' : 'Stay Outside Request'),
          content: SizedBox(
            width: 400, // Adjust the width for better aesthetics
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isFixServiceRequest) ...[
                      // Fields for Fix Service Request
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Material Type'),
                        validator: (value) => value!.isEmpty ? 'Please enter material type' : null,
                        onSaved: (value) {
                          materialType = value!;
                        },
                      ),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Condition'),
                        validator: (value) => value!.isEmpty ? 'Please enter condition' : null,
                        onSaved: (value) {
                          condition = value!;
                        },
                      ),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Quantity'),
                        validator: (value) => value!.isEmpty ? 'Please enter quantity' : null,
                        onSaved: (value) {
                          quantity = int.parse(value!);
                        },
                      ),
                    ] else ...[
                      // Fields for Stay Outside Request
                      GestureDetector(
                        onTap: _selectLeaveDate,
                        child: AbsorbPointer(
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Leave Date',
                              hintText: _leaveDate != null ? _formatDate(_leaveDate!.toIso8601String()) : 'Select Leave Date',
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _selectReturnDate,
                        child: AbsorbPointer(
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Return Date',
                              hintText: _returnDate != null ? _formatDate(_returnDate!.toIso8601String()) : 'Select Return Date',
                            ),
                          ),
                        ),
                      ),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Reason'),
                        validator: (value) => value!.isEmpty ? 'Please enter reason' : null,
                        onSaved: (value) {
                          reason = value!;
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();

                  // Create a request map to save to Firestore
                  Map<String, dynamic> requestData = {
                    'type': isFixServiceRequest ? 'Fix Service Request' : 'Stay Outside Request',
                    'studentId': widget.studentId,
                    'dormitory': dormitoryName,
                    'room': roomNumber,
                    'status': 'Pending', // Initial status
                    'requestTime': DateTime.now().toIso8601String(), // Current time
                    'requestDate': DateTime.now().toLocal().toString(), // Current date
                  };

                  // Add specific fields based on request type
                  if (isFixServiceRequest) {
                    requestData.addAll({
                      'materialType': materialType,
                      'condition': condition,
                      'quantity': quantity,
                    });
                  } else {
                    requestData.addAll({
                      'leaveDate': _leaveDate != null ? _leaveDate!.toIso8601String() : null,
                      'returnDate': _returnDate != null ? _returnDate!.toIso8601String() : null,
                      'reason': reason,
                    });
                  }

                  // Save the request in Firestore
                  _serviceCollection!.add(requestData).then((value) {
                    _showSnackbar('Request submitted successfully.');
                    Navigator.of(context).pop(); // Close the dialog
                  }).catchError((error) {
                    _showSnackbar('Error submitting request: $error');
                  });
                }
              },
              child: const Text('Submit'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cancel and close the dialog
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Function to select leave date
  Future<void> _selectLeaveDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _leaveDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _leaveDate) {
      setState(() {
        _leaveDate = pickedDate;
      });
    }
  }

  // Function to select return date
  Future<void> _selectReturnDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _returnDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _returnDate) {
      setState(() {
        _returnDate = pickedDate;
      });
    }
  }

  // Build the form selection layout
  Widget _buildFormSelection() {
    return Expanded(
      child: FutureBuilder<List<QueryDocumentSnapshot>>(
        future: _fetchRequests(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No requests available.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return _buildRequestCard(snapshot.data![index]);
              },
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF7EB4FF), Color(0xFF7EB4FF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent, // Set transparency
            elevation: 0,
            title: const Text('Service request'),
            centerTitle: true,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF7EB4FF), Color.fromARGB(255, 255, 255, 255)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildFormSelection(),
                    const SizedBox(height: 20),
                    // Move the buttons here
                    if (!widget.isAdmin) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                         ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isFixServiceRequest = true;
                          });
                          _showRequestForm(); // Show the form
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10), 
                          ),
                        ),
                        child: const Text('Fix Service Request', style: TextStyle(color: Colors.white)),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isFixServiceRequest = false;
                          });
                          _showRequestForm(); // Show the form
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10), // Set the radius here
                          ),
                        ),
                        child: const Text('Stay Outside Request', style: TextStyle(color: Colors.white)),
                      ),

                        ],
                      ),
                    ],
                    const SizedBox(height: 20),
                    if (widget.isAdmin) ...[
                      ElevatedButton(
                        onPressed: () async {
                          await downloadRequests(); // Call the download function
                        },
                       style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10), // Set the radius here
                          ),
                        ),
                        child: const Text('Download The Request', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }

  // Download requests as CSV
  Future<void> downloadRequests() async {
  // Call showDownloadDialog to allow user to select file type to download
  await showDownloadDialog(context, _serviceCollection!);
}

}
