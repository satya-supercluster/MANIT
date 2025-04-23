import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/complaint_provider.dart';
import '../providers/auth_provider.dart';

class AddComplaintScreen extends StatefulWidget {

  const AddComplaintScreen({super.key});

  @override
  State<AddComplaintScreen> createState() => _AddComplaintScreenState();
}

class _AddComplaintScreenState extends State<AddComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final Map<String, dynamic> _formData = {
    'roomNumber': '',
    'hostelNumber': '',
    'complaintType': '',
    'complaintSubType': '',
    'description': '',
    'dateReported': DateFormat('yyyy-MM-dd').format(DateTime.now()),
  };
  
  final Map<String, List<String>> _complaintSubTypes = {
    'Academic': [
      'Course Registration',
      'Grading Issues',
      'Faculty Complaint',
      'Attendance',
      'Examination',
      'Others',
    ],
    'Hostel': [
      'Maintenance',
      'Room Allocation',
      'Cleanliness',
      'Facility Issues',
      'Roommate Issues',
      'Others',
    ],
    'Scholarship': [
      'Disbursement Delay',
      'Amount Discrepancy',
      'Eligibility Issues',
      'Documentation',
      'Others',
    ],
    'Medical': [
      'Health Center Services',
      'Emergency Response',
      'Medical Leave',
      'Insurance Issues',
      'Others',
    ],
    'Department': [
      'Lab Equipment',
      'Classroom Issues',
      'Department Staff',
      'Resources',
      'Others',
    ],
    'Sports': [
      'Equipment',
      'Facility Access',
      'Team Selection',
      'Coaching Issues',
      'Events',
      'Others',
    ],
    'Ragging': [
      'Physical Harassment',
      'Verbal Abuse',
      'Forced Activity',
      'Bullying',
      'Others',
    ],
  };

  @override
  void initState() {
    super.initState();
  }
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final complaintProvider = Provider.of<ComplaintProvider>(context, listen: false);
      
      // Add user info to form data
      final completeFormData = {
        ..._formData,
        'studentId': authProvider.currentUser?.studentId,
        'studentName': authProvider.currentUser?.name,
      };
      
      await complaintProvider.addComplaint(Map<String, dynamic>.from(completeFormData));
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Complaint submitted successfully')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit complaint: ${error.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Complaint', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[600],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Student ID field (disabled)
                    TextFormField(
                      initialValue: authProvider.currentUser?.studentId,
                      decoration: const InputDecoration(
                        labelText: 'Student ID',
                        border: OutlineInputBorder(),
                      ),
                      enabled: false,
                    ),
                    const SizedBox(height: 16),
                    
                    // Student Name field (disabled)
                    TextFormField(
                      initialValue: authProvider.currentUser?.name,
                      decoration: const InputDecoration(
                        labelText: 'Student Name',
                        border: OutlineInputBorder(),
                      ),
                      enabled: false,
                    ),
                    const SizedBox(height: 16),
                    
                    // Hostel Number dropdown
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Hostel Number',
                        border: OutlineInputBorder(),
                      ),
                      value: _formData['hostelNumber'] == '' ? null : _formData['hostelNumber'],
                      items: List.generate(12, (index) {
                        final hostel = 'H${index + 1}';
                        return DropdownMenuItem(
                          value: hostel,
                          child: Text(hostel),
                        );
                      }),
                      onChanged: (value) {
                        setState(() {
                          _formData['hostelNumber'] = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a hostel';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Room Number field
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Room Number',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.text,
                      onSaved: (value) {
                        _formData['roomNumber'] = value;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your room number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Complaint Type dropdown
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Complaint Type',
                        border: OutlineInputBorder(),
                      ),
                      value: _formData['complaintType'] == '' ? null : _formData['complaintType'],
                      items: _complaintSubTypes.keys.map((String type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _formData['complaintType'] = value;
                          _formData['complaintSubType'] = '';  // Reset subtype when type changes
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a complaint type';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Complaint Subtype dropdown
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Complaint Sub-Type',
                        border: OutlineInputBorder(),
                      ),
                      value: _formData['complaintSubType'] == '' ? null : _formData['complaintSubType'],
                      items: _formData['complaintType'] == ''
                          ? []
                          : _complaintSubTypes[_formData['complaintType']]!.map((String subType) {
                              return DropdownMenuItem(
                                value: subType,
                                child: Text(subType),
                              );
                            }).toList(),
                      onChanged: _formData['complaintType'] == ''
                          ? null
                          : (value) {
                              setState(() {
                                _formData['complaintSubType'] = value;
                              });
                            },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a complaint sub-type';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Description field
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 4,
                      onSaved: (value) {
                        _formData['description'] = value;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Date Reported field (disabled)
                    TextFormField(
                      initialValue: _formData['dateReported'],
                      decoration: const InputDecoration(
                        labelText: 'Date Reported',
                        border: OutlineInputBorder(),
                      ),
                      enabled: false,
                    ),
                    const SizedBox(height: 24),
                    
                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text(
                          'Submit Complaint',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}