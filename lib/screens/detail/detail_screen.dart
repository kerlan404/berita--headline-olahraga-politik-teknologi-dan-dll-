import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/article_analysis.dart';
import '../../data/models/news_article.dart';
import '../../data/services/article_analysis_service.dart';
import '../../widgets/bookmark_button.dart';

class DetailScreen extends StatefulWidget {
  final NewsArticle article;

  const DetailScreen({
    super.key,
    required this.article,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  // Article Analysis
  final ArticleAnalysisService _analysisService = ArticleAnalysisService();
  ArticleAnalysis? _analysis;
  bool _isAnalyzing = false;
  bool _analysisError = false;

  // WebView only on mobile (not web)
  WebViewController? _controller;
  int _progress = 0;
  bool _isError = false;
  bool _showWebView = false; // Toggle between article content and WebView

  // BACA LENGKAP sudah diklik — tombol akan hilang
  bool _hasOpenedArticle = false;

  // WebView is lazy-initialized — only loads when user taps the toggle button
  @override
  void initState() {
    super.initState();
    _startAnalysis();
  }

  /// Jalankan analisis artikel oleh Editor Berita Senior REEDFEED
  Future<void> _startAnalysis() async {
    setState(() {
      _isAnalyzing = true;
      _analysisError = false;
    });

    try {
      final result = await _analysisService.analyze(widget.article);
      if (mounted) {
        setState(() {
          _analysis = result;
          _isAnalyzing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _analysisError = true;
          _isAnalyzing = false;
        });
      }
    }
  }

  void _initWebView() {
    try {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {
              if (mounted) setState(() => _progress = progress);
            },
            onPageStarted: (String url) {
              if (mounted) setState(() { _progress = 0; _isError = false; });
            },
            onPageFinished: (String url) {
              if (mounted) setState(() => _progress = 100);
            },
            onWebResourceError: (WebResourceError error) {
              if (error.errorType != WebResourceErrorType.unknown) {
                if (mounted) setState(() => _isError = true);
              }
            },
          ),
        )
        ..loadRequest(Uri.parse(widget.article.url));
    } catch (e) {
      if (mounted) setState(() => _isError = true);
    }
  }

  Future<void> _shareArticle() async {
    final text = '${widget.article.title}\n\n${widget.article.url}';
    await SharePlus.instance.share(
      ShareParams(text: text, subject: widget.article.title),
    );
  }

  Future<void> _openInBrowser() async {
    final uri = Uri.parse(widget.article.url);
    try {
      // Langsung launch — canLaunchUrl() unreliable di beberapa HP
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (mounted) {
        setState(() => _hasOpenedArticle = true);
      }
    } catch (e) {
      debugPrint('_openInBrowser error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuka browser: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = widget.article.urlToImage != null && widget.article.urlToImage!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.article.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          // Toggle WebView button (mobile only) — lazy init on first tap
          if (!kIsWeb && !_isError)
            IconButton(
              icon: Icon(_showWebView ? Icons.article_rounded : Icons.web_rounded),
              tooltip: _showWebView ? 'Lihat Ringkasan' : 'Buka WebView',
              onPressed: () {
                if (_controller == null) _initWebView();
                setState(() => _showWebView = !_showWebView);
              },
            ),
          BookmarkButton(article: widget.article, iconSize: 22),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Bagikan Berita',
            onPressed: _shareArticle,
          ),
        ],
        bottom: !kIsWeb && _showWebView && _progress < 100 && !_isError
            ? PreferredSize(
                preferredSize: const Size.fromHeight(2.0),
                child: LinearProgressIndicator(
                  value: _progress / 100.0,
                  backgroundColor: AppTheme.background,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryAccent),
                  minHeight: 2.0,
                ),
              )
            : null,
      ),
      body: _showWebView && !kIsWeb && !_isError
          ? _buildWebViewBody()
          : _buildArticleContent(hasImage),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  /// WebView body (when user taps "Buka WebView")
  Widget _buildWebViewBody() {
    return Stack(
      children: [
        if (_controller != null) WebViewWidget(controller: _controller!),
        if (_isError || _controller == null) _buildWebError(),
      ],
    );
  }

  Widget _buildWebError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.signal_wifi_off_rounded, size: 64, color: AppTheme.primaryAccent),
            const SizedBox(height: 16),
            const Text('Halaman Gagal Dimuat',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            const SizedBox(height: 8),
            const Text('Ada masalah saat memuat halaman web. Silakan coba lagi.',
              style: TextStyle(fontSize: 14, color: AppTheme.textSecondary), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () { setState(() { _isError = false; }); _initWebView(); },
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text('Muat Ulang', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.surface, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
            ),
          ],
        ),
      ),
    );
  }

  /// Article content body (default view — beautiful article summary)
  Widget _buildArticleContent(bool hasImage) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ── SliverAppBar with hero image ──
        SliverAppBar(
          expandedHeight: hasImage ? 300 : 100,
          pinned: true,
          backgroundColor: AppTheme.background,
          leading: const SizedBox.shrink(), // no back button — AppBar handles it
          flexibleSpace: FlexibleSpaceBar(
            background: hasImage
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: widget.article.urlToImage!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(color: AppTheme.surface),
                        errorWidget: (_, __, ___) => Container(
                          color: AppTheme.surface,
                          child: const Icon(Icons.image_not_supported_rounded, size: 48, color: AppTheme.textSecondary),
                        ),
                      ),
                      // Bottom gradient
                      Positioned(
                        left: 0, right: 0, bottom: 0, height: 160,
                        child: IgnorePointer(child: Container(
                          decoration: BoxDecoration(gradient: LinearGradient(
                            begin: Alignment.bottomCenter, end: Alignment.topCenter,
                            colors: [AppTheme.background.withValues(alpha: 1.0), AppTheme.background.withValues(alpha: 0.6), Colors.transparent],
                          )),
                        )),
                      ),
                      // Source badge
                      Positioned(
                        left: 16, bottom: 20,
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
                              Text(widget.article.sourceName?.toUpperCase() ?? 'NEWS',
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
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ═══ TITLE ═══
                Text(
                  widget.article.title,
                  style: const TextStyle(
                    fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.textPrimary,
                    height: 1.35, letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 16),

                // ═══ META: Author + Time ═══
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppTheme.primaryAccent.withValues(alpha: 0.15),
                      child: Text(
                        (widget.article.author != null && widget.article.author!.isNotEmpty)
                            ? widget.article.author![0].toUpperCase() : 'N',
                        style: const TextStyle(color: AppTheme.primaryAccent, fontWeight: FontWeight.w800, fontSize: 14),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.article.author ?? 'Redaksi',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(Icons.schedule_rounded, size: 11, color: AppTheme.textSecondary.withValues(alpha: 0.7)),
                              const SizedBox(width: 4),
                              Text(DateFormatter.getRelativeTime(widget.article.publishedAt),
                                style: TextStyle(fontSize: 11, color: AppTheme.textSecondary.withValues(alpha: 0.7))),
                              const SizedBox(width: 12),
                              Icon(Icons.source_rounded, size: 11, color: AppTheme.textSecondary.withValues(alpha: 0.7)),
                              const SizedBox(width: 4),
                              Text(widget.article.sourceName ?? 'Sumber',
                                style: TextStyle(fontSize: 11, color: AppTheme.textSecondary.withValues(alpha: 0.7))),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ═══ ACCENT DIVIDER ═══
                Container(
                  height: 3, width: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppTheme.primaryAccent, AppTheme.secondaryAccent]),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),

                // ═══ ANALISIS EDITOR — REEDFEED ═══
                _buildEditorAnalysis(),
                const SizedBox(height: 24),

                // ═══ INFO LENGKAP ARTIKEL ═══
                _buildInfoPanel(),
                const SizedBox(height: 20),

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
                      const Icon(Icons.open_in_new_rounded, size: 18, color: AppTheme.primaryAccent),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Ketuk tombol "BACA LENGKAP" di bawah untuk membuka artikel asli di browser.',
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
    );
  }

  /// Widget analisis editor — menampilkan hasil ekstraksi inti berita
  Widget _buildEditorAnalysis() {
    // Loading state
    if (_isAnalyzing) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ANALISIS EDITOR',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.primaryAccent, letterSpacing: 1.0),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.divider.withValues(alpha: 0.5)),
            ),
            child: Column(
              children: [
                const SizedBox(
                  width: 24, height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryAccent),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Editor REEDFEED sedang menganalisis artikel...',
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary.withValues(alpha: 0.7)),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // Error state
    if (_analysisError) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'ANALISIS EDITOR',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.primaryAccent, letterSpacing: 1.0),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _startAnalysis,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh, size: 12, color: AppTheme.primaryAccent.withValues(alpha: 0.7)),
                    const SizedBox(width: 4),
                    Text('Coba lagi',
                      style: TextStyle(fontSize: 10, color: AppTheme.primaryAccent.withValues(alpha: 0.7))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.divider.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 16, color: AppTheme.textSecondary.withValues(alpha: 0.5)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Gagal menganalisis artikel. Silakan baca ringkasan di bawah ini.',
                    style: TextStyle(fontSize: 12, color: AppTheme.textSecondary.withValues(alpha: 0.7)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Fallback — tampilkan description & content asli
          if (widget.article.description != null && widget.article.description!.isNotEmpty) ...[
            const Text('RINGKASAN',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.primaryAccent, letterSpacing: 1.0)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.divider.withValues(alpha: 0.5)),
              ),
              child: Text(widget.article.description!,
                style: const TextStyle(fontSize: 15, color: AppTheme.textPrimary, height: 1.7)),
            ),
          ],
          if (widget.article.content != null && widget.article.content!.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text('ISI BERITA',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textSecondary, letterSpacing: 1.0)),
            const SizedBox(height: 8),
            Text(widget.article.content!,
              style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.8)),
          ],
        ],
      );
    }

    // Analysis ready
    if (_analysis == null) return const SizedBox.shrink();

    final analysis = _analysis!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ═══ HEADER: badge editor ═══
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.primaryAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppTheme.primaryAccent.withValues(alpha: 0.2)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome_rounded, size: 12, color: AppTheme.primaryAccent),
                  SizedBox(width: 4),
                  Text(
                    'ANALISIS EDITOR REEDFEED',
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppTheme.primaryAccent, letterSpacing: 0.8),
                  ),
                ],
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: _startAnalysis,
              child: Icon(Icons.refresh_rounded, size: 14, color: AppTheme.textSecondary.withValues(alpha: 0.5)),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // ═══ INTI BERITA ═══
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.divider.withValues(alpha: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Suggested title
              Text(
                analysis.judulSaran,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),

              // Accent divider
              Container(
                height: 2, width: 32,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppTheme.primaryAccent, AppTheme.secondaryAccent]),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              const SizedBox(height: 12),

              // Core content
              Text(
                analysis.intiBerita,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textPrimary,
                  height: 1.7,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // ═══ POIN KUNCI ═══
        if (analysis.poinKunci.isNotEmpty) ...[
          const Text(
            'POIN PENTING',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textSecondary, letterSpacing: 1.0),
          ),
          const SizedBox(height: 10),
          ...analysis.poinKunci.asMap().entries.map((entry) {
            final index = entry.key + 1;
            final poin = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryAccent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        '$index',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryAccent,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      poin,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],

        const SizedBox(height: 8),

        // ═══ FOOTER: sumber analisis ═══
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.surface.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.auto_awesome_rounded, size: 12, color: AppTheme.textSecondary.withValues(alpha: 0.4)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _analysisService.isAiMode
                      ? 'Analisis oleh AI Editor REEDFEED. Dapatkan konteks utama sebelum membaca artikel penuh.'
                      : 'Analisis otomatis oleh Editor REEDFEED. Ketuk BACA LENGKAP untuk artikel asli.',
                  style: TextStyle(fontSize: 10, color: AppTheme.textSecondary.withValues(alpha: 0.5), height: 1.4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Panel info lengkap artikel — menampilkan semua metadata artikel
  Widget _buildInfoPanel() {
    final article = widget.article;
    final url = Uri.tryParse(article.url);
    final domain = url?.host.replaceFirst('www.', '') ?? 'Sumber tidak diketahui';
    final readTime = _estimateReadTime(article.content, article.description);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Row(
            children: [
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  color: AppTheme.primaryAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.info_outline_rounded, size: 14, color: AppTheme.primaryAccent),
              ),
              const SizedBox(width: 8),
              const Text(
                'DETAIL ARTIKEL',
                style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w800,
                  color: AppTheme.textSecondary, letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Penulis ──
          _infoRow(Icons.person_outline_rounded, 'Penulis',
              article.author ?? 'Tidak tercantum'),

          // ── Sumber ──
          _infoRow(Icons.source_rounded, 'Sumber',
              article.sourceName ?? 'Tidak diketahui'),

          // ── Domain / Website ──
          _infoRow(Icons.language_rounded, 'Domain', domain),

          // ── Dipublikasikan ──
          _infoRow(Icons.schedule_rounded, 'Publikasi',
              _formatFullDate(article.publishedAt)),

          // ── Estimasi baca ──
          _infoRow(Icons.timer_rounded, 'Estimasi baca', readTime),

          // ── URL Lengkap ──
          const Divider(height: 24, color: AppTheme.divider),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.link_rounded, size: 14,
                  color: AppTheme.textSecondary.withValues(alpha: 0.5)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  article.url,
                  style: TextStyle(
                    fontSize: 10,
                    color: AppTheme.textSecondary.withValues(alpha: 0.6),
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              // Copy button
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: article.url));
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('URL disalin ke clipboard'),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: AppTheme.surface,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryAccent.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(Icons.copy_rounded, size: 12,
                      color: AppTheme.primaryAccent.withValues(alpha: 0.6)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppTheme.textSecondary.withValues(alpha: 0.5)),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: Text(label,
              style: TextStyle(fontSize: 10, color: AppTheme.textSecondary.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w500),
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

  /// Format tanggal lengkap (misal: 21 Juli 2026, 14:30)
  String _formatFullDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
      ];
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}, $hour:$minute';
    } catch (_) {
      return dateStr;
    }
  }

  /// Estimasi waktu baca berdasarkan panjang konten
  String _estimateReadTime(String? content, String? description) {
    final textLen = (content?.length ?? 0) + (description?.length ?? 0);
    if (textLen == 0) return '1 menit';
    // Rata-rata kecepatan baca: 200 kata/menit, ~5 char/kata
    final minutes = (textLen / (200 * 5)).ceil();
    if (minutes < 1) return 'Kurang dari 1 menit';
    return '$minutes menit';
  }

  /// Bottom bar with BACA LENGKAP button → opens URL in external browser
  /// After opening once, the button disappears to indicate article was read.
  Widget _buildBottomBar() {
    if (_hasOpenedArticle) {
      return Container(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 12,
          bottom: MediaQuery.of(context).padding.bottom + 12,
        ),
        decoration: BoxDecoration(
          color: AppTheme.surface.withValues(alpha: 0.95),
          border: Border(top: BorderSide(color: AppTheme.divider.withValues(alpha: 0.5))),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_rounded, size: 16, color: AppTheme.successColor.withValues(alpha: 0.7)),
            const SizedBox(width: 8),
            Text(
              'Artikel dibuka di browser',
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary.withValues(alpha: 0.7)),
            ),
          ],
        ),
      );
    }

    return Container(
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
        height: 48,
        child: ElevatedButton.icon(
          onPressed: _openInBrowser,
          icon: const Icon(Icons.open_in_new_rounded, size: 20, color: Colors.white),
          label: const Text(
            'BACA LENGKAP',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 0.8, fontSize: 14),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryAccent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
        ),
      ),
    );
  }
}
