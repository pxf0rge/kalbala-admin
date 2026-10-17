import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kalbala_admin/core/constants/app_constants.dart';
import 'package:kalbala_admin/core/routing/route_names.dart';
import 'package:kalbala_admin/core/theme/app_colors.dart';
import 'package:kalbala_admin/core/theme/app_spacing.dart';
import 'package:kalbala_admin/features/admin/data/admin_remote_datasource.dart';
import 'package:kalbala_admin/shared/widgets/admin_detail.dart';
import 'package:kalbala_admin/shared/widgets/admin_list_scaffold.dart';
import 'package:kalbala_admin/shared/widgets/admin_list_tile.dart';

class PaymentsScreen extends ConsumerWidget {
  const PaymentsScreen({super.key});

  static const _accent = Color(0xFF0891B2);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remote = ref.watch(adminRemoteDataSourceProvider);
    return AdminListScaffold(
      title: 'پرداخت‌ها',
      subtitle: 'مشاهده تراکنش‌های پرداخت',
      icon: Icons.payments_rounded,
      accent: _accent,
      searchHint: 'جستجوی پرداخت…',
      emptyMessage: 'پرداختی یافت نشد',
      fetcher: ({required search}) {
        if (remote == null) return Future.error('Supabase پیکربندی نشده است');
        return remote.listPayments(search: search);
      },
      rowBuilder: (context, item) {
        final id = adminStr(item, 'id');
        final status = adminStr(item, 'status');
        final amount = item['amount'];
        final gateway = adminStr(item, 'gateway');
        return AdminColorfulTile(
          title: amount == null ? id : '$amount ${AppConstants.currencySymbol}',
          accent: _accent,
          icon: Icons.payments_rounded,
          onTap: id.isEmpty ? null : () => context.push(RouteNames.paymentDetailPath(id)),
          subtitle: [gateway, status].where((e) => e.isNotEmpty).join(' · '),
        );
      },
    );
  }
}

class PaymentDetailScreen extends ConsumerStatefulWidget {
  const PaymentDetailScreen({super.key, required this.paymentId});
  final String paymentId;

  @override
  ConsumerState<PaymentDetailScreen> createState() => _PaymentDetailScreenState();
}

