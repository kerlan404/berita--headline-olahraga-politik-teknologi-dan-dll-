import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/api_constants.dart';
import '../core/theme/app_theme.dart';
import '../providers/news_list_provider.dart';

class CategoryBar extends StatefulWidget {
  final VoidCallback? onCategoryChanged;

  const CategoryBar({super.key, this.onCategoryChanged});

  @override
  State<CategoryBar> createState() => _CategoryBarState();
}

class _CategoryBarState extends State<CategoryBar> {
  final ScrollController _categoryScrollController = ScrollController();
  bool _showLeftArrow = false;
  bool _showRightArrow = true;

  @override
  void initState() {
    super.initState();
    _categoryScrollController.addListener(_onCategoryScroll);
  }

  @override
  void dispose() {
    _categoryScrollController.dispose();
    super.dispose();
  }

  void _onCategoryScroll() {
    if (!_categoryScrollController.hasClients) return;
    final newLeft = _categoryScrollController.offset > 10;
    final newRight = _categoryScrollController.offset <
        _categoryScrollController.position.maxScrollExtent - 10;
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
                            widget.onCategoryChanged?.call();
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
}
