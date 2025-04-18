import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/student_data_provider.dart';
import '../../core/constants/app_theme.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/result_detail_screen.dart';
import '../widgets/result_for_print.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  int _activeAccordionIndex = -1;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadResultData();
    });
  }
  
  Future<void> _loadResultData() async {
    final studentDataProvider = Provider.of<StudentDataProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final studentId = authProvider.currentUser?.studentId;
    
    setState(() {
      _isLoading = true;
    });
    
    await studentDataProvider.fetchResult(studentId ?? "");
    
    setState(() {
      _isLoading = false;
    });
  }

  void _toggleAccordion(int index) {
    setState(() {
      _activeAccordionIndex = _activeAccordionIndex == index ? -1 : index;
    });
  }

  void _handleShowResultDetail(int index, Map<String, dynamic> resultData) {
    final semesterData = {
      'details': resultData['data']['Semester_Data'][index],
      'cgpa': resultData['data']['FINAL_CGPA'][index],
      'basicDetails': resultData['data']['Basic_Details'][index],
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultDetailScreen(data: semesterData),
      ),
    );
  }

  void _handleDownloadPDF(int index, Map<String, dynamic> resultData, BuildContext context) {
    final semesterData = {
      'details': resultData['data']['Semester_Data'][index],
      'cgpa': resultData['data']['FINAL_CGPA'][index],
      'basicDetails': resultData['data']['Basic_Details'][index],
    };

    // Create temporary instance of ResultForPrint just to generate PDF
    final printHelper = ResultForPrint(data: semesterData);
    printHelper.generatePdf(context);
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Text(value),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final studentDataProvider = Provider.of<StudentDataProvider>(context);
    
    final resultData = studentDataProvider.resultData;

    return Scaffold(
      appBar: CustomAppBar(
        title: "Result",
        avatarBackgroundColor: AppTheme.primaryColor.withOpacity(0.2),
      ),
      body: RefreshIndicator(
        onRefresh: _loadResultData,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : studentDataProvider.hasError
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: AppTheme.errorColor,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          studentDataProvider.errorMessage,
                          style: TextStyle(color: AppTheme.errorColor),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _loadResultData,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : resultData == null || resultData['data'] == null || 
                  resultData['data']['Basic_Details'] == null || 
                  resultData['data']['Basic_Details'].isEmpty
                    ? const Center(
                        child: Text('No result data available'),
                      )
                    : ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Result',
                                    style: theme.textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Accordion list of semesters
                                  ...List.generate(
                                    resultData['data']['Basic_Details'].length,
                                    (index) {
                                      final detail = resultData['data']['Basic_Details'][index];
                                      final isActive = _activeAccordionIndex == index;
                                      
                                      return Column(
                                        children: [
                                          if (index > 0) const Divider(height: 1),
                                          InkWell(
                                            onTap: () => _toggleAccordion(index),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 16),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    detail['semester_term_description'] ?? 'Unknown Semester',
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  Icon(
                                                    isActive
                                                        ? Icons.keyboard_arrow_up
                                                        : Icons.keyboard_arrow_down,
                                                    color: theme.primaryColor,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          if (isActive)
                                            Container(
                                              padding: const EdgeInsets.only(
                                                bottom: 16,
                                                left: 16,
                                                right: 16,
                                              ),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  _buildInfoRow(
                                                    'Exam Type:',
                                                    resultData['data']['Semester_Data'][index]['data']['grand_total']['exam_type'] ?? 'N/A',
                                                  ),
                                                  const SizedBox(height: 8),
                                                  _buildInfoRow(
                                                    'SGPA:',
                                                    resultData['data']['Semester_Data'][index]['data']['grand_total']['sgpa']?.toString() ?? 'N/A',
                                                  ),
                                                  const SizedBox(height: 8),
                                                  _buildInfoRow(
                                                    'CGPA:',
                                                    resultData['data']['FINAL_CGPA'][index]?.toString() ?? 'N/A',
                                                  ),
                                                  const SizedBox(height: 16),
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: ElevatedButton(
                                                          onPressed: () => _handleShowResultDetail(index, resultData),
                                                          style: ElevatedButton.styleFrom(
                                                            backgroundColor: AppTheme.primaryColor,
                                                            foregroundColor: Colors.white,
                                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                                          ),
                                                          child: const Text('View Details'),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Expanded(
                                                        child: ElevatedButton(
                                                          onPressed: () => _handleDownloadPDF(index, resultData, context),
                                                          style: ElevatedButton.styleFrom(
                                                            backgroundColor: Colors.green,
                                                            foregroundColor: Colors.white,
                                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                                          ),
                                                          child: const Text('Download PDF'),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
      ),
    );
  }
}