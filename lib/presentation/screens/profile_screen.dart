import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/student_data_provider.dart';
import '../../core/constants/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final studentDataProvider = Provider.of<StudentDataProvider>(context, listen: false);
    
    setState(() {
      _isLoading = true;
    });
    
    await studentDataProvider.fetchProfileData();
    
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final studentDataProvider = Provider.of<StudentDataProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final profileData = studentDataProvider.profileData;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadProfileData,
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
                          onPressed: _loadProfileData,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        expandedHeight: 220,
                        pinned: true,
                        flexibleSpace: FlexibleSpaceBar(
                          background: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  AppTheme.primaryColor,
                                  AppTheme.primaryDarkColor,
                                ],
                              ),
                            ),
                            child: SafeArea(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 50,
                                    backgroundColor: Colors.white,
                                    child: Text(
                                      user?.name.isNotEmpty == true 
                                        ? user!.name[0].toUpperCase() 
                                        : 'S',
                                      style: const TextStyle(
                                        fontSize: 40,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    user?.name ?? 'Student',
                                    style: theme.textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            // Student Information Card
                            _buildInfoCard(
                              theme,
                              title: 'Student Information',
                              icon: Icons.school,
                              children: [
                                _buildInfoRow(theme, 'Student ID', user?.studentId ?? 'N/A'),
                                _buildInfoRow(theme, 'Program', user?.program ?? 'N/A'),
                                _buildInfoRow(theme, 'Year Level', profileData?['yearLevel'] ?? 'N/A'),
                                _buildInfoRow(theme, 'Status', profileData?['status'] ?? 'Active'),
                                _buildInfoRow(theme, 'Department', profileData?['department'] ?? 'N/A'),
                              ],
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Personal Information Card
                            _buildInfoCard(
                              theme,
                              title: 'Personal Information',
                              icon: Icons.person,
                              children: [
                                _buildInfoRow(theme, 'Email', profileData?['email'] ?? 'N/A'),
                                _buildInfoRow(theme, 'Phone', profileData?['phone'] ?? 'N/A'),
                                _buildInfoRow(theme, 'Date of Birth', profileData?['birthDate'] ?? 'N/A'),
                                _buildInfoRow(theme, 'Gender', profileData?['gender'] ?? 'N/A'),
                              ],
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Address Information Card
                            _buildInfoCard(
                              theme,
                              title: 'Address',
                              icon: Icons.home,
                              children: [
                                _buildInfoRow(theme, 'Street', profileData?['address']?['street'] ?? 'N/A'),
                                _buildInfoRow(theme, 'City', profileData?['address']?['city'] ?? 'N/A'),
                                _buildInfoRow(theme, 'State', profileData?['address']?['state'] ?? 'N/A'),
                                _buildInfoRow(theme, 'Postal Code', profileData?['address']?['postalCode'] ?? 'N/A'),
                                _buildInfoRow(theme, 'Country', profileData?['address']?['country'] ?? 'N/A'),
                              ],
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Academic Record
                            _buildInfoCard(
                              theme,
                              title: 'Academic Information',
                              icon: Icons.assessment,
                              children: [
                                _buildInfoRow(theme, 'GPA', profileData?['gpa'] ?? 'N/A'),
                                _buildInfoRow(theme, 'Credits Earned', profileData?['creditsEarned']?.toString() ?? 'N/A'),
                                _buildInfoRow(theme, 'Expected Graduation', profileData?['expectedGraduation'] ?? 'N/A'),
                              ],
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Emergency Contact
                            _buildInfoCard(
                              theme,
                              title: 'Emergency Contact',
                              icon: Icons.emergency,
                              children: [
                                _buildInfoRow(theme, 'Name', profileData?['emergencyContact']?['name'] ?? 'N/A'),
                                _buildInfoRow(theme, 'Relationship', profileData?['emergencyContact']?['relationship'] ?? 'N/A'),
                                _buildInfoRow(theme, 'Phone', profileData?['emergencyContact']?['phone'] ?? 'N/A'),
                              ],
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Edit Profile Button
                            ElevatedButton.icon(
                              onPressed: () {
                                // Navigate to edit profile screen
                              },
                              icon: const Icon(Icons.edit),
                              label: const Text('Edit Profile'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ]),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildInfoCard(
    ThemeData theme, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}