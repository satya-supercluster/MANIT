import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../../data/services/api_service.dart';
import '../../data/models/complaint_model.dart';

class ComplaintProvider extends ChangeNotifier {
  bool _isLoading = false;
  String _error = '';
  bool _hasError = false;
  List<Complaint> _complaints = [];
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  final ApiService _apiService;
  ComplaintProvider({required Dio dio}) : _apiService = ApiService(dio: dio);

  bool get isLoading => _isLoading;
  String get error => _error;
  List<Complaint> get complaints => _complaints;
  bool get hasError => _hasError;

  Future<void> getComplaintToken(String studentId) async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();
    // print("comp");
    try {
      final response = await _apiService.getComplaintToken(studentId);
      // print(response);
      if (response['success'] == true) {

        await _storage.write(key: 'complaint-token', value: response['token']);
        _hasError = false;
      } else {
        _hasError = true;
        _error = response['message'] ?? 'Failed to generate complaint token';
      }
    } catch (e) {
      _hasError = true;
      _error = 'Connection error. Please check your internet.';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchComplaints(String studentId) async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();
    // print("fetch");
    try {
      
      final response = await _apiService.getComplaints(studentId);
      // print(response);
      if (response['success'] == true) {
        final outer = response['data'] as Map<String, dynamic>;
        final rawList = outer['data'];

        if (rawList is List) {
          _complaints = rawList
            .map((item) => Complaint.fromJson(
                Map<String, dynamic>.from(item as Map)))
            .toList();
          _hasError = false;
        }
        else {
        // In case the server sends an unexpected shape
        _hasError = true;
        _error = 'Unexpected data format from server.';
      }
      }
      else {
        _hasError = true;
        _error = response['message'] ?? 'Failed to load complaints';
      }
    } catch (e) {
      _hasError = true;
      _error = 'Connection error. Please check your internet.';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addComplaint(Map<String, dynamic> completeFormData) async {
    // Make a copy to ensure it's not affected by reference
    final formDataCopy = Map<String, dynamic>.from(completeFormData);
    
    _isLoading = true;
    _hasError = false;
    notifyListeners();

    try {
      // Pass the copy to maintain integrity
      final response = await _apiService.postComplaint(formDataCopy);

      if (response['success'] == true) {
        // print("Complaint added successfully");
      } else {
        _hasError = true;
        _error = response['message'] ?? 'Failed to load complaints';
      }
    } catch (e) {
      _hasError = true;
      _error = 'Connection error. Please check your internet.';
    }

    _isLoading = false;
    notifyListeners();
  }
}