import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'result_for_print.dart';
import '../../core/constants/app_theme.dart';

class ResultDetailScreen extends StatelessWidget {
  final Map<String, dynamic> data;
  
  const ResultDetailScreen({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final details = data['details'];
    final cgpa = data['cgpa'];
    final basicDetails = data['basicDetails'];

    if (details == null || basicDetails == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Result Detail')),
        body: const Center(child: Text('No data available')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Examination Result'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ResultForPrint(data: data),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _downloadPDF(context),
        icon: const Icon(Icons.download),
        label: const Text('Save PDF'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _downloadPDF(BuildContext context) async {
    // Create temporary instance of ResultForPrint just to generate PDF
    final printHelper = ResultForPrint(data: data);
    await printHelper.generatePdf(context);
  }
}