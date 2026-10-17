import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kalbala_admin/core/routing/route_names.dart';
import 'package:kalbala_admin/features/admin/data/admin_remote_datasource.dart';
import 'package:kalbala_admin/shared/widgets/admin_detail.dart';
import 'package:kalbala_admin/shared/widgets/admin_list_scaffold.dart';
import 'package:kalbala_admin/shared/widgets/admin_list_tile.dart';

class BoothsScreen extends ConsumerWidget {
  const BoothsScreen({super.key});

  static const _accent = Color(0xFF1A8FB8);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remote = ref.watch(adminRemoteDataSourceProvider);

    return AdminListScaffold(
      title: 'غرفه‌ها',
      subtitle: 'اطلاعات غرفه، ویژه و مسدودسازی',
      icon: Icons.storefront_rounded,
      accent: _accent,
      searchHint: 'جستجوی غرفه…',
      emptyMessage: 'غرفه‌ای یافت نشد',
      fetcher: ({required search}) {
        if (remote == null) return Future.error('Supabase پیکربندی نشده است');
        return remote.listBooths(search: search);
      },
      rowBuilder: (context, item) {
        final id = adminStr(item, 'id');
        final name = adminStr(item, 'name', adminStr(item, 'title', 'بدون نام'));
        final status = adminStr(item, 'approval_status', adminStr(item, 'status'));
        final city = adminStr(item, 'city');
        final blocked = adminBool(item, 'is_blocked');
        final featured = adminBool(item, 'is_featured');

        return AdminColorfulTile(
          title: name,
          accent: blocked ? const Color(0xFFD92D20) : _accent,
          icon: Icons.storefront_rounded,
          muted: blocked,
          onTap: id.isEmpty
              ? null
              : () => context.push(RouteNames.boothDetailPath(id)),
          subtitle: [
            if (city.isNotEmpty) city,
            if (status.isNotEmpty) status,
            if (featured) 'ویژه',
            if (blocked) 'مسدود',
          ].join(' · '),
        );
      },
    );
  }
}
