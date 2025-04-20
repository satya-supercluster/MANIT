import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/student_data_provider.dart';
import '../../core/constants/app_theme.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  bool _isLoading = true;
  bool _showCompletedCourses = false;
  
  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEnrollmentData();
    });
  }
  
  Future<void> _loadEnrollmentData() async {
    final studentDataProvider = Provider.of<StudentDataProvider>(context, listen: false);
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      await studentDataProvider.fetchEnrollmentData();
    } catch (e) {
      // Error will be displayed through the provider
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
    final theme = Theme.of(context);
    final studentDataProvider = Provider.of<StudentDataProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Course Enrollment',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
              _showEnrollNewCourseDialog();
            },
            tooltip: 'Enroll in a new course',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : studentDataProvider.hasError
              ? _buildErrorView(studentDataProvider.errorMessage)
              : _buildEnrollmentContent(studentDataProvider),
    );
  }
  
  Widget _buildEnrollmentContent(StudentDataProvider provider) {
    final theme = Theme.of(context);
    final enrollmentData = provider.enrollmentData;
    
    if (enrollmentData == null || 
        (enrollmentData['currentCourses']?.isEmpty == true && 
         enrollmentData['completedCourses']?.isEmpty == true)) {
      return _buildEmptyView();
    }
    
    final currentCourses = enrollmentData['currentCourses'] ?? [];
    final completedCourses = enrollmentData['completedCourses'] ?? [];
    
    return RefreshIndicator(
      onRefresh: _loadEnrollmentData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Enrollment status card
            Card(
              color: AppTheme.primaryColor.withOpacity(0.1),
              margin: const EdgeInsets.only(bottom: 24),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.verified,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Enrollment Status',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatusItem(
                            icon: Icons.school,
                            title: 'Current Credits',
                            value: '${enrollmentData['currentCredits'] ?? 0}',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatusItem(
                            icon: Icons.library_books,
                            title: 'Current Courses',
                            value: '${currentCourses.length}',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatusItem(
                            icon: Icons.schedule,
                            title: 'Academic Term',
                            value: enrollmentData['term'] ?? 'Spring 2025',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatusItem(
                            icon: Icons.star,
                            title: 'Academic Standing',
                            value: enrollmentData['standing'] ?? 'Good',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // Current courses section
            Text(
              'Current Courses',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            currentCourses.isEmpty
                ? const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No current courses enrolled'),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: currentCourses.length,
                    itemBuilder: (context, index) {
                      final course = currentCourses[index];
                      return _buildCourseCard(course, isCurrentCourse: true);
                    },
                  ),
            
            // Completed courses section - toggle
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Completed Courses',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(_showCompletedCourses ? Icons.expand_less : Icons.expand_more),
                    onPressed: () {
                      setState(() {
                        _showCompletedCourses = !_showCompletedCourses;
                      });
                    },
                  ),
                ],
              ),
            ),
            
            if (_showCompletedCourses)
              completedCourses.isEmpty
                  ? const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('No completed courses'),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: completedCourses.length,
                      itemBuilder: (context, index) {
                        final course = completedCourses[index];
                        return _buildCourseCard(course, isCurrentCourse: false);
                      },
                    ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 4),
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  Widget _buildCourseCard(Map<String, dynamic> course, {required bool isCurrentCourse}) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course['courseCode'] ?? 'Unknown',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        course['courseName'] ?? 'Unknown Course',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (!isCurrentCourse && course['grade'] != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.successColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      course['grade'],
                      style: TextStyle(
                        color: AppTheme.successColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Course details
            Row(
              children: [
                Icon(
                  Icons.person,
                  size: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                const SizedBox(width: 8),
                Text(
                  'Instructor: ${course['instructor'] ?? 'TBA'}',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.credit_card,
                  size: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                const SizedBox(width: 8),
                Text(
                  'Credits: ${course['credits'] ?? '0'}',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
            
            if (isCurrentCourse) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Show course details
                        _showCourseDetailsDialog(course);
                      },
                      icon: const Icon(Icons.info_outline),
                      label: const Text('Details'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: course['canWithdraw'] == true
                          ? () {
                              _showWithdrawConfirmation(course);
                            }
                          : null,
                      icon: const Icon(Icons.exit_to_app),
                      label: const Text('Withdraw'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.errorColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  void _showCourseDetailsDialog(Map<String, dynamic> course) {
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                course['courseName'] ?? 'Unknown Course',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                course['courseCode'] ?? 'Unknown',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildDetailRow('Instructor', course['instructor'] ?? 'TBA'),
              _buildDetailRow('Credits', '${course['credits'] ?? '0'}'),
              _buildDetailRow('Schedule', course['schedule'] ?? 'TBA'),
              _buildDetailRow('Location', course['location'] ?? 'TBA'),
              _buildDetailRow('Term', course['term'] ?? 'Current Term'),
              
              if (course['description'] != null) ...[
                const SizedBox(height: 16),
                Text(
                  'Description',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  course['description'],
                  style: theme.textTheme.bodyMedium,
                ),
              ],
              
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
  
  void _showWithdrawConfirmation(Map<String, dynamic> course) {
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Withdrawal'),
        content: RichText(
          text: TextSpan(
            style: theme.textTheme.bodyMedium,
            children: [
              const TextSpan(
                text: 'Are you sure you want to withdraw from ',
              ),
              TextSpan(
                text: '${course['courseCode']} - ${course['courseName']}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(
                text: '? This action cannot be undone.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Process withdrawal
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Withdrawal request submitted for ${course['courseCode']}'),
                  backgroundColor: AppTheme.warningColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Withdraw'),
          ),
        ],
      ),
    );
  }
  
  void _showEnrollNewCourseDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Available Courses'),
        content: const SizedBox(
          width: double.maxFinite,
          height: 300,
          child: Center(
            child: Text('Course registration for the next term will open soon.'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Enrollment Data',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You are not currently enrolled in any courses',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              _showEnrollNewCourseDialog();
            },
            icon: const Icon(Icons.add),
            label: const Text('Enroll in Courses'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildErrorView(String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: AppTheme.errorColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to Load Enrollment Data',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              errorMessage,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadEnrollmentData,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}