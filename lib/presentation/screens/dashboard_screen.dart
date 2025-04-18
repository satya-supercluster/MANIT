import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/student_data_provider.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/custom_navigation_bar.dart';
import '../widgets/custom_app_bar.dart'; // Import the new widget
import '../../core/constants/app_theme.dart';
import 'profile_screen.dart';
import 'grades_screen.dart';
import 'schedule_screen.dart';
import 'announcements_screen.dart';
import 'enrollment_screen.dart';
import 'fee_status_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;
  int _selectedIndex = 0;
  bool _hasNotifications = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }
  
  // Load initial data
  Future<void> _loadData() async {
    final studentDataProvider = Provider.of<StudentDataProvider>(context, listen: false);
    
    setState(() {
      _isLoading = true;
    });
    
    // Load profile and announcements data on dashboard load
    await Future.wait([
      studentDataProvider.fetchProfileData(),
      studentDataProvider.fetchAnnouncements(),
    ]);
    
    // Check if there are new announcements
    final announcements = studentDataProvider.announcementsData;
    if (announcements != null && announcements.isNotEmpty) {
      setState(() {
        _hasNotifications = true;
      });
    }
    
    setState(() {
      _isLoading = false;
    });
  }

  // Sign out and navigate to login
  void _signOut() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final studentDataProvider = Provider.of<StudentDataProvider>(context, listen: false);
    
    await authProvider.logout();
    studentDataProvider.reset();
    
    if (!mounted) return;
    
    // Navigate back to login screen
    Navigator.of(context).pushReplacementNamed('/login');
  }
  
  // Navigate to notifications
  void _navigateToNotifications() {
    setState(() {
      _selectedIndex = 3; // Switch to Announcements tab
      _hasNotifications = false; // Clear notification indicator
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final studentDataProvider = Provider.of<StudentDataProvider>(context);
    final theme = Theme.of(context);
    final user = authProvider.currentUser;

    // List of screen titles that correspond to navigation destinations
    final List<String> screenTitles = [
      'Student Dashboard',
      'Schedule',
      'Profile',
      'Alerts'
    ];

    // Main content screens
    Widget getBody() {
      switch (_selectedIndex) {
        case 0:
          return _buildDashboardContent(context, studentDataProvider, authProvider);
        case 1:
          return const ScheduleScreen();
        case 2:
          return const ProfileScreen();
        case 3:
          return const AnnouncementsScreen();
        default:
          return _buildDashboardContent(context, studentDataProvider, authProvider);
      }
    }

    // Generate avatar text from user's name
    String avatarText = 'S';
    if (user?.name != null && user!.name.isNotEmpty) {
      avatarText = user.name[0].toUpperCase();
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: screenTitles[_selectedIndex],
        onSignOut: _signOut,
        showNotification: _hasNotifications && _selectedIndex != 3,
        onNotificationTap: _navigateToNotifications,
        avatarText: _selectedIndex == 0 ? avatarText : null,
        avatarBackgroundColor: AppTheme.primaryColor.withOpacity(0.2),
        additionalActions: _selectedIndex == 0 ? [
          IconButton(
            icon: const Icon(Icons.refresh),
            color: Colors.white70,
            onPressed: _loadData,
            tooltip: 'Refresh data',
          ),
        ] : null,
      ),
      body: _isLoading && _selectedIndex == 0
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : getBody(),
      // Use the extracted CustomNavigationBar widget
      bottomNavigationBar: CustomNavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
            
            // Clear notification indicator when navigating to announcements
            if (index == 3) {
              _hasNotifications = false;
            }
          });
        },
      ),
    );
  }

  Widget _buildDashboardContent(
    BuildContext context, 
    StudentDataProvider studentDataProvider,
    AuthProvider authProvider,
  ) {
    // Dashboard content implementation remains the same
    final theme = Theme.of(context);
    final user = authProvider.currentUser;
    final announcements = studentDataProvider.announcementsData;
    
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Welcome Card
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                        child: Text(
                          user?.name.isNotEmpty == true 
                            ? user!.name[0].toUpperCase() 
                            : 'S',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back,',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user?.name ?? 'Student',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Student ID: ${user?.studentId ?? 'N/A'}',
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  if (user?.program != null)
                    Text(
                      'Program: ${user?.program}',
                      style: theme.textTheme.bodyLarge,
                    ),
                ],
              ),
            ),
          ),
          
          // Quick Actions Grid
          Padding(
            padding: const EdgeInsets.only(bottom: 8, top: 8),
            child: Text(
              'Quick Access',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              DashboardCard(
                title: 'Grades',
                icon: Icons.grading_rounded,
                color: AppTheme.primaryColor,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const GradesScreen()),
                  );
                },
              ),
              DashboardCard(
                title: 'Schedule',
                icon: Icons.calendar_month_rounded,
                color: AppTheme.accentColor,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ScheduleScreen()),
                  );
                },
              ),
              DashboardCard(
                title: 'Enrollment',
                icon: Icons.school_rounded,
                color: AppTheme.successColor,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EnrollmentScreen()),
                  );
                },
              ),
              DashboardCard(
                title: 'Fee Status',
                icon: Icons.account_balance_wallet_rounded,
                color: AppTheme.warningColor,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FeeStatusScreen()),
                  );
                },
              ),
            ],
          ),
          
          // Recent Announcements
          Padding(
            padding: const EdgeInsets.only(bottom: 8, top: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Announcements',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedIndex = 3; // Switch to Announcements tab
                    });
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
          ),
          
          if (studentDataProvider.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (studentDataProvider.hasError)
            Card(
              margin: const EdgeInsets.only(top: 8),
              color: AppTheme.errorColor.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  studentDataProvider.errorMessage,
                  style: TextStyle(color: AppTheme.errorColor),
                ),
              ),
            )
          else if (announcements == null || announcements.isEmpty)
            Card(
              margin: const EdgeInsets.only(top: 8),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Text('No recent announcements'),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: announcements.length > 3 ? 3 : announcements.length,
              itemBuilder: (context, index) {
                final announcement = announcements[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.announcement,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                announcement['title'] ?? 'Announcement',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          announcement['message'] ?? '',
                          style: theme.textTheme.bodyMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              announcement['date'] ?? 'N/A',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                // Show full announcement
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text(announcement['title'] ?? 'Announcement'),
                                    content: SingleChildScrollView(
                                      child: Text(announcement['message'] ?? ''),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(),
                                        child: const Text('Close'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: const Text('Read More'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}