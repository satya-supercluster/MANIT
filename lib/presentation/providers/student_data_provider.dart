import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../data/services/api_service.dart';
import '../../data/repositories/transform_result_data_format.dart';

class StudentDataProvider extends ChangeNotifier {

  final ApiService _apiService;
  StudentDataProvider({required Dio dio}) : _apiService = ApiService(dio: dio);
  
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';

  // Student profile data
  Map<String, dynamic>? _resultData;
  Map<String, dynamic>? _scheduleData;
  List<dynamic>? _announcementsData;
  Map<String, dynamic>? _enrollmentData;
  Map<String, dynamic>? _feeData;

  // Getters
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;
  Map<String, dynamic>? get resultData => _resultData;
  Map<String, dynamic>? get scheduleData => _scheduleData;
  List<dynamic>? get announcementsData => _announcementsData;
  Map<String, dynamic>? get enrollmentData => _enrollmentData;
  Map<String, dynamic>? get feeData => _feeData;

  // Reset state on logout
  void reset() {
    _resultData = null;
    _scheduleData = null;
    _announcementsData = null;
    _enrollmentData = null;
    _feeData = null;
    _hasError = false;
    _errorMessage = '';
    notifyListeners();
  }

  // Fetch Result
  Future<void> fetchResult(String studentId) async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();

    try {
      final response = await _apiService.getResults(studentId);
      
      if (response['success'] == true) {
        print(response['data']);
        _resultData = transformResultDataFormat(response['data']);
        print(_resultData);
        _hasError = false;
      } else {
        _hasError = true;
        // _errorMessage = response['message'] ?? 'Failed to load result';
        _errorMessage = 'Failed to load result';
      }
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Connection error. Please check your internet.';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Fetch course schedule
  Future<void> fetchSchedule() async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();

    try {
      final response = await _apiService.getCourseSchedule();
      
      if (response['success'] == true) {
        _scheduleData = response['data'];
      } else {
        _hasError = true;
        _errorMessage = response['message'] ?? 'Failed to load schedule';
      }
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Connection error. Please check your internet.';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Fetch announcements
  Future<void> fetchAnnouncements() async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();

    try {
      final response = await _apiService.getAnnouncements();
      
      if (response['success'] == true) {
        _announcementsData = response['data'];
      } else {
        _hasError = true;
        _errorMessage = response['message'] ?? 'Failed to load announcements';
      }
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Connection error. Please check your internet.';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Fetch enrollment info
  Future<void> fetchEnrollmentData() async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();

    try {
      final response = await _apiService.getEnrollmentInfo();
      
      if (response['success'] == true) {
        _enrollmentData = response['data'];
      } else {
        _hasError = true;
        _errorMessage = response['message'] ?? 'Failed to load enrollment data';
      }
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Connection error. Please check your internet.';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Fetch fee status
  Future<void> fetchFeeStatus() async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();

    try {
      final response = await _apiService.getFeeStatus();
      
      if (response['success'] == true) {
        _feeData = response['data'];
      } else {
        _hasError = true;
        _errorMessage = response['message'] ?? 'Failed to load fee status';
      }
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Connection error. Please check your internet.';
    }

    _isLoading = false;
    notifyListeners();
  }
}