import 'package:intl/intl.dart';

Map<String, dynamic> transformFeeDataFormat(Map<String, dynamic> rawData) {

  final Map<String, dynamic> summaryData = {
    'totalAmount': rawData['totalAmount'] ?? 0.0,
    'totalExcessFee': rawData['totalExcessFee'] ?? 0.0,
    'totalFeesPrice': rawData['totalFeesPrice'] ?? 0.0,
    'feeDifference': (rawData['totalFeesPrice'] ?? 0.0) - (rawData['totalAmount'] ?? 0.0),
  };

  // Group fee data by semester and then by fee type
  final Map<String, dynamic> groupedData = {};
  
  if (rawData['feeData'] != null && rawData['feeData'] is List) {
    final List<dynamic> feeDataList = rawData['feeData'];
    
    for (var fee in feeDataList) {
      final String semesterKey = '${fee['semester_type_id_code']}_${fee['semester_code_desc']}';
      
      // Initialize semester entry if it doesn't exist
      if (!groupedData.containsKey(semesterKey)) {
        groupedData[semesterKey] = {
          'feeTypes': {},
          'totalSemesterPrice': 0.0,
          'semesterDesc': fee['semester_code_desc'],
        };
      }
      
      // Fee type (Institute Fees, Hostel Fees, Other Fees)
      final String feeType = fee['fees_head_id'].toString();
      
      // Initialize fee type if it doesn't exist
      if (!groupedData[semesterKey]['feeTypes'].containsKey(feeType)) {
        groupedData[semesterKey]['feeTypes'][feeType] = {
          'fees': [],
          'totalPrice': 0.0,
        };
      }
      
      // Add fee to the appropriate group
      groupedData[semesterKey]['feeTypes'][feeType]['fees'].add(fee);
      
      // Update total price for this fee type
      groupedData[semesterKey]['feeTypes'][feeType]['totalPrice'] += 
          (fee['fees_price'] is num) ? fee['fees_price'] : 0.0;
      
      // Update total semester price
      groupedData[semesterKey]['totalSemesterPrice'] += 
          (fee['fees_price'] is num) ? fee['fees_price'] : 0.0;
    }
  }
  // Return combined data
  // print(groupedData);
  return {
    'groupedData': groupedData,
    'summaryData': summaryData,
  };
}

/// Helper function to get fee type label based on fees_head_id
String getFeeTypeLabel(String feeTypeId) {
  switch (feeTypeId) {
    case '6':
      return "Institute Fees";
    case '9':
      return "Hostel Fees";
    case '7':
      return "Other Fees";
    default:
      return "Unknown Fee Type";
  }
}

/// Format currency in Indian Rupee format
String formatCurrency(dynamic amount) {
  if (amount == null) return '₹0';
  final formatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );
  return formatter.format(amount);
}