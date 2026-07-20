import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/news_article.dart';
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
  // WebView only works on mobile platforms, not web
  WebViewController? _controller;
  int _progress = 0;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _initWebView();
    }
  }

  void _initWebView() {
    try {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {
              if (mounted) {
                setState(() {
                  _progress = progress;
                });
              }
            },
            onPageStarted: (String url) {
              if (mounted) {
                setState(() {
                  _progress = 0;
                  _isError = false;
                });
              }
            },
            onPageFinished: (String url) {
              if (mounted) {
                setState(() {
                  _progress = 100;
                });
              }
            },
            onWebResourceError: (WebResourceError error) {
              if (error.errorType != WebResourceErrorType.unknown) {
                if (mounted) {
                  setState(() {
                    _isError = true;
                  });
                }
              }
            },
          ),
        )
        ..loadRequest(Uri.parse(widget.article.url));
    } catch (e) {
      // WebView initialization failed, fall back to error state
      if (mounted) {
        setState(() {
          _isError = true;
        });
      }
    }
  }

  Future<void> _launchInBrowser() async {
    final Uri url = Uri.parse(widget.article.url);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw 'Tidak bisa membuka tautan';
      }
    } catch (e) {
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

  Future<void> _shareArticle() async {
    final text = '${widget.article.title}\n\n${widget.article.url}';
    await SharePlus.instance.share(
      ShareParams(text: text, subject: widget.article.title),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.article.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          BookmarkButton(
            article: widget.article,
            iconSize: 22,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Bagikan Berita',
            onPressed: _shareArticle,
          ),
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            tooltip: 'Buka di Browser',
            onPressed: _launchInBrowser,
          ),
        ],
        bottom: !kIsWeb && _progress < 100 && !_isError
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
      body: kIsWeb ? _buildWebFallback() : _buildMobileView(),
    );
  }

  Widget _buildWebFallback() {
    final hasImage = widget.article.urlToImage != null && widget.article.urlToImage!.isNotEmpty;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Hero Image Section ──
          if (hasImage)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  child: Image.network(
                    widget.article.urlToImage!,
                    width: double.infinity,
                    height: 280,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildImageFallback(),
                  ),
                ),
                // Gradient overlay
                Positioned(
                  left: 0, right: 0, bottom: 0,
                  height: 160,
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            AppTheme.background.withValues(alpha: 0.95),
                            AppTheme.background.withValues(alpha: 0.6),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Floating source badge
                Positioned(
                  left: 20,
                  top: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryAccent,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryAccent.withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.source_rounded, size: 12, color: Colors.white),
                        const SizedBox(width: 6),
                        Text(
                          widget.article.sourceName?.toUpperCase() ?? 'NEWS',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Title overlaid at bottom
                Positioned(
                  left: 20, right: 20,
                  bottom: 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.article.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.3,
                          shadows: [
                            Shadow(color: Colors.black54, blurRadius: 12),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.schedule_rounded, size: 12, color: Colors.white70),
                          const SizedBox(width: 4),
                          Text(
                            DateFormatter.getRelativeTime(widget.article.publishedAt),
                            style: const TextStyle(fontSize: 11, color: Colors.white70),
                          ),
                          if (widget.article.author != null && widget.article.author!.isNotEmpty) ...[                            const SizedBox(width: 12),
                            const Icon(Icons.person_rounded, size: 12, color: Colors.white70),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                widget.article.author!,
                                style: const TextStyle(fontSize: 11, color: Colors.white70),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            )
          else
            // No image — use compact header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Source & time row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryAccent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          widget.article.sourceName?.toUpperCase() ?? 'NEWS',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryAccent,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(Icons.schedule_rounded, size: 12, color: AppTheme.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        DateFormatter.getRelativeTime(widget.article.publishedAt),
                        style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.article.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),

          // ── Article Body ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Author (if not shown in hero)
                if (!hasImage && widget.article.author != null && widget.article.author!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: AppTheme.primaryAccent.withValues(alpha: 0.15),
                          child: const Icon(Icons.person_rounded, size: 16, color: AppTheme.primaryAccent),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          widget.article.author!,
                          style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),

                // Divider
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryAccent.withValues(alpha: 0.3),
                        AppTheme.divider,
                        AppTheme.divider.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Description
                if (widget.article.description != null && widget.article.description!.isNotEmpty)
                  Text(
                    widget.article.description!,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppTheme.textPrimary,
                      height: 1.7,
                    ),
                  ),
                if (widget.article.description != null && widget.article.description!.isNotEmpty)
                  const SizedBox(height: 16),

                // Content
                if (widget.article.content != null && widget.article.content!.isNotEmpty)
                  Text(
                    widget.article.content!,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppTheme.textSecondary,
                      height: 1.7,
                    ),
                  ),

                const SizedBox(height: 32),

                // Action buttons
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _launchInBrowser,
                    icon: const Icon(Icons.open_in_new_rounded, color: Colors.white, size: 18),
                    label: const Text(
                      'BACA ARTIKEL LENGKAP',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        fontSize: 13,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryAccent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _shareArticle,
                    icon: const Icon(Icons.share_rounded, size: 18),
                    label: const Text(
                      'BAGIKAN ARTIKEL',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        fontSize: 12,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textSecondary,
                      side: const BorderSide(color: AppTheme.divider),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageFallback() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: const Center(
        child: Icon(Icons.image_not_supported_rounded, size: 48, color: AppTheme.textSecondary),
      ),
    );
  }

  Widget _buildMobileView() {
    return Stack(
      children: [
        if (!_isError && _controller != null)
          WebViewWidget(controller: _controller!),
        if (_isError || _controller == null)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.signal_wifi_off_rounded,
                    size: 64,
                    color: AppTheme.primaryAccent,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Halaman Gagal Dimuat',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Ada masalah saat memuat halaman web ini. Silakan coba lagi atau buka langsung di browser bawaan HP.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _isError = false;
                          });
                          _initWebView();
                        },
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        label: const Text('Muat Ulang', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.surface,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _launchInBrowser,
                        icon: const Icon(Icons.open_in_browser, color: Colors.white),
                        label: const Text('Buka di Browser', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryAccent,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
