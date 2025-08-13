import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../insights/insights_screen.dart';
import '../../theme/app_colors.dart';
import '../../widgets/quanto_text.dart';
import '../../widgets/quanto_button.dart';

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

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  // Main Animation Controllers
  late AnimationController _contentController;
  late AnimationController _transitionController;
  late AnimationController _imageController;
  
  // Content Animations
  late Animation<Offset> _contentSlide;
  late Animation<double> _contentOpacity;
  
  // Image Transition Animations
  late Animation<double> _imageFadeOut;
  late Animation<double> _imageFadeIn;
  late Animation<Offset> _imageSlideOut;
  
  int _currentStep = 1; // Current onboarding step (1-3)
  final int _totalSteps = 3;
  bool _isTransitioning = false;
  bool _isAnimating = false;
  


  @override
  void initState() {
    super.initState();
    
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );
    
    // Initialize animation controllers
    _contentController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _transitionController = AnimationController(
      duration: const Duration(milliseconds: 700), // Smooth 700ms transitions
      vsync: this,
    );
    
    _imageController = AnimationController(
      duration: const Duration(milliseconds: 500), // Smooth 500ms image transitions
      vsync: this,
    );
    
    _initializeAnimations();
    
    // Start content animation
    _contentController.forward();
  }
  
  void _initializeAnimations() {
    // Content animations
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));
    
    _contentOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    ));
    
    // Image transition animations
    _imageFadeOut = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _imageController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeInQuart),
    ));
    
    _imageSlideOut = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.8),
    ).animate(CurvedAnimation(
      parent: _imageController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeInCubic),
    ));
    
    _imageFadeIn = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _imageController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutQuart),
    ));
    
    // Removed _imageScaleIn - now using direct Transform.scale calculation
  }

  @override
  void dispose() {
    _contentController.dispose();
    _transitionController.dispose();
    _imageController.dispose();
    super.dispose();
  }
  


  Widget _buildImageDisplay() {
    return AnimatedBuilder(
      animation: _imageController,
      builder: (context, child) {
        // Special case for step 3: show both onboarding-3 and onboarding-4 together with overlap
        if (_currentStep == 3 && !_isAnimating) {
          // Static state for step 3 - show both images overlapping with correct sizes
          return Stack(
            alignment: Alignment.center,
            children: [
              // onboarding-4.png (bottom z-order layer - positioned higher up with overlap)
              Positioned(
                top: 20, // Adjusted to maintain overlap within larger container
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'assets/images/onboarding-4.png',
                    width: 309,
                    height: 309,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              // onboarding-3.png (top z-order layer - positioned at container bottom)
              Positioned(
                bottom: 0, // At container bottom, now touches header since spacer removed
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'assets/images/onboarding-3.png',
                    width: 311,
                    height: 267,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          );
        }
        
        // Special animation from step 2 to step 3 with onboarding-4 sliding from center to top
        if (_currentStep == 3 && _isAnimating) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // onboarding-2.png sliding out and fading out completely
              Transform.translate(
                offset: Offset(0, -_imageController.value * 200), // Slide up and out
                child: Opacity(
                  opacity: (1.0 - _imageController.value).clamp(0.0, 1.0), // Fade out from 1.0 to 0.0
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/images/onboarding-2.png',
                      height: 300,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              // onboarding-4.png sliding from higher position to final overlapping position
              Positioned(
                top: 75 - (55 * _imageController.value), // From 75px to 20px (maintains overlap)
                child: Opacity(
                  opacity: _imageController.value,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/images/onboarding-4.png',
                      width: 309,
                      height: 309,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              // onboarding-3.png fading in at container bottom
              Positioned(
                bottom: 0, // Match static position - touches header with spacer removed
                child: Opacity(
                  opacity: _imageController.value,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/images/onboarding-3.png',
                      width: 311,
                      height: 267,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ],
          );
        }
        
        // Normal animation for steps 1->2 and 2->3 (without special case)
        if (_isAnimating) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Next image (behind, sliding up from bottom with opacity increase)
              Transform.translate(
                offset: Offset(0, 50 * (1 - _imageController.value)), // Slide up from 50px below
                child: Opacity(
                  opacity: _imageController.value, // Opacity increases as it slides up
                  child: Transform.scale(
                    scale: 0.95 + (0.05 * _imageController.value), // Subtle scale from 0.95 to 1.0
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'assets/images/onboarding-$_currentStep.png',
                        height: 300,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
              
              // Current image (on top, sliding up and fading out)
              SlideTransition(
                position: _imageSlideOut,
                child: FadeTransition(
                  opacity: _imageFadeOut,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/images/onboarding-${_currentStep - 1}.png',
                      height: 300,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ],
          );
        }
        
        // Static state - show current step image
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(
            'assets/images/onboarding-$_currentStep.png',
            height: 300,
            fit: BoxFit.contain,
          ),
        );
      },
    );
  }    
  
  Future<void> _nextStep() async {
    if (_isTransitioning || _isAnimating) return;
    
    if (_currentStep < _totalSteps) {
      _isTransitioning = true;
      _isAnimating = true;
      
      // Start image transition animation
      _imageController.reset();
      
      setState(() {
        _currentStep++;
      });
      
      // Wait for animation to complete
      await _imageController.forward();
      
      setState(() {
        _isTransitioning = false;
        _isAnimating = false;
      });
      
      _imageController.reset();
    } else {
      // Complete onboarding
      await _completeOnboarding();
    }
  }

  Future<void> _previousStep() async {
    if (_isTransitioning || _isAnimating) return;
    
    if (_currentStep > 1) {
      _isTransitioning = true;
      _isAnimating = true;
      
      // Start reverse image transition animation
      _imageController.reset();
      
      setState(() {
        _currentStep--;
      });
      
      // Wait for animation to complete
      await _imageController.reverse();
      
      setState(() {
        _isTransitioning = false;
        _isAnimating = false;
      });
      
      _imageController.reset();
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _completeOnboarding() async {
    // Save onboarding completion status
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);

    if (!mounted) return;

    // Navigate to insights screen with smooth transition
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const InsightsScreen(),
        transitionDuration: const Duration(milliseconds: 600),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  // Helper methods for dynamic text content
  String _getHeaderText() {
    switch (_currentStep) {
      case 1:
        return 'Track income & expenses';
      case 2:
        return 'Spot patterns, stay in control';
      case 3:
        return 'Understand your spending';
      default:
        return 'Track income & expenses';
    }
  }

  String _getSubheaderText() {
    switch (_currentStep) {
      case 1:
        return 'Log your expenses and income in seconds, it\'s fast, simple, and smooth.';
      case 2:
        return 'Visualize your daily spending trends and make smarter decisions.';
      case 3:
        return 'Analyze your breakdowns, contribution to your totals by category and more.';
      default:
        return 'Log your expenses and income in seconds, it\'s fast, simple, and smooth.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.transparent, // Transparent to allow seamless transition
        child: Stack(
            children: [
              // Background will be handled by the transition
              // Only show background if not in transition
              if (ModalRoute.of(context)?.isActive == true)
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: const Color(0xFF0B0F12),
                  child: CustomPaint(
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
                ),
              
              // Top navigation bar
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                    child: Row(
                      children: [
                        // Back button
                        GestureDetector(
                          onTap: () {
                            if (_currentStep > 1) {
                              _previousStep();
                            } else {
                              Navigator.of(context).pop();
                            }
                          },
                          child: SvgPicture.asset(
                            'assets/svg/back_btn.svg',
                            width: 38,
                            height: 38,
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        
                        // Progress indicator in center
                        Expanded(
                          child: Center(
                            child: Container(
                              width: 32, // Total width for progress bar
                              height: 6,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: _currentStep / _totalSteps,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        // Spacer to balance the back button
                        const SizedBox(width: 40),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Onboarding content
              AnimatedBuilder(
                animation: _contentController,
                builder: (context, child) {
                  return SlideTransition(
                    position: _contentSlide,
                    child: FadeTransition(
                      opacity: _contentOpacity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Spacer(flex: 2),
                            
                            // Onboarding image with smooth animation
                            RepaintBoundary(
                              child: SizedBox(
                                height: 500, // Increased to accommodate extended positioning (-50px top/bottom)
                                child: _buildImageDisplay(),
                              ),
                            ),
                            
                            // Dynamic header based on current step
                            QuantoText(
                              _getHeaderText(),
                              styleVariant: 'Header/H3',
                              color: AppColors.textPrimaryDark,
                              textAlign: TextAlign.center,
                            ),
                            
                            const SizedBox(height: 8),
                            
                            // Dynamic description text based on current step
                            QuantoText(
                              _getSubheaderText(),
                              styleVariant: 'Body/B1-L',
                              color: AppColors.textSecondaryDark,
                              textAlign: TextAlign.center,
                            ),
                            
                            const SizedBox(height: 48),
                            
                            // Continue button
                            SizedBox(
                              width: double.infinity,
                              child: QuantoButton(
                                text: 'Continue',
                                onPressed: _nextStep,
                              ),
                            ),
                            
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
    );
  }
}