class _PaymentDetailScreenState extends ConsumerState<PaymentDetailScreen> {
  static const _accent = Color(0xFF0891B2);

  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<Map<String, dynamic>> _load() {
    final remote = ref.read(adminRemoteDataSourceProvider);
    if (remote == null) throw Exception('Supabase پیکربندی نشده است');
    return remote.getPaymentDetail(widget.paymentId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _future,
      builder: (context, snapshot) {
        final data = snapshot.data;
        final payment = adminMap(data?['payment'] ?? data) ?? data;
        return AdminDetailScaffold(
          title: 'جزئیات پرداخت',
          subtitle: adminStr(payment, 'status'),
          accent: _accent,
          icon: Icons.payments_rounded,
          isLoading: snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData,
          error: snapshot.hasError ? '${snapshot.error}' : null,
          onRetry: () => setState(() => _future = _load()),
          body: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              AdminInfoSection(
                title: 'پرداخت',
                accent: _accent,
                icon: Icons.account_balance_wallet_outlined,
                children: [
                  AdminInfoField(
                    label: 'شناسه',
                    value: widget.paymentId,
                    icon: Icons.fingerprint_rounded,
                    accent: _accent,
                    mono: true,
                  ),
                  AdminInfoField(
                    label: 'وضعیت',
                    value: adminStr(payment, 'status'),
                    icon: Icons.flag_outlined,
                    accent: _accent,
                  ),
                  AdminInfoField(
                    label: 'مبلغ',
                    value: payment?['amount'] == null
                        ? '—'
                        : '${payment?['amount']} ${AppConstants.currencySymbol}',
                    icon: Icons.payments_outlined,
                    accent: _accent,
                  ),
                  AdminInfoField(
                    label: 'درگاه',
                    value: adminStr(payment, 'gateway'),
                    icon: Icons.account_balance_outlined,
                    accent: _accent,
                  ),
                  AdminInfoField(
                    label: 'سفارش',
                    value: adminStr(payment, 'order_id'),
                    icon: Icons.receipt_long_outlined,
                    accent: _accent,
                    mono: true,
                  ),
                  AdminInfoField(
                    label: 'مرجع',
                    value: adminStr(payment, 'gateway_reference'),
                    icon: Icons.tag_rounded,
                    accent: _accent,
                    mono: true,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class RefundsScreen extends ConsumerWidget {
  const RefundsScreen({super.key});

  static const _accent = Color(0xFF0E7490);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remote = ref.watch(adminRemoteDataSourceProvider);
    return AdminListScaffold(
      title: 'بازپرداخت‌ها',
      subtitle: 'پیگیری بازپرداخت‌ها',
      icon: Icons.replay_rounded,
      accent: _accent,
      emptyMessage: 'بازپرداختی یافت نشد',
      fetcher: ({required search}) {
        if (remote == null) return Future.error('Supabase پیکربندی نشده است');
        return remote.listRefunds(search: search);
      },
      rowBuilder: (context, item) {
        return AdminColorfulTile(
          title: '${item['amount'] ?? '—'} ${AppConstants.currencySymbol}',
          accent: _accent,
          icon: Icons.replay_rounded,
          subtitle: adminStr(item, 'status'),
        );
      },
    );
  }
}

class SettlementsScreen extends ConsumerWidget {
  const SettlementsScreen({super.key});

  static const _accent = Color(0xFF059669);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remote = ref.watch(adminRemoteDataSourceProvider);
    return AdminListScaffold(
      title: 'تسویه‌ها',
      subtitle: 'درخواست‌های تسویه فروشندگان',
      icon: Icons.account_balance_wallet_rounded,
      accent: _accent,
      emptyMessage: 'تسویه‌ای یافت نشد',
      fetcher: ({required search}) {
        if (remote == null) return Future.error('Supabase پیکربندی نشده است');
        return remote.listSettlements(search: search);
      },
      rowBuilder: (context, item) {
        final id = adminStr(item, 'id');
        return AdminColorfulTile(
          title: '${item['amount'] ?? '—'} ${AppConstants.currencySymbol}',
          accent: _accent,
          icon: Icons.account_balance_wallet_rounded,
          onTap: id.isEmpty ? null : () => context.push(RouteNames.settlementDetailPath(id)),
          subtitle: adminStr(item, 'status'),
        );
      },
    );
  }
}

class SettlementDetailScreen extends ConsumerStatefulWidget {
  const SettlementDetailScreen({super.key, required this.settlementId});
  final String settlementId;

  @override
  ConsumerState<SettlementDetailScreen> createState() => _SettlementDetailScreenState();
}

class _SettlementDetailScreenState extends ConsumerState<SettlementDetailScreen> {
  static const _accent = Color(0xFF059669);

  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<Map<String, dynamic>> _load() {
    final remote = ref.read(adminRemoteDataSourceProvider);
    if (remote == null) throw Exception('Supabase پیکربندی نشده است');
    return remote.getSettlementDetail(widget.settlementId);
  }

  Future<void> _process(String status) async {
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
      final ok = await confirmAdminAction(
        context,
        title: 'به‌روزرسانی تسویه',
        message: 'وضعیت تسویه تغییر کند؟',
        confirmLabel: 'بله',
      );
      if (!ok) return;
    }
    try {
      await ref.read(adminRemoteDataSourceProvider)?.processSettlementStatus(
            settlementId: widget.settlementId,
            status: status,
            rejectionReason: reason,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('وضعیت به‌روز شد')),
      );
      setState(() => _future = _load());
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _future,
      builder: (context, snapshot) {
        final data = snapshot.data;
        final settlement = adminMap(data?['settlement'] ?? data) ?? data;
        final status = adminStr(settlement, 'status');
        final canProcess = status == 'requested' || status == 'processing';

        return AdminDetailScaffold(
          title: 'جزئیات تسویه',
          accent: _accent,
          icon: Icons.account_balance_wallet_rounded,
          isLoading: snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData,
          error: snapshot.hasError ? '${snapshot.error}' : null,
          onRetry: () => setState(() => _future = _load()),
          body: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              AdminInfoSection(
                title: 'تسویه',
                accent: _accent,
                icon: Icons.savings_outlined,
                trailing: AdminStatusChip(label: status.isEmpty ? '—' : status),
                children: [
                  AdminInfoField(
                    label: 'شناسه',
                    value: widget.settlementId,
                    icon: Icons.fingerprint_rounded,
                    accent: _accent,
                    mono: true,
                  ),
                  AdminInfoField(
                    label: 'وضعیت',
                    value: status,
                    icon: Icons.flag_outlined,
                    accent: _accent,
                  ),
                  AdminInfoField(
                    label: 'مبلغ',
                    value: settlement?['amount'] == null
                        ? '—'
                        : '${settlement?['amount']} ${AppConstants.currencySymbol}',
                    icon: Icons.payments_outlined,
                    accent: _accent,
                  ),
                  AdminInfoField(
                    label: 'فروشنده',
                    value: adminStr(settlement, 'seller_id'),
                    icon: Icons.person_outline_rounded,
                    accent: _accent,
                    mono: true,
                  ),
                  AdminInfoField(
                    label: 'بانک',
                    value: adminStr(settlement, 'bank_name'),
                    icon: Icons.account_balance_outlined,
                    accent: _accent,
                  ),
                  AdminInfoField(
                    label: 'شماره حساب',
                    value: adminStr(settlement, 'account_number'),
                    icon: Icons.credit_card_outlined,
                    accent: _accent,
                    mono: true,
                  ),
                  if (adminStr(settlement, 'rejection_reason').isNotEmpty)
                    AdminInfoField(
                      label: 'دلیل رد',
                      value: adminStr(settlement, 'rejection_reason'),
                      icon: Icons.info_outline,
                      accent: AppColors.error,
                      multiline: true,
                    ),
                ],
              ),
              if (canProcess)
                AdminActionGroup(
                  accent: _accent,
                  children: [
                    FilledButton.tonal(
                      onPressed: () => _process('processing'),
                      child: const Text('علامت‌گذاری: در حال پردازش'),
                    ),
                    FilledButton(
                      onPressed: () => _process('completed'),
                      child: const Text('تکمیل / پرداخت شد'),
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
                      onPressed: () => _process('rejected'),
                      child: const Text('رد درخواست'),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

class BalancesScreen extends ConsumerWidget {
  const BalancesScreen({super.key});

  static const _accent = Color(0xFF16A34A);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remote = ref.watch(adminRemoteDataSourceProvider);
    return AdminListScaffold(
      title: 'موجودی فروشندگان',
      subtitle: 'مانده قابل برداشت',
      icon: Icons.savings_rounded,
      accent: _accent,
      emptyMessage: 'موجودی‌ای یافت نشد',
      fetcher: ({required search}) {
        if (remote == null) return Future.error('Supabase پیکربندی نشده است');
        return remote.listSellerBalances(search: search);
      },
      rowBuilder: (context, item) {
        return AdminColorfulTile(
          title: adminStr(item, 'seller_name', adminStr(item, 'seller_id', 'فروشنده')),
          accent: _accent,
          icon: Icons.savings_rounded,
          subtitle:
              'قابل برداشت: ${item['available_balance'] ?? item['balance'] ?? '—'} ${AppConstants.currencySymbol}',
        );
      },
    );
  }
}

class BankAccountsScreen extends ConsumerWidget {
  const BankAccountsScreen({super.key});

  static const _accent = Color(0xFF4F46E5);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remote = ref.watch(adminRemoteDataSourceProvider);
    return AdminListScaffold(
      title: 'حساب‌های بانکی',
      subtitle: 'حساب‌های اعلام‌شده فروشندگان',
      icon: Icons.account_balance_rounded,
      accent: _accent,
      emptyMessage: 'حسابی یافت نشد',
      fetcher: ({required search}) {
        if (remote == null) return Future.error('Supabase پیکربندی نشده است');
        return remote.listBankAccounts(search: search);
      },
      rowBuilder: (context, item) {
        final verified = adminBool(item, 'is_verified');
        final id = adminStr(item, 'id');
        return AdminColorfulTile(
          title: adminStr(item, 'bank_name', 'بانک'),
          accent: verified ? AppColors.success : AppColors.warning,
          icon: Icons.account_balance_rounded,
          subtitle: [
            adminStr(item, 'account_holder'),
            adminStr(item, 'account_number'),
            verified ? 'تأییدشده' : 'تأییدنشده',
          ].where((e) => e.isNotEmpty).join(' · '),
          onTap: verified || id.isEmpty
              ? null
              : () async {
                  final ok = await confirmAdminAction(
                    context,
                    title: 'تأیید حساب بانکی',
                    message: 'این حساب تأیید شود؟',
                    confirmLabel: 'تأیید',
                  );
                  if (!ok) return;
                  try {
                    await ref.read(adminRemoteDataSourceProvider)?.verifyBankAccount(id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('حساب بانکی تأیید شد — لیست را رفرش کنید')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text('$e')));
                    }
                  }
                },
          trailing: verified
              ? const AdminStatusChip(label: 'تأیید', tone: AdminChipTone.success)
              : const AdminStatusChip(label: 'تأیید کن', tone: AdminChipTone.warning),
        );
      },
    );
  }
}
