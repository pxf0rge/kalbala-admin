import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kalbala_admin/core/constants/app_constants.dart';
import 'package:kalbala_admin/core/routing/route_names.dart';
import 'package:kalbala_admin/features/admin/data/admin_remote_datasource.dart';
import 'package:kalbala_admin/shared/widgets/admin_detail.dart';
import 'package:kalbala_admin/shared/widgets/admin_list_scaffold.dart';
import 'package:kalbala_admin/shared/widgets/admin_list_tile.dart';

class ListingsScreen extends ConsumerWidget {
  const ListingsScreen({super.key});

  static const _accent = Color(0xFFE2A116);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remote = ref.watch(adminRemoteDataSourceProvider);

    return AdminListScaffold(
      title: 'آگهی‌ها',
      subtitle: 'وضعیت، قیمت و ویژه کردن',
      icon: Icons.sell_rounded,
      accent: _accent,
      searchHint: 'جستجوی آگهی…',
      emptyMessage: 'آگهی‌ای یافت نشد',
      fetcher: ({required search}) {
        if (remote == null) return Future.error('Supabase پیکربندی نشده است');
        return remote.listListings(search: search);
      },
      rowBuilder: (context, item) {
        final id = adminStr(item, 'id');
        final title = adminStr(item, 'title', adminStr(item, 'name', 'بدون عنوان'));
        final status = adminStr(item, 'status');
        final price = item['price'] ?? item['base_price'];
        final featured = adminBool(item, 'is_featured');

        return AdminColorfulTile(
          title: title,
          accent: _accent,
          icon: featured ? Icons.star_rounded : Icons.sell_rounded,
          onTap: id.isEmpty
              ? null
              : () => context.push(RouteNames.listingDetailPath(id)),
          subtitle: [
            if (status.isNotEmpty) status,
            if (price != null) '$price ${AppConstants.currencySymbol}',
            if (featured) 'ویژه',
          ].join(' · '),
          trailing: featured
              ? const AdminStatusChip(
                  label: 'ویژه',
                  tone: AdminChipTone.warning,
                )
              : null,
        );
      },
    );
  }
}
