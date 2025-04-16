import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  // Replace with your college API base URL
  // final String baseUrl = 'https://complaint-portal-manit-backend.onrender.com';
  final String baseUrl = 'https://erpapi.manit.ac.in/api';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  final Dio dio;

  ApiService({required this.dio});

  // Get auth headers
  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.read(key: 'token');
    return {
      'Content-Type': 'application/json',
      'Authorization': token != null ? 'Bearer $token' : '',
    };
  }

  // Login endpoint
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await dio.post(
        '$baseUrl/login',
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: jsonEncode({
          'username': username,
          'password': password,
        }),
      );
      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Invalid username or password',
        };
      } else {
        return {
          'success': false,
          'message': 'Server error. Please try again later.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error. Please check your internet.',
      };
    }
  }

  // Get student profile info
  Future<Map<String, dynamic>> getStudentProfile() async {
    try {
      final response = await dio.get(
        '$baseUrl/student_profile_check',
        options: Options(headers: await _getHeaders()),
      );
      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      } else if (response.statusCode == 401) {
        return {'success': false, 'message': 'Unauthorized access'};
      } else {
        return {'success': false, 'message': 'Failed to load profile'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error'};
    }
  }

  // Get student profile image
  Future<Map<String, dynamic>> getStudentProfileImage() async {
    try {
      final response = await dio.get(
        '$baseUrl/student_profile',
        options: Options(headers: await _getHeaders()),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      } else if (response.statusCode == 401) {
        return {'success': false, 'message': 'Unauthorized access'};
      } else {
        return {'success': false, 'message': 'Failed to load profile'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error'};
    }
  }

  // Get Results with GPA
  Future<Map<String, dynamic>> getResults() async {
    try {
      final response = await dio.get(
        '$baseUrl/student_result',
        options: Options(headers: await _getHeaders()),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      } else {
        return {'success': false, 'message': 'Failed to load grades'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error'};
    }
  }

  // Get course schedule
  Future<Map<String, dynamic>> getCourseSchedule() async {
    try {
      final response = await dio.get(
        '$baseUrl/student/schedule',
        options: Options(headers: await _getHeaders()),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      } else {
        return {'success': false, 'message': 'Failed to load schedule'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error'};
    }
  }

  // Get campus announcements
  Future<Map<String, dynamic>> getAnnouncements() async {
    try {
      final response = await dio.get(
        '$baseUrl/announcements',
        options: Options(headers: await _getHeaders()),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      } else {
        return {'success': false, 'message': 'Failed to load announcements'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error'};
    }
  }

  // Get enrollment information
  Future<Map<String, dynamic>> getEnrollmentInfo() async {
    try {
      final response = await dio.get(
        '$baseUrl/student/enrollment',
        options: Options(headers: await _getHeaders()),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      } else {
        return {'success': false, 'message': 'Failed to load enrollment info'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error'};
    }
  }
  
  // Get fee status
  Future<Map<String, dynamic>> getFeeStatus() async {
    try {
      final response = await dio.get(
        '$baseUrl/student/fee-status',
        options: Options(headers: await _getHeaders()),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      } else {
        return {'success': false, 'message': 'Failed to load fee status'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error'};
    }
  }
}