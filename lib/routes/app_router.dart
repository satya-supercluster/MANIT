import 'package:flutter/material.dart';
import 'package:manit/presentation/screens/splash_screen.dart';
import 'package:provider/provider.dart';

import '../presentation/screens/login_screen.dart';
import '../presentation/providers/auth_provider.dart';
import '../presentation/screens/dashboard_screen.dart';


class AppRouter {
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String splash='/';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      
      case dashboard:
        return ProtectedRoute(builder: (_) => DashboardScreen());

      case splash:
        return ProtectedRoute(builder: (_) => SplashScreen());

      
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}

// Custom route that checks authentication status
class ProtectedRoute extends MaterialPageRoute {
  ProtectedRoute({required super.builder});

  @override
  Widget buildContent(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // If not authenticated, redirect to login screen
    if (!authProvider.isAuthenticated) {
      return LoginScreen();
    }
    
    // If authenticated, proceed to the requested screen
    return super.buildContent(context);
  }
}

// For public routes that are accessible to all users
class PublicRoute extends MaterialPageRoute {
  PublicRoute({required super.builder});
}