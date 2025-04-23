import 'package:flutter/material.dart';
import 'package:manit/presentation/widgets/custom_load_widget.dart';
import 'package:manit/presentation/widgets/profile_avatar.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _activeTab = 'personal';

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userData = authProvider.currentUser;

    if (userData == null) {
      return const CustomLoadWidget();
    }

    return Scaffold(
      body: SingleChildScrollView(
        child:Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            children: [
              // Profile Header with Gradient
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // Profile Image
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.2),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [Colors.white.withOpacity(0.8), Colors.white.withOpacity(0.4)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: ProfileAvatar(base64Image: userData.profilePicture)
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // User Details
                      Text(
                        userData.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userData.department,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Badges
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildBadge(Icons.numbers, userData.studentId),
                          const SizedBox(width: 8),
                          _buildBadge(Icons.calendar_today, userData.semester),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Tab Navigation
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildTabButton('personal', 'Personal', Icons.person),
                      _buildTabButton('academic', 'Academic', Icons.school),
                      _buildTabButton('family', 'Family', Icons.family_restroom),
                      _buildTabButton('contact', 'Contact', Icons.phone),
                      _buildTabButton('documents', 'Documents', Icons.description),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Content based on active tab
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: _buildTabContent(userData),
              ),
              SizedBox(height: 80,)
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String tab, String label, IconData icon) {
    bool isActive = _activeTab == tab;
    
    return InkWell(
      onTap: () {
        setState(() {
          _activeTab = tab;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          border: isActive
              ? const Border(
                  bottom: BorderSide(
                    color: Color(0xFF4F46E5),
                    width: 2.0,
                  ),
                )
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive ? const Color(0xFF4F46E5) : Colors.grey,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isActive ? const Color(0xFF4F46E5) : Colors.grey,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(user) {
    switch (_activeTab) {
      case 'personal':
        return _buildPersonalInfo(user);
      case 'academic':
        return _buildAcademicInfo(user);
      case 'family':
        return _buildFamilyInfo(user);
      case 'contact':
        return _buildContactInfo(user);
      case 'documents':
        return _buildDocumentsInfo(user);
      default:
        return _buildPersonalInfo(user);
    }
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: const Color(0xFF4F46E5),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF4F46E5),
        ),
      ),
    );
  }

  Widget _buildPersonalInfo(user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Personal Information',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const Divider(height: 32),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          childAspectRatio: 2.5,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 8,
          children: [
            _buildInfoItem(Icons.person, 'Full Name', user.fullName),
            _buildInfoItem(Icons.calendar_today, 'Date of Birth', user.dateOfBirth ?? 'N/A'),
            _buildInfoItem(Icons.favorite, 'Marital Status', user.maritalStatus ?? 'N/A'),
            _buildInfoItem(Icons.public, 'Nationality', user.nationality ?? 'N/A'),
            _buildInfoItem(Icons.local_hospital, 'Blood Group', user.bloodGroup ?? 'N/A'),
            _buildInfoItem(Icons.language, 'Mother Tongue', user.motherTongue ?? 'N/A'),
            _buildInfoItem(Icons.people, 'Caste', user.caste ?? 'N/A'),
            _buildInfoItem(Icons.person_outline, 'Gender', user.gender ?? 'N/A'),
            _buildInfoItem(Icons.home, 'Hostel', user.hostel ?? 'N/A'),
            _buildInfoItem(Icons.hotel, 'Room No', user.roomNo ?? 'N/A'),
          ],
        ),
      ],
    );
  }

  Widget _buildAcademicInfo(user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Academic Information',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const Divider(height: 32),
        _buildInfoItem(Icons.school, 'Department', user.department),
        _buildInfoItem(Icons.numbers, 'Student ID', user.studentId),
        _buildInfoItem(Icons.calendar_today, 'Current Semester', user.semester),
        _buildInfoItem(Icons.calendar_month, 'Batch', user.batch),
        _buildInfoItem(Icons.how_to_reg, 'Enrollment Status', user.enrollmentStatus),
        _buildInfoItem(Icons.grade, 'Program', user.program),
      ],
    );
  }

  Widget _buildFamilyInfo(user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Family Information',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const Divider(height: 32),
        _buildSectionTitle('Parents'),
        _buildInfoItem(Icons.person, 'Father\'s Name', user.fatherName ?? 'N/A'),
        _buildInfoItem(Icons.work, 'Father\'s Profession', user.fatherProfession ?? 'N/A'),
        _buildInfoItem(Icons.person, 'Mother\'s Name', user.motherName ?? 'N/A'),
        _buildInfoItem(Icons.work, 'Mother\'s Profession', user.motherProfession ?? 'N/A'),
        _buildInfoItem(Icons.location_on, 'Parents\' Address', user.parentsAddress ?? 'N/A'),
        _buildInfoItem(Icons.phone, 'Parents\' Phone', user.parentsPhone ?? 'N/A'),
        _buildInfoItem(Icons.email, 'Parents\' Email', user.parentsEmail ?? 'N/A'),
        
        const SizedBox(height: 16),
        _buildSectionTitle('Guardian'),
        _buildInfoItem(Icons.person, 'Guardian\'s Name', user.guardianName ?? 'N/A'),
        _buildInfoItem(Icons.people, 'Relationship with Guardian', user.relationshipWithGuardian ?? 'N/A'),
        _buildInfoItem(Icons.location_on, 'Guardian\'s Address', user.guardianAddress ?? 'N/A'),
        _buildInfoItem(Icons.phone, 'Guardian\'s Phone', user.guardianPhone ?? 'N/A'),
        _buildInfoItem(Icons.email, 'Guardian\'s Email', user.guardianEmail ?? 'N/A'),
      ],
    );
  }

  Widget _buildContactInfo(user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact Information',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const Divider(height: 32),
        _buildInfoItem(Icons.phone, 'Phone Number', user.phoneNumber ?? 'N/A'),
        _buildInfoItem(Icons.phone_android, 'Alternate Phone Number', user.alternatePhoneNumber ?? 'N/A'),
        _buildInfoItem(Icons.email, 'Email ID', user.email),
        _buildInfoItem(Icons.alternate_email, 'Alternate Email ID', user.alternateEmailId ?? 'N/A'),
        _buildInfoItem(Icons.home, 'Permanent Address', user.permanentAddress ?? 'N/A'),
        _buildInfoItem(Icons.location_on, 'Present Address', user.presentAddress ?? 'N/A'),
      ],
    );
  }

  Widget _buildDocumentsInfo(user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Documents & Identification',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const Divider(height: 32),
        _buildInfoItem(Icons.credit_card, 'Aadhar Number', user.aadharNumber ?? 'N/A'),
        _buildInfoItem(Icons.book, 'Passport Number', user.passportNumber ?? 'N/A'),
        _buildInfoItem(Icons.credit_card, 'PAN Number', user.panNumber ?? 'N/A'),
        _buildInfoItem(Icons.description, 'ABC ID', user.abcId ?? 'N/A'),
        _buildInfoItem(Icons.how_to_vote, 'Voter Card', user.voterCard ?? 'N/A'),
      ],
    );
  }
}