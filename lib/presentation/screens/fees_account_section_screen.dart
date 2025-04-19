import 'package:flutter/material.dart';
import 'package:manit/data/repositories/transform_fee_data_format.dart';
import 'package:manit/presentation/providers/auth_provider.dart';
import 'package:manit/presentation/providers/student_data_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'fees_semester_details_screen.dart';

class FeesAccountSectionScreen extends StatefulWidget {
  const FeesAccountSectionScreen({super.key});

  @override
  State<FeesAccountSectionScreen> createState() => _FeesAccountSectionScreenState();
}

class _FeesAccountSectionScreenState extends State<FeesAccountSectionScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _transformedData;
  int? _openSemesterIndex;
  int? _openFeeTypeIndex;
  
  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchFeeData();
    });
  }

  Future<void> _fetchFeeData() async {
    setState(() {
      _isLoading = true;
    });
    
    final studentDataProvider = Provider.of<StudentDataProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final program = authProvider.currentUser?.programMasterId;
    final studentuid = authProvider.currentUser?.id;

    
    await studentDataProvider.fetchFeeData(program??"",studentuid??"");
    
    if (studentDataProvider.feeData != null) {
      setState(() {
        _transformedData = studentDataProvider.feeData;
      });
    }
    
    setState(() {
      _isLoading = false;
    });
  }

  // Helper method to toggle semester accordion
  void _toggleSemesterAccordion(int index) {
    setState(() {
      _openSemesterIndex = _openSemesterIndex == index ? null : index;
      // Reset fee type accordion when changing semester
      _openFeeTypeIndex = null;
    });
  }

  // Helper method to toggle fee type accordion
  void _toggleFeeTypeAccordion(int index) {
    setState(() {
      _openFeeTypeIndex = _openFeeTypeIndex == index ? null : index;
    });
  }
  
  // Launch URL for payment or status check
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch URL')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final studentDataProvider = Provider.of<StudentDataProvider>(context);
    
    if (studentDataProvider.hasError) {
      return Center(
       child: Padding(
         padding: const EdgeInsets.all(24),
         child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
             const Icon(
               Icons.error_outline,
               size: 64,
               color: Colors.red,
             ),
             const SizedBox(height: 16),
             Text(
               'Error Loading Fee Data',
               style: Theme.of(context).textTheme.titleLarge?.copyWith(
                 fontWeight: FontWeight.bold,
               ),
             ),
             const SizedBox(height: 8),
             Text(
               studentDataProvider.errorMessage,
               textAlign: TextAlign.center,
               style: Theme.of(context).textTheme.bodyMedium,
             ),
             const SizedBox(height: 24),
             ElevatedButton(
               onPressed: _fetchFeeData,
               child: const Text('Try Again'),
             ),
           ],
         ),
       ),
     );
    }

    if (_transformedData == null) {
      return const Center(child: Text('No fee data available'));
    }

    final summaryData = _transformedData!['summaryData'];
    final groupedData = _transformedData!['groupedData'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Section'),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchFeeData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFeesOverview(summaryData),
                const SizedBox(height: 24),
                _buildActionButtons(),
                const SizedBox(height: 24),
                const Text(
                  'Fees Information',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'The fees section provides an overview only. Please check the real fee status through the provided link.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                _buildFeesAccordion(groupedData),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeesOverview(Map<String, dynamic> summaryData) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fees Overview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.3,
            children: [
              _buildSummaryCard(
                'Total Amount',
                summaryData['totalAmount'] ?? 0,
                'The total fees collected for this term.',
                Colors.blue.shade100,
                Icons.account_balance_wallet,
              ),
              _buildSummaryCard(
                'Total Excess Fee',
                summaryData['totalExcessFee'] ?? 0,
                'Any extra amount paid over required fees.',
                Colors.green.shade100,
                Icons.savings,
              ),
              _buildSummaryCard(
                'Total Fees Demand',
                summaryData['totalFeesPrice'] ?? 0,
                'Total price for all registered subjects.',
                Colors.amber.shade100,
                Icons.receipt_long,
              ),
              _buildSummaryCard(
                'Fees Due',
                summaryData['feeDifference'] ?? 0,
                'Amount still pending to be paid.',
                Colors.red.shade100,
                Icons.warning_amber,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, dynamic amount, String description, Color bgColor, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.black54),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            formatCurrency(amount),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () => _launchURL('https://payment.manit.ac.in/secure/smile_student_online_payment_trxn_report'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
            backgroundColor: Theme.of(context).primaryColor,
          ),
          child: const Text('Check RealTime Fees Status'),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () => _launchURL('https://payment.manit.ac.in/secure/smile_student_fees_payment'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
            backgroundColor: Colors.green,
          ),
          child: const Text('Pay Fees'),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/fees_structure');
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
            backgroundColor: Theme.of(context).primaryColor,
          ),
          child: const Text('Fees Structure'),
        ),
      ],
    );
  }

  Widget _buildFeesAccordion(Map<String, dynamic> groupedData) {
    final semesterKeys = groupedData.keys.toList();
    
    if (semesterKeys.isEmpty) {
      return const Center(child: Text('No semester data available'));
    }
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: semesterKeys.length,
      itemBuilder: (context, semesterIndex) {
        final semesterKey = semesterKeys[semesterIndex];
        final semesterData = groupedData[semesterKey];
        final semesterDesc = semesterData['semesterDesc'] ?? 'Unknown Semester';
        final totalSemesterPrice = semesterData['totalSemesterPrice'] ?? 0.0;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            children: [
              // Semester Header
              InkWell(
                onTap: () => _toggleSemesterAccordion(semesterIndex),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '$semesterDesc - Total Fees: ${formatCurrency(totalSemesterPrice)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FeesSemesterDetailsScreen(
                                    semesterData: semesterData,
                                    semesterDesc: semesterDesc,
                                  ),
                                ),
                              );
                            },
                            child: const Text('Payment Slip'),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            _openSemesterIndex == semesterIndex
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              // Semester Details (expanded accordion)
              if (_openSemesterIndex == semesterIndex)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildFeeTypesList(semesterData['feeTypes']),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeeTypesList(Map<String, dynamic> feeTypes) {
    final feeTypeKeys = feeTypes.keys.toList();
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: feeTypeKeys.length,
      itemBuilder: (context, feeTypeIndex) {
        final feeTypeId = feeTypeKeys[feeTypeIndex];
        final feeTypeData = feeTypes[feeTypeId];
        final feeTypeLabel = getFeeTypeLabel(feeTypeId);
        final totalPrice = feeTypeData['totalPrice'] ?? 0.0;
        
        return Column(
          children: [
            // Fee Type Header
            InkWell(
              onTap: () => _toggleFeeTypeAccordion(feeTypeIndex),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$feeTypeLabel - ${formatCurrency(totalPrice)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      _openFeeTypeIndex == feeTypeIndex
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                    ),
                  ],
                ),
              ),
            ),
            
            // Fee Type Details
            if (_openFeeTypeIndex == feeTypeIndex)
              _buildFeesTable(feeTypeData['fees']),
            
            const Divider(),
          ],
        );
      },
    );
  }

  Widget _buildFeesTable(List<dynamic> fees) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 20,
          columns: const [
            DataColumn(label: Text('Fee Title')),
            DataColumn(label: Text('Fees Amount')),
            DataColumn(label: Text('Fees Paid')),
          ],
          rows: fees.map<DataRow>((fee) {
            return DataRow(
              cells: [
                DataCell(Text(fee['fees_sub_head_title'] ?? '')),
                DataCell(Text(formatCurrency(fee['fees_price']))),
                DataCell(Text(formatCurrency(fee['amount']))),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}