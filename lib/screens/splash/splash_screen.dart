import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/route_transitions.dart';
import '../main/main_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Logo
  late Animation<double> _logoScale;
  late Animation<double> _logoRotation;
  late Animation<double> _logoOpacity;

  // REEDSFEED text
  late Animation<Offset> _textSlide;
  late Animation<double> _textOpacity;

  // Subtitle
  late Animation<double> _subtitleOpacity;

  // Loading bar
  late Animation<double> _loadingProgress;

  // Glow pulse
  late Animation<double> _glowOpacity;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    // ── Logo: scale bounce + rotation ──
    _logoScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.15),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.15, end: 1.0),
        weight: 10,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.30, curve: Curves.easeOutBack),
      ),
    );

    _logoRotation = Tween<double>(begin: -0.15, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.30, curve: Curves.easeOutCubic),
      ),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.12, curve: Curves.easeOut),
      ),
    );

    // ── Glow pulse ──
    _glowOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.15, 0.50, curve: Curves.easeOut),
      ),
    );

    // ── REEDSFEED text: slide up + fade ──
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.35),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 0.50, curve: Curves.easeOutCubic),
      ),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 0.40, curve: Curves.easeOut),
      ),
    );

    // ── Subtitle ──
    _subtitleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.42, 0.55, curve: Curves.easeOut),
      ),
    );

    // ── Loading progress bar ──
    _loadingProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.45, 1.0, curve: Curves.easeInOut),
      ),
    );

    _controller.forward();

    // Navigate after animation completes
    Future.delayed(const Duration(milliseconds: 2800), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          FadeThroughRoute(page: const MainShell()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Logo with glow, scale, rotation ──
                Opacity(
                  opacity: _logoOpacity.value,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer glow (simplified for perf — no boxShadow on web)
                      if (_glowOpacity.value > 0.3)
                        Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.primaryAccent
                                .withValues(alpha: 0.08 * _glowOpacity.value),
                          ),
                        ),
                      // Logo container
                      Transform.rotate(
                        angle: _logoRotation.value,
                        child: Transform.scale(
                          scale: _logoScale.value,
                          child: Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppTheme.primaryAccent,
                                  Color(0xFFFF4444),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryAccent
                                      .withValues(alpha: 0.4),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.explore_rounded,
                                  color: Colors.white,
                                  size: 42,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'RF',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white.withValues(alpha: 0.8),
                                    letterSpacing: 2.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // ── REEDSFEED text ──
                SlideTransition(
                  position: _textSlide,
                  child: Opacity(
                    opacity: _textOpacity.value,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'REEDS',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'FEED',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                                color: AppTheme.primaryAccent,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // ── Subtitle ──
                Opacity(
                  opacity: _subtitleOpacity.value,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryAccent.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'BERITA & HEADLINE TERKINI',
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 2.5,
                        color: AppTheme.primaryAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 56),

                // ── Animated loading bar ──
                SizedBox(
                  width: 160,
                  height: 3,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: Container(
                      color: AppTheme.surface,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: 160 * _loadingProgress.value,
                          height: 3,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppTheme.primaryAccent,
                                AppTheme.secondaryAccent,
                                AppTheme.primaryAccent,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
