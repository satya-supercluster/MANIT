import 'package:flutter/material.dart';
import 'package:manit/presentation/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../providers/student_data_provider.dart';
import '../../core/constants/app_theme.dart';

class GradesScreen extends StatefulWidget {
  const GradesScreen({super.key});

  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  TabController? _tabController;
  List<String> _semesters = [];
  
  @override
  void initState() {
    super.initState();
    _loadGradesData();
  }
  
  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _loadGradesData() async {
    final studentDataProvider = Provider.of<StudentDataProvider>(context, listen: false);
    
    setState(() {
      _isLoading = true;
    });
    
    await studentDataProvider.fetchGrades();
    
    // Initialize tabs after data is loaded
    if (studentDataProvider.gradesData != null) {
      final semesters = studentDataProvider.gradesData!['semesters'] as List<dynamic>? ?? [];
      _semesters = semesters.map((s) => s['term'] as String? ?? '').toList();
      
      _tabController = TabController(
        length: _semesters.length,
        vsync: this,
      );
    }
    
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final studentDataProvider = Provider.of<StudentDataProvider>(context);
    final gradesData = studentDataProvider.gradesData;

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
    final List<dynamic> semesters = gradesData['semesters'] ?? [];
    
    return semesters.map((semester) {
      final courses = semester['courses'] as List<dynamic>? ?? [];
      final semesterGPA = semester['gpa'] ?? 'N/A';
      
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
                            'Courses',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${courses.length}',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
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
                          Text(
                            'Credits: $courseCredits',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
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
        ],
      );
    }).toList();
  }
  
  Color _getGPAColor(double gpa) {
    if (gpa >= 3.5) return Colors.green;
    if (gpa >= 2.5) return Colors.blue;
    if (gpa >= 1.5) return Colors.orange;
    return Colors.red;
  }
  
  Color _getGradeColor(String grade) {
    final theme = Theme.of(context);
    const gradeMap = {
      'A+': Colors.green,
      'A': Colors.green,
      'A-': Colors.green,
      'B+': Colors.blue,
      'B': Colors.blue,
      'B-': Colors.blue,
      'C+': Colors.orange,
      'C': Colors.orange,
      'C-': Colors.orange,
      'D+': Colors.deepOrange,
      'D': Colors.deepOrange,
      'F': Colors.red,
    };
    
    return gradeMap[grade] ?? theme.colorScheme.onSurface;
  }
}