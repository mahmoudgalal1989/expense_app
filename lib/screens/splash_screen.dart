import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_app/screens/onboarding/onboarding_screen.dart';
import 'package:expense_app/main_page.dart';

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
      backgroundColor: const Color(0xFF283339),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF283339), Color(0xFF0C0F11)],
          ),
        ),
        child: Center(
          child: Semantics(
            label: "Quanto logo",
            header: true,
            child: SvgPicture.asset(
              'assets/svg/splash.svg',
              width: 200,
              height: 200,
            ),
          ),
        ),
      ),
    );
  }
}
