import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';
import 'dart:async';

class ResultForPrint extends StatelessWidget {
  final Map<String, dynamic> data;
  
  const ResultForPrint({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final details = data['details'];
    final cgpa = data['cgpa'];
    final basicDetails = data['basicDetails'];

    if (details == null || basicDetails == null) {
      return const Center(child: Text('No data available'));
    }

    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Institution Header with Logo
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/manit_logo.png',
                    height: 80,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'MAULANA AZAD NATIONAL INSTITUTE OF TECHNOLOGY',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'BHOPAL - 462003 (M.P.), INDIA',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'EXAMINATION RESULT',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            // Student Information Section
            Container(
              padding: const EdgeInsets.all(16),
              child: Table(
                columnWidths: const {
                  0: FlexColumnWidth(1.2),
                  1: FlexColumnWidth(1.5),
                  2: FlexColumnWidth(1.2),
                  3: FlexColumnWidth(1.5),
                },
                border: TableBorder.all(color: Colors.grey.shade300),
                children: [
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Scholar No:', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('${basicDetails['roll_no']}'),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Degree:', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('${basicDetails['degree']}'),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Exam Held In:', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('${details['data']['grand_total']['adjusted_month']} ${details['data']['grand_total']['adjusted_year']}'),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Department:', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('${basicDetails['department_name']}'),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Branch:', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('${basicDetails['program_name']}'),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Semester:', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('${basicDetails['semester_term_description']}'),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Candidate Name:', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('${basicDetails['full_name']}'),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Father / Guardian Name:', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('${basicDetails['father_name']}'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Subject Details Table
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Table(
                    columnWidths: const {
                      0: FlexColumnWidth(1),
                      1: FlexColumnWidth(2),
                      2: FlexColumnWidth(1),
                      3: FlexColumnWidth(1),
                      4: FlexColumnWidth(0.8),
                    },
                    border: TableBorder.all(color: Colors.grey.shade300),
                    children: [
                      // Header row
                      TableRow(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                        ),
                        children: const [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Subject Code', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Subject Name', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Earned Credit', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Grade Point', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Grade', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      
                      // Data rows
                      ...List.generate(
                        details['data']['subjects'].length,
                        (index) {
                          final subject = details['data']['subjects'][index];
                          return TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('${subject['subject_code']}'),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('${subject['subname']}'),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('${subject['credit']}'),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('${subject['gradePoint']}'),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('${subject['grade']}'),
                              ),
                            ],
                          );
                        },
                      ),
                      
                      // Result row
                      TableRow(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                        ),
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Result', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('SGPA: ${details['data']['grand_total']['sgpa']}, CGPA: $cgpa'),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('${details['data']['grand_total']['total_credits']}'),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(''),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('${details['data']['grand_total']['pass_or_fail']}'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Disclaimer Section
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Note: MAULANA AZAD NATIONAL INSTITUTE OF TECHNOLOGY, BHOPAL is not responsible for any inadvertent error that may have crept in the result being published on the website of https://erp.manit.ac.in. The result published on the website are for immediate information to examinees.',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // PDF Generation Method
  Future<void> generatePdf(BuildContext context) async {
    final details = data['details'];
    final cgpa = data['cgpa'];
    final basicDetails = data['basicDetails'];
    
    if (details == null || basicDetails == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No data available for PDF generation')),
      );
      return;
    }

    final pdf = pw.Document();
    
    // Load logo image
    // final logoImage = await imageFromAssetBundle('assets/images/manit_logo.png');
    // final ByteData bytes = await rootBundle.load('assets/images/manit_logo.png');
    // final Uint8List imageBytes = bytes.buffer.asUint8List();

     Uint8List? logoImageBytes;
    try {
      final ByteData data = await rootBundle.load('assets/images/manit_logo.png');
      logoImageBytes = data.buffer.asUint8List();
    } catch (e) {
      // Handle image loading error
      print('Error loading logo image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load logo image')),
      );
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Center(
                child: pw.Text(
                  'Examination Result',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 10),
              
              // Institution Header with Logo
              pw.Center(
                child: pw.Column(
                  children: [
                    logoImageBytes != null
                        ? pw.Image(pw.MemoryImage(logoImageBytes), height: 80)
                        : pw.SizedBox(height: 80), // Placeholder if image fails to load
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'MAULANA AZAD NATIONAL INSTITUTE OF TECHNOLOGY',
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'MAULANA AZAD NATIONAL INSTITUTE OF TECHNOLOGY',
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'BHOPAL - 462003 (M.P.), INDIA',
                      style: const pw.TextStyle(fontSize: 14),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'EXAMINATION RESULT',
                      style: pw.TextStyle(
                        fontSize: 15,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              
              // Student Information
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: {
                  0: const pw.FlexColumnWidth(1.2),
                  1: const pw.FlexColumnWidth(1.5),
                  2: const pw.FlexColumnWidth(1.2),
                  3: const pw.FlexColumnWidth(1.5),
                },
                children: [
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('Scholar No:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('${basicDetails['roll_no']}'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('Degree:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('${basicDetails['degree']}'),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('Exam Held In:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('${details['data']['grand_total']['adjusted_month']} ${details['data']['grand_total']['adjusted_year']}'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('Department:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('${basicDetails['department_name']}'),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('Branch:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('${basicDetails['program_name']}'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('Semester:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('${basicDetails['semester_term_description']}'),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('Candidate Name:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('${basicDetails['full_name']}'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('Father / Guardian Name:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('${basicDetails['father_name']}'),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              
              // Subject Details Table
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: {
                  0: const pw.FlexColumnWidth(1),
                  1: const pw.FlexColumnWidth(2),
                  2: const pw.FlexColumnWidth(1),
                  3: const pw.FlexColumnWidth(1),
                  4: const pw.FlexColumnWidth(0.8),
                },
                children: [
                  // Header row
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('Subject Code', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('Subject Name', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('Earned Credit', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('Grade Point', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('Grade', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                  
                  // Subject rows
                  ...List.generate(
                    details['data']['subjects'].length,
                    (index) {
                      final subject = details['data']['subjects'][index];
                      return pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8.0),
                            child: pw.Text('${subject['subject_code']}'),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8.0),
                            child: pw.Text('${subject['subname']}'),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8.0),
                            child: pw.Text('${subject['credit']}'),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8.0),
                            child: pw.Text('${subject['gradePoint']}'),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8.0),
                            child: pw.Text('${subject['grade']}'),
                          ),
                        ],
                      );
                    },
                  ),
                  
                  // Result row
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('Result', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('SGPA: ${details['data']['grand_total']['sgpa']}, CGPA: $cgpa'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('${details['data']['grand_total']['total_credits']}'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text(''),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('${details['data']['grand_total']['pass_or_fail']}'),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              
              // Disclaimer
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
                ),
                child: pw.Text(
                  'Note: MAULANA AZAD NATIONAL INSTITUTE OF TECHNOLOGY, BHOPAL is not responsible for any inadvertent error that may have crept in the result being published on the website of https://erp.manit.ac.in. The result published on the website are for immediate information to examinees.',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.sharePdf(bytes: await pdf.save(), filename: 'Result-${basicDetails['semester_term_description']}.pdf');
  }
}