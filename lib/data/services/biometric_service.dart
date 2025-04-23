import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class BiometricService {
  static final LocalAuthentication _localAuth = LocalAuthentication();
  
  // Check if device supports biometrics
  static Future<bool> checkBiometricSupport() async {
    try {
      bool p=await _localAuth.canCheckBiometrics;
      print(p);
      return p;
    } on PlatformException catch (e) {
      print('Error checking biometric support: $e');
      return false;
    }
  }
  
  // Get available biometric types
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      print('Error getting available biometrics: $e');
      return [];
    }
  }
  
  // Authenticate user
  static Future<bool> authenticate({String reason = 'Authenticate to continue'}) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } on PlatformException catch (e) {
      print('Error authenticating: $e');
      return false;
    }
  }
}