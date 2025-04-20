import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:manit/presentation/providers/auth_provider.dart';
import 'package:manit/presentation/widgets/custom_load_widget.dart';
import 'package:provider/provider.dart';

class AddComplaintScreen extends StatefulWidget{

  const AddComplaintScreen({super.key});

  @override
  _AddComplaintScreenState createState()=>_AddComplaintScreenState();
}

class _AddComplaintScreenState extends State<AddComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  Map<String, String?> _errors = {};
  List<File> _selectedFiles = [];

  // Complaint form data
  Map<String, dynamic> _formData = {
    'studentId': '',
    'studentName': '',
    'roomNumber': '',
    'hostelNumber': '',
    'complaintType': '',
    'complaintSubType': '',
    'description': '',
    'dateReported': DateFormat('yyyy-MM-dd').format(DateTime.now()),
    'attachments': [],
  };

  // Complaint types and subtypes
  final List<String> _complaintTypes = [
    "Academic",
    "Hostel",
    "Scholarship",
    "Medical",
    "Department",
    "Sports",
    "Ragging",
  ];

  final Map<String, List<String>> _complaintSubTypes = {
    "Academic": [
      "Course Registration",
      "Grading Issues",
      "Faculty Complaint",
      "Attendance",
      "Examination",
      "Others",
    ],
    "Hostel": [
      "Maintenance",
      "Room Allocation",
      "Cleanliness",
      "Facility Issues",
      "Roommate Issues",
      "Others",
    ],
    "Scholarship": [
      "Disbursement Delay",
      "Amount Discrepancy",
      "Eligibility Issues",
      "Documentation",
      "Others",
    ],
    "Medical": [
      "Health Center Services",
      "Emergency Response",
      "Medical Leave",
      "Insurance Issues",
      "Others",
    ],
    "Department": [
      "Lab Equipment",
      "Classroom Issues",
      "Department Staff",
      "Resources",
      "Others",
    ],
    "Sports": [
      "Equipment",
      "Facility Access",
      "Team Selection",
      "Coaching Issues",
      "Events",
      "Others",
    ],
    "Ragging": [
      "Physical Harassment",
      "Verbal Abuse",
      "Forced Activity",
      "Bullying",
      "Others",
    ],
  };

  @override
  void initState() {
    super.initState();
    _loadStudentInfo();
  }

  Future<void> _loadStudentInfo() async {
    // Load student info from your data provider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final studentId = authProvider.currentUser?.studentId;
    final studentName = authProvider.currentUser?.name;
    setState(() {
      _formData['studentId'] = studentId;
      _formData['studentName'] = studentName;
    });
  }

  Map<String, String?> _validateForm() {
    final Map<String, String?> newErrors = {};
    
    if (_formData['studentId']?.isEmpty ?? true) {
      newErrors['studentId'] = "Student ID is required";
    }
    if (_formData['studentName']?.isEmpty ?? true) {
      newErrors['studentName'] = "Student Name is required";
    }
    if (_formData['roomNumber']?.isEmpty ?? true) {
      newErrors['roomNumber'] = "Room Number is required";
    }
    if (_formData['hostelNumber']?.isEmpty ?? true) {
      newErrors['hostelNumber'] = "Hostel Number is required";
    }
    if (_formData['complaintType']?.isEmpty ?? true) {
      newErrors['complaintType'] = "Complaint Type is required";
    }
    if (_formData['complaintSubType']?.isEmpty ?? true) {
      newErrors['complaintSubType'] = "Complaint SubType is required";
    }
    if (_formData['description']?.isEmpty ?? true) {
      newErrors['description'] = "Description is required";
    }
    if (_formData['dateReported']?.isEmpty ?? true) {
      newErrors['dateReported'] = "Date Reported is required";
    }
    
    return newErrors;
  }

  Future<void> _submitComplaint() async {
    final validationErrors = _validateForm();
    
    setState(() {
      _errors = validationErrors;
    });
    
    if (validationErrors.isEmpty) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        // Get token from secure storage
        final token = await ApiServices.getToken();
        
        // Create form data
        final studentId = _formData['studentId'];
        final url = '${ApiServices.baseUrl}/complaint/post?studentId=$studentId';
        
        // Submit complaint
        final response = await ApiServices.postWithAuth(
          url, 
          _formData,
          token: token,
          attachments: _selectedFiles,
        );
        
        if (response.statusCode == 200 || response.statusCode == 201) {
          // Success message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Complaint Submitted Successfully')),
            );
          }
          
          // Reset form
          _resetForm();
        } else {
          // Error message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${response.reasonPhrase}')),
            );
          }
        }
      } catch (e) {
        // Error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  void _resetForm() {
    setState(() {
      _formData = {
        'studentId': _formData['studentId'],
        'studentName': _formData['studentName'],
        'roomNumber': '',
        'hostelNumber': '',
        'complaintType': '',
        'complaintSubType': '',
        'description': '',
        'dateReported': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        'attachments': [],
      };
      _selectedFiles = [];
    });
  }
  
  Future<void> _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
    );

    if (result != null) {
      setState(() {
        _selectedFiles = result.paths.map((path) => File(path!)).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Complaint'),
        centerTitle: true,
      ),
      body: _isLoading 
        ? const Center(child: CustomLoadWidget())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GridView.count(
                    crossAxisCount: MediaQuery.of(context).size.width > 900 ? 3 : 
                                   MediaQuery.of(context).size.width > 600 ? 2 : 1,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 3.0,
                    children: [
                      // Student ID
                      _buildTextField(
                        label: 'Student ID',
                        name: 'studentId',
                        enabled: false,
                      ),
                      
                      // Student Name
                      _buildTextField(
                        label: 'Student Name',
                        name: 'studentName',
                        enabled: false,
                      ),
                      
                      // Hostel Number
                      _buildDropdownField(
                        label: 'Hostel Number',
                        name: 'hostelNumber',
                        items: List.generate(12, (index) => 'H${index + 1}'),
                        placeholder: 'Select Hostel',
                      ),
                      
                      // Room Number
                      _buildTextField(
                        label: 'Room Number',
                        name: 'roomNumber',
                      ),
                      
                      // Complaint Type
                      _buildDropdownField(
                        label: 'Complaint Type',
                        name: 'complaintType',
                        items: _complaintTypes,
                        placeholder: 'Select a type',
                        onChanged: (value) {
                          setState(() {
                            _formData['complaintType'] = value;
                            _formData['complaintSubType'] = '';
                            if (_errors.containsKey('complaintSubType')) {
                              _errors.remove('complaintSubType');
                            }
                          });
                        },
                      ),
                      
                      // Complaint Sub-Type
                      _buildDropdownField(
                        label: 'Complaint Sub-Type',
                        name: 'complaintSubType',
                        items: _formData['complaintType']?.isNotEmpty ?? false
                            ? _complaintSubTypes[_formData['complaintType']] ?? []
                            : [],
                        placeholder: _formData['complaintType']?.isNotEmpty ?? false
                            ? 'Select a sub-type'
                            : 'Select complaint type first',
                        enabled: _formData['complaintType']?.isNotEmpty ?? false,
                      ),
                      
                      // Description
                      _buildTextField(
                        label: 'Description',
                        name: 'description',
                        maxLines: 3,
                      ),
                      
                      // Date Reported
                      _buildTextField(
                        label: 'Date Reported',
                        name: 'dateReported',
                        enabled: false,
                      ),
                      
                      // Attachments
                      _buildAttachmentsField(),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Submit Button
                  Center(
                    child: SizedBox(
                      width: 300,
                      child: ElevatedButton(
                        onPressed: _submitComplaint,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                            side: const BorderSide(color: Colors.white, width: 2, style: BorderStyle.solid),
                          ),
                        ),
                        child: const Text(
                          'Submit Complaint',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height:24),
                ],
              ),
            ),
          ),
    );
  }
  
  Widget _buildTextField({
    required String label,
    required String name,
    bool enabled = true,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: _formData[name],
          enabled: enabled,
          maxLines: maxLines,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            filled: !enabled,
            fillColor: !enabled ? Colors.grey.shade200 : null,
          ),
          onChanged: (value) {
            setState(() {
              _formData[name] = value;
              if (_errors.containsKey(name)) {
                _errors.remove(name);
              }
            });
          },
        ),
        if (_errors.containsKey(name))
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _errors[name]!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
      ],
    );
  }
  
  Widget _buildDropdownField({
    required String label,
    required String name,
    required List<String> items,
    required String placeholder,
    bool enabled = true,
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _formData[name]?.isNotEmpty ?? false ? _formData[name] : null,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            filled: !enabled,
            fillColor: !enabled ? Colors.grey.shade200 : null,
          ),
          hint: Text(placeholder),
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down),
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: enabled
              ? (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _formData[name] = newValue;
                      if (_errors.containsKey(name)) {
                        _errors.remove(name);
                      }
                      
                      if (onChanged != null) {
                        onChanged(newValue);
                      }
                    });
                  }
                }
              : null,
        ),
        if (_errors.containsKey(name))
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _errors[name]!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
      ],
    );
  }
  
  Widget _buildAttachmentsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Attachments',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _pickFiles,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                const Icon(Icons.attach_file),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _selectedFiles.isEmpty
                        ? 'Select files'
                        : '${_selectedFiles.length} file(s) selected',
                    style: TextStyle(
                      color: _selectedFiles.isEmpty ? Colors.grey.shade700 : Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_selectedFiles.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedFiles.map((file) {
                return Chip(
                  label: Text(
                    file.path.split('/').last,
                    overflow: TextOverflow.ellipsis,
                  ),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () {
                    setState(() {
                      _selectedFiles.remove(file);
                    });
                  },
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}

// API Services Extensions
class ApiServices {
  static String get baseUrl => const String.fromEnvironment('API_BASE_URL', defaultValue: 'https://your-api-url.com');
  
  static Future<String> getToken() async {
    // Implement your token retrieval logic here
    // This is just a placeholder
    // return await secureStorage.read('site_token');
    return "hello";
  }
  
  static Future<http.Response> postWithAuth(
    String url, 
    Map<String, dynamic> data, {
    required String token,
    List<File>? attachments,
  }) async {
    if (attachments != null && attachments.isNotEmpty) {
      // Handle file upload
      var request = http.MultipartRequest('POST', Uri.parse(url));
      
      // Add auth header
      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });
      
      // Add form fields
      data.forEach((key, value) {
        if (key != 'attachments' && value != null) {
          request.fields[key] = value.toString();
        }
      });
      
      // Add files
      for (var file in attachments) {
        var stream = http.ByteStream(file.openRead());
        var length = await file.length();
        
        var multipartFile = http.MultipartFile(
          'attachments',
          stream,
          length,
          filename: file.path.split('/').last,
        );
        
        request.files.add(multipartFile);
      }
      
      var streamedResponse = await request.send();
      return await http.Response.fromStream(streamedResponse);
    } else {
      // Handle regular JSON post
      return await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );
    }
  }
}