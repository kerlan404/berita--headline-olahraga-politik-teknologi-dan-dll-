import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/api_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/route_transitions.dart';
import '../../data/models/news_article.dart';
import '../../providers/news_list_provider.dart';
import '../../providers/search_provider.dart';
import '../../widgets/bookmark_button.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_retry_widget.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/news_card.dart';
import '../../widgets/news_hero_card.dart';
import '../../widgets/shimmer_loading.dart';
import '../detail/article_preview_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final ScrollController _searchScrollController = ScrollController();
  final ScrollController _categoryScrollController = ScrollController();
  late AnimationController _staggeredController;

  // Search state
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _debounceTimer;
  bool _isSearching = false;

  double _scrollOffset = 0.0;
  bool _isGridView = false;
  DateTime _lastParallaxUpdate = DateTime.now();

  // Category scroll tracking
  bool _showLeftArrow = false;
  bool _showRightArrow = true;

  @override
  void initState() {
    super.initState();
    _staggeredController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<NewsListProvider>();
      if (provider.articles.isEmpty || provider.needsRefresh) {
        provider.fetchNews(isRefresh: true);
      }
    });

    _scrollController.addListener(_onScroll);
    _searchScrollController.addListener(_onSearchScroll);
    _searchController.addListener(_onSearchChanged);
    _categoryScrollController.addListener(_onCategoryScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchScrollController.dispose();
    _categoryScrollController.dispose();
    _staggeredController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onScroll() {
    // Throttle parallax updates to every 50ms to reduce GPU load
    final now = DateTime.now();
    if (now.difference(_lastParallaxUpdate).inMilliseconds > 50) {
      _scrollOffset = _scrollController.hasClients ? _scrollController.offset : 0.0;
      _lastParallaxUpdate = now;
    }

    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<NewsListProvider>().loadMore();
    }
  }

  void _onSearchScroll() {
    if (_searchScrollController.position.pixels >=
        _searchScrollController.position.maxScrollExtent - 200) {
      context.read<SearchProvider>().loadMore();
    }
  }

  void _onCategoryScroll() {
    if (!_categoryScrollController.hasClients) return;
    final newLeft = _categoryScrollController.offset > 10;
    final newRight = _categoryScrollController.offset <
        _categoryScrollController.position.maxScrollExtent - 10;
    // Only rebuild when arrow visibility actually changes
    if (newLeft != _showLeftArrow || newRight != _showRightArrow) {
      setState(() {
        _showLeftArrow = newLeft;
        _showRightArrow = newRight;
      });
    }
  }

  void _scrollCategoryLeft() {
    final currentOffset = _categoryScrollController.offset;
    final target = (currentOffset - 200).clamp(0.0, _categoryScrollController.position.maxScrollExtent);
    _categoryScrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  void _scrollCategoryRight() {
    final currentOffset = _categoryScrollController.offset;
    final target = (currentOffset + 200).clamp(0.0, _categoryScrollController.position.maxScrollExtent);
    _categoryScrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  void _triggerStaggeredAnimation() {
    _staggeredController.reset();
    _staggeredController.forward();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _searchFocusNode.unfocus();
        context.read<SearchProvider>().clearSearch();
      } else {
        // Focus after a frame so the text field is built
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _searchFocusNode.requestFocus();
        });
      }
    });
  }

  void _onSearchChanged() {
    // Clear button visibility handled by ListenableBuilder — no need for setState
    if (_debounceTimer?.isActive ?? false) _debounceTimer?.cancel();

    final query = _searchController.text;
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        context.read<SearchProvider>().search(query, isRefresh: true);
      }
    });
  }

  String _getCurrentLabel(String category) {
    for (final entry in ApiConstants.categoryMap.entries) {
      if (entry.value == category) return entry.key;
    }
    return ApiConstants.allCategory;
  }

  IconData _getCategoryIcon(String label) {
    switch (label) {
      case 'Semua': return Icons.explore;
      case 'Olahraga': return Icons.sports_soccer;
      case 'Teknologi': return Icons.computer;
      case 'Bisnis': return Icons.business_center;
      case 'Hiburan': return Icons.movie;
      case 'Kesehatan': return Icons.favorite;
      case 'Politik': return Icons.account_balance;
      default: return Icons.article;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isSearching ? _buildSearchAppBar() : _buildNormalAppBar(),
      body: Column(
        children: [
          // ── Category Scroll Bar (sembunyi saat search) ──
          if (!_isSearching) _buildCategoryBar(),
          // ── Main Content ──
          Expanded(
            child: _isSearching ? _buildSearchBody() : _buildNewsBody(),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  // Normal App Bar (tanpa menu drawer)
  // ──────────────────────────────────────────────

  PreferredSizeWidget _buildNormalAppBar() {
    return AppBar(
      title: const Row(
        children: [
          Text(
            'REEDS',
            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5),
          ),
          Text(
            'FEED',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: AppTheme.primaryAccent,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search_rounded),
          tooltip: 'Cari Berita',
          onPressed: _toggleSearch,
        ),
        IconButton(
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              _isGridView ? Icons.grid_view_rounded : Icons.view_list_rounded,
              key: ValueKey(_isGridView),
            ),
          ),
          tooltip: _isGridView ? 'Tampilan List' : 'Tampilan Grid',
          onPressed: () {
            setState(() {
              _isGridView = !_isGridView;
            });
          },
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────
  // Search App Bar
  // ──────────────────────────────────────────────

  PreferredSizeWidget _buildSearchAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        tooltip: 'Tutup Pencarian',
        onPressed: _toggleSearch,
      ),
      title: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'Cari topik atau judul berita...',
          hintStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
          border: InputBorder.none,
        ),
        style: const TextStyle(color: Colors.white, fontSize: 16),
        textInputAction: TextInputAction.search,
      ),
      actions: [
        ListenableBuilder(
          listenable: _searchController,
          builder: (context, _) {
            if (_searchController.text.isNotEmpty) {
              return IconButton(
                icon: const Icon(Icons.clear),
                tooltip: 'Hapus',
                onPressed: () {
                  _searchController.clear();
                  context.read<SearchProvider>().clearSearch();
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────
  // Horizontal Category Scroll Bar
  // ──────────────────────────────────────────────

  Widget _buildCategoryBar() {
    final categories = ApiConstants.categories;

    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          bottom: BorderSide(color: AppTheme.divider.withValues(alpha: 0.5)),
        ),
      ),
      child: Consumer<NewsListProvider>(
        builder: (context, provider, child) {
          final currentLabel = _getCurrentLabel(provider.currentCategory);

          return LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 600;

              return Row(
                children: [
                  // Left scroll arrow (mobile only)
                  if (isMobile)
                    _buildArrowButton(
                      icon: Icons.chevron_left_rounded,
                      onTap: _scrollCategoryLeft,
                      isVisible: _showLeftArrow,
                    ),

                  // Categories horizontal scroll
                  Expanded(
                    child: ListView.builder(
                      controller: _categoryScrollController,
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.only(
                        left: isMobile ? 0 : 12,
                        right: isMobile ? 0 : 12,
                      ),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final label = categories[index];
                        final isSelected = label == currentLabel;
                        return _buildCategoryPill(
                          label: label,
                          icon: _getCategoryIcon(label),
                          isSelected: isSelected,
                          onTap: () {
                            final apiKeyName = ApiConstants.categoryMap[label] ?? 'all';
                            provider.setCategory(apiKeyName);
                            _triggerStaggeredAnimation();
                          },
                        );
                      },
                    ),
                  ),

                  // Right scroll arrow (mobile only)
                  if (isMobile)
                    _buildArrowButton(
                      icon: Icons.chevron_right_rounded,
                      onTap: _scrollCategoryRight,
                      isVisible: _showRightArrow,
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildArrowButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isVisible,
  }) {
    return AnimatedOpacity(
      opacity: isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: IgnorePointer(
        ignoring: !isVisible,
        child: Container(
          width: 32,
          height: 52,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.surface,
                AppTheme.surface.withValues(alpha: 0.0),
              ],
              begin: icon == Icons.chevron_left_rounded
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              end: icon == Icons.chevron_left_rounded
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isVisible ? onTap : null,
              borderRadius: BorderRadius.circular(8),
              child: Icon(
                icon,
                size: 20,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryPill({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primaryAccent.withValues(alpha: 0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? AppTheme.primaryAccent.withValues(alpha: 0.4)
                    : AppTheme.divider.withValues(alpha: 0.3),
                width: isSelected ? 1.5 : 1.0,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: isSelected ? AppTheme.primaryAccent : AppTheme.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────
  // News Body
  // ──────────────────────────────────────────────

  Widget _buildNewsBody() {
    return Consumer<NewsListProvider>(
      builder: (context, provider, child) {
        return _buildNewsContent(provider);
      },
    );
  }

  // ──────────────────────────────────────────────
  // News Content
  // ──────────────────────────────────────────────

  Widget _buildNewsContent(NewsListProvider provider) {
    if (provider.isLoading && provider.articles.isEmpty) {
      return _isGridView
          ? const ShimmerGrid(itemCount: 6)
          : const ShimmerList(itemCount: 5);
    }

    if (provider.errorMessage != null && provider.articles.isEmpty) {
      return ErrorRetryWidget(
        errorMessage: provider.errorMessage!,
        onRetry: () {
          provider.fetchNews(isRefresh: true);
          _triggerStaggeredAnimation();
        },
      );
    }

    if (provider.articles.isEmpty) {
      return const EmptyState(
        title: 'Tidak ada berita',
        description: 'Saat ini belum ada berita untuk kategori ini.',
      );
    }

    if (!provider.isLoading && _staggeredController.value == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _triggerStaggeredAnimation();
      });
    }

    if (_isGridView) return _buildGridContent(provider);
    return _buildListContent(provider);
  }

  // ──────────────────────────────────────────────
  // List View
  // ──────────────────────────────────────────────

  Widget _buildListContent(NewsListProvider provider) {
    return RefreshIndicator(
      color: AppTheme.primaryAccent,
      backgroundColor: AppTheme.surface,
      onRefresh: () async {
        await provider.fetchNews(isRefresh: true);
        _triggerStaggeredAnimation();
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(12),
        itemCount: provider.articles.length + (provider.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == provider.articles.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: LoadingIndicator(isSmall: true),
            );
          }

          final article = provider.articles[index];

          Widget cardWidget;
          if (index == 0) {
            cardWidget = Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: ListenableBuilder(
                listenable: _scrollController,
                builder: (context, _) {
                  return NewsHeroCard(
                    article: article,
                    onTap: () => _openArticleDetail(context, article),
                    scrollOffset: _scrollOffset,
                  );
                },
              ),
            );
          } else {
            cardWidget = Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: NewsCard(
                article: article,
                onTap: () => _openArticleDetail(context, article),
              ),
            );
          }

          return RepaintBoundary(
            child: StaggeredListAnimation(
              index: index,
              controller: _staggeredController,
              child: cardWidget,
            ),
          );
        },
      ),
    );
  }

  // ──────────────────────────────────────────────
  // Grid View
  // ──────────────────────────────────────────────

  Widget _buildGridContent(NewsListProvider provider) {
    return RefreshIndicator(
      color: AppTheme.primaryAccent,
      backgroundColor: AppTheme.surface,
      onRefresh: () async {
        await provider.fetchNews(isRefresh: true);
      },
      child: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 0.72,
        ),
        itemCount: provider.articles.length + (provider.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == provider.articles.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: LoadingIndicator(isSmall: true),
              ),
            );
          }

          final article = provider.articles[index];
          return _buildCompactGridCard(context, article);
        },
      ),
    );
  }

  Widget _buildCompactGridCard(BuildContext context, NewsArticle article) {
    return GestureDetector(
      onTap: () => _openArticleDetail(context, article),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.divider),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image
            AspectRatio(
              aspectRatio: 16 / 10,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (article.urlToImage != null && article.urlToImage!.isNotEmpty)
                    CachedNetworkImage(
                      imageUrl: article.urlToImage!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[850],
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[900],
                        child: const Icon(Icons.broken_image, color: AppTheme.textSecondary, size: 28),
                      ),
                    )
                  else
                    Container(
                      color: Colors.grey[900],
                      child: const Icon(Icons.image_not_supported, color: AppTheme.textSecondary, size: 28),
                    ),
                  // Gradient overlay
                  Positioned(
                    left: 0, right: 0, bottom: 0,
                    height: 40,
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.6),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Bookmark overlay
                  Positioned(
                    top: 6,
                    right: 6,
                    child: BookmarkButton(
                      article: article,
                      iconSize: 16,
                      inactiveColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    article.sourceName?.toUpperCase() ?? 'NEWS',
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryAccent,
                      letterSpacing: 0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    article.title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormatter.getRelativeTime(article.publishedAt),
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────
  // Search Body
  // ──────────────────────────────────────────────

  Widget _buildSearchBody() {
    return Consumer<SearchProvider>(
      builder: (context, provider, child) {
        if (provider.query.trim().isEmpty) {
          return const EmptyState(
            title: 'Cari Berita',
            description: 'Ketik kata kunci judul atau deskripsi berita di atas.',
            icon: Icons.search,
          );
        }

        if (provider.isLoading && provider.searchResults.isEmpty) {
          return const LoadingIndicator();
        }

        if (provider.errorMessage != null && provider.searchResults.isEmpty) {
          return ErrorRetryWidget(
            errorMessage: provider.errorMessage!,
            onRetry: () => provider.search(provider.query, isRefresh: true),
          );
        }

        if (provider.searchResults.isEmpty) {
          return EmptyState(
            title: 'Tidak Ada Hasil',
            description: 'Tidak ada berita yang cocok untuk "${provider.query}".',
            icon: Icons.search_off,
          );
        }

        return ListView.builder(
          controller: _searchScrollController,
          padding: const EdgeInsets.all(12),
          itemCount: provider.searchResults.length + (provider.hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == provider.searchResults.length) {
              return const LoadingIndicator(isSmall: true);
            }

            final article = provider.searchResults[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: NewsCard(
                article: article,
                onTap: () {
                  Navigator.of(context).push(
                    SlideRightRoute(page: ArticlePreviewScreen(article: article)),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  void _openArticleDetail(BuildContext context, NewsArticle article) {
    Navigator.of(context).push(
      SlideRightRoute(page: ArticlePreviewScreen(article: article)),
    );
  }
}
