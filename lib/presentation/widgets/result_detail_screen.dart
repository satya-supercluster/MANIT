import 'package:flutter/material.dart';
import 'result_for_print.dart';

class ResultDetailScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const ResultDetailScreen({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final details = data['details'];
    final basicDetails = data['basicDetails'];

    if (details == null || basicDetails == null) {
      return Scaffold(
        appBar: AppBar(
        title: Text(
          "Result Details",
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
        body: const Center(child: Text('No data available')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          basicDetails['semester_term_description'],
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
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