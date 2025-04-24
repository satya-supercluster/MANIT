import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/auth_provider.dart';
import './login_screen.dart';
import './dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  String _statusMessage = 'Initializing...';
  bool _isCheckingAuth = true;
  late AnimationController _logoController;
  String _currentFact = '';
  final Random _random = Random();
  
  // List of facts about MANIT
  final List<String> _facts = [
    'Did you know? MANIT was established in 1960 as Maulana Azad College of Technology (MACT).',
    'Fun Fact: Our campus spans over 650 acres of lush greenery in the heart of Bhopal.',
    'Tip: Use the dashboard to track your academic performance and attendance.',
    'Did you know? We have over 30 student clubs ranging from technical to cultural activities.',
    'Fun Fact: Our alumni network spans across 60+ countries worldwide.',
    'Did you know? MANIT was renamed from MACT and declared an NIT in 2002.',
    'Fun Fact: The institute is named after India\'s first Education Minister, Maulana Abul Kalam Azad.',
    'Tip: The Central Library remains open until midnight during exam periods.',
    'Did you know? MANIT offers 10 undergraduate programs in engineering.',
    'Fun Fact: Our campus houses over 5,000 students from across India.',
    'Did you know? MANIT has 16 academic departments offering various specializations.',
    'Tip: Register for the Training & Placement Cell portal to access job opportunities.',
    'Fun Fact: The annual technical festival "Technosearch" attracts participants from all over India.',
    'Did you know? MANIT was granted deemed university status in 2002.',
    'Fun Fact: The campus has its own post office with PIN code 462051.',
    'Did you know? MANIT ranks consistently among the top 50 engineering institutes in India.',
    'Tip: Join the National Service Scheme (NSS) for community service opportunities.',
    'Fun Fact: The cultural festival "Maffick" showcases talents across various art forms.',
    'Did you know? MANIT has separate hostels for international students.',
    'Fun Fact: The institute has 11 boys\' hostels and 3 girls\' hostels on campus.',
    'Did you know? MANIT has collaborations with several international universities for research.',
    'Tip: Visit the Career Development Cell for guidance on higher education and placements.',
    'Fun Fact: The campus has its own shopping complex with essential services.',
    'Did you know? MANIT\'s Entrepreneurship Cell helps students launch their startups.',
    'Fun Fact: The institute has a dedicated Sports Complex with facilities for multiple games.',
    'Did you know? MANIT conducts the Central Counselling Board (CCB) examinations.',
    'Tip: The Institute\'s Management Information System helps track academic progress online.',
    'Fun Fact: The institute has a fully equipped health center for medical emergencies.',
    'Did you know? MANIT has its own FM radio station run by students.',
    'Fun Fact: The campus has an Olympic-sized swimming pool.',
    'Did you know? MANIT hosts the annual "Alumni Meet" to strengthen the alumni network.',
    'Tip: Participate in the Institute\'s Innovation Cell to develop entrepreneurial skills.',
    'Fun Fact: The institute has partnerships with industry giants like Microsoft and Google.',
    'Did you know? MANIT\'s Robotics Club participates in national-level competitions.',
    'Fun Fact: The campus has its own bank branches and ATMs for financial services.',
    'Did you know? MANIT offers dual degree programs in select engineering branches.',
    'Tip: Utilize the Digital Library for accessing thousands of e-journals and books.',
    'Fun Fact: The institute celebrates "Engineer\'s Day" with special technical events.',
    'Did you know? MANIT has a dedicated Intellectual Property Rights Cell.',
    'Fun Fact: The campus has a meteorological observatory for weather monitoring.',
    'Did you know? MANIT\'s placement record includes multinational companies from various sectors.',
    'Tip: Join technical chapters like IEEE, ACM, or ISTE for professional development.',
    'Fun Fact: The institute has a solar power plant contributing to campus electricity needs.',
    'Did you know? MANIT conducts faculty development programs throughout the year.',
    'Fun Fact: The campus has Wi-Fi connectivity across all academic and residential areas.',
    'Did you know? MANIT offers PhD programs in all engineering departments.',
    'Tip: Use the institute\'s online grievance redressal system for addressing issues.',
    'Fun Fact: The institute has a dedicated Innovation and Incubation Center for startups.',
    'Did you know? MANIT hosts national conferences and symposiums regularly.',
    'Fun Fact: The institute implements rainwater harvesting across the campus.'
  ];
  
  // Set of already shown facts to prevent repetition
  final Set<int> _shownFactsIndices = {};
  
  @override
  void initState() {
    super.initState();
    
    // Setup animation controller
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    
    _logoController.forward();
    
    // Display an initial random fact
    _selectRandomFact();
    
    // Start a timer to change facts every 5 seconds
    _startFactRotation();
    
    // Check authentication status after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthStatus();
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    super.dispose();
  }
  
  void _selectRandomFact() {
    // Reset shown facts if we've shown all of them
    if (_shownFactsIndices.length >= _facts.length) {
      _shownFactsIndices.clear();
    }
    
    // Find a fact we haven't shown yet
    int randomIndex;
    do {
      randomIndex = _random.nextInt(_facts.length);
    } while (_shownFactsIndices.contains(randomIndex));
    
    // Add this fact to our shown set
    _shownFactsIndices.add(randomIndex);
    
    setState(() {
      _currentFact = _facts[randomIndex];
    });
  }
  
  void _startFactRotation() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _selectRandomFact();
        _startFactRotation();
      }
    });
  }

  Future<void> _checkAuthStatus() async {
    print("check status");
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.initialize();
      print(authProvider.canCheckBiometrics);
      print(authProvider.isBiometricEnabled);
      // First try biometric authentication
      if (authProvider.canCheckBiometrics && authProvider.isBiometricEnabled) {
        print("can");
        setState(() {
          _statusMessage = 'Waiting for biometric authentication...';
        });
        
        final biometricSuccess = await authProvider.authenticateWithBiometrics();
        print("bbbio: $biometricSuccess");
        if (!mounted) return;
        
        if (biometricSuccess) {
          // If biometric auth succeeds, navigate to dashboard
          print('Biometric authentication successful!');
          _navigateToDashboard();
          return;
        } else {
          // If biometric fails, update status message
          print('Biometric authentication failed, trying regular auth...');
          setState(() {
            _statusMessage = 'Checking saved credentials...';
          });
        }
      }
      
      // If biometric not available or failed, initialize regular auth
      await authProvider.initAuth();
      
      if (!mounted) return;
      
      // Check if we got authenticated through initAuth
      if (authProvider.isAuthenticated) {
        print('Regular authentication successful!');
        _navigateToDashboard();
      } else {
        print('All authentication methods failed, going to login screen.');
        _navigateToLogin();
      }
    } catch (e) {
      print('Error during authentication check: $e');
      if (mounted) {
        _navigateToLogin();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingAuth = false;
        });
      }
    }
  }
  
  void _navigateToDashboard() {
    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const DashboardScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = 0.0;
            const end = 1.0;
            const curve = Curves.easeInOut;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var fadeAnimation = animation.drive(tween);
            return FadeTransition(opacity: fadeAnimation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    });
  }
  
  void _navigateToLogin() {
    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = 0.0;
            const end = 1.0;
            const curve = Curves.easeInOut;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var fadeAnimation = animation.drive(tween);
            return FadeTransition(opacity: fadeAnimation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo with clean animation
              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, -0.2),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _logoController,
                  curve: Curves.easeOut,
                )),
                child: FadeTransition(
                  opacity: _logoController,
                  child: Container(
                    height: 140,
                    width: 140,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: 1,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/manit_logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 50),
              
              // Title with animation
              Text(
                'MANIT - Academic Portal',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                  letterSpacing: 0.5,
                ),
              )
              .animate()
              .fadeIn(duration: 600.ms, delay: 300.ms)
              .slideY(begin: 0.2, end: 0, duration: 600.ms, curve: Curves.easeOut),
              
              const SizedBox(height: 8),
              
              // Subtitle with animation
              Text(
                'Your complete academic solution',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  letterSpacing: 0.5,
                ),
              )
              .animate()
              .fadeIn(duration: 600.ms, delay: 500.ms),
              
              const SizedBox(height: 60),
              
              // Animated loading indicator
              if (_isCheckingAuth)
                _buildLoadingIndicator(context),
              
              const SizedBox(height: 16),
              
              // Status message
              AnimatedOpacity(
                opacity: _isCheckingAuth ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Text(
                  _statusMessage,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blue[800],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Random fact with animation
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.2),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: Container(
                  key: ValueKey<String>(_currentFact),
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    _currentFact,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildLoadingIndicator(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final accentColor = Theme.of(context).colorScheme.secondary;
    
    return SizedBox(
      width: 100,
      height: 4,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Animated loading bar
          Container(
            width: 20,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, accentColor],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          )
          .animate(onPlay: (controller) => controller.repeat())
          .slideX(
            begin: -2,
            end: 2,
            duration: 1500.ms,
            curve: Curves.easeInOut,
          ),
        ],
      ),
    );
  }
}