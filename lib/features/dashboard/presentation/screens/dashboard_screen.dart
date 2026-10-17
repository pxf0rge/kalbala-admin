import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kalbala_admin/core/constants/app_constants.dart';
import 'package:kalbala_admin/core/routing/route_names.dart';
import 'package:kalbala_admin/core/theme/app_colors.dart';
import 'package:kalbala_admin/core/theme/app_spacing.dart';
import 'package:kalbala_admin/features/admin/data/admin_remote_datasource.dart';
import 'package:kalbala_admin/features/auth/presentation/providers/auth_provider.dart';
import 'package:kalbala_admin/shared/widgets/kalbala_logo_mark.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  late Future<_DashboardStats> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = _loadStats();
  }

  Future<_DashboardStats> _loadStats() async {
    final remote = ref.read(adminRemoteDataSourceProvider);
    if (remote == null) {
      return const _DashboardStats();
    }

    Future<int?> one(Future<AdminListPage> Function() call) async {
      try {
        return (await call()).total;
      } catch (_) {
        return null;
      }
    }

    final results = await Future.wait([
      one(() => remote.listUsers(pageSize: 1)),
      one(() => remote.listBooths(pageSize: 1)),
      one(() => remote.listListings(pageSize: 1)),
      one(() => remote.listOrders(pageSize: 1)),
    ]);

    return _DashboardStats(
      users: results[0],
      booths: results[1],
      listings: results[2],
      orders: results[3],
    );
  }

  void _refresh() {
    setState(() {
      _statsFuture = _loadStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final admin = ref.watch(currentAdminProvider).valueOrNull;
    final now = DateTime.now();
    final dateLabel =
        '${now.year}/${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}';

    return RefreshIndicator(
      color: AppColors.accent,
      backgroundColor: AppColors.surface,
      onRefresh: () async {
        final future = _loadStats();
        setState(() => _statsFuture = future);
        await future;
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          _WelcomeHero(
            name: admin?.displayName ?? 'مدیر',
            role: admin?.adminRole ?? 'admin',
            dateLabel: dateLabel,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.xl,
              AppSpacing.lg,
              AppSpacing.xxl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _SectionHeader(
                  title: 'وضعیت بازارگاه',
                  subtitle: 'آمار لحظه‌ای پلتفرم',
                  icon: Icons.insights_rounded,
                  accent: AppColors.primary,
                ),
                const SizedBox(height: AppSpacing.md),
                FutureBuilder<_DashboardStats>(
                  future: _statsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting &&
                        !snapshot.hasData) {
                      return const _StatsLoadingGrid();
                    }

                    final stats = snapshot.data ?? const _DashboardStats();
                    return _StatsGrid(stats: stats);
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => context.push(RouteNames.approvals),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    child: Ink(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                        gradient: const LinearGradient(
                          begin: Alignment.centerRight,
                          end: Alignment.centerLeft,
                          colors: [Color(0xFFE2A116), Color(0xFFDC6803)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFDC6803).withValues(alpha: 0.28),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.pending_actions_rounded,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'در انتظار تأیید',
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                                Text(
                                  'احراز هویت، غرفه، محصول، بانک، تسویه و گزارش',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colors.white.withValues(alpha: 0.88),
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_left_rounded,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                const _SectionHeader(
                  title: 'دسترسی سریع',
                  subtitle: 'همه ماژول‌های مدیریت در یک نگاه',
                  icon: Icons.grid_view_rounded,
                  accent: AppColors.accent,
                ),
                const SizedBox(height: AppSpacing.lg),
                const _QuickActionsPanel(),
                const SizedBox(height: AppSpacing.lg),
                Center(
                  child: FilledButton.tonalIcon(
                    onPressed: _refresh,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('به‌روزرسانی آمار'),
                    style: FilledButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      backgroundColor: AppColors.primarySoft,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                    ),
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

class _DashboardStats {
  const _DashboardStats({
    this.users,
    this.booths,
    this.listings,
    this.orders,
  });

  final int? users;
  final int? booths;
  final int? listings;
  final int? orders;
}

class _WelcomeHero extends StatelessWidget {
  const _WelcomeHero({
    required this.name,
    required this.role,
    required this.dateLabel,
  });

  final String name;
  final String role;
  final String dateLabel;

  @override
  Widget build(BuildContext context) {
    final roleLabel = switch (role) {
      'super_admin' => 'مدیر ارشد',
      'admin' => 'مدیر',
      _ => role,
    };

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(AppSpacing.radiusLg + 4),
        bottomRight: Radius.circular(AppSpacing.radiusLg + 4),
      ),
      child: Stack(
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
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Opacity(
              opacity: 0.18,
              child: Image.asset(
                'assets/branding/login_skyline.png',
                height: 72,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
          ),
          Positioned(
            top: -40,
            left: -30,
            child: _GlowOrb(
              size: 140,
              color: AppColors.accent.withValues(alpha: 0.18),
            ),
          ),
          Positioned(
            bottom: -20,
            right: -10,
            child: _GlowOrb(
              size: 100,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.accent.withValues(alpha: 0.22),
                                  borderRadius:
                                      BorderRadius.circular(AppSpacing.radiusPill),
                                  border: Border.all(
                                    color: AppColors.accent.withValues(alpha: 0.45),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.calendar_today_rounded,
                                      size: 12,
                                      color: Colors.white.withValues(alpha: 0.92),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      dateLabel,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            color: Colors.white.withValues(alpha: 0.92),
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'سلام، $name 👋',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  height: 1.2,
                                ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            AppConstants.appTagline,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.78),
                                  height: 1.5,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.verified_user_rounded,
                                  size: 14,
                                  color: AppColors.accent.withValues(alpha: 0.95),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  roleLabel,
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.22),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const KalBalaLogoMark(
                        size: 52,
                        color: Colors.white,
                        showAccent: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    gradient: LinearGradient(
                      colors: [
                        AppColors.accent.withValues(alpha: 0.15),
                        AppColors.accent,
                        AppColors.accent.withValues(alpha: 0.15),
                      ],
                    ),
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

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                accent.withValues(alpha: 0.18),
                accent.withValues(alpha: 0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: accent.withValues(alpha: 0.22)),
          ),
          child: Icon(icon, color: accent, size: 22),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.inkMuted,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats});

  final _DashboardStats stats;

  @override
  Widget build(BuildContext context) {
    final items = [
      _StatItem(
        title: 'کاربران',
        value: stats.users,
        icon: Icons.people_alt_rounded,
        gradient: const [Color(0xFF0D6B56), Color(0xFF0A4D3C)],
        route: RouteNames.users,
      ),
      _StatItem(
        title: 'غرفه‌ها',
        value: stats.booths,
        icon: Icons.storefront_rounded,
        gradient: const [Color(0xFF1A8FB8), Color(0xFF1565C0)],
        route: RouteNames.booths,
      ),
      _StatItem(
        title: 'آگهی‌ها',
        value: stats.listings,
        icon: Icons.inventory_2_rounded,
        gradient: const [Color(0xFFE2A116), Color(0xFFC77800)],
        route: RouteNames.listings,
      ),
      _StatItem(
        title: 'سفارش‌ها',
        value: stats.orders,
        icon: Icons.receipt_long_rounded,
        gradient: const [Color(0xFFE25555), Color(0xFFB42318)],
        route: RouteNames.orders,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 720;
        if (wide) {
          return Row(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                if (i > 0) const SizedBox(width: AppSpacing.md),
                Expanded(child: _StatCard(item: items[i])),
              ],
            ],
          );
        }

        return Column(
          children: [
            Row(
              children: [
                Expanded(child: _StatCard(item: items[0])),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: _StatCard(item: items[1])),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(child: _StatCard(item: items[2])),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: _StatCard(item: items[3])),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _StatItem {
  const _StatItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
    required this.route,
  });

  final String title;
  final int? value;
  final IconData icon;
  final List<Color> gradient;
  final String route;
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.item});

  final _StatItem item;

  @override
  Widget build(BuildContext context) {
    final valueText = item.value == null
        ? '—'
        : NumberFormat.decimalPattern().format(item.value);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push(item.route),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: item.gradient,
            ),
            boxShadow: [
              BoxShadow(
                color: item.gradient.last.withValues(alpha: 0.28),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: -12,
                left: -12,
                child: _GlowOrb(
                  size: 56,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
              Positioned(
                bottom: -8,
                right: -8,
                child: Icon(
                  item.icon,
                  size: 64,
                  color: Colors.white.withValues(alpha: 0.12),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(item.icon, color: Colors.white, size: 20),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      valueText,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.title,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.88),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsLoadingGrid extends StatelessWidget {
  const _StatsLoadingGrid();

  @override
  Widget build(BuildContext context) {
    Widget box(Color color) => Container(
          height: 118,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                color.withValues(alpha: 0.35),
                color.withValues(alpha: 0.18),
              ],
            ),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        );

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: box(AppColors.primary)),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: box(const Color(0xFF1565C0))),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(child: box(AppColors.accent)),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: box(AppColors.error)),
          ],
        ),
      ],
    );
  }
}

class _QuickAction {
  const _QuickAction({
    required this.title,
    required this.icon,
    required this.route,
    required this.color,
  });

  final String title;
  final IconData icon;
  final String route;
  final Color color;
}

class _ActionGroup {
  const _ActionGroup({
    required this.title,
    required this.emoji,
    required this.accent,
    required this.actions,
  });

  final String title;
  final String emoji;
  final Color accent;
  final List<_QuickAction> actions;
}

class _QuickActionsPanel extends StatelessWidget {
  const _QuickActionsPanel();

  static const _groups = [
    _ActionGroup(
      title: 'بازارگاه',
      emoji: '🛒',
      accent: AppColors.primary,
      actions: [
        _QuickAction(
          title: 'کاربران',
          icon: Icons.people_alt_rounded,
          route: RouteNames.users,
          color: Color(0xFF0A4D3C),
        ),
        _QuickAction(
          title: 'محصولات',
          icon: Icons.inventory_2_rounded,
          route: RouteNames.products,
          color: Color(0xFF127A62),
        ),
        _QuickAction(
          title: 'آگهی‌ها',
          icon: Icons.sell_rounded,
          route: RouteNames.listings,
          color: Color(0xFF0D6B56),
        ),
        _QuickAction(
          title: 'غرفه‌ها',
          icon: Icons.storefront_rounded,
          route: RouteNames.booths,
          color: Color(0xFF1A8FB8),
        ),
        _QuickAction(
          title: 'سفارش‌ها',
          icon: Icons.receipt_long_rounded,
          route: RouteNames.orders,
          color: Color(0xFFB42318),
        ),
      ],
    ),
    _ActionGroup(
      title: 'محتوا',
      emoji: '🎨',
      accent: Color(0xFF7C3AED),
      actions: [
        _QuickAction(
          title: 'دسته‌ها',
          icon: Icons.category_rounded,
          route: RouteNames.categories,
          color: Color(0xFF7C3AED),
        ),
        _QuickAction(
          title: 'بنرها',
          icon: Icons.view_carousel_rounded,
          route: RouteNames.banners,
          color: Color(0xFF9333EA),
        ),
      ],
    ),
    _ActionGroup(
      title: 'اعتماد و پشتیبانی',
      emoji: '🛡️',
      accent: Color(0xFFDC6803),
      actions: [
        _QuickAction(
          title: 'در انتظار تأیید',
          icon: Icons.pending_actions_rounded,
          route: RouteNames.approvals,
          color: Color(0xFFDC6803),
        ),
        _QuickAction(
          title: 'نظرات',
          icon: Icons.rate_review_rounded,
          route: RouteNames.reviews,
          color: Color(0xFFDC6803),
        ),
        _QuickAction(
          title: 'گزارش‌ها',
          icon: Icons.flag_rounded,
          route: RouteNames.reports,
          color: Color(0xFFD92D20),
        ),
        _QuickAction(
          title: 'پشتیبانی',
          icon: Icons.support_agent_rounded,
          route: RouteNames.tickets,
          color: Color(0xFF2563EB),
        ),
      ],
    ),
    _ActionGroup(
      title: 'مالی',
      emoji: '💰',
      accent: Color(0xFF0891B2),
      actions: [
        _QuickAction(
          title: 'پرداخت‌ها',
          icon: Icons.payments_rounded,
          route: RouteNames.payments,
          color: Color(0xFF0891B2),
        ),
        _QuickAction(
          title: 'بازپرداخت‌ها',
          icon: Icons.replay_rounded,
          route: RouteNames.refunds,
          color: Color(0xFF0E7490),
        ),
        _QuickAction(
          title: 'تسویه‌ها',
          icon: Icons.account_balance_wallet_rounded,
          route: RouteNames.settlements,
          color: Color(0xFF059669),
        ),
        _QuickAction(
          title: 'موجودی',
          icon: Icons.savings_rounded,
          route: RouteNames.balances,
          color: Color(0xFF16A34A),
        ),
        _QuickAction(
          title: 'حساب بانکی',
          icon: Icons.account_balance_rounded,
          route: RouteNames.bankAccounts,
          color: Color(0xFF4F46E5),
        ),
        _QuickAction(
          title: 'کمیسیون',
          icon: Icons.percent_rounded,
          route: RouteNames.commission,
          color: Color(0xFFCA8A04),
        ),
        _QuickAction(
          title: 'نرخ ارسال',
          icon: Icons.local_shipping_rounded,
          route: RouteNames.shipping,
          color: Color(0xFFEA580C),
        ),
      ],
    ),
    _ActionGroup(
      title: 'سیستم',
      emoji: '⚙️',
      accent: Color(0xFF475569),
      actions: [
        _QuickAction(
          title: 'تنظیمات',
          icon: Icons.settings_rounded,
          route: RouteNames.settings,
          color: Color(0xFF475569),
        ),
        _QuickAction(
          title: 'اعلان‌ها',
          icon: Icons.notifications_rounded,
          route: RouteNames.notifications,
          color: Color(0xFF2563EB),
        ),
        _QuickAction(
          title: 'ادمین‌ها',
          icon: Icons.admin_panel_settings_rounded,
          route: RouteNames.admins,
          color: Color(0xFF0A4D3C),
        ),
        _QuickAction(
          title: 'لاگ ممیزی',
          icon: Icons.history_rounded,
          route: RouteNames.audit,
          color: Color(0xFF64748B),
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < _groups.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.lg),
          _ActionGroupCard(group: _groups[i]),
        ],
      ],
    );
  }
}

class _ActionGroupCard extends StatelessWidget {
  const _ActionGroupCard({required this.group});

  final _ActionGroup group;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: group.accent.withValues(alpha: 0.14)),
        boxShadow: [
          BoxShadow(
            color: group.accent.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
                colors: [
                  group.accent.withValues(alpha: 0.12),
                  group.accent.withValues(alpha: 0.04),
                ],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppSpacing.radiusLg),
              ),
            ),
            child: Row(
              children: [
                Text(group.emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(
                  group.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: group.accent,
                      ),
                ),
                const Spacer(),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: group.accent,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: LayoutBuilder(
              builder: (context, constraints) {
                const spacing = AppSpacing.sm;
                final tileWidth = (constraints.maxWidth - spacing) / 2;

                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: [
                    for (final action in group.actions)
                      SizedBox(
                        width: tileWidth,
                        child: _QuickActionTile(action: action),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({required this.action});

  final _QuickAction action;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push(action.route),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Ink(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            color: action.color.withValues(alpha: 0.06),
            border: Border.all(
              color: action.color.withValues(alpha: 0.12),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      action.color.withValues(alpha: 0.85),
                      action.color,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: action.color.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(action.icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  action.title,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.chevron_left_rounded,
                size: 18,
                color: action.color.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
