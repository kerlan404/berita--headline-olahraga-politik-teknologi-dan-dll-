import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class EmptyState extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    this.title = 'TIDAK ADA DATA',
    this.description = 'Tidak ada berita yang ditemukan saat ini.',
    this.icon = Icons.find_in_page_outlined,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppTheme.dividerFor(isDark).withValues(alpha: 0.3),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                icon,
                size: 48,
                color: AppTheme.textSecondaryFor(isDark).withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: AppTheme.headlineMd.copyWith(
                color: AppTheme.textPrimaryFor(isDark),
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: AppTheme.bodyMd.copyWith(
                color: AppTheme.textSecondaryFor(isDark),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
