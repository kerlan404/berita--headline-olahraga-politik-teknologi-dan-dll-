import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/date_formatter.dart';
import '../data/models/news_article.dart';
import 'bookmark_button.dart';

class NewsCard extends StatelessWidget {
  final NewsArticle article;
  final VoidCallback onTap;

  const NewsCard({
    super.key,
    required this.article,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBgFor(isDark),
        border: Border.all(
          color: AppTheme.dividerFor(isDark).withValues(alpha: 0.5),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail with grayscale filter
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: article.urlToImage != null && article.urlToImage!.isNotEmpty
                      ? ColorFiltered(
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
                              child: const Icon(Icons.broken_image,
                                  color: AppTheme.textSecondary),
                            ),
                          ),
                        )
                      : Container(
                          color: AppTheme.cardBgFor(isDark),
                          child: const Icon(Icons.image_not_supported,
                              color: AppTheme.textSecondary),
                        ),
                ),
              ),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: SizedBox(
                  height: 100,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Source label + Bookmark
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  article.sourceName?.toUpperCase() ?? 'NEWS',
                                  style: AppTheme.labelBold.copyWith(
                                    fontSize: 10,
                                    color: AppTheme.primaryContainer,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              BookmarkButton(
                                article: article,
                                iconSize: 18,
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          // Title - Anton uppercase
                          Text(
                            article.title,
                            style: AppTheme.headlineMd.copyWith(
                              fontSize: 16,
                              color: AppTheme.textPrimaryFor(isDark),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      // Time
                      Text(
                        DateFormatter.getRelativeTime(article.publishedAt).toUpperCase(),
                        style: AppTheme.labelSm.copyWith(
                          fontSize: 10,
                          color: AppTheme.textSecondaryFor(isDark),
                        ),
                      ),
                    ],
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
