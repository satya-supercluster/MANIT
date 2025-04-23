import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:manit/data/models/complaint_model.dart';
import 'package:manit/presentation/providers/auth_provider.dart';
import 'package:provider/provider.dart';

import '../providers/complaint_provider.dart';
import '../widgets/status_badge.dart';
import './complaint_detail_screen.dart';
import './add_complaint_screen.dart';

class ComplaintScreen extends StatefulWidget {
  final ScrollController scrollController;
  const ComplaintScreen({Key? key, required this.scrollController}) : super(key: key);

  @override
  State<ComplaintScreen> createState() => _ComplaintScreenState();
}

class _ComplaintScreenState extends State<ComplaintScreen> {
  bool _isLoading = true;
  bool _isFilterOpen = false;
  List<Complaint> _complaints = [];
  List<Complaint> _filteredComplaints = [];
  
  // Filter states
  String _searchTerm = '';
  String _statusFilter = 'all';
  DateTime? _startDate;
  DateTime? _endDate;
  
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchComplaints();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchComplaints() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final complaintProvider = Provider.of<ComplaintProvider>(context, listen: false);
      await complaintProvider.getComplaintToken(authProvider.currentUser?.studentId ?? "");
      await complaintProvider.fetchComplaints(authProvider.currentUser?.studentId ?? "");
      setState(() {
        _complaints = complaintProvider.complaints;
        _filteredComplaints = _complaints;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load complaints: ${error.toString()}')),
      );
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredComplaints = _complaints.where((complaint) {
        // Status filter
        if (_statusFilter != 'all' && complaint.status != _statusFilter) {
          return false;
        }
        
        // Date filter
        if (_startDate != null && _endDate != null) {
          final complaintDate = DateTime.parse(complaint.createdAt);
          if (complaintDate.isBefore(_startDate!) || complaintDate.isAfter(_endDate!)) {
            return false;
          }
        }
        
        // Search filter
        if (_searchTerm.isNotEmpty) {
          final searchLower = _searchTerm.toLowerCase();
          return complaint.complaintNumber.toLowerCase().contains(searchLower) ||
              complaint.complaintType.toLowerCase().contains(searchLower) ||
              complaint.dateReported.toLowerCase().contains(searchLower);
        }
        
        return true;
      }).toList();
    });
  }

  void _clearFilters() {
    setState(() {
      _statusFilter = 'all';
      _startDate = null;
      _endDate = null;
      _searchTerm = '';
      _searchController.clear();
      _filteredComplaints = _complaints;
    });
  }

  void _toggleFilterPanel() {
    setState(() {
      _isFilterOpen = !_isFilterOpen;
    });
  }

  void _exportToCsv() {
    // Implementation for exporting to CSV would go here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exporting to CSV...')),
    );
  }

  Widget _buildFilterPanel() {
    if (!_isFilterOpen) {
      return const SizedBox.shrink();
    }
    
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Filter Your Search',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Status filter
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Status:'),
                    DropdownButton<String>(
                      isExpanded: true,
                      value: _statusFilter,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _statusFilter = newValue;
                            _applyFilters();
                          });
                        }
                      },
                      items: <String>['all', 'open', 'assigned', 'processing', 'resolved', 'rejected']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value[0].toUpperCase() + value.substring(1)),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Date from filter
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('From:'),
                    TextButton.icon(
                      icon: const Icon(Icons.calendar_today, size: 16),
                      label: Text(
                        _startDate == null
                            ? 'Select Date'
                            : DateFormat('yyyy-MM-dd').format(_startDate!),
                      ),
                      onPressed: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: _startDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null && picked != _startDate) {
                          setState(() {
                            _startDate = picked;
                            _applyFilters();
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Date to filter
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('To:'),
                    TextButton.icon(
                      icon: const Icon(Icons.calendar_today, size: 16),
                      label: Text(
                        _endDate == null
                            ? 'Select Date'
                            : DateFormat('yyyy-MM-dd').format(_endDate!),
                      ),
                      onPressed: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: _endDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null && picked != _endDate) {
                          setState(() {
                            _endDate = DateTime(picked.year, picked.month, picked.day, 23, 59, 59);
                            _applyFilters();
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              TextButton(
                onPressed: _clearFilters,
                child: const Text('Clear Filters'),
              ),
              if (_statusFilter != 'all' || _startDate != null || _endDate != null)
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        if (_statusFilter != 'all')
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Chip(
                              label: Text('Status: $_statusFilter'),
                              backgroundColor: Colors.blue[100],
                              labelStyle: TextStyle(color: Colors.blue[800]),
                            ),
                          ),
                        if (_startDate != null && _endDate != null)
                          Chip(
                            label: Text(
                              'Date: ${DateFormat('yyyy-MM-dd').format(_startDate!)} - ${DateFormat('yyyy-MM-dd').format(_endDate!)}',
                            ),
                            backgroundColor: Colors.blue[100],
                            labelStyle: TextStyle(color: Colors.blue[800]),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: ()=>_fetchComplaints(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Search and buttons
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    // Search field
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search Here',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchTerm = value;
                            _applyFilters();
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Filter button
                    TextButton.icon(
                      onPressed: _toggleFilterPanel,
                      icon: const Icon(Icons.filter_list),
                      label: const Text('Filters'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                    // Export CSV button
                    TextButton.icon(
                      onPressed: _exportToCsv,
                      icon: const Icon(Icons.download),
                      label: const Text('CSV'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Filter panel
              if (_isFilterOpen) _buildFilterPanel(),
              
              // Complaints list
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredComplaints.isEmpty
                        ? const Center(child: Text('No complaints match your filter criteria'))
                        : ListView.builder(
                          controller: widget.scrollController,
                            padding: const EdgeInsets.all(8.0),
                            itemCount: _filteredComplaints.length,
                            itemBuilder: (ctx, index) {
                              final complaint = _filteredComplaints[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  title: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          complaint.complaintNumber,
                                          style: const TextStyle(
                                            color: Colors.blue,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      StatusBadge(status: complaint.status),
                                    ],
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Row(
                                      children: [
                                        Expanded(child: Text('Date: ${complaint.dateReported}')),
                                        Text(
                                          complaint.complaintType,
                                          style: TextStyle(
                                            color: Colors.blue[800],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => ComplaintDetailScreen(complaint: complaint),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
              ),
              SizedBox(height:70),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddComplaintScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}