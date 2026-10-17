import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kalbala_admin/core/constants/app_constants.dart';
import 'package:kalbala_admin/core/routing/route_names.dart';
import 'package:kalbala_admin/core/theme/app_colors.dart';
import 'package:kalbala_admin/core/theme/theme_mode_provider.dart';
import 'package:kalbala_admin/features/auth/presentation/providers/auth_provider.dart';
import 'package:kalbala_admin/shared/widgets/kalbala_logo_mark.dart';

const _titles = <String, String>{
  RouteNames.dashboard: 'داشبورد',
  RouteNames.users: 'کاربران',
  RouteNames.products: 'محصولات',
  RouteNames.listings: 'آگهی‌ها',
  RouteNames.booths: 'غرفه‌ها',
  RouteNames.orders: 'سفارش‌ها',
  RouteNames.categories: 'دسته‌ها',
  RouteNames.banners: 'بنرها',
  RouteNames.reviews: 'نظرات',
  RouteNames.reports: 'گزارش‌ها',
  RouteNames.tickets: 'پشتیبانی',
  RouteNames.approvals: 'در انتظار تأیید',
  RouteNames.pendingVerifications: 'احراز هویت فروشنده',
  RouteNames.pendingBoothApps: 'درخواست غرفه',
  RouteNames.pendingProducts: 'محصولات در انتظار',
  RouteNames.pendingBankAccounts: 'حساب بانکی در انتظار',
  RouteNames.pendingSettlements: 'تسویه در انتظار',
  RouteNames.payments: 'پرداخت‌ها',
  RouteNames.refunds: 'بازپرداخت‌ها',
  RouteNames.settlements: 'تسویه‌ها',
  RouteNames.balances: 'موجودی فروشندگان',
  RouteNames.bankAccounts: 'حساب‌های بانکی',
  RouteNames.commission: 'کمیسیون',
  RouteNames.shipping: 'نرخ ارسال',
  RouteNames.settings: 'تنظیمات',
  RouteNames.notifications: 'اعلان‌ها',
  RouteNames.admins: 'ادمین‌ها',
  RouteNames.audit: 'لاگ ممیزی',
};

String _titleFor(String location) {
  if (_titles.containsKey(location)) return _titles[location]!;
  for (final entry in _titles.entries) {
    if (entry.key != RouteNames.dashboard &&
        location.startsWith('${entry.key}/')) {
      return entry.value;
    }
  }
  return AppConstants.appName;
}

/// Hub-style shell: no side navigation. Modules open from dashboard quick access.
/// Back always returns toward the dashboard.
class AdminShell extends ConsumerWidget {
  const AdminShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    final isDashboard = location == RouteNames.dashboard;
    final isDetail = GoRouterState.of(context).pathParameters.containsKey('id');
    final themeMode = ref.watch(themeModeProvider);
    final canRouterPop = GoRouter.of(context).canPop();

    return PopScope(
      canPop: isDashboard || canRouterPop,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (!isDashboard) {
          context.go(RouteNames.dashboard);
        }
      },
      child: Scaffold(
        appBar: isDetail
            ? null
            : AppBar(
                title: isDashboard
                    ? Row(
                        children: [
                          const KalBalaLogoMark(size: 28, useBrandAsset: true),
                          const SizedBox(width: 10),
                          Text(
                            AppConstants.appName,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ],
                      )
                    : Text(_titleFor(location)),
                leading: isDashboard
                    ? null
                    : IconButton(
                        tooltip: 'بازگشت به داشبورد',
                        icon: const Icon(Icons.arrow_forward_rounded),
                        onPressed: () {
                          if (canRouterPop) {
                            context.pop();
                          } else {
                            context.go(RouteNames.dashboard);
                          }
                        },
                      ),
                actions: [
                  IconButton(
                    tooltip: 'تغییر تم',
                    onPressed: () =>
                        ref.read(themeModeProvider.notifier).toggle(),
                    icon: Icon(
                      themeMode == ThemeMode.dark
                          ? Icons.light_mode_rounded
                          : Icons.dark_mode_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  IconButton(
                    tooltip: 'خروج',
                    onPressed: () =>
                        ref.read(signOutActionProvider.notifier).signOut(),
                    icon: Icon(
                      Icons.logout_rounded,
                      color: AppColors.error.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
        body: child,
      ),
    );
  }
}
