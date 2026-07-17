import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/api_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/route_transitions.dart';
import '../../providers/news_list_provider.dart';
import '../../widgets/bookmark_button.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_retry_widget.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/news_card.dart';
import '../../widgets/news_hero_card.dart';
import '../../widgets/shimmer_loading.dart';
import '../detail/detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _staggeredController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _showFab = false;
  double _scrollOffset = 0.0;
  bool _isGridView = false;

  @override
  void initState() {
    super.initState();
    _staggeredController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NewsListProvider>().fetchNews(isRefresh: true);
    });

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _staggeredController.dispose();
    super.dispose();
  }

  void _onScroll() {
    _scrollOffset = _scrollController.hasClients ? _scrollController.offset : 0.0;

    final shouldShow = _scrollOffset > 300;
    if (shouldShow != _showFab) {
      setState(() {
        _showFab = shouldShow;
      });
    }

    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<NewsListProvider>().loadMore();
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  void _triggerStaggeredAnimation() {
    _staggeredController.reset();
    _staggeredController.forward();
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
      default: return Icons.article;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ApiConstants.categories;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          tooltip: 'Kategori',
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Consumer<NewsListProvider>(
          builder: (context, provider, child) {
            final currentLabel = _getCurrentLabel(provider.currentCategory);
            return GestureDetector(
              onTap: () => _scaffoldKey.currentState?.openDrawer(),
              child: Row(
                children: [
                  const Text(
                    'SPORTS',
                    style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5),
                  ),
                  Text(
                    'FEED',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: AppTheme.primaryAccent,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getCategoryIcon(currentLabel),
                          size: 12,
                          color: AppTheme.primaryAccent,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          currentLabel.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryAccent,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(Icons.arrow_drop_down, size: 14, color: AppTheme.primaryAccent),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
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
      ),
      // Sidebar Drawer untuk kategori
      drawer: Drawer(
        backgroundColor: AppTheme.surface,
        child: Consumer<NewsListProvider>(
          builder: (context, provider, child) {
            final currentLabel = _getCurrentLabel(provider.currentCategory);
            return Column(
              children: [
                // Header Drawer
                DrawerHeader(
                  decoration: const BoxDecoration(
                    color: AppTheme.background,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryAccent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.sports_kabaddi_outlined,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'SPORTSFEED',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.textPrimary,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const Text(
                          'Pilih kategori berita',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Daftar Kategori
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final label = categories[index];
                      final isSelected = label == currentLabel;
                      return _buildDrawerItem(
                        icon: _getCategoryIcon(label),
                        label: label,
                        isSelected: isSelected,
                        onTap: () {
                          final apiKeyName = ApiConstants.categoryMap[label] ?? 'all';
                          provider.setCategory(apiKeyName);
                          Navigator.pop(context); // close drawer
                          _triggerStaggeredAnimation();
                        },
                      );
                    },
                  ),
                ),
                // Footer
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: AppTheme.divider),
                    ),
                  ),
                  child: const Text(
                    'Berita & Headline Terkini',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            );
          },
        ),
      ),
      body: Consumer<NewsListProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // Category Filter Chips
              _buildCategoryChips(provider),
              // Main Content
              Expanded(
                child: _buildContent(provider),
              ),
            ],
          );
        },
      ),
      // Floating Action Button — Scroll to Top
      floatingActionButton: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (child, animation) {
          return ScaleTransition(scale: animation, child: child);
        },
        child: _showFab
            ? FloatingActionButton(
                key: const ValueKey('scroll_top_fab'),
                onPressed: _scrollToTop,
                backgroundColor: AppTheme.primaryAccent,
                elevation: 4,
                child: const Icon(Icons.keyboard_arrow_up, color: Colors.white),
              )
            : const SizedBox.shrink(key: ValueKey('scroll_top_fab_hidden')),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryAccent.withValues(alpha: 0.15) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(color: AppTheme.primaryAccent.withValues(alpha: 0.3))
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: isSelected ? AppTheme.primaryAccent : AppTheme.textSecondary,
                ),
                const SizedBox(width: 16),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
                  ),
                ),
                const Spacer(),
                if (isSelected)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryAccent,
                      shape: BoxShape.circle,
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
  // Category Indicator Chip (hanya 'Semua')
  // ──────────────────────────────────────────────

  Widget _buildCategoryChips(NewsListProvider provider) {
    final currentLabel = _getCurrentLabel(provider.currentCategory);

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppTheme.background,
        border: Border(
          bottom: BorderSide(color: AppTheme.divider),
        ),
      ),
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Icon(
            _getCategoryIcon(currentLabel),
            size: 16,
            color: AppTheme.primaryAccent,
          ),
          const SizedBox(width: 8),
          Text(
            currentLabel.toUpperCase(),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(),
          // View toggle indicator
          Consumer<NewsListProvider>(
            builder: (context, p, child) {
              // Hanya tampilkan kategori lain sebagai label kecil
              if (currentLabel == 'Semua') return const SizedBox.shrink();
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.primaryAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'FILTERED',
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryAccent,
                    letterSpacing: 0.5,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  // Content Builder
  // ──────────────────────────────────────────────

  Widget _buildContent(NewsListProvider provider) {
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

          return StaggeredListAnimation(
            index: index,
            controller: _staggeredController,
            child: cardWidget,
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

  Widget _buildCompactGridCard(BuildContext context, dynamic article) {
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
                        color: Colors.grey[900],
                        child: const Center(
                          child: SizedBox(
                            width: 18, height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryAccent),
                            ),
                          ),
                        ),
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
                  // Gradient overlay for readability
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
                  // Source
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
                  // Title
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
                  // Time
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

  void _openArticleDetail(BuildContext context, dynamic article) {
    Navigator.of(context).push(
      SlideRightRoute(page: DetailScreen(article: article)),
    );
  }
}
