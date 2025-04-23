import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:manit/routes/app_router.dart';
import 'dart:convert';
import '../../data/services/api_service.dart';
import '../../data/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String _error = '';
  User? _currentUser;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _canCheckBiometrics = false;
  bool _isBiometricEnabled = false;

  final ApiService _apiService;
  AuthProvider({required Dio dio}) : _apiService = ApiService(dio: dio) {
    _checkBiometricAvailability();
  }

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String get error => _error;
  User? get currentUser => _currentUser;
  bool get canCheckBiometrics => _canCheckBiometrics;
  bool get isBiometricEnabled => _isBiometricEnabled;

  // Check if biometric authentication is available
  Future<void> _checkBiometricAvailability() async {
    try {
      _canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final biometricTypes = await _localAuth.getAvailableBiometrics();
      _canCheckBiometrics = _canCheckBiometrics && biometricTypes.isNotEmpty;
      
      // Check if biometric login is enabled in user preferences
      _isBiometricEnabled = await _storage.read(key: 'biometric_enabled') == 'true';
    } on PlatformException catch (e) {
      print('Biometric check failed: $e');
      _canCheckBiometrics = false;
      _isBiometricEnabled = false;
    }
    notifyListeners();
  }

  // Toggle biometric login
  Future<void> setBiometricEnabled(bool enabled) async {
    _isBiometricEnabled = enabled;
    await _storage.write(key: 'biometric_enabled', value: enabled.toString());
    notifyListeners();
  }

  // Authenticate using biometrics
  Future<bool> authenticateWithBiometrics() async {
    if (!_canCheckBiometrics || !_isBiometricEnabled) return false;
    
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access MANIT Academic Portal',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (authenticated) {
        // Get stored credentials and try to login
        final storedUsername = await _storage.read(key: 'username');
        final storedPassword = await _storage.read(key: 'password');
        
        if (storedUsername != null && storedPassword != null) {
          // Silently login without showing loading state
          final bool success = await _silentLogin(storedUsername, storedPassword);
          return success;
        }
      }
      return false;
    } catch (e) {
      print('Biometric authentication error: $e');
      return false;
    }
  }

  // Silent login for biometric auth (doesn't update loading state)
  Future<bool> _silentLogin(String username, String password) async {
    try {
      final response = await _apiService.login(username, password);
      if (response['success']) {
        _currentUser = User.fromJson(response['data']);
        _isAuthenticated = true;
        await _storage.write(key: 'user', value: jsonEncode(_currentUser!.toJson()));
        await _storage.write(key: 'token', value: response['token']);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Initialize auth state from storage
  Future<void> initAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      // First try biometric authentication if enabled
      if (_isBiometricEnabled) {
        final biometricSuccess = await authenticateWithBiometrics();
        if (biometricSuccess) {
          _isLoading = false;
          notifyListeners();
          return;
        }
      }

      // Fall back to token-based authentication
      final userJson = await _storage.read(key: 'user');
      final token = await _storage.read(key: 'token');

      if (userJson != null && token != null) {
        _currentUser = User.fromJson(jsonDecode(userJson));
        _isAuthenticated = true;
      }
    } catch (e) {
      _error = 'Failed to initialize auth state';
      await _storage.delete(key: 'user');
      await _storage.delete(key: 'token');
      _isAuthenticated = false;
      _currentUser = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  // Login function
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = '';
    notifyListeners();
    
    try {
      final response = await _apiService.login(username, password);
      if (response['success']) {
        _currentUser = User.fromJson(response['data']);
        _isAuthenticated = true;
        
        // Save user and token data
        await _storage.write(key: 'user', value: jsonEncode(_currentUser!.toJson()));
        await _storage.write(key: 'token', value: response['token']);
        
        // Store credentials if biometric is enabled (for future biometric logins)
        if (_isBiometricEnabled) {
          await _storage.write(key: 'username', value: username);
          await _storage.write(key: 'password', value: password);
        }
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Login failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Failed to connect to server. Please check your internet connection. $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout function
  Future<void> logout(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Keep biometric settings when logging out
      final biometricEnabled = _isBiometricEnabled;
      
      // Clear auth data but keep settings
      await _storage.delete(key: 'user');
      await _storage.delete(key: 'token');
      await _storage.delete(key: 'username');
      await _storage.delete(key: 'password');
      
      // Restore biometric setting
      if (biometricEnabled) {
        await _storage.write(key: 'biometric_enabled', value: 'true');
      }
      
      _isAuthenticated = false;
      _currentUser = null;

      // Navigate to login screen
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRouter.login,
        (route) => false,
      );
    } catch (e) {
      _error = 'Failed to logout';
    }

    _isLoading = false;
    notifyListeners();
  }
}