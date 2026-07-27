import 'dart:async';
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
  late Animation<double> _progressAnim;
  late Animation<double> _logoScale;
  late Animation<double> _brandFade;
  late Animation<Offset> _brandSlide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.35, curve: Curves.easeOutBack),
      ),
    );

    _brandSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.55, curve: Curves.easeOutCubic),
      ),
    );

    _brandFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.45, curve: Curves.easeOut),
      ),
    );

    _progressAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeInOut),
      ),
    );

    _controller.forward();

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
      backgroundColor: AppTheme.darkBackground,
      body: Stack(
        children: [
          // Scanline overlay for broadcast aesthetic
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _ScanlinePainter(),
              ),
            ),
          ),

          // Subtle red glow top-right
          Positioned(
            top: -100,
            right: -100,
            width: 300,
            height: 300,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryContainer.withValues(alpha: 0.08),
                ),
              ),
            ),
          ),

          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _logoScale.value,
                      child: Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryContainer,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryContainer.withValues(alpha: 0.4),
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
                              size: 40,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'RF',
                              style: AppTheme.labelBold.copyWith(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 12,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 36),

                // REEDFEEDS brand
                SlideTransition(
                  position: _brandSlide,
                  child: Opacity(
                    opacity: _brandFade.value,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'REED',
                              style: AppTheme.headlineMd.copyWith(
                                color: Colors.white,
                                fontSize: 34,
                                letterSpacing: 1,
                              ),
                            ),
                            Text(
                              'FEEDS',
                              style: AppTheme.headlineMd.copyWith(
                                color: AppTheme.primaryContainer,
                                fontSize: 34,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'BERITA & HEADLINE TERKINI',
                          style: AppTheme.labelBold.copyWith(
                            color: AppTheme.primaryContainer,
                            fontSize: 10,
                            letterSpacing: 2.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 60),

                // Loading progress bar
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return SizedBox(
                      width: 200,
                      height: 4,
                      child: Container(
                        color: AppTheme.darkSurfaceVariant,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: 200 * _progressAnim.value,
                            height: 4,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryContainer,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryContainer.withValues(alpha: 0.5),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  'INITIALIZING STREAM...',
                  style: AppTheme.labelSm.copyWith(
                    color: AppTheme.secondaryFixedDim,
                    fontSize: 10,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),

          // Bottom branding
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                '© 2026 REEDFEEDS | LIVE DATA FEED',
                style: AppTheme.labelSm.copyWith(
                  color: AppTheme.secondaryFixedDim.withValues(alpha: 0.5),
                  fontSize: 9,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Scanline painter for broadcast graphic aesthetic
class _ScanlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primaryContainer.withValues(alpha: 0.03)
      ..strokeWidth = 1;
    for (double y = 0; y < size.height; y += 4) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
