import 'package:flutter/material.dart';
import 'package:manit/data/models/registration_model.dart';
import 'package:manit/presentation/providers/auth_provider.dart';
import 'package:manit/presentation/providers/student_data_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

// Main Semester Registration Screen
class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  int? activeIndex;

  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchRegistrationData();
    });
  }

  void _fetchRegistrationData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final studentDataProvider = Provider.of<StudentDataProvider>(context, listen: false);
    if (authProvider.currentUser != null) {
      final studentuid = authProvider.currentUser!.id;
      final program = authProvider.currentUser!.programMasterId;
      await studentDataProvider.registerCheck(program, studentuid);
    }
  }

  void _toggleAccordion(int index) {
    setState(() {
      activeIndex = activeIndex == index ? null : index;
    });
  }

  void _viewSlip(RegistrationDetails details) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegistrationSlipScreen(registrationDetails: details),
      ),
    );
  }

  void _viewSubjects(List<Subject> subjects) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubjectDetailsScreen(subjects: subjects),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final studentDataProvider = Provider.of<StudentDataProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Semester Registration'),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _fetchRegistrationData(),
        child: ListView(
          children: [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Semester Registration',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  
                  // Register Now Button - Fixed with constrained width
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => print("hello"),
                      child: Text('Register Now', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Status Display
                  if (studentDataProvider.isLoading)
                    Center(child: CircularProgressIndicator())
                  else if (studentDataProvider.registrationData != null && 
                           studentDataProvider.registrationData!.isNotEmpty)
                    _buildAccordionList(studentDataProvider)
                  else
                    Text('No registration data available.'),
                ],
              ),
            ),
          ],
        ),
      )
    );
  }

  Widget _buildAccordionList(StudentDataProvider studentDataProvider) {
    return Column(
      children: studentDataProvider.registrationData!.asMap().entries.map((entry) {
        int index = entry.key;
        RegistrationDetails item = entry.value;
        
        return Card(
          margin: EdgeInsets.only(bottom: 8),
          color: Colors.grey[100],
          child: Column(
            children: [
              // Accordion Header
              ListTile(
                title: Text(
                  'Semester ${item.regSemesterTypeIdCode == '2' ? 'Odd' : 'Even'} - ${item.regSession}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: Icon(
                  activeIndex == index ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down
                ),
                onTap: () => _toggleAccordion(index),
              ),
              
              // Accordion Content
              if (activeIndex == index)
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Registration Details Table
                      Table(
                        border: TableBorder.all(color: Colors.grey[300]!),
                        children: [
                          _buildTableRow('Session:', item.regSession),
                          _buildTableRow('Semester:', item.regSemesterTypeIdCode == '2' ? 'Odd' : 'Even'),
                          _buildTableRow('Current Status:', item.currentStatus),
                          _buildTableRow('Fee Status:', item.feesStatus),
                          _buildTableRow('Credit:', item.credits.toString()),
                        ],
                      ),
                      
                      SizedBox(height: 16),
                      
                      // Action Buttons (View Subjects, View Slip) - FIXED
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green[700],
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () => _viewSubjects(item.subjects),
                                child: Text('Subjects'),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue[700],
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () => _viewSlip(item),
                                child: Text('Slip'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
  
  TableRow _buildTableRow(String label, String value) {
    return TableRow(
      children: [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(value),
        ),
      ],
    );
  }
}

// Registration Slip Screen
class RegistrationSlipScreen extends StatelessWidget {
  final RegistrationDetails registrationDetails;

  RegistrationSlipScreen({required this.registrationDetails});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registration Slip'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Card(
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Header with Logo and Institute Name
                  Image.asset(
                    'assets/logo5.png',
                    height: 80,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'MAULANA AZAD NATIONAL INSTITUTE OF TECHNOLOGY, BHOPAL',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'SEMESTER REGISTRATION SLIP',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  SizedBox(height: 24),
                  
                  // Registration Details Table
                  Table(
                    border: TableBorder.all(color: Colors.grey[300]!),
                    columnWidths: {
                      0: FlexColumnWidth(1.2),
                      1: FlexColumnWidth(1.8),
                      2: FlexColumnWidth(1.2),
                      3: FlexColumnWidth(1.8),
                    },
                    children: [
                      TableRow(
                        children: [
                          _buildTableCell('Name'),
                          _buildTableCell(registrationDetails.fullName),
                          _buildTableCell('Roll No'),
                          _buildTableCell(registrationDetails.rollNo),
                        ],
                      ),
                      TableRow(
                        children: [
                          _buildTableCell('Program'),
                          _buildTableCell(registrationDetails.degreeName),
                          _buildTableCell('Degree'),
                          _buildTableCell(registrationDetails.degree),
                        ],
                      ),
                      TableRow(
                        children: [
                          _buildTableCell('Session'),
                          _buildTableCell(registrationDetails.regSession),
                          _buildTableCell('Semester Type'),
                          _buildTableCell(registrationDetails.regSemesterTypeIdCode == '2' 
                                          ? 'Odd' : 'Even'),
                        ],
                      ),
                      TableRow(
                        children: [
                          _buildTableCell('Status'),
                          _buildTableCell(registrationDetails.currentStatus),
                          _buildTableCell('Fee Status'),
                          _buildTableCell(registrationDetails.feesStatus),
                        ],
                      ),
                      TableRow(
                        children: [
                          _buildTableCell('Registration Date'),
                          _buildTableCell(registrationDetails.creationTime),
                          _buildTableCell('Fee Paid'),
                          _buildTableCell('Paid'),
                        ],
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 32),
                  
                  // Signature Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Student Signature:'),
                            SizedBox(height: 4),
                            Container(
                              height: 1,
                              color: Colors.black,
                              width: 120,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Assistant Registrar (Admission):'),
                            SizedBox(height: 4),
                            Container(
                              height: 1,
                              color: Colors.black,
                              width: 120,
                              alignment: Alignment.centerRight,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Date
                  Text(
                    'Date - ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  
                  SizedBox(height: 32),
                  
                  // Action Buttons - FIXED
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Back'),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              // In a real app, we would implement printing functionality
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Printing document...'))
                              );
                            },
                            child: Text('Print Page'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildTableCell(String text) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Text(text),
    );
  }
}

// Subject Details Screen - FIXED
class SubjectDetailsScreen extends StatelessWidget {
  final List<Subject> subjects;

  SubjectDetailsScreen({required this.subjects});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Subject Details'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Subjects',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                
                // Fixed layout with Expanded
                Expanded(
                  child: subjects.isNotEmpty 
                    ? SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          child: DataTable(
                            columns: [
                              DataColumn(label: Text('Subject Code')),
                              DataColumn(label: Text('Subject Name')),
                              DataColumn(label: Text('Component Name')),
                              DataColumn(label: Text('Semester Code')),
                              DataColumn(label: Text('Subject Teacher')),
                            ],
                            rows: subjects.map((subject) {
                              return DataRow(
                                cells: [
                                  DataCell(Text(subject.subjectCode)),
                                  DataCell(Text(subject.subjectName)),
                                  DataCell(Text(subject.componentName)),
                                  DataCell(Text(subject.semesterCode)),
                                  DataCell(Text(subject.subjectTeacher)),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      )
                    : Center(
                        child: Text('No subjects available.'),
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}