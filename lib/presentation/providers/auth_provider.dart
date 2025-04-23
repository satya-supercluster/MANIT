import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../../data/services/api_service.dart';
import '../../data/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isAuthenticated = false;
  bool canCheckBiometrics=true;
  String _error = '';
  User? _currentUser;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  final ApiService _apiService;
  AuthProvider({required Dio dio}) : _apiService = ApiService(dio: dio);

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String get error => _error;
  User? get currentUser => _currentUser;

  // Initialize auth state from storage
  Future<void> initAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      final userJson = await _storage.read(key: 'user');
      final token = await _storage.read(key: 'token');

      print("hello");
      if (userJson != null && token != null) {
        _currentUser = User.fromJson(jsonDecode(userJson));
        _isAuthenticated = true;
      }
    } catch (e) {
      _error = 'Failed to initialize auth state';
      await logout(); // Reset on error
    }

    _isLoading = false;
    notifyListeners();
  }

  // Login function
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = '';
    notifyListeners();
    // print("in");
    try {
      final response = await _apiService.login(username, password);
      if (response['success']) {
        _currentUser = User.fromJson(response['data']);
        _isAuthenticated = true;
        // Save user and token data
        await _storage.write(key: 'user', value: jsonEncode(_currentUser!.toJson()));
        await _storage.write(key: 'token', value: response['token']);
        // print("login_prov");
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Login failed';
        print(_error);
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Failed to connect to server. Please check your internet connection. $e';
      print(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout function
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _storage.deleteAll();
      _isAuthenticated = false;
      _currentUser = null;
    } catch (e) {
      _error = 'Failed to logout';
    }

    _isLoading = false;
    notifyListeners();
  }
}