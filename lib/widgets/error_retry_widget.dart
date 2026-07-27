import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class ErrorRetryWidget extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  const ErrorRetryWidget({
    super.key,
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppTheme.primaryContainer.withValues(alpha: 0.3),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: AppTheme.primaryContainer,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'GAGAL MEMUAT BERITA',
              style: AppTheme.headlineMd.copyWith(
                color: AppTheme.textPrimaryFor(isDark),
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: AppTheme.bodyMd.copyWith(
                fontSize: 13,
                color: AppTheme.textSecondaryFor(isDark),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, color: Colors.white, size: 18),
              label: Text(
                'COBA LAGI',
                style: AppTheme.labelBold.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
