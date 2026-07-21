import 'dart:async';
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../data/models/news_article.dart';
import '../core/utils/date_formatter.dart';

/// ESPN-style Breaking News banner with horizontal auto-scroll ticker.
/// Each ticker item is independently tappable.
class BreakingNewsBanner extends StatefulWidget {
  final List<NewsArticle> articles;
  final void Function(int index) onArticleTap;
  final VoidCallback onDismiss;

  const BreakingNewsBanner({
    super.key,
    required this.articles,
    required this.onArticleTap,
    required this.onDismiss,
  });

  @override
  State<BreakingNewsBanner> createState() => _BreakingNewsBannerState();
}

class _BreakingNewsBannerState extends State<BreakingNewsBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _opacityAnimation;

  late ScrollController _tickerController;
  Timer? _tickerTimer;
  double _scrollPosition = 0;
  double _maxScrollExtent = 0;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();

    // Slide-in animation
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: const Interval(0, 0.3, curve: Curves.easeOut),
      ),
    );

    _tickerController = ScrollController();
    _slideController.forward();

    // Start auto-scroll after a short delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });
  }

  @override
  void didUpdateWidget(BreakingNewsBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.articles != oldWidget.articles) {
      _scrollPosition = 0;
      _startAutoScroll();
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _tickerController.dispose();
    _tickerTimer?.cancel();
    super.dispose();
  }

  void _startAutoScroll() {
    _tickerTimer?.cancel();
    _scrollPosition = 0;

    // Ensure layout is ready before measuring scroll extent
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_tickerController.hasClients) {
        _tickerController.jumpTo(0);
        _maxScrollExtent = _tickerController.position.maxScrollExtent;
      }

      _tickerTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
        if (!mounted || _isPaused) return;
        if (!_tickerController.hasClients) return;

        _maxScrollExtent = _tickerController.position.maxScrollExtent;
        if (_maxScrollExtent <= 0) return;

        _scrollPosition += 1.2;
        if (_scrollPosition >= _maxScrollExtent) {
          _scrollPosition = 0;
        }
        _tickerController.jumpTo(_scrollPosition);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.articles.isEmpty) return const SizedBox.shrink();

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: GestureDetector(
          onHorizontalDragStart: (_) => _isPaused = true,
          onHorizontalDragEnd: (_) => _isPaused = false,
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryAccent.withValues(alpha: 0.12),
                  Colors.transparent,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.primaryAccent.withValues(alpha: 0.15),
                ),
              ),
            ),
            child: Row(
              children: [
                // ── LIVE / BREAKING Badge ──
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  margin: const EdgeInsets.only(left: 4),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppTheme.primaryAccent,
                        Color(0xFFFF1744),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryAccent.withValues(alpha: 0.4),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Pulsing dot
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        'BREAKING',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),

                // ── Ticker News Items ──
                Expanded(
                  child: _buildTickerContent(),
                ),

                // ── Dismiss Button ──
                SizedBox(
                  width: 40,
                  height: 44,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: widget.onDismiss,
                      borderRadius: BorderRadius.circular(8),
                      child: Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: AppTheme.textSecondary.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTickerContent() {
    return ListView.builder(
      controller: _tickerController,
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: widget.articles.length,
      itemBuilder: (context, index) {
        final article = widget.articles[index];
        return GestureDetector(
          onTap: () => widget.onArticleTap(index),
          child: Padding(
            padding: const EdgeInsets.only(right: 32),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Separator
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryAccent.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                // Time
                Text(
                  DateFormatter.getRelativeTime(article.publishedAt),
                  style: TextStyle(
                    fontSize: 10,
                    color: AppTheme.primaryAccent.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                // Title
                Text(
                  article.title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
