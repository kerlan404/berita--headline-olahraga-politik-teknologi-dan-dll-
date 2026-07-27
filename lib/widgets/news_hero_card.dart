import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/date_formatter.dart';
import '../data/models/news_article.dart';
import 'bookmark_button.dart';

class NewsHeroCard extends StatelessWidget {
  final NewsArticle article;
  final VoidCallback onTap;
  final double scrollOffset;

  const NewsHeroCard({
    super.key,
    required this.article,
    required this.onTap,
    this.scrollOffset = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: AppTheme.dividerFor(isDark).withValues(alpha: 0.5),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero image 16:9 with overlay
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Background image with parallax
                  if (article.urlToImage != null && article.urlToImage!.isNotEmpty)
                    ClipRect(
                      child: Transform.translate(
                        offset: Offset(0, -scrollOffset * 0.15),
                        child: ColorFiltered(
                          colorFilter: const ColorFilter.matrix(<double>[
                            0.33, 0.33, 0.33, 0, 0,
                            0.33, 0.33, 0.33, 0, 0,
                            0.33, 0.33, 0.33, 0, 0,
                            0, 0, 0, 1, 0,
                          ]),
                          child: CachedNetworkImage(
                            imageUrl: article.urlToImage!,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              color: AppTheme.cardBgFor(isDark),
                            ),
                            errorWidget: (_, __, ___) => Container(
                              color: AppTheme.cardBgFor(isDark),
                              child: const Icon(Icons.broken_image, size: 40,
                                  color: AppTheme.textSecondary),
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      color: AppTheme.cardBgFor(isDark),
                      child: const Icon(Icons.image_not_supported, size: 40,
                          color: AppTheme.textSecondary),
                    ),

                  // Gradient overlay - bottom to top
                  Positioned(
                    left: 0, right: 0, bottom: 0,
                    height: 140,
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.85),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // HEADLINE badge top-left
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      color: AppTheme.primaryContainer,
                      child: Text(
                        'HEADLINE',
                        style: AppTheme.labelBold.copyWith(
                          fontSize: 10,
                          color: Colors.white,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),

                  // Bookmark top-right
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: BookmarkButton(
                          article: article,
                          iconSize: 18,
                          inactiveColor: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  // Title overlay at bottom
                  Positioned(
                    left: 0, right: 0, bottom: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Time & Source
                          Row(
                            children: [
                              Icon(Icons.schedule, size: 12,
                                  color: Colors.white.withValues(alpha: 0.8)),
                              const SizedBox(width: 4),
                              Text(
                                DateFormatter.getRelativeTime(article.publishedAt).toUpperCase(),
                                style: AppTheme.labelSm.copyWith(
                                  fontSize: 10,
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                article.sourceName?.toUpperCase() ?? 'NEWS',
                                style: AppTheme.labelBold.copyWith(
                                  fontSize: 10,
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Title - Anton uppercase
                          Text(
                            article.title,
                            style: AppTheme.headlineMd.copyWith(
                              color: Colors.white,
                              fontSize: 20,
                              shadows: const [
                                Shadow(
                                  color: Colors.black54,
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Description below image
            if (article.description != null && article.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Text(
                  article.description!,
                  style: AppTheme.bodyMd.copyWith(
                    color: AppTheme.textSecondaryFor(isDark),
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
