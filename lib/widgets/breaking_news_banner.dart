import 'dart:async';
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../data/models/news_article.dart';
import '../core/utils/date_formatter.dart';

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

  late ScrollController _tickerController;
  Timer? _tickerTimer;
  double _scrollPosition = 0;
  double _maxScrollExtent = 0;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
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
    _tickerController = ScrollController();
    _slideController.forward();

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
      child: GestureDetector(
        onHorizontalDragStart: (_) => _isPaused = true,
        onHorizontalDragEnd: (_) => _isPaused = false,
        child: Container(
          height: 44,
          color: AppTheme.darkBackground,
          child: Row(
            children: [
              // BREAKING badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                margin: const EdgeInsets.only(left: 4),
                color: AppTheme.primaryContainer,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'BREAKING',
                      style: AppTheme.labelBold.copyWith(
                        fontSize: 9,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),

              // Ticker news items
              Expanded(
                child: ListView.builder(
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
                            Container(
                              width: 4, height: 4,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryContainer.withValues(alpha: 0.5),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              DateFormatter.getRelativeTime(article.publishedAt).toUpperCase(),
                              style: AppTheme.labelSm.copyWith(
                                fontSize: 10,
                                color: AppTheme.primaryContainer.withValues(alpha: 0.7),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              article.title,
                              style: AppTheme.labelBold.copyWith(
                                fontSize: 12,
                                color: AppTheme.onSurfaceDark,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Dismiss button
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
    );
  }
}
