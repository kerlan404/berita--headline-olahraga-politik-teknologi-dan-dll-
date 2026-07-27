import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../core/theme/app_theme.dart';

class ShimmerList extends StatelessWidget {
  final int itemCount;

  const ShimmerList({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer(
      gradient: LinearGradient(
        colors: [
          AppTheme.cardBgFor(isDark),
          AppTheme.dividerFor(isDark).withValues(alpha: 0.8),
          AppTheme.cardBgFor(isDark),
        ],
        begin: Alignment(-1.0, -0.5),
        end: Alignment(1.0, 0.5),
        stops: const [0.0, 0.5, 1.0],
      ),
      period: const Duration(milliseconds: 1500),
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: itemCount,
        itemBuilder: (context, index) {
          if (index == 0) return _buildHeroShimmer(isDark);
          return _buildCardShimmer(isDark);
        },
      ),
    );
  }

  Widget _buildHeroShimmer(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardBgFor(isDark),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: AppTheme.dividerFor(isDark),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120, height: 12,
                  decoration: BoxDecoration(
                    color: AppTheme.dividerFor(isDark),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity, height: 16,
                  decoration: BoxDecoration(
                    color: AppTheme.dividerFor(isDark),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 200, height: 16,
                  decoration: BoxDecoration(
                    color: AppTheme.dividerFor(isDark),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardShimmer(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardBgFor(isDark),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 90, height: 90,
            decoration: BoxDecoration(
              color: AppTheme.dividerFor(isDark),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 80, height: 10,
                      decoration: BoxDecoration(
                        color: AppTheme.dividerFor(isDark),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity, height: 14,
                      decoration: BoxDecoration(
                        color: AppTheme.dividerFor(isDark),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 160, height: 14,
                      decoration: BoxDecoration(
                        color: AppTheme.dividerFor(isDark),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 60, height: 10,
                  decoration: BoxDecoration(
                    color: AppTheme.dividerFor(isDark),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ShimmerGrid extends StatelessWidget {
  final int itemCount;

  const ShimmerGrid({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer(
      gradient: LinearGradient(
        colors: [
          AppTheme.cardBgFor(isDark),
          AppTheme.dividerFor(isDark).withValues(alpha: 0.8),
          AppTheme.cardBgFor(isDark),
        ],
        begin: Alignment(-1.0, -0.5),
        end: Alignment(1.0, 0.5),
      ),
      period: const Duration(milliseconds: 1500),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.75,
          ),
          itemCount: itemCount,
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                color: AppTheme.dividerFor(isDark),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          },
        ),
      ),
    );
  }
}
