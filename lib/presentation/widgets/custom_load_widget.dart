import 'package:flutter/material.dart';
import 'dart:math' as math;

class CustomLoadWidget extends StatefulWidget {
  final Color primaryColor;
  final Color secondaryColor;
  final Color dotColor;
  
  const CustomLoadWidget({
    super.key, 
    this.primaryColor = Colors.green,
    this.secondaryColor = Colors.orange,
    this.dotColor = Colors.grey,
  });

  @override
  State<CustomLoadWidget> createState() => _CustomLoadWidgetState();
}

class _CustomLoadWidgetState extends State<CustomLoadWidget> with TickerProviderStateMixin {
  late AnimationController _outerRingController;
  late AnimationController _innerRingController;
  late AnimationController _centerDotController;
  late List<AnimationController> _dotsControllers;
  
  @override
  void initState() {
    super.initState();
    
    // Outer ring animation (clockwise)
    _outerRingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    
    // Inner ring animation (counter-clockwise)
    _innerRingController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
    
    // Center dot pulsing animation
    _centerDotController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
    
    // Bottom dots animation
    _dotsControllers = List.generate(3, (index) {
      return AnimationController(
        duration: const Duration(milliseconds: 1500),
        vsync: this,
      );
    });
    
    // Add delays to the dots
    for (int i = 0; i < _dotsControllers.length; i++) {
      Future.delayed(Duration(milliseconds: 300 * i), () {
        if (mounted) {
          _dotsControllers[i].repeat();
        }
      });
    }
  }
  
  @override
  void dispose() {
    _outerRingController.dispose();
    _innerRingController.dispose();
    _centerDotController.dispose();
    for (var controller in _dotsControllers) {
      controller.dispose();
    }
    super.dispose();
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
              SizedBox(
                height: 150,
                width: 150,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer ring
                    AnimatedBuilder(
                      animation: _outerRingController,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _outerRingController.value * 2 * math.pi,
                          child: CustomPaint(
                            size: const Size(128, 128),
                            painter: SemiCircleBorderPainter(
                              color: widget.primaryColor,
                              startAngle: 0,
                              sweepAngle: math.pi,
                              strokeWidth: 4,
                            ),
                          ),
                        );
                      },
                    ),
                    
                    // Inner ring
                    AnimatedBuilder(
                      animation: _innerRingController,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: -_innerRingController.value * 2 * math.pi,
                          child: CustomPaint(
                            size: const Size(96, 96),
                            painter: SemiCircleBorderPainter(
                              color: widget.secondaryColor,
                              startAngle: math.pi,
                              sweepAngle: math.pi,
                              strokeWidth: 4,
                            ),
                          ),
                        );
                      },
                    ),
                    
                    // Center dot
                    AnimatedBuilder(
                      animation: _centerDotController,
                      builder: (context, child) {
                        final scale = Tween(begin: 1.0, end: 1.2)
                            .chain(CurveTween(curve: Curves.easeInOut))
                            .evaluate(_centerDotController);
                            
                        final opacity = Tween(begin: 0.7, end: 1.0)
                            .chain(CurveTween(curve: Curves.easeInOut))
                            .evaluate(_centerDotController);
                        
                        return Transform.scale(
                          scale: scale,
                          child: Opacity(
                            opacity: opacity,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: widget.dotColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Animated dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return AnimatedBuilder(
                    animation: _dotsControllers[index],
                    builder: (context, child) {
                      final opacity = Tween(begin: 0.4, end: 1.0)
                          .chain(CurveTween(curve: Curves.easeInOut))
                          .animate(_dotsControllers[index])
                          .value;
                      
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(opacity),
                          shape: BoxShape.circle,
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom painter for semi-circle borders
class SemiCircleBorderPainter extends CustomPainter {
  final Color color;
  final double startAngle;
  final double sweepAngle;
  final double strokeWidth;

  SemiCircleBorderPainter({
    required this.color,
    required this.startAngle,
    required this.sweepAngle,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(SemiCircleBorderPainter oldDelegate) {
    return color != oldDelegate.color ||
        startAngle != oldDelegate.startAngle ||
        sweepAngle != oldDelegate.sweepAngle ||
        strokeWidth != oldDelegate.strokeWidth;
  }
}