import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kalbala_admin/core/constants/app_constants.dart';
import 'package:kalbala_admin/core/routing/route_names.dart';
import 'package:kalbala_admin/core/theme/app_colors.dart';
import 'package:kalbala_admin/core/theme/app_spacing.dart';
import 'package:kalbala_admin/features/admin/data/admin_remote_datasource.dart';
import 'package:kalbala_admin/shared/widgets/admin_detail.dart';
import 'package:kalbala_admin/shared/widgets/admin_list_tile.dart';
import 'package:kalbala_admin/shared/widgets/admin_media.dart';
import 'package:kalbala_admin/shared/widgets/admin_states.dart';

/// Hub: all client-side flows that wait for admin approval.
class ApprovalsScreen extends ConsumerStatefulWidget {
  const ApprovalsScreen({super.key});

  @override
  ConsumerState<ApprovalsScreen> createState() => _ApprovalsScreenState();
}

class _ApprovalsCounts {
  const _ApprovalsCounts({
    this.verifications = 0,
    this.boothApps = 0,
    this.products = 0,
    this.bankAccounts = 0,
    this.settlements = 0,
    this.reports = 0,
  });

  final int verifications;
  final int boothApps;
  final int products;
  final int bankAccounts;
  final int settlements;
  final int reports;

  int get total =>
      verifications + boothApps + products + bankAccounts + settlements + reports;
}

class _ApprovalsScreenState extends ConsumerState<ApprovalsScreen> {
  static const _accent = Color(0xFFDC6803);

  late Future<_ApprovalsCounts> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_ApprovalsCounts> _load() async {
    final remote = ref.read(adminRemoteDataSourceProvider);
    if (remote == null) return const _ApprovalsCounts();

    Future<int> safe(Future<AdminListPage> Function() call) async {
      try {
        return (await call()).total;
      } catch (_) {
        return 0;
      }
    }

    final results = await Future.wait([
      safe(() => remote.listSellerVerifications(status: 'pending', pageSize: 1)),
      safe(() => remote.listBoothApplications(status: 'pending', pageSize: 1)),
      safe(() => remote.listProducts(approvalStatus: 'pending', pageSize: 1)),
      safe(() => remote.listBankAccounts(isVerified: false, pageSize: 1)),
      safe(() => remote.listSettlements(status: 'requested', pageSize: 1)),
      safe(() => remote.listReports(status: 'pending', pageSize: 1)),
    ]);

    return _ApprovalsCounts(
      verifications: results[0],
      boothApps: results[1],
      products: results[2],
      bankAccounts: results[3],
      settlements: results[4],
      reports: results[5],
    );
  }

  void _reload() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: _accent,
      onRefresh: () async {
        final f = _load();
        setState(() => _future = f);
        await f;
      },
      child: FutureBuilder<_ApprovalsCounts>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: _accent));
          }
          if (snapshot.hasError) {
            return AdminErrorState(
              message: '${snapshot.error}',
              onRetry: _reload,
            );
          }

          final counts = snapshot.data ?? const _ApprovalsCounts();
          final queues = [
            _QueueCard(
              title: 'احراز هویت فروشنده',
              subtitle: 'مدارک هویت در انتظار بررسی',
              count: counts.verifications,
              icon: Icons.badge_rounded,
              accent: const Color(0xFF0A4D3C),
              route: RouteNames.pendingVerifications,
            ),
            _QueueCard(
              title: 'درخواست غرفه',
              subtitle: 'درخواست ساخت فروشگاه',
              count: counts.boothApps,
              icon: Icons.storefront_rounded,
              accent: const Color(0xFF1A8FB8),
              route: RouteNames.pendingBoothApps,
            ),
            _QueueCard(
              title: 'محصولات',
              subtitle: 'محصولات منتظر تأیید',
              count: counts.products,
              icon: Icons.inventory_2_rounded,
              accent: const Color(0xFF127A62),
              route: RouteNames.pendingProducts,
            ),
            _QueueCard(
              title: 'حساب بانکی',
              subtitle: 'حساب‌های تأییدنشده فروشندگان',
              count: counts.bankAccounts,
              icon: Icons.account_balance_rounded,
              accent: const Color(0xFF4F46E5),
              route: RouteNames.pendingBankAccounts,
            ),
            _QueueCard(
              title: 'تسویه',
              subtitle: 'درخواست‌های برداشت در انتظار',
              count: counts.settlements,
              icon: Icons.account_balance_wallet_rounded,
              accent: const Color(0xFF059669),
              route: RouteNames.pendingSettlements,
            ),
            _QueueCard(
              title: 'گزارش‌ها',
              subtitle: 'گزارش‌های کاربران',
              count: counts.reports,
              icon: Icons.flag_rounded,
              accent: const Color(0xFFD92D20),
              route: RouteNames.reports,
            ),
          ];

          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
            children: [
              AdminPageBanner(
                title: 'در انتظار تأیید',
                subtitle: counts.total == 0
                    ? 'فعلاً موردی برای بررسی نیست'
                    : '${counts.total} مورد منتظر اقدام شماست',
                icon: Icons.pending_actions_rounded,
                accent: _accent,
                count: counts.total,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  children: [
                    for (final q in queues) ...[
                      q,
                      const SizedBox(height: AppSpacing.sm),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _QueueCard extends StatelessWidget {
  const _QueueCard({
    required this.title,
    required this.subtitle,
    required this.count,
    required this.icon,
    required this.accent,
    required this.route,
  });

  final String title;
  final String subtitle;
  final int count;
  final IconData icon;
  final Color accent;
  final String route;

  @override
  Widget build(BuildContext context) {
    return AdminColorfulTile(
      title: title,
      subtitle: subtitle,
      icon: icon,
      accent: accent,
      muted: count == 0,
      onTap: () => context.push(route),
      trailing: Container(
        constraints: const BoxConstraints(minWidth: 36),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: count == 0
              ? AppColors.inkMuted.withValues(alpha: 0.12)
              : accent.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        ),
        child: Text(
          '$count',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: count == 0 ? AppColors.inkMuted : accent,
              ),
        ),
      ),
    );
  }
}

// ── Seller verifications ──────────────────────────────────────────────

class PendingVerificationsScreen extends ConsumerStatefulWidget {
  const PendingVerificationsScreen({super.key});

  @override
  ConsumerState<PendingVerificationsScreen> createState() =>
      _PendingVerificationsScreenState();
}

class _PendingVerificationsScreenState
    extends ConsumerState<PendingVerificationsScreen> {
  static const _accent = Color(0xFF0A4D3C);
  late Future<AdminListPage> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<AdminListPage> _load() {
    final remote = ref.read(adminRemoteDataSourceProvider);
    if (remote == null) throw Exception('Supabase پیکربندی نشده است');
    return remote.listSellerVerifications(status: 'pending', pageSize: 50);
  }

  void _reload() => setState(() => _future = _load());

  Future<void> _review(String id, {required bool approve}) async {
    String? reason;
    if (!approve) {
      reason = await promptAdminText(
        context,
        title: 'رد احراز هویت',
        label: 'دلیل رد',
        maxLines: 3,
        confirmLabel: 'رد کردن',
      );
      if (reason == null || reason.isEmpty) return;
    } else {
      final ok = await confirmAdminAction(
        context,
        title: 'تأیید احراز هویت',
        message: 'این درخواست تأیید شود؟',
        confirmLabel: 'تأیید',
      );
      if (!ok) return;
    }

    try {
      await ref.read(adminRemoteDataSourceProvider)?.reviewSellerVerification(
            verificationId: id,
            status: approve ? 'approved' : 'rejected',
            rejectionReason: reason,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(approve ? 'تأیید شد' : 'رد شد')),
      );
      _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AdminListPage>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: _accent));
        }
        if (snapshot.hasError) {
          return AdminErrorState(
            message: '${snapshot.error}',
            onRetry: _reload,
          );
        }
        final items = snapshot.data?.items ?? const [];
        return RefreshIndicator(
          color: _accent,
          onRefresh: () async {
            final f = _load();
            setState(() => _future = f);
            await f;
          },
          child: ListView(
            padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
            children: [
              AdminPageBanner(
                title: 'احراز هویت فروشنده',
                subtitle: 'مدارک در انتظار بررسی',
                icon: Icons.badge_rounded,
                accent: _accent,
                count: items.length,
              ),
              if (items.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(AppSpacing.xl),
                  child: AdminEmptyState(
                    message: 'درخواست احراز هویتی در انتظار نیست',
                    icon: Icons.badge_outlined,
                    accent: _accent,
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Column(
                    children: [
                      for (final item in items) ...[
                        _VerificationCard(
                          item: item,
                          accent: _accent,
                          onApprove: () =>
                              _review(adminStr(item, 'id'), approve: true),
                          onReject: () =>
                              _review(adminStr(item, 'id'), approve: false),
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _VerificationCard extends StatelessWidget {
  const _VerificationCard({
    required this.item,
    required this.accent,
    required this.onApprove,
    required this.onReject,
  });

  final Map<String, dynamic> item;
  final Color accent;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final photo = adminImageUrl(item, keys: const ['photo_url']);
    final name = adminStr(item, 'full_name', adminStr(item, 'profile_name', '—'));
    final phone = adminStr(item, 'phone', adminStr(item, 'profile_phone'));
    final idNumber = adminStr(item, 'id_number');

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: accent.withValues(alpha: 0.14)),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (photo != null)
            AspectRatio(
              aspectRatio: 4 / 3,
              child: AdminNetworkImage(
                url: photo,
                borderRadius: BorderRadius.zero,
                fallbackIcon: Icons.badge_outlined,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                AdminInfoField(
                  label: 'نام',
                  value: name,
                  icon: Icons.person_outline_rounded,
                  accent: accent,
                ),
                AdminInfoField(
                  label: 'موبایل',
                  value: phone,
                  icon: Icons.phone_iphone_rounded,
                  accent: accent,
                ),
                AdminInfoField(
                  label: 'شماره هویت',
                  value: idNumber,
                  icon: Icons.credit_card_outlined,
                  accent: accent,
                  mono: true,
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: onApprove,
                        icon: const Icon(Icons.check_rounded),
                        label: const Text('تأیید'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                        ),
                        onPressed: onReject,
                        icon: const Icon(Icons.close_rounded),
                        label: const Text('رد'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Booth applications ────────────────────────────────────────────────

class PendingBoothAppsScreen extends ConsumerStatefulWidget {
  const PendingBoothAppsScreen({super.key});

  @override
  ConsumerState<PendingBoothAppsScreen> createState() =>
      _PendingBoothAppsScreenState();
}

class _PendingBoothAppsScreenState extends ConsumerState<PendingBoothAppsScreen> {
  static const _accent = Color(0xFF1A8FB8);
  late Future<AdminListPage> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<AdminListPage> _load() {
    final remote = ref.read(adminRemoteDataSourceProvider);
    if (remote == null) throw Exception('Supabase پیکربندی نشده است');
    return remote.listBoothApplications(status: 'pending', pageSize: 50);
  }

  void _reload() => setState(() => _future = _load());

  Future<void> _approve(Map<String, dynamic> item) async {
    final ownership = adminStr(item, 'ownership_type');
    DateTime? start;
    DateTime? end;

    if (ownership == 'rental') {
      final now = DateTime.now();
      start = await showDatePicker(
        context: context,
        firstDate: now.subtract(const Duration(days: 30)),
        lastDate: now.add(const Duration(days: 365 * 3)),
        initialDate: now,
        helpText: 'شروع اجاره',
      );
      if (start == null || !mounted) return;
      end = await showDatePicker(
        context: context,
        firstDate: start,
        lastDate: start.add(const Duration(days: 365 * 3)),
        initialDate: start.add(const Duration(days: 30)),
        helpText: 'پایان اجاره',
      );
      if (end == null || !mounted) return;
    } else {
      final ok = await confirmAdminAction(
        context,
        title: 'تأیید درخواست غرفه',
        message: 'فروشگاه «${adminStr(item, 'booth_name')}» ساخته شود؟',
        confirmLabel: 'تأیید و ساخت',
      );
      if (!ok) return;
    }

    try {
      await ref.read(adminRemoteDataSourceProvider)?.approveBoothApplication(
            applicationId: adminStr(item, 'id'),
            rentalStart: start,
            rentalEnd: end,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('غرفه تأیید و ساخته شد')),
      );
      _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  Future<void> _reject(Map<String, dynamic> item) async {
    final reason = await promptAdminText(
      context,
      title: 'رد درخواست غرفه',
      label: 'دلیل رد',
      maxLines: 3,
      confirmLabel: 'رد کردن',
    );
    if (reason == null || reason.isEmpty) return;
    try {
      await ref.read(adminRemoteDataSourceProvider)?.rejectBoothApplication(
            applicationId: adminStr(item, 'id'),
            reason: reason,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('درخواست رد شد')),
      );
      _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AdminListPage>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: _accent));
        }
        if (snapshot.hasError) {
          return AdminErrorState(message: '${snapshot.error}', onRetry: _reload);
        }
        final items = snapshot.data?.items ?? const [];
        return RefreshIndicator(
          color: _accent,
          onRefresh: () async {
            final f = _load();
            setState(() => _future = f);
            await f;
          },
          child: ListView(
            padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
            children: [
              AdminPageBanner(
                title: 'درخواست غرفه',
                subtitle: 'درخواست‌های ساخت فروشگاه',
                icon: Icons.storefront_rounded,
                accent: _accent,
                count: items.length,
              ),
              if (items.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(AppSpacing.xl),
                  child: AdminEmptyState(
                    message: 'درخواست غرفه‌ای در انتظار نیست',
                    icon: Icons.storefront_outlined,
                    accent: _accent,
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Column(
                    children: [
                      for (final item in items) ...[
                        _BoothAppCard(
                          item: item,
                          accent: _accent,
                          onApprove: () => _approve(item),
                          onReject: () => _reject(item),
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _BoothAppCard extends StatelessWidget {
  const _BoothAppCard({
    required this.item,
    required this.accent,
    required this.onApprove,
    required this.onReject,
  });

  final Map<String, dynamic> item;
  final Color accent;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final cover = adminImageUrl(item, keys: const ['cover_url']);
    final logo = adminImageUrl(item, keys: const ['logo_url']);
    final ownership = adminStr(item, 'ownership_type');
    final verificationOk = adminStr(item, 'verification_status') == 'approved';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: accent.withValues(alpha: 0.14)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          if (cover != null)
            AspectRatio(
              aspectRatio: 16 / 7,
              child: AdminNetworkImage(url: cover, borderRadius: BorderRadius.zero),
            ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                Row(
                  children: [
                    AdminAvatar(
                      url: logo,
                      size: 52,
                      accent: accent,
                      fallbackIcon: Icons.storefront_rounded,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            adminStr(item, 'booth_name', 'بدون نام'),
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          Text(
                            [
                              adminStr(item, 'city'),
                              ownership,
                              adminStr(item, 'owner_name', adminStr(item, 'owner_phone')),
                            ].where((e) => e.isNotEmpty).join(' · '),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.inkMuted,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                AdminInfoField(
                  label: 'توضیحات',
                  value: adminStr(item, 'description'),
                  icon: Icons.notes_rounded,
                  accent: accent,
                  multiline: true,
                ),
                AdminInfoField(
                  label: 'احراز هویت فروشنده',
                  value: verificationOk ? 'تأیید شده' : adminStr(item, 'verification_status', 'نامشخص'),
                  icon: Icons.verified_user_outlined,
                  accent: verificationOk ? AppColors.success : AppColors.warning,
                ),
                if (!verificationOk)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Text(
                      'قبل از تأیید غرفه، احراز هویت فروشنده باید تأیید شود.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.warning,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: verificationOk ? onApprove : null,
                        icon: const Icon(Icons.check_rounded),
                        label: Text(ownership == 'rental' ? 'تأیید + اجاره' : 'تأیید'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                        ),
                        onPressed: onReject,
                        icon: const Icon(Icons.close_rounded),
                        label: const Text('رد'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Pending products ──────────────────────────────────────────────────

class PendingProductsScreen extends ConsumerStatefulWidget {
  const PendingProductsScreen({super.key});

  @override
  ConsumerState<PendingProductsScreen> createState() =>
      _PendingProductsScreenState();
}

class _PendingProductsScreenState extends ConsumerState<PendingProductsScreen> {
  static const _accent = Color(0xFF127A62);
  late Future<AdminListPage> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<AdminListPage> _load() {
    final remote = ref.read(adminRemoteDataSourceProvider);
    if (remote == null) throw Exception('Supabase پیکربندی نشده است');
    return remote.listProducts(approvalStatus: 'pending', pageSize: 50);
  }

  void _reload() => setState(() => _future = _load());

  Future<void> _review(String id, {required bool approve}) async {
    String? reason;
    if (!approve) {
      reason = await promptAdminText(
        context,
        title: 'رد محصول',
        label: 'دلیل رد',
        maxLines: 3,
        confirmLabel: 'رد کردن',
      );
      if (reason == null || reason.isEmpty) return;
    } else {
      final ok = await confirmAdminAction(
        context,
        title: 'تأیید محصول',
        message: 'این محصول تأیید شود؟',
        confirmLabel: 'تأیید',
      );
      if (!ok) return;
    }

    try {
      await ref.read(adminRemoteDataSourceProvider)?.reviewProduct(
            productId: id,
            status: approve ? 'approved' : 'rejected',
            rejectionReason: reason,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(approve ? 'محصول تأیید شد' : 'محصول رد شد')),
      );
      _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AdminListPage>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: _accent));
        }
        if (snapshot.hasError) {
          return AdminErrorState(message: '${snapshot.error}', onRetry: _reload);
        }
        final items = snapshot.data?.items ?? const [];
        return RefreshIndicator(
          color: _accent,
          onRefresh: () async {
            final f = _load();
            setState(() => _future = f);
            await f;
          },
          child: ListView(
            padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
            children: [
              AdminPageBanner(
                title: 'محصولات در انتظار',
                subtitle: 'تأیید یا رد محصولات جدید',
                icon: Icons.inventory_2_rounded,
                accent: _accent,
                count: items.length,
              ),
              if (items.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(AppSpacing.xl),
                  child: AdminEmptyState(
                    message: 'محصولی در انتظار تأیید نیست',
                    icon: Icons.inventory_2_outlined,
                    accent: _accent,
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Column(
                    children: [
                      for (final item in items) ...[
                        AdminColorfulTile(
                          title: adminStr(item, 'name', 'بدون نام'),
                          subtitle: [
                            adminStr(item, 'brand'),
                            adminStr(item, 'creator_name', adminStr(item, 'creator_phone')),
                            adminStr(item, 'category_name'),
                          ].where((e) => e.isNotEmpty).join(' · '),
                          icon: Icons.inventory_2_rounded,
                          accent: _accent,
                          onTap: () => context.push(
                            RouteNames.productDetailPath(adminStr(item, 'id')),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'تأیید',
                                onPressed: () =>
                                    _review(adminStr(item, 'id'), approve: true),
                                icon: const Icon(Icons.check_circle, color: AppColors.success),
                              ),
                              IconButton(
                                tooltip: 'رد',
                                onPressed: () =>
                                    _review(adminStr(item, 'id'), approve: false),
                                icon: const Icon(Icons.cancel, color: AppColors.error),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// ── Pending bank accounts ─────────────────────────────────────────────

class PendingBankAccountsScreen extends ConsumerStatefulWidget {
  const PendingBankAccountsScreen({super.key});

  @override
  ConsumerState<PendingBankAccountsScreen> createState() =>
      _PendingBankAccountsScreenState();
}

class _PendingBankAccountsScreenState
    extends ConsumerState<PendingBankAccountsScreen> {
  static const _accent = Color(0xFF4F46E5);
  late Future<AdminListPage> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<AdminListPage> _load() {
    final remote = ref.read(adminRemoteDataSourceProvider);
    if (remote == null) throw Exception('Supabase پیکربندی نشده است');
    return remote.listBankAccounts(isVerified: false, pageSize: 50);
  }

  void _reload() => setState(() => _future = _load());

  Future<void> _verify(String id) async {
    final ok = await confirmAdminAction(
      context,
      title: 'تأیید حساب بانکی',
      message: 'این حساب بانکی تأیید شود؟',
      confirmLabel: 'تأیید',
    );
    if (!ok) return;
    try {
      await ref.read(adminRemoteDataSourceProvider)?.verifyBankAccount(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حساب بانکی تأیید شد')),
      );
      _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AdminListPage>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: _accent));
        }
        if (snapshot.hasError) {
          return AdminErrorState(message: '${snapshot.error}', onRetry: _reload);
        }
        final items = snapshot.data?.items ?? const [];
        return RefreshIndicator(
          color: _accent,
          onRefresh: () async {
            final f = _load();
            setState(() => _future = f);
            await f;
          },
          child: ListView(
            padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
            children: [
              AdminPageBanner(
                title: 'حساب‌های بانکی',
                subtitle: 'حساب‌های تأییدنشده',
                icon: Icons.account_balance_rounded,
                accent: _accent,
                count: items.length,
              ),
              if (items.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(AppSpacing.xl),
                  child: AdminEmptyState(
                    message: 'حساب تأییدنشده‌ای نیست',
                    icon: Icons.account_balance_outlined,
                    accent: _accent,
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Column(
                    children: [
                      for (final item in items) ...[
                        Container(
                          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceRaised,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                            border: Border.all(color: _accent.withValues(alpha: 0.14)),
                          ),
                          child: Column(
                            children: [
                              AdminInfoField(
                                label: 'بانک',
                                value: adminStr(item, 'bank_name'),
                                icon: Icons.account_balance_outlined,
                                accent: _accent,
                              ),
                              AdminInfoField(
                                label: 'صاحب حساب',
                                value: adminStr(item, 'account_holder'),
                                icon: Icons.person_outline_rounded,
                                accent: _accent,
                              ),
                              AdminInfoField(
                                label: 'شماره حساب',
                                value: adminStr(item, 'account_number'),
                                icon: Icons.credit_card_outlined,
                                accent: _accent,
                                mono: true,
                              ),
                              AdminInfoField(
                                label: 'فروشنده',
                                value: adminStr(
                                  item,
                                  'seller_name',
                                  adminStr(item, 'seller_phone'),
                                ),
                                icon: Icons.storefront_outlined,
                                accent: _accent,
                              ),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton.icon(
                                  onPressed: () => _verify(adminStr(item, 'id')),
                                  icon: const Icon(Icons.verified_rounded),
                                  label: const Text('تأیید حساب'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// ── Pending settlements ───────────────────────────────────────────────

class PendingSettlementsScreen extends ConsumerStatefulWidget {
  const PendingSettlementsScreen({super.key});

  @override
  ConsumerState<PendingSettlementsScreen> createState() =>
      _PendingSettlementsScreenState();
}

class _PendingSettlementsScreenState
    extends ConsumerState<PendingSettlementsScreen> {
  static const _accent = Color(0xFF059669);
  late Future<AdminListPage> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<AdminListPage> _load() {
    final remote = ref.read(adminRemoteDataSourceProvider);
    if (remote == null) throw Exception('Supabase پیکربندی نشده است');
    return remote.listSettlements(status: 'requested', pageSize: 50);
  }

  void _reload() => setState(() => _future = _load());

  Future<void> _process(String id, String status) async {
    String? reason;
    if (status == 'rejected') {
      reason = await promptAdminText(
        context,
        title: 'رد تسویه',
        label: 'دلیل رد',
        maxLines: 3,
        confirmLabel: 'رد',
      );
      if (reason == null || reason.isEmpty) return;
    } else {
      final label = switch (status) {
        'processing' => 'در حال پردازش',
        'completed' => 'تکمیل / پرداخت‌شده',
        _ => status,
      };
      final ok = await confirmAdminAction(
        context,
        title: 'به‌روزرسانی تسویه',
        message: 'وضعیت به «$label» تغییر کند؟',
        confirmLabel: 'بله',
      );
      if (!ok) return;
    }

    try {
      await ref.read(adminRemoteDataSourceProvider)?.processSettlementStatus(
            settlementId: id,
            status: status,
            rejectionReason: reason,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('وضعیت تسویه به‌روز شد')),
      );
      _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AdminListPage>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: _accent));
        }
        if (snapshot.hasError) {
          return AdminErrorState(message: '${snapshot.error}', onRetry: _reload);
        }
        final items = snapshot.data?.items ?? const [];
        return RefreshIndicator(
          color: _accent,
          onRefresh: () async {
            final f = _load();
            setState(() => _future = f);
            await f;
          },
          child: ListView(
            padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
            children: [
              AdminPageBanner(
                title: 'تسویه‌های در انتظار',
                subtitle: 'درخواست‌های برداشت فروشندگان',
                icon: Icons.account_balance_wallet_rounded,
                accent: _accent,
                count: items.length,
              ),
              if (items.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(AppSpacing.xl),
                  child: AdminEmptyState(
                    message: 'تسویه‌ای در انتظار نیست',
                    icon: Icons.account_balance_wallet_outlined,
                    accent: _accent,
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Column(
                    children: [
                      for (final item in items) ...[
                        Container(
                          margin: const EdgeInsets.only(bottom: AppSpacing.md),
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceRaised,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                            border: Border.all(color: _accent.withValues(alpha: 0.14)),
                          ),
                          child: Column(
                            children: [
                              AdminInfoField(
                                label: 'مبلغ',
                                value:
                                    '${item['amount'] ?? '—'} ${AppConstants.currencySymbol}',
                                icon: Icons.payments_outlined,
                                accent: _accent,
                              ),
                              AdminInfoField(
                                label: 'فروشنده',
                                value: adminStr(
                                  item,
                                  'seller_name',
                                  adminStr(item, 'seller_phone'),
                                ),
                                icon: Icons.person_outline_rounded,
                                accent: _accent,
                              ),
                              AdminInfoField(
                                label: 'بانک',
                                value:
                                    '${adminStr(item, 'bank_name')} · ${adminStr(item, 'account_number')}',
                                icon: Icons.account_balance_outlined,
                                accent: _accent,
                              ),
                              AdminInfoField(
                                label: 'تاریخ درخواست',
                                value: adminStr(item, 'requested_at'),
                                icon: Icons.calendar_today_outlined,
                                accent: _accent,
                              ),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  FilledButton.tonal(
                                    onPressed: () =>
                                        _process(adminStr(item, 'id'), 'processing'),
                                    child: const Text('در حال پردازش'),
                                  ),
                                  FilledButton(
                                    onPressed: () =>
                                        _process(adminStr(item, 'id'), 'completed'),
                                    child: const Text('تکمیل شد'),
                                  ),
                                  OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.error,
                                    ),
                                    onPressed: () =>
                                        _process(adminStr(item, 'id'), 'rejected'),
                                    child: const Text('رد'),
                                  ),
                                  TextButton(
                                    onPressed: () => context.push(
                                      RouteNames.settlementDetailPath(
                                        adminStr(item, 'id'),
                                      ),
                                    ),
                                    child: const Text('جزئیات'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
