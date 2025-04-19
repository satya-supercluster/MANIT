import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:manit/presentation/providers/auth_provider.dart';
import 'package:manit/presentation/providers/student_data_provider.dart';
import 'package:manit/core/constants/app_theme.dart';

class AcademicPerformanceScreen extends StatefulWidget {
  const AcademicPerformanceScreen({super.key});

  @override
  State<AcademicPerformanceScreen> createState() => _AcademicPerformanceScreenState();
}

class _AcademicPerformanceScreenState extends State<AcademicPerformanceScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  TabController? _tabController;
  List<String> _semesters = [];

  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadGradesData();
    });
  }
  
  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _loadGradesData() async {
    try {
      final studentDataProvider = Provider.of<StudentDataProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final studentId = authProvider.currentUser?.studentId;
      
      if (studentId == null) {
        throw Exception("Student ID is null");
      }
      
      setState(() {
        _isLoading = true;
      });
      
      await studentDataProvider.fetchResult(studentId);
      
      if (studentDataProvider.resultData != null) {
        // The key in your data is 'semesters' (plural)
        final semesters = studentDataProvider.resultData!['semesters'] as List<dynamic>? ?? [];
        _semesters = semesters.map((s) => s['term'] as String? ?? '').toList();
        
        _tabController = TabController(
          length: _semesters.length,
          vsync: this,
        );
      }
    } catch (e) {
      print("Error loading grades data: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final studentDataProvider = Provider.of<StudentDataProvider>(context);
    final gradesData = studentDataProvider.resultData;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Academic Performance'),
        bottom: _isLoading || _semesters.isEmpty || _tabController == null
            ? null
            : TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: _semesters.map((sem) => Tab(text: sem)).toList(),
                labelColor: theme.colorScheme.primary,
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(
                    width: 3.0,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadGradesData,
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
                          onPressed: _loadGradesData,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : gradesData == null || _semesters.isEmpty
                    ? const Center(
                        child: Text('No grades data available'),
                      )
                    : TabBarView(
                        controller: _tabController,
                        children: _buildSemesterTabs(gradesData, theme),
                      ),
      ),
    );
  }

  List<Widget> _buildSemesterTabs(Map<String, dynamic> gradesData, ThemeData theme) {
    // The key is 'semesters' (plural) in your data format
    final List<dynamic> semesters = gradesData['semesters'] ?? [];
    
    return semesters.map<Widget>((semester) {
      final courses = semester['courses'] as List<dynamic>? ?? [];
      final semesterGPA = semester['gpa'] ?? 'N/A';
      final cgpa = semester['cgpa'] ?? 'N/A';
      final totalCredits = semester['totalCredits'] ?? 'N/A';
      final examType = semester['examType'] ?? 'N/A';
      final result = semester['result'] ?? 'N/A';
      
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Semester Summary Card
          Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Semester Summary',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Semester GPA',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            semesterGPA.toString(),
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _getGPAColor(double.tryParse(semesterGPA.toString()) ?? 0),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CGPA',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            cgpa.toString(),
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _getGPAColor(double.tryParse(cgpa.toString()) ?? 0),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Credits',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            totalCredits.toString(),
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Exam Type',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            examType.toString(),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Result',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            result.toString(),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: result.toString().toLowerCase() == 'pass' ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Courses',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${courses.length}',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Course List
          ...courses.map((course) {
            final courseCode = course['code'] ?? '';
            final courseName = course['name'] ?? '';
            final courseGrade = course['grade'] ?? '';
            final courseGradePoint = course['gradePoint'] ?? 0;
            final courseCredits = course['credits'] ?? 0;
            
            return Card(
              elevation: 1,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            courseCode,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            courseName,
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                'Credits: $courseCredits',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Grade Point: $courseGradePoint/10',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: _getGradeColor(courseGrade.toString()).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        courseGrade.toString(),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _getGradeColor(courseGrade.toString()),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),

          // Add original details if present
          if (semester['originalDetails'] != null) 
            ..._buildOriginalDetailsSection(semester['originalDetails'], theme),
        ],
      );
    }).toList();
  }

  List<Widget> _buildOriginalDetailsSection(Map<String, dynamic>? originalDetails, ThemeData theme) {
    if (originalDetails == null || 
        originalDetails['details'] == null || 
        originalDetails['details'] is! Map<String, dynamic>) {
      return [];
    }
    
    final details = originalDetails['details'] as Map<String, dynamic>;
    
    if (details['data'] == null || 
        details['data'] is! Map<String, dynamic> || 
        details['data']['subjects'] == null) {
      return [];
    }
    
    final subjects = details['data']['subjects'] as List<dynamic>? ?? [];
    
    if (subjects.isEmpty) {
      return [];
    }
    
    return [
      const SizedBox(height: 24),
      Text(
        'Additional Details',
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 8),
      
      ...subjects.map((subject) {
        if (subject is! Map<String, dynamic>) {
          return const SizedBox.shrink();
        }
        
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            title: Text(
              subject['subname']?.toString() ?? '',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text('Code: ${subject['subject_code']?.toString() ?? ''}'),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Mid-term: ${subject['mid_term_marks']?.toString() ?? 'N/A'}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'End-term: ${subject['end_term_marks']?.toString() ?? 'N/A'}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Total marks: ${subject['total_marks']?.toString() ?? 'N/A'}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Obtained: ${subject['marks_obtained']?.toString() ?? 'N/A'}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _getMarksColor(
                            obtained: subject['marks_obtained'],
                            total: subject['total_marks'],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    ];
  }
  
  Color _getGPAColor(double gpa) {
    if (gpa >= 9.0) return Colors.green.shade700;
    if (gpa >= 8.0) return Colors.green;
    if (gpa >= 7.0) return Colors.blue.shade700;
    if (gpa >= 6.0) return Colors.blue;
    if (gpa >= 5.0) return Colors.orange;
    return Colors.red;
  }
  
  Color _getGradeColor(String grade) {
    final gradeMap = {
      'A+': Colors.green.shade700,
      'A': Colors.green,
      'B+': Colors.blue.shade700,
      'B': Colors.blue,
      'C+': Colors.orange.shade700,
      'C': Colors.orange,
      'D': Colors.deepOrange,
      'F': Colors.red,
    };
    
    return gradeMap[grade] ?? Theme.of(context).colorScheme.onSurface;
  }
  
  Color _getMarksColor({dynamic obtained, dynamic total}) {
    try {
      if (obtained == null || total == null) return Colors.grey;
      
      final obtainedValue = double.tryParse(obtained.toString()) ?? 0;
      final totalValue = double.tryParse(total.toString()) ?? 1;
      
      if (totalValue == 0) return Colors.grey;
      
      final percentage = (obtainedValue / totalValue) * 100;
      
      if (percentage >= 80) return Colors.green;
      if (percentage >= 60) return Colors.blue;
      if (percentage >= 40) return Colors.orange;
      return Colors.red;
    } catch (e) {
      return Colors.grey;
    }
  }
}