import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import "../../data/models/complaint_model.dart";
import '../widgets/status_badge.dart';

class ComplaintDetailScreen extends StatelessWidget {
  final Complaint complaint;

  const ComplaintDetailScreen({
    Key? key,
    required this.complaint,
  }) : super(key: key);

  Widget _buildInfoRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: label == 'Student Name' || label == 'Complaint Type' || 
              label == 'Description' || label == 'Created At'
            ? Colors.white
            : Colors.grey[50],
        border: const Border(bottom: BorderSide(color: Colors.black12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Complaint Details', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[600],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.black12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Complaint ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            complaint.complaintNumber,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[900],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Reported on ${complaint.dateReported}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          complaint.complaintSubType,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 8),
                      StatusBadge(status: complaint.status),
                    ],
                  ),
                ],
              ),
            ),
            
            _buildInfoRow('Student Name', complaint.studentName),
            _buildInfoRow('Student ID', complaint.studentId),
            _buildInfoRow('Hostel & Room', 'Hostel ${complaint.hostelNumber}, Room ${complaint.roomNumber}'),
            _buildInfoRow('Complaint Type', complaint.complaintType),
            _buildInfoRow('Complaint Subtype', complaint.complaintSubType),
            _buildInfoRow('Description', complaint.description),
            
            // Conditionally show feedback based on status
            if (complaint.status != 'open') ...[
              if (complaint.processingFeedback != null && complaint.processingFeedback!.isNotEmpty)
                _buildInfoRow('Processing Feedback', complaint.processingFeedback!),
                
              if (complaint.resolvingFeedback != null && complaint.resolvingFeedback!.isNotEmpty)
                _buildInfoRow('Resolving Feedback', complaint.resolvingFeedback!),
            ],
            
            _buildInfoRow(
              'Created At', 
              DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.parse(complaint.createdAt))
            ),
          ],
        ),
      ),
    );
  }
}