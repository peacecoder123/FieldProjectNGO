import 'package:flutter/material.dart';
import 'package:ngo_volunteer_management/app/theme/app_colors.dart';

/// Animated splash screen shown ONCE on app startup as an overlay.
/// After the animation completes, calls [onFinished] to dismiss itself.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.onFinished});

  final VoidCallback onFinished;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final AnimationController _textController;
  late final AnimationController _pulseController;
  late final AnimationController _fadeOutController;

  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _textFade;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _taglineFade;
  late final Animation<double> _pulseAnimation;
  late final Animation<double> _fadeOut;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _logoFade = CurvedAnimation(parent: _logoController, curve: Curves.easeOut);
    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );

    _textController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _textFade = CurvedAnimation(parent: _textController, curve: Curves.easeOut);
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );
    _taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: const Interval(0.4, 1.0, curve: Curves.easeOut)),
    );

    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeOutController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _fadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeOutController, curve: Curves.easeIn),
    );

    _startAnimationSequence();
  }

  Future<void> _startAnimationSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 500));
    _textController.forward();

    await Future.delayed(const Duration(milliseconds: 400));
    _pulseController.repeat(reverse: true);

    // Wait then fade out
    await Future.delayed(const Duration(milliseconds: 1900));
    if (mounted) {
      await _fadeOutController.forward();
      widget.onFinished();
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _pulseController.dispose();
    _fadeOutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FadeTransition(
      opacity: _fadeOut,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
                  : [const Color(0xFFF8FAFC), const Color(0xFFE0E7FF), const Color(0xFFC7D2FE)],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: Listenable.merge([_logoController, _pulseController]),
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _logoFade,
                      child: Transform.scale(
                        scale: _logoScale.value * _pulseAnimation.value,
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.navy500, AppColors.indigo600],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.navy500.withValues(alpha: 0.3),
                          blurRadius: 40,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset('assets/images/logo.png', width: 100, height: 100, fit: BoxFit.cover),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                SlideTransition(
                  position: _textSlide,
                  child: FadeTransition(
                    opacity: _textFade,
                    child: Text(
                      'Jayashree Foundation',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.slate900, letterSpacing: 0.5),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                FadeTransition(
                  opacity: _taglineFade,
                  child: Text(
                    'Making a Difference Together',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: isDark ? AppColors.slate400 : AppColors.slate500, letterSpacing: 1.0),
                  ),
                ),
                const SizedBox(height: 60),
                FadeTransition(
                  opacity: _textFade,
                  child: SizedBox(
                    width: 28, height: 28,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: isDark ? AppColors.navy400 : AppColors.navy500),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
