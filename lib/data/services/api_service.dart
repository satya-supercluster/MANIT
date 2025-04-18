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
    // Step 1: Login to get authentication token and studentId
    final loginResponse = await dio.post(
      '$baseUrl/login',
      options: Options(headers: {'Content-Type': 'application/json'}),
      data: jsonEncode({
        'username': username,
        'password': password,
      }),
    );
    
    if (loginResponse.statusCode != 200) {
      if (loginResponse.statusCode == 401) {
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
    }
    // print(loginResponse);
    // Extract authentication token and studentId from login response
    final loginData = loginResponse.data;
    final token = loginData['token']; // Assuming token is in the response
    final studentId = loginData['userInfo']?['uid']; // Assuming studentId is in the response
    if (token == null || studentId == null) {
      return {
        'success': false,
        'message': 'Authentication successful but missing required data',
      };
    }
    
    // Prepare headers with authentication token
    final authHeaders = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    
    // Step 2: Get student profile information
    final profileResponse = await dio.post(
      '$baseUrl/student_profile_check',
      options: Options(headers: authHeaders),
      data: jsonEncode({
        'uid': studentId,
      }),
    );
    if (profileResponse.statusCode != 200) {
      if (profileResponse.statusCode == 401) {
        return {'success': false, 'message': 'Unauthorized access to profile data'};
      } else {
        return {'success': false, 'message': 'Failed to load profile data'};
      }
    }
    // print(profileResponse);
    final profileData = profileResponse.data;
    
    // Step 3: Get student profile image
    final profileImageResponse = await dio.post(
      '$baseUrl/student_profile',
      options: Options(headers: authHeaders),
      data: jsonEncode({
        'uid': studentId,
      }),
    );
    
    if (profileImageResponse.statusCode != 200) {
      if (profileImageResponse.statusCode == 401) {
        return {'success': false, 'message': 'Unauthorized access to profile image'};
      } else {
        return {'success': false, 'message': 'Failed to load profile image'};
      }
    }
    // print(profileImageResponse);
    final profileImageData = profileImageResponse.data;
    
    // Step 5: Get result Data
    final resultResponse = await dio.post(
      '$baseUrl/student_result',
      options: Options(headers: authHeaders),
      data: jsonEncode({
        'uid': studentId,
      }),
    );
    
    if (resultResponse.statusCode != 200) {
      if (resultResponse.statusCode == 401) {
        return {'success': false, 'message': 'Unauthorized access to result'};
      } else {
        return {'success': false, 'message': 'Failed to load result'};
      }
    }
    // print(resultResponse);
    final resultData = resultResponse.data;
    
    // Step 5: Combine all data and return a complete response
    return {
      'success': true,
      'data': {
        'loginData': loginData,
        'profileData': profileData,
        'profileImageData': profileImageData,
        'resultData': resultData,
      }
    };
    
  } catch (e) {
    return {
      'success': false,
      'message': 'Connection error. Please check your internet connection.',
      'error': e.toString(),
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