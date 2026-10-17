import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kalbala_admin/core/theme/app_colors.dart';
import 'package:kalbala_admin/core/theme/app_spacing.dart';
import 'package:kalbala_admin/features/auth/presentation/providers/auth_provider.dart';
import 'package:kalbala_admin/shared/widgets/kalbala_logo_mark.dart';

class UnauthorizedScreen extends ConsumerWidget {
  const UnauthorizedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Color(0xFF127A62),
                    AppColors.primary,
                    Color(0xFF06382C),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const KalBalaLogoMark(size: 56, useBrandAsset: true),
                      const SizedBox(height: AppSpacing.lg),
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppColors.errorSoft,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lock_outline_rounded,
                          size: 36,
                          color: AppColors.error,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'دسترسی مدیریت ندارید',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'این حساب در نقش ادمین ثبت نشده است. با حساب مدیر وارد شوید.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.inkMuted,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      FilledButton(
                        onPressed: () =>
                            ref.read(signOutActionProvider.notifier).signOut(),
                        child: const Text('خروج و ورود مجدد'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
