import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/student_data_provider.dart';
import '../../core/constants/app_theme.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _loadAnnouncements();
  }
  
  Future<void> _loadAnnouncements() async {
    final studentDataProvider = Provider.of<StudentDataProvider>(context, listen: false);
    
    // Only load if not already loaded
    if (studentDataProvider.announcementsData == null) {
      setState(() {
        _isLoading = true;
      });
      
      await studentDataProvider.fetchAnnouncements();
      
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
    final announcements = studentDataProvider.announcementsData;
    
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadAnnouncements,
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : studentDataProvider.hasError 
            ? _buildErrorView(studentDataProvider.errorMessage)
            : announcements == null || announcements.isEmpty
              ? _buildEmptyView()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: announcements.length,
                  itemBuilder: (context, index) {
                    final announcement = announcements[index];
                    final bool isImportant = announcement['important'] == true;
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: isImportant 
                        ? RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: AppTheme.warningColor,
                              width: 2,
                            ),
                          )
                        : null,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  isImportant ? Icons.warning_rounded : Icons.announcement,
                                  color: isImportant ? AppTheme.warningColor : theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    announcement['title'] ?? 'Announcement',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                if (isImportant)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppTheme.warningColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Important',
                                      style: TextStyle(
                                        color: AppTheme.warningColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              announcement['message'] ?? '',
                              style: theme.textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.person_outline,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      announcement['sender'] ?? 'Administration',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                                Text(
                                  announcement['date'] ?? 'N/A',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                            if (announcement['actionRequired'] == true)
                              Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    // Action button handler
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Acknowledged: ${announcement['title']}'),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.check_circle_outline),
                                  label: const Text('Acknowledge'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppTheme.primaryColor,
                                    side: BorderSide(color: AppTheme.primaryColor),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Filter options dialog
          showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => _buildFilterOptions(),
          );
        },
        child: const Icon(Icons.filter_list),
      ),
    );
  }
  
  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Announcements',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for updates',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadAnnouncements,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
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
            'Failed to Load Announcements',
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
            onPressed: _loadAnnouncements,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFilterOptions() {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter Announcements',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          _buildFilterOption(
            title: 'All Announcements',
            icon: Icons.all_inbox,
            isSelected: true,
          ),
          _buildFilterOption(
            title: 'Important Only',
            icon: Icons.priority_high,
            isSelected: false,
          ),
          _buildFilterOption(
            title: 'Action Required',
            icon: Icons.pending_actions,
            isSelected: false,
          ),
          _buildFilterOption(
            title: 'This Week',
            icon: Icons.date_range,
            isSelected: false,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  // Apply filter and close sheet
                  Navigator.pop(context);
                },
                child: const Text('Apply'),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildFilterOption({
    required String title,
    required IconData icon,
    required bool isSelected,
  }) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: () {
        // Select this filter option
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected 
                ? theme.colorScheme.primary 
                : theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: isSelected 
                  ? theme.colorScheme.primary 
                  : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: theme.colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}