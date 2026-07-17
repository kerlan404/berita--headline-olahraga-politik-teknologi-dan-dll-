import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../data/models/news_article.dart';
import '../providers/bookmark_provider.dart';

/// An animated heart button for bookmarking articles.
/// Handles its own scale animation when tapped.
class BookmarkButton extends StatefulWidget {
  final NewsArticle article;
  final double iconSize;
  final Color? activeColor;
  final Color? inactiveColor;

  const BookmarkButton({
    super.key,
    required this.article,
    this.iconSize = 20,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  State<BookmarkButton> createState() => _BookmarkButtonState();
}

class _BookmarkButtonState extends State<BookmarkButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.4), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.4, end: 0.9), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.2), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 25),
    ]).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onTap() {
    final provider = context.read<BookmarkProvider>();
    final wasBookmarked = provider.isBookmarked(widget.article.url);

    provider.toggleBookmark(widget.article);

    // Play bounce animation only when adding bookmark (not removing)
    if (!wasBookmarked) {
      _animController.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BookmarkProvider>(
      builder: (context, provider, child) {
        final isBookmarked = provider.isBookmarked(widget.article.url);

        return GestureDetector(
          onTap: _onTap,
          child: AnimatedBuilder(
            animation: _scaleAnim,
            builder: (context, child) {
              return Transform.scale(
                scale: isBookmarked ? _scaleAnim.value : 1.0,
                child: child,
              );
            },
            child: Icon(
              isBookmarked ? Icons.favorite : Icons.favorite_border,
              size: widget.iconSize,
              color: isBookmarked
                  ? (widget.activeColor ?? AppTheme.primaryAccent)
                  : (widget.inactiveColor ?? AppTheme.textSecondary),
              shadows: isBookmarked
                  ? [
                      Shadow(
                        color: AppTheme.primaryAccent.withValues(alpha: 0.5),
                        blurRadius: 8,
                      ),
                    ]
                  : null,
            ),
          ),
        );
      },
    );
  }
}
