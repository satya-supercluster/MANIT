import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:manit/presentation/screens/splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

import 'core/constants/app_theme.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/student_data_provider.dart';
import 'presentation/providers/complaint_provider.dart';
import 'presentation/providers/theme_provider.dart'; // Add this import

final dio = Dio();

void setupCertificatePinning() {
  const pinnedFingerprint = '5EE4E546F8BC2E4612DB7C13FF5FC8143EB7C6128F518A3F582E3F581CE0A5AF';

  (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
    final client = HttpClient();
    client.badCertificateCallback = (X509Certificate cert, String host, int port) {
      final sha256Hex = sha256.convert(cert.der).bytes
          .map((b) => b.toRadixString(16).padLeft(2, '0'))
          .join()
          .toUpperCase();
      return sha256Hex == pinnedFingerprint;
    };
    return client;
  };
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupCertificatePinning();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(dio: dio),
        ),
        ChangeNotifierProvider(
          create: (_) => StudentDataProvider(dio: dio),
        ),
        ChangeNotifierProvider(
          create: (_) => ComplaintProvider(dio: dio),
        ),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(), // Add the theme provider
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'MANIT - Academic Portal',
            theme: AppTheme.lightTheme(),
            darkTheme: AppTheme.darkTheme(),
            themeMode: themeProvider.themeMode, // Use the theme from provider
            home: SplashScreen(),
          );
        },
      ),
    );
  }
}