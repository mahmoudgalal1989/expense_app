import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_app/screens/onboarding/onboarding_screen.dart';
import 'package:expense_app/main_page.dart';
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

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    // Check if onboarding is completed
    final prefs = await SharedPreferences.getInstance();
    final isOnboardingComplete = prefs.getBool('onboarding_completed') ?? false;

    // Wait for 2.5 seconds
    await Future.delayed(const Duration(seconds: 2, milliseconds: 500));

    if (!mounted) return;

    // Navigate based on onboarding status
    if (isOnboardingComplete) {
      // If onboarding is complete, navigate to the main app
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const MainPage(),
          ),
        );
      }
    } else {
      // Otherwise, show the onboarding flow
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const OnboardingScreen(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GlowOverlay(
        baseColor: const Color(0xFF0B0F12),
        spots: const [
          GlowSpot(
            pos: Offset(0.75, 0.18), // x75%, y18%
            radius: 391,
            intensity: 0.8, // 80% density
            color: Color(0xFF008AFF), // Blue color
          ),
        ],
      ),
    );
  }
}
