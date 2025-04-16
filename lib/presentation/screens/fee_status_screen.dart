import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/student_data_provider.dart';
import '../../core/constants/app_theme.dart';
import 'package:intl/intl.dart';

class FeeStatusScreen extends StatefulWidget {
  const FeeStatusScreen({super.key});

  @override
  State<FeeStatusScreen> createState() => _FeeStatusScreenState();
}

class _FeeStatusScreenState extends State<FeeStatusScreen> {
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadFeeData();
  }
  
  Future<void> _loadFeeData() async {
    final studentDataProvider = Provider.of<StudentDataProvider>(context, listen: false);
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      await studentDataProvider.fetchFeeStatus();
    } catch (e) {
      // Error handling will be displayed through the provider
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
          'Fee Status',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : studentDataProvider.hasError
              ? _buildErrorView(studentDataProvider.errorMessage)
              : _buildFeeStatusContent(studentDataProvider),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showPaymentOptionsDialog();
        },
        icon: const Icon(Icons.payment),
        label: const Text('Make Payment'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }
  
  Widget _buildFeeStatusContent(StudentDataProvider provider) {
    final theme = Theme.of(context);
    final feeData = provider.feeData;
    
    if (feeData == null) {
      return _buildEmptyView();
    }
    
    final formatter = NumberFormat.currency(symbol: '\$');
    final totalFees = feeData['totalFees'] ?? 0.0;
    final paidAmount = feeData['paidAmount'] ?? 0.0;
    final dueAmount = feeData['dueAmount'] ?? 0.0;
    final dueDate = feeData['dueDate'] ?? 'N/A';
    final transactions = feeData['transactions'] ?? [];
    final paymentStatus = feeData['status'] ?? 'Unknown';
    
    // Calculate payment progress
    final double progressValue = totalFees > 0 ? paidAmount / totalFees : 0.0;
    
    Color getStatusColor() {
      switch (paymentStatus.toLowerCase()) {
        case 'paid':
          return AppTheme.successColor;
        case 'partial':
          return AppTheme.warningColor;
        case 'overdue':
          return AppTheme.errorColor;
        case 'pending':
          return AppTheme.infoColor;
        default:
          return AppTheme.primaryColor;
      }
    }
    
    return RefreshIndicator(
      onRefresh: _loadFeeData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Summary Card
          Card(
            margin: const EdgeInsets.only(bottom: 24),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Payment Summary',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: getStatusColor().withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          paymentStatus,
                          style: TextStyle(
                            color: getStatusColor(),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Fee Details
                  Row(
                    children: [
                      Expanded(
                        child: _buildFeeDetailItem(
                          label: 'Total Fees',
                          amount: formatter.format(totalFees),
                          icon: Icons.account_balance,
                        ),
                      ),
                      Expanded(
                        child: _buildFeeDetailItem(
                          label: 'Amount Paid',
                          amount: formatter.format(paidAmount),
                          icon: Icons.check_circle,
                          amountColor: AppTheme.successColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildFeeDetailItem(
                          label: 'Amount Due',
                          amount: formatter.format(dueAmount),
                          icon: Icons.warning,
                          amountColor: dueAmount > 0 ? AppTheme.warningColor : AppTheme.successColor,
                        ),
                      ),
                      Expanded(
                        child: _buildFeeDetailItem(
                          label: 'Due Date',
                          amount: dueDate,
                          icon: Icons.calendar_today,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  Text(
                    'Payment Progress',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progressValue,
                    backgroundColor: Colors.grey[200],
                    color: getStatusColor(),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${(progressValue * 100).toStringAsFixed(0)}% Paid',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: getStatusColor(),
                        ),
                      ),
                      Text(
                        '${formatter.format(paidAmount)} of ${formatter.format(totalFees)}',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Fee Breakdown Card
          Card(
            margin: const EdgeInsets.only(bottom: 24),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fee Breakdown',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  if (feeData['breakdown'] != null) ...[
                    ...feeData['breakdown'].map<Widget>((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item['description'] ?? 'Unknown Fee',
                            style: theme.textTheme.bodyLarge,
                          ),
                          Text(
                            formatter.format(item['amount'] ?? 0.0),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                    const Divider(thickness: 1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          formatter.format(totalFees),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ] else
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('No fee breakdown available'),
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          // Payment History
          Text(
            'Payment History',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          if (transactions.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No payment history available'),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                return _buildTransactionCard(transaction);
              },
            ),
            
          const SizedBox(height: 80), // Space for floating action button
        ],
      ),
    );
  }
  
  Widget _buildFeeDetailItem({
    required String label, 
    required String amount, 
    required IconData icon, 
    Color? amountColor,
  }) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: amountColor,
          ),
        ),
      ],
    );
  }
  
  Widget _buildTransactionCard(Map<String, dynamic> transaction) {
    final theme = Theme.of(context);
    final formatter = NumberFormat.currency(symbol: '\$');
    
    // Format date if available
    String formattedDate = transaction['date'] ?? 'N/A';
    if (formattedDate != 'N/A') {
      try {
        final dateTime = DateTime.parse(formattedDate);
        formattedDate = DateFormat('MMM d, yyyy').format(dateTime);
      } catch (e) {
        // Use the original string if parsing fails
      }
    }
    
    final status = transaction['status'] ?? 'Unknown';
    final amount = transaction['amount'] ?? 0.0;
    final paymentMethod = transaction['paymentMethod'] ?? 'Unknown';
    final transactionId = transaction['id'] ?? 'Unknown';
    
    Color getStatusColor() {
      switch (status.toLowerCase()) {
        case 'success':
        case 'completed':
          return AppTheme.successColor;
        case 'pending':
          return AppTheme.warningColor;
        case 'failed':
          return AppTheme.errorColor;
        default:
          return AppTheme.primaryColor;
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              formatter.format(amount),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: getStatusColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: getStatusColor(),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  formattedDate,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.payment_outlined,
                  size: 14,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  paymentMethod,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 14,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  'ID: $transactionId',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: () {
          _showTransactionDetails(transaction);
        },
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
  
  void _showTransactionDetails(Map<String, dynamic> transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final theme = Theme.of(context);
        final formatter = NumberFormat.currency(symbol: '\$');
        
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Transaction Details',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              _buildDetailRow('Amount', formatter.format(transaction['amount'] ?? 0.0)),
              _buildDetailRow('Status', transaction['status'] ?? 'Unknown'),
              _buildDetailRow('Date', transaction['date'] ?? 'N/A'),
              _buildDetailRow('Payment Method', transaction['paymentMethod'] ?? 'Unknown'),
              _buildDetailRow('Transaction ID', transaction['id'] ?? 'Unknown'),
              
              if (transaction['notes'] != null)
                _buildDetailRow('Notes', transaction['notes']),
              
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Implement receipt download or sharing
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Receipt download feature coming soon')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Download Receipt'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showPaymentOptionsDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final theme = Theme.of(context);
        final studentDataProvider = Provider.of<StudentDataProvider>(context);
        final feeData = studentDataProvider.feeData;
        final dueAmount = feeData?['dueAmount'] ?? 0.0;
        final formatter = NumberFormat.currency(symbol: '\$');
        
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Make Payment',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Amount Due: ${formatter.format(dueAmount)}',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 24),
              
              // Payment options
              _buildPaymentOptionTile(
                icon: Icons.credit_card,
                title: 'Credit/Debit Card',
                subtitle: 'Pay using your card',
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to card payment screen
                  _showComingSoonSnackBar();
                },
              ),
              
              _buildPaymentOptionTile(
                icon: Icons.account_balance,
                title: 'Bank Transfer',
                subtitle: 'Pay directly from your bank account',
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to bank transfer screen
                  _showComingSoonSnackBar();
                },
              ),
              
              _buildPaymentOptionTile(
                icon: Icons.phone_android,
                title: 'Mobile Payment',
                subtitle: 'Pay using mobile payment apps',
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to mobile payment screen
                  _showComingSoonSnackBar();
                },
              ),
              
              _buildPaymentOptionTile(
                icon: Icons.receipt_long,
                title: 'Pay at Institution',
                subtitle: 'Get receipt details for in-person payment',
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to receipt details screen
                  _showComingSoonSnackBar();
                },
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildPaymentOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: theme.colorScheme.primary,
        ),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
  
  void _showComingSoonSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('This payment method is coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
  
  Widget _buildErrorView(String errorMessage) {
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
              errorMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadFeeData,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEmptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.account_balance_wallet_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No Fee Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'There is no fee information available at this time.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadFeeData,
              child: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }
}