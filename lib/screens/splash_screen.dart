import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:expense_app/screens/onboarding/onboarding_screen.dart';
import '../theme/app_colors.dart';
import '../widgets/quanto_text.dart';

class GlowSpot {
  /// Position as a fraction of the canvas (0..1). e.g. Offset(0.8, 0.1) = near top-right
  final Offset pos;

  /// Radius in logical pixels
  final double radius;

  /// Core color of the glow
  final Color color;

  /// 0..1 multiplier for brightness
  final double intensity;

  const GlowSpot({
    required this.pos,
    required this.radius,
    this.color = const Color(0xFF2DA9FF),
    this.intensity = 1.0,
  });
}

class GlowOverlay extends StatelessWidget {
  final Color baseColor;
  final List<GlowSpot> spots;

  const GlowOverlay({
    super.key,
    this.baseColor = const Color(0xFF0B0F12), // deep, near-black base
    required this.spots,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: baseColor,
      child: Stack(
        children: [
          CustomPaint(
            painter: _GlowPainter(spots),
            size: Size.infinite,
          ),
          // Quanto text in center
          Center(
            child: QuantoText(
              'Quanto',
              styleVariant: 'Display/D2',
              color: AppColors.textPrimaryDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowPainter extends CustomPainter {
  final List<GlowSpot> spots;

  _GlowPainter(this.spots);

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in spots) {
      final center = Offset(s.pos.dx * size.width, s.pos.dy * size.height);

      // Gradient from #008AFF to #00A1FF with radial fade
      final shader = ui.Gradient.radial(
        center,
        s.radius,
        [
          const Color(0xFF008AFF).withOpacity(0.75 * s.intensity), // Inner gradient start
          const Color(0xFF00A1FF).withOpacity(0.5 * s.intensity),  // Mid gradient
          const Color(0xFF00A1FF).withOpacity(0.25 * s.intensity), // Outer gradient
          Colors.transparent,
        ],
        const [0.0, 0.3, 0.6, 1.0],
      );

      final paint = Paint()
        ..shader = shader
        // 'plus' (additive) blending keeps background dark and adds glow on top
        ..blendMode = BlendMode.plus;

      // Large circle; gradient handles the fade
      canvas.drawCircle(center, s.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GlowPainter old) => old.spots != spots;
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _logoOpacity;
  late Animation<double> _logoScale;

  @override
  void initState() {
    super.initState();
    
    // Set status bar style for dark background
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFF0B0F12),
      systemNavigationBarIconBrightness: Brightness.light,
    ));
    
    // Initialize logo animation controller
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _logoOpacity = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeInOut,
    ));
    
    _logoScale = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _logoController.dispose();
    super.dispose();
  }

  Future<void> _navigateToOnboarding() async {
    // Animate logo out
    await _logoController.forward();
    
    if (!mounted) return;

    // Navigate to onboarding with seamless background transition
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const OnboardingScreen(),
        transitionDuration: const Duration(milliseconds: 800),
        reverseTransitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Create a seamless transition by overlaying content
          return Stack(
            children: [
              // Keep the same background during transition
              Container(
                width: double.infinity,
                height: double.infinity,
                color: const Color(0xFF0B0F12),
                child: CustomPaint(
                  painter: _GlowPainter(const [
                    GlowSpot(
                      pos: Offset(0.75, 0.18), // x75%, y18%
                      radius: 391,
                      intensity: 0.8,
                      color: Color(0xFF008AFF),
                    ),
                  ]),
                  size: Size.infinite,
                ),
              ),
              // Fade in the new content
              FadeTransition(
                opacity: animation,
                child: child,
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: _navigateToOnboarding,
        child: AnimatedBuilder(
          animation: _logoController,
          builder: (context, child) {
            return Container(
              width: double.infinity,
              height: double.infinity,
              color: const Color(0xFF0B0F12),
              child: Stack(
                children: [
                  CustomPaint(
                    painter: _GlowPainter(const [
                      GlowSpot(
                        pos: Offset(0.75, 0.18), // x75%, y18%
                        radius: 391,
                        intensity: 0.8, // 80% density
                        color: Color(0xFF008AFF), // Blue color
                      ),
                    ]),
                    size: Size.infinite,
                  ),
                  // Animated Quanto text in center
                  Center(
                    child: Transform.scale(
                      scale: _logoScale.value,
                      child: Opacity(
                        opacity: _logoOpacity.value,
                        child: QuantoText(
                          'Quanto',
                          styleVariant: 'Display/D2',
                          color: AppColors.textPrimaryDark,
                        ),
                      ),
                    ),
                  ),
                  // Tap instruction at bottom
                  Positioned(
                    bottom: 60,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Opacity(
                        opacity: 1.0 - _logoController.value,
                        child: QuantoText(
                          'Tap to continue',
                          styleVariant: 'Body/B2',
                          color: AppColors.textSecondaryDark.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
