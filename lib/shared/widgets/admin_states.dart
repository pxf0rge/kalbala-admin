import 'package:flutter/material.dart';
import 'package:kalbala_admin/core/theme/app_colors.dart';
import 'package:kalbala_admin/core/theme/app_spacing.dart';

class AdminEmptyState extends StatelessWidget {
  const AdminEmptyState({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.accent = AppColors.primary,
  });

  final String message;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    accent.withValues(alpha: 0.18),
                    accent.withValues(alpha: 0.06),
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(color: accent.withValues(alpha: 0.2)),
              ),
              child: Icon(icon, size: 40, color: accent),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              message,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.inkMuted,
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class AdminErrorState extends StatelessWidget {
  const AdminErrorState({
    super.key,
    required this.message,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.errorSoft,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.2),
                ),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.lg),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('تلاش مجدد'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
