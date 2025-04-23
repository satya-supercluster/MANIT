import 'package:flutter/material.dart';
import 'package:flutter_floating_bottom_bar/flutter_floating_bottom_bar.dart';
import 'package:manit/presentation/screens/academic_performance_screen.dart';
import 'package:manit/presentation/screens/complaint_screen.dart';
import 'package:manit/presentation/widgets/custom_load_widget.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/student_data_provider.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/custom_app_bar.dart';
import '../../core/constants/app_theme.dart';
import 'profile_screen.dart';
import 'result_screen.dart';
import 'settings_screen.dart';
import 'registration_screen.dart';
import 'fees_account_section_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  int _selectedIndex = 0;
  bool _hasNotifications = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    
    _tabController = TabController(length: 4, vsync: this, initialIndex: 0);
    
    // Add listener to update _selectedIndex when tab changes
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging && _tabController.index != _selectedIndex) {
        setState(() {
          _selectedIndex = _tabController.index;
          
          // Clear notification indicator when navigating to announcements
          if (_selectedIndex == 3) {
            _hasNotifications = false;
          }
        });
      }
    });
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  // Load initial data
  Future<void> _loadData() async {
    final studentDataProvider = Provider.of<StudentDataProvider>(context, listen: false);
    
    setState(() {
      _isLoading = true;
    });
    
    // Load profile and announcements data on dashboard load
    await Future.wait([
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
      _tabController.animateTo(3); // Animate to the announcements tab
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
      'Profile',
      'Complaints',
      'Settings'
    ];

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
      ),
      body: BottomBar(
        body: (context, controller) => TabBarView(
          controller: _tabController,
          physics: const NeverScrollableScrollPhysics(), // Disable swipe between tabs
          children: [
            _isLoading ? 
              const CustomLoadWidget() : 
              _buildDashboardContent(context, studentDataProvider, authProvider, controller),
            ProfileScreen(scrollController: controller),
            ComplaintScreen(scrollController: controller),
            SettingsScreen(scrollController: controller)
          ],
        ),
        // Customizations for the floating bar
        width: MediaQuery.of(context).size.width * 0.9,
        borderRadius: BorderRadius.circular(20),
        duration: const Duration(milliseconds: 500),
        curve: Curves.decelerate,
        showIcon: true,
        barColor: AppTheme.primaryColor,
        start: 2,
        end: 0,
        offset: 10,
        barAlignment: Alignment.bottomCenter,
        iconHeight: 30,
        iconWidth: 30,
        reverse: false,
        hideOnScroll: true,
        scrollOpposite: false,
        icon: (width, height) => Center(
          child: Icon(
            Icons.arrow_upward_rounded,
            color: Colors.white,
            size: width,
          ),
        ),
        // The floating bottom bar
        child: _buildBottomBarContent(),
      ),
    );
  }

  Widget _buildBottomBarContent() {

    final List<IconData> icons = [
      Icons.dashboard_rounded,
      Icons.person_rounded,
      Icons.pending_actions_rounded,
      Icons.settings_rounded
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(4, (index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedIndex = index;
                _tabController.animateTo(index);
                if (index == 3) {
                  _hasNotifications = false;
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _selectedIndex == index 
                  ? Colors.white.withOpacity(0.3)
                  : Colors.transparent,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Stack(
                children: [
                  Icon(
                    icons[index],
                    color: Colors.white,
                    size: 28,
                  ),
                  if (index == 3 && _hasNotifications)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDashboardContent(
    BuildContext context, 
    StudentDataProvider studentDataProvider,
    AuthProvider authProvider,
    ScrollController controller,
  ) {
    final theme = Theme.of(context);
    final user = authProvider.currentUser;
    final announcements = studentDataProvider.announcementsData;
    
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        controller: controller,
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
                  if (user?.degree != null)
                    Text(
                      'Degree: ${user?.degree}',
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
                title: 'Result',
                icon: Icons.grading_rounded,
                color: AppTheme.primaryColor,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ResultScreen()),
                  );
                },
              ),
              DashboardCard(
                title: 'Performance',
                icon: Icons.grade_rounded,
                color: AppTheme.accentColor,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AcademicPerformanceScreen()),
                  );
                },
              ),
              DashboardCard(
                title: 'Registration',
                icon: Icons.school_rounded,
                color: AppTheme.successColor,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegistrationScreen()),
                  );
                },
              ),
              DashboardCard(
                title: 'Fee Info',
                icon: Icons.account_balance_wallet_rounded,
                color: AppTheme.warningColor,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FeesAccountSectionScreen()),
                  );
                },
              ),
              DashboardCard(
                title: 'Feedback',
                icon: Icons.chat,
                color: Colors.purple,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FeesAccountSectionScreen()),
                  );
                },
              ),
              DashboardCard(
                title: 'TimeTable',
                icon: Icons.calendar_month_rounded,
                color: Colors.orange,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FeesAccountSectionScreen()),
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
                      _tabController.animateTo(3);
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
          
          // Add some padding at the bottom for the floating bar
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}