import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kalbala_admin/core/routing/route_names.dart';
import 'package:kalbala_admin/features/admin/data/admin_remote_datasource.dart';
import 'package:kalbala_admin/shared/widgets/admin_detail.dart';
import 'package:kalbala_admin/shared/widgets/admin_list_scaffold.dart';
import 'package:kalbala_admin/shared/widgets/admin_list_tile.dart';

class ProductsScreen extends ConsumerWidget {
  const ProductsScreen({super.key});

  static const _accent = Color(0xFF127A62);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remote = ref.watch(adminRemoteDataSourceProvider);

    return AdminListScaffold(
      title: 'محصولات',
      subtitle: 'ویرایش مشخصات و تأیید یا رد',
      icon: Icons.inventory_2_rounded,
      accent: _accent,
      searchHint: 'جستجوی محصول…',
      emptyMessage: 'محصولی یافت نشد',
      fetcher: ({required search}) {
        if (remote == null) return Future.error('Supabase پیکربندی نشده است');
        return remote.listProducts(search: search);
      },
      rowBuilder: (context, item) {
        final id = adminStr(item, 'id');
        final name = adminStr(item, 'name', 'بدون نام');
        final status = adminStr(item, 'approval_status');
        final blocked = adminBool(item, 'is_blocked');
        final brand = adminStr(item, 'brand');

        return AdminColorfulTile(
          title: name,
          accent: blocked ? const Color(0xFFD92D20) : _accent,
          icon: Icons.inventory_2_rounded,
          muted: blocked,
          onTap: id.isEmpty
              ? null
              : () => context.push(RouteNames.productDetailPath(id)),
          subtitle: [
            if (brand.isNotEmpty) brand,
            if (status.isNotEmpty) status,
            if (blocked) 'مسدود',
          ].join(' · '),
        );
      },
    );
  }
}
