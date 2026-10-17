import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kalbala_admin/core/constants/app_constants.dart';
import 'package:kalbala_admin/core/routing/route_names.dart';
import 'package:kalbala_admin/features/admin/data/admin_remote_datasource.dart';
import 'package:kalbala_admin/shared/widgets/admin_detail.dart';
import 'package:kalbala_admin/shared/widgets/admin_list_scaffold.dart';
import 'package:kalbala_admin/shared/widgets/admin_list_tile.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  static const _accent = Color(0xFFB42318);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remote = ref.watch(adminRemoteDataSourceProvider);

    return AdminListScaffold(
      title: 'سفارش‌ها',
      subtitle: 'جزئیات و پیگیری سفارش‌ها',
      icon: Icons.receipt_long_rounded,
      accent: _accent,
      searchHint: 'جستجوی سفارش…',
      emptyMessage: 'سفارشی یافت نشد',
      fetcher: ({required search}) {
        if (remote == null) return Future.error('Supabase پیکربندی نشده است');
        return remote.listOrders(search: search);
      },
      rowBuilder: (context, item) {
        final id = adminStr(item, 'id');
        final code = adminStr(item, 'order_number', id);
        final status = adminStr(item, 'status');
        final total = item['total'] ?? item['grand_total'] ?? item['amount'];
        final createdAt = adminStr(item, 'created_at');

        return AdminColorfulTile(
          title: code,
          accent: _accent,
          icon: Icons.receipt_long_rounded,
          onTap: id.isEmpty
              ? null
              : () => context.push(RouteNames.orderDetailPath(id)),
          subtitle: [
            if (status.isNotEmpty) status,
            if (total != null) '$total ${AppConstants.currencySymbol}',
            if (createdAt.length >= 10) createdAt.substring(0, 10),
          ].join(' · '),
        );
      },
    );
  }
}
