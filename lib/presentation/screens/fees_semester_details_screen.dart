import 'package:flutter/material.dart';
import 'package:manit/data/repositories/transform_fee_data_format.dart';
import 'package:manit/presentation/providers/student_data_provider.dart';
import 'package:manit/presentation/widgets/custom_load_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';

class FeesSemesterDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> semesterData;
  final String semesterDesc;

  const FeesSemesterDetailsScreen({
    super.key,
    required this.semesterData,
    required this.semesterDesc,
  });

  @override
  State<FeesSemesterDetailsScreen> createState() => _FeesSemesterDetailsScreenState();
}

class _FeesSemesterDetailsScreenState extends State<FeesSemesterDetailsScreen> {
  bool _isGeneratingPdf = false;
  Uint8List? _logoImage;

  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLogoImage();
    });
  }

  Future<void> _loadLogoImage() async {
    try {
      final ByteData data = await rootBundle.load('assets/images/logo5.png');
      setState(() {
        _logoImage = data.buffer.asUint8List();
      });
    } catch (e) {
      print('Failed to load logo: $e');
    }
  }

  Future<void> _generateAndDownloadPDF() async {
    setState(() {
      _isGeneratingPdf = true;
    });

    try {
      final pdf = pw.Document();
      final user = Provider.of<StudentDataProvider>(context, listen: false).feeData?['studentInfo'] ?? {};
      
      final instituteFeesTotal = widget.semesterData['feeTypes']['6']?['totalPrice'] ?? 0.0;
      final hostelFeesTotal = widget.semesterData['feeTypes']['9']?['totalPrice'] ?? 0.0;
      final totalFees = instituteFeesTotal + hostelFeesTotal;
      
      final currentDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
      
      // Font registration
      final ttf = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
      final font = pw.Font.ttf(ttf);
      final ttfBold = await rootBundle.load("assets/fonts/Roboto-Bold.ttf");
      final fontBold = pw.Font.ttf(ttfBold);

      pw.Widget buildHeader() {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            if (_logoImage != null)
              pw.Image(
                pw.MemoryImage(_logoImage!),
                width: 80,
                height: 80,
              ),
            pw.SizedBox(height: 10),
            pw.Text(
              'MAULANA AZAD NATIONAL INSTITUTE OF TECHNOLOGY',
              style: pw.TextStyle(
                font: fontBold,
                fontSize: 16,
              ),
              textAlign: pw.TextAlign.center,
            ),
            pw.Text(
              'BHOPAL - 462003 (M.P.), INDIA',
              style: pw.TextStyle(
                font: font,
                fontSize: 12,
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              'SEMESTER FEES SLIP',
              style: pw.TextStyle(
                font: fontBold,
                fontSize: 14,
                decoration: pw.TextDecoration.underline,
              ),
            ),
            pw.SizedBox(height: 10),
          ],
        );
      }
      
      pw.Widget buildStudentDetailsTable() {
        return pw.Table(
          border: pw.TableBorder.all(),
          children: [
            pw.TableRow(
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.all(5),
                  color: PdfColors.grey200,
                  child: pw.Text('Field', style: pw.TextStyle(font: fontBold)),
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.all(5),
                  color: PdfColors.grey200,
                  child: pw.Text('Details', style: pw.TextStyle(font: fontBold)),
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.all(5),
                  color: PdfColors.grey200,
                  child: pw.Text('Field', style: pw.TextStyle(font: fontBold)),
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.all(5),
                  color: PdfColors.grey200,
                  child: pw.Text('Details', style: pw.TextStyle(font: fontBold)),
                ),
              ],
            ),
            pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text('Name of Student:', style: pw.TextStyle(font: font)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text(user['full_name'] ?? '', style: pw.TextStyle(font: font)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text('Scholar Number:', style: pw.TextStyle(font: font)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text(user['roll_no'] ?? '', style: pw.TextStyle(font: font)),
                ),
              ],
            ),
            pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text('Admission Year:', style: pw.TextStyle(font: font)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text(user['start_session'] ?? '', style: pw.TextStyle(font: font)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text('Branch Programme:', style: pw.TextStyle(font: font)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text(user['code'] ?? '', style: pw.TextStyle(font: font)),
                ),
              ],
            ),
            pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text('Semester:', style: pw.TextStyle(font: font)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text(widget.semesterDesc, style: pw.TextStyle(font: font)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text('Branch:', style: pw.TextStyle(font: font)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text(user['program_name'] ?? '', style: pw.TextStyle(font: font)),
                ),
              ],
            ),
          ],
        );
      }

      pw.Widget buildFeesSummaryTable() {
        final instituteFees = widget.semesterData['feeTypes']['6']?['fees'] ?? [];
        final hostelFees = widget.semesterData['feeTypes']['9']?['fees'] ?? [];
        
        // Determine how many rows we need (max of institute and hostel fees)
        final maxRows = instituteFees.length > hostelFees.length ? 
                        instituteFees.length : hostelFees.length;
        
        final rows = <pw.TableRow>[];
        
        // Header row
        rows.add(
          pw.TableRow(
            decoration: const pw.BoxDecoration(color: PdfColors.grey200),
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text('Institute Fees', style: pw.TextStyle(font: fontBold)),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text('Amount', style: pw.TextStyle(font: fontBold)),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text('Hostel Fees', style: pw.TextStyle(font: fontBold)),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text('Amount', style: pw.TextStyle(font: fontBold)),
              ),
            ],
          ),
        );
        
        // Fee rows
        for (int i = 0; i < maxRows; i++) {
          rows.add(
            pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text(
                    i < instituteFees.length ? instituteFees[i]['fees_sub_head_title'] ?? '' : '',
                    style: pw.TextStyle(font: font),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text(
                    i < instituteFees.length ? formatCurrency(instituteFees[i]['fees_price']) : '',
                    style: pw.TextStyle(font: font),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text(
                    i < hostelFees.length ? hostelFees[i]['fees_sub_head_title'] ?? '' : '',
                    style: pw.TextStyle(font: font),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text(
                    i < hostelFees.length ? formatCurrency(hostelFees[i]['fees_price']) : '',
                    style: pw.TextStyle(font: font),
                  ),
                ),
              ],
            ),
          );
        }
        
        // Total rows
        rows.add(
          pw.TableRow(
            decoration: const pw.BoxDecoration(color: PdfColors.grey200),
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text('Total Institute Fees', style: pw.TextStyle(font: fontBold)),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text(formatCurrency(instituteFeesTotal), style: pw.TextStyle(font: fontBold)),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text('Total Hostel Fees', style: pw.TextStyle(font: fontBold)),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text(formatCurrency(hostelFeesTotal), style: pw.TextStyle(font: fontBold)),
              ),
            ],
          ),
        );
        
        // Grand total row
        rows.add(
          pw.TableRow(
            decoration: const pw.BoxDecoration(color: PdfColors.grey300),
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.all(5),
                alignment: pw.Alignment.centerLeft,
                child: pw.Text('Grand Total Fees', style: pw.TextStyle(font: fontBold)),
                constraints: const pw.BoxConstraints.expand(width: 3 * 100), // Adjust width as needed
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text(formatCurrency(totalFees), style: pw.TextStyle(font: fontBold)),
              ),
            ],
          ),
        );
        
        return pw.Table(
          border: pw.TableBorder.all(),
          children: rows,
        );
      }

      pw.Widget buildFooter() {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.SizedBox(height: 20),
            pw.Center(
              child: pw.Text(
                'This is an electronically generated receipt, hence does not require signature.',
                style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 10,
                ),
                textAlign: pw.TextAlign.center,
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Row(
              children: [
                pw.Text('Date:', style: pw.TextStyle(font: fontBold)),
                pw.SizedBox(width: 10),
                pw.Text(currentDate, style: pw.TextStyle(font: font)),
              ],
            ),
          ],
        );
      }
      
      // Build the PDF document
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(20),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                buildHeader(),
                pw.SizedBox(height: 20),
                buildStudentDetailsTable(),
                pw.SizedBox(height: 20),
                buildFeesSummaryTable(),
                pw.SizedBox(height: 20),
                buildFooter(),
              ],
            );
          },
        ),
      );
      
      // Save the PDF file
      final output = await getTemporaryDirectory();
      final file = File('${output.path}/semester_payment_slip.pdf');
      await file.writeAsBytes(await pdf.save());
      
      // Open the PDF file
      await OpenFile.open(file.path);
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating PDF: $e')),
      );
      print('Error generating PDF: $e');
    } finally {
      setState(() {
        _isGeneratingPdf = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final instituteFeesTotal = widget.semesterData['feeTypes']['6']?['totalPrice'] ?? 0.0;
    final hostelFeesTotal = widget.semesterData['feeTypes']['9']?['totalPrice'] ?? 0.0;
    final totalFees = instituteFeesTotal + hostelFeesTotal;
    
    final user = Provider.of<StudentDataProvider>(context).feeData?['studentInfo'] ?? {};
    final currentDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Semester Fees Slip'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _isGeneratingPdf ? null : _generateAndDownloadPDF,
            tooltip: 'Download PDF',
          ),
        ],
      ),
      body: _isGeneratingPdf
          ? CustomLoadWidget()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  _buildStudentDetailsTable(user),
                  const SizedBox(height: 20),
                  _buildFeesSummaryTable(),
                  const SizedBox(height: 20),
                  _buildFooter(currentDate),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Image.asset(
          'assets/images/logo5.png',
          height: 80,
        ),
        const SizedBox(height: 8),
        const Text(
          'MAULANA AZAD NATIONAL INSTITUTE OF TECHNOLOGY',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const Text(
          'BHOPAL - 462003 (M.P.), INDIA',
          style: TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            'SEMESTER FEES SLIP',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStudentDetailsTable(Map<dynamic, dynamic> user) {
    return Table(
      border: TableBorder.all(color: Colors.grey.shade300),
      columnWidths: const {
        0: FlexColumnWidth(1.2),
        1: FlexColumnWidth(1.5),
        2: FlexColumnWidth(1.2),
        3: FlexColumnWidth(1.5),
      },
      children: [
        // Header row with styling
        TableRow(
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
          ),
          children: const [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Field', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Details', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Field', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Details', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        // Name and Scholar Number
        TableRow(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Name of Student:'),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(user['full_name'] ?? ''),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Scholar Number:'),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(user['roll_no'] ?? ''),
            ),
          ],
        ),
        // Admission Year and Branch Programme
        TableRow(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Admission Year:'),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(user['start_session'] ?? ''),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Branch Programme:'),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(user['code'] ?? ''),
            ),
          ],
        ),
        // Semester and Branch
        TableRow(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Semester:'),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(widget.semesterDesc),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Branch:'),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(user['program_name'] ?? ''),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeesSummaryTable() {
    final instituteFees = widget.semesterData['feeTypes']['6']?['fees'] ?? [];
    final hostelFees = widget.semesterData['feeTypes']['9']?['fees'] ?? [];
    
    final instituteFeesTotal = widget.semesterData['feeTypes']['6']?['totalPrice'] ?? 0.0;
    final hostelFeesTotal = widget.semesterData['feeTypes']['9']?['totalPrice'] ?? 0.0;
    final totalFees = instituteFeesTotal + hostelFeesTotal;
    
    // Determine the maximum number of rows needed
    final maxRows = instituteFees.length > hostelFees.length ? instituteFees.length : hostelFees.length;
    
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Table header
            Table(
              border: TableBorder.all(color: Colors.grey.shade300),
              columnWidths: const {
                0: FlexColumnWidth(1.5),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1.5),
                3: FlexColumnWidth(1),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                  ),
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Institute Fees', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Hostel Fees', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
            
            // Table body
            Table(
              border: TableBorder.all(color: Colors.grey.shade300),
              columnWidths: const {
                0: FlexColumnWidth(1.5),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1.5),
                3: FlexColumnWidth(1),
              },
              children: List.generate(maxRows, (index) {
                return TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        index < instituteFees.length ? instituteFees[index]['fees_sub_head_title'] ?? '' : '',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        index < instituteFees.length ? formatCurrency(instituteFees[index]['fees_price']) : '',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        index < hostelFees.length ? hostelFees[index]['fees_sub_head_title'] ?? '' : '',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        index < hostelFees.length ? formatCurrency(hostelFees[index]['fees_price']) : '',
                      ),
                    ),
                  ],
                );
              }),
            ),
            
            // Totals table
            Table(
              border: TableBorder.all(color: Colors.grey.shade300),
              columnWidths: const {
                0: FlexColumnWidth(1.5),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1.5),
                3: FlexColumnWidth(1),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                  ),
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Total Institute Fees', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        formatCurrency(instituteFeesTotal),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Total Hostel Fees', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        formatCurrency(hostelFeesTotal),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            // Grand total
            Table(
              border: TableBorder.all(color: Colors.grey.shade300),
              columnWidths: const {
                0: FlexColumnWidth(1.5),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1.5),
                3: FlexColumnWidth(1),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                  ),
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Grand Total Fees',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(''),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(''),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        formatCurrency(totalFees),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(String currentDate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'This is an electronically generated receipt, hence does not require signature.',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Text(
              'Date:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Text(currentDate),
          ],
        ),
      ],
    );
  }
}