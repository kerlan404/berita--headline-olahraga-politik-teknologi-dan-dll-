import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/news_article.dart';
import '../../widgets/bookmark_button.dart';

class ArticlePreviewScreen extends StatelessWidget {
  final NewsArticle article;

  const ArticlePreviewScreen({
    super.key,
    required this.article,
  });

  Future<void> _openFullArticle(BuildContext context) async {
    final uri = Uri.parse(article.url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuka artikel: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _shareArticle() async {
    final text = '${article.title}\n\n${article.url}';
    await SharePlus.instance.share(
      ShareParams(text: text, subject: article.title),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = article.urlToImage != null && article.urlToImage!.isNotEmpty;

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── SliverAppBar with hero image ──
          SliverAppBar(
            expandedHeight: hasImage ? 340 : 120,
            pinned: true,
            backgroundColor: AppTheme.background,
            leading: IconButton(
              icon: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppTheme.surface.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.divider),
                ),
                child: const Icon(Icons.arrow_back_rounded, size: 20),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              // Share button
              Container(
                width: 38,
                height: 38,
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color: AppTheme.surface.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.divider),
                ),
                child: IconButton(
                  icon: const Icon(Icons.share_rounded, size: 18),
                  tooltip: 'Bagikan',
                  onPressed: _shareArticle,
                  padding: EdgeInsets.zero,
                ),
              ),
              // Bookmark button
              Container(
                width: 38,
                height: 38,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: AppTheme.surface.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.divider),
                ),
                child: Center(
                  child: BookmarkButton(
                    article: article,
                    iconSize: 18,
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: hasImage
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: article.urlToImage!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(color: AppTheme.surface),
                          errorWidget: (_, __, ___) => Container(
                            color: AppTheme.surface,
                            child: const Icon(Icons.image_not_supported_rounded, size: 48, color: AppTheme.textSecondary),
                          ),
                        ),
                        // Bottom gradient
                        Positioned(
                          left: 0, right: 0, bottom: 0, height: 200,
                          child: IgnorePointer(child: Container(
                            decoration: BoxDecoration(gradient: LinearGradient(
                              begin: Alignment.bottomCenter, end: Alignment.topCenter,
                              colors: [AppTheme.background.withValues(alpha: 1.0), AppTheme.background.withValues(alpha: 0.7), Colors.transparent],
                            )),
                          )),
                        ),
                        // Top gradient
                        Positioned(
                          left: 0, right: 0, top: 0, height: 80,
                          child: IgnorePointer(child: Container(
                            decoration: BoxDecoration(gradient: LinearGradient(
                              begin: Alignment.topCenter, end: Alignment.bottomCenter,
                              colors: [Colors.black.withValues(alpha: 0.4), Colors.transparent],
                            )),
                          )),
                        ),
                        // Source badge
                        Positioned(
                          left: 16, bottom: 24,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryAccent,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [BoxShadow(color: AppTheme.primaryAccent.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 4))],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.source_rounded, size: 12, color: Colors.white),
                                const SizedBox(width: 6),
                                Text(article.sourceName?.toUpperCase() ?? 'NEWS',
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1.0)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : Container(color: AppTheme.surface),
            ),
          ),

          // ── Article Content ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ═══ TITLE ═══
                  Text(
                    article.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textPrimary,
                      height: 1.35,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ═══ META: Author + Time + Source ═══
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppTheme.primaryAccent.withValues(alpha: 0.15),
                        child: Text(
                          (article.author != null && article.author!.isNotEmpty)
                              ? article.author![0].toUpperCase() : 'N',
                          style: const TextStyle(color: AppTheme.primaryAccent, fontWeight: FontWeight.w800, fontSize: 14),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              article.author ?? 'Redaksi',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(Icons.schedule_rounded, size: 11, color: AppTheme.textSecondary.withValues(alpha: 0.7)),
                                const SizedBox(width: 4),
                                Text(DateFormatter.getRelativeTime(article.publishedAt),
                                  style: TextStyle(fontSize: 11, color: AppTheme.textSecondary.withValues(alpha: 0.7))),
                                const SizedBox(width: 12),
                                Icon(Icons.timer_outlined, size: 11, color: AppTheme.textSecondary.withValues(alpha: 0.7)),
                                const SizedBox(width: 4),
                                Text('3 menit baca',
                                  style: TextStyle(fontSize: 11, color: AppTheme.textSecondary.withValues(alpha: 0.7))),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ═══ SOURCE & CATEGORY CHIPS ═══
                  Row(
                    children: [
                      // Source chip
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.divider),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.business_rounded, size: 12, color: AppTheme.textSecondary.withValues(alpha: 0.7)),
                            const SizedBox(width: 6),
                            Text(
                              article.sourceName ?? 'Sumber Tidak Diketahui',
                              style: TextStyle(fontSize: 11, color: AppTheme.textSecondary.withValues(alpha: 0.8), fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Category chip
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryAccent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.primaryAccent.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.category_rounded, size: 12, color: AppTheme.primaryAccent.withValues(alpha: 0.7)),
                            const SizedBox(width: 6),
                            Text(
                              'Headline',
                              style: TextStyle(fontSize: 11, color: AppTheme.primaryAccent.withValues(alpha: 0.8), fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ═══ ACCENT DIVIDER ═══
                  Container(
                    height: 3, width: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppTheme.primaryAccent, AppTheme.secondaryAccent]),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ═══ DESKRIPSI LENGKAP ═══
                  if (article.description != null && article.description!.isNotEmpty) ...[
                    const Text(
                      'RINGKASAN BERITA',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.primaryAccent, letterSpacing: 1.0),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.surface.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.divider.withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        article.description!,
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppTheme.textPrimary,
                          height: 1.7,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // ═══ KONTEN ARTIKEL ═══
                  if (article.content != null && article.content!.isNotEmpty) ...[
                    const Text(
                      'ISI BERITA',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textSecondary, letterSpacing: 1.0),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      article.content!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                        height: 1.8,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // ═══ INFO PANEL: Detail Artikel ═══
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.divider),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline_rounded, size: 18, color: AppTheme.primaryAccent.withValues(alpha: 0.7)),
                            const SizedBox(width: 8),
                            const Text(
                              'DETAIL ARTIKEL',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textSecondary, letterSpacing: 0.8),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _infoRow(Icons.person_outline, 'Penulis', article.author ?? 'Tidak diketahui'),
                        _infoRow(Icons.source_rounded, 'Sumber', article.sourceName ?? 'Tidak diketahui'),
                        _infoRow(Icons.schedule_rounded, 'Dipublikasikan', _formatDate(article.publishedAt)),
                        _infoRow(Icons.timer_outlined, 'Estimasi baca', '3 menit'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ═══ HINT: Baca Selengkapnya ═══
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryAccent.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.primaryAccent.withValues(alpha: 0.1)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.touch_app_rounded, size: 18, color: AppTheme.primaryAccent),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Ketuk tombol "BACA LENGKAP" di bawah untuk membuka artikel ini di sumber aslinya.',
                            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary.withValues(alpha: 0.8), height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // ═══ BOTTOM BAR: BACA LENGKAP ═══
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 12,
          bottom: MediaQuery.of(context).padding.bottom + 12,
        ),
        decoration: BoxDecoration(
          color: AppTheme.surface.withValues(alpha: 0.95),
          border: Border(top: BorderSide(color: AppTheme.divider.withValues(alpha: 0.5))),
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _openFullArticle(context),
            icon: const Icon(Icons.open_in_new_rounded, size: 20, color: Colors.white),
            label: const Text(
              'BACA LENGKAP',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 0.8, fontSize: 14),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryAccent,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppTheme.textSecondary.withValues(alpha: 0.5)),
          const SizedBox(width: 8),
          SizedBox(
            width: 100,
            child: Text(label,
              style: TextStyle(fontSize: 11, color: AppTheme.textSecondary.withValues(alpha: 0.6), fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value,
              style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary, fontWeight: FontWeight.w500),
              maxLines: 1, overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return dateStr;
    }
  }
}
