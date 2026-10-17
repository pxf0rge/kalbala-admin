import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kalbala_admin/core/constants/app_constants.dart';
import 'package:kalbala_admin/core/theme/app_colors.dart';
import 'package:kalbala_admin/core/theme/app_spacing.dart';
import 'package:kalbala_admin/features/admin/data/admin_remote_datasource.dart';
import 'package:kalbala_admin/shared/widgets/admin_detail.dart';
import 'package:kalbala_admin/shared/widgets/admin_media.dart';

class OrderDetailScreen extends ConsumerStatefulWidget {
  const OrderDetailScreen({super.key, required this.orderId});

  final String orderId;

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  static const _accent = Color(0xFFB42318);

  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<Map<String, dynamic>> _load() {
    final remote = ref.read(adminRemoteDataSourceProvider);
    if (remote == null) throw Exception('Supabase پیکربندی نشده است');
    return remote.getOrderDetail(widget.orderId);
  }

  void _reload() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _future,
      builder: (context, snapshot) {
        final data = snapshot.data;
        final order = adminMap(data?['order'] ?? data) ?? data;
        final code = adminStr(order, 'order_number', widget.orderId);
        final status = adminStr(order, 'status', '—');
        final total = order?['total'] ?? order?['grand_total'] ?? order?['amount'];
        final items = adminMapList(data?['items'] ?? order?['items']);

        return AdminDetailScaffold(
          title: code,
          accent: _accent,
          icon: Icons.receipt_long_rounded,
          subtitle: status,
          isLoading: snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData,
          error: snapshot.hasError ? snapshot.error.toString() : null,
          onRetry: _reload,
          onRefresh: () async {
            final f = _load();
            setState(() => _future = f);
            await f;
          },
          body: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.xxl,
            ),
            children: [
              AdminDetailHero(
                title: code,
                subtitle: total == null
                    ? status
                    : '$total ${AppConstants.currencySymbol} · $status',
                accent: _accent,
                fallbackIcon: Icons.receipt_long_rounded,
                chips: [
                  AdminStatusChip(label: status),
                ],
              ),
              AdminInfoSection(
                title: 'خلاصه سفارش',
                accent: _accent,
                icon: Icons.summarize_outlined,
                children: [
                  AdminInfoField(
                    label: 'شناسه',
                    value: widget.orderId,
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
                    value: total == null ? '—' : '$total ${AppConstants.currencySymbol}',
                    icon: Icons.payments_outlined,
                    accent: _accent,
                  ),
                  AdminInfoField(
                    label: 'پرداخت',
                    value: adminStr(order, 'payment_method'),
                    icon: Icons.credit_card_outlined,
                    accent: _accent,
                  ),
                  AdminInfoField(
                    label: 'خریدار',
                    value: adminStr(order, 'buyer_id'),
                    icon: Icons.person_outline_rounded,
                    accent: _accent,
                    mono: true,
                  ),
                  AdminInfoField(
                    label: 'توضیح',
                    value: adminStr(order, 'buyer_note'),
                    icon: Icons.notes_rounded,
                    accent: _accent,
                    multiline: true,
                  ),
                  AdminInfoField(
                    label: 'تاریخ',
                    value: adminStr(order, 'created_at'),
                    icon: Icons.calendar_today_outlined,
                    accent: _accent,
                  ),
                ],
              ),
              if (items.isNotEmpty)
                AdminInfoSection(
                  title: 'اقلام (${items.length})',
                  accent: _accent,
                  icon: Icons.shopping_bag_outlined,
                  children: [
                    for (final item in items)
                      _OrderItemTile(item: item, accent: _accent),
                  ],
                ),
              AdminActionGroup(
                accent: _accent,
                children: [
                  FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: AppColors.error),
                    onPressed: () async {
                      final reason = await promptAdminText(
                        context,
                        title: 'لغو سفارش',
                        label: 'دلیل لغو',
                        maxLines: 3,
                        confirmLabel: 'لغو سفارش',
                      );
                      if (reason == null || reason.isEmpty) return;
                      final remote = ref.read(adminRemoteDataSourceProvider);
                      if (remote == null) return;
                      try {
                        await remote.cancelOrder(orderId: widget.orderId, reason: reason);
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('سفارش لغو شد')),
                        );
                        _reload();
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text('$e')));
                      }
                    },
                    icon: const Icon(Icons.cancel_outlined),
                    label: const Text('لغو سفارش'),
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

class _OrderItemTile extends StatelessWidget {
  const _OrderItemTile({required this.item, required this.accent});

  final Map<String, dynamic> item;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final title = adminStr(item, 'title', adminStr(item, 'name', 'آیتم'));
    final qty = item['quantity'] ?? 1;
    final price = item['price'] ?? item['unit_price'];
    final image = adminImageUrl(item) ??
        (adminImageUrls(item).isEmpty ? null : adminImageUrls(item).first);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: accent.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          AdminNetworkImage(
            url: image,
            width: 56,
            height: 56,
            fallbackIcon: Icons.shopping_bag_outlined,
            borderRadius: BorderRadius.circular(12),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  '× $qty  ·  ${price ?? '—'} ${AppConstants.currencySymbol}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.inkMuted,
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
