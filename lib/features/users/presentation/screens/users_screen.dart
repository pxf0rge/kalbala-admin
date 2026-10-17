import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kalbala_admin/core/routing/route_names.dart';
import 'package:kalbala_admin/core/utils/phone_utils.dart';
import 'package:kalbala_admin/features/admin/data/admin_remote_datasource.dart';
import 'package:kalbala_admin/shared/widgets/admin_detail.dart';
import 'package:kalbala_admin/shared/widgets/admin_list_scaffold.dart';
import 'package:kalbala_admin/shared/widgets/admin_list_tile.dart';

class UsersScreen extends ConsumerWidget {
  const UsersScreen({super.key});

  static const _accent = Color(0xFF0A4D3C);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remote = ref.watch(adminRemoteDataSourceProvider);

    return AdminListScaffold(
      title: 'کاربران',
      subtitle: 'مدیریت حساب‌ها، نقش فروشنده و مسدودسازی',
      icon: Icons.people_alt_rounded,
      accent: _accent,
      searchHint: 'جستجوی نام یا شماره…',
      emptyMessage: 'کاربری یافت نشد',
      fetcher: ({required search}) {
        if (remote == null) return Future.error('Supabase پیکربندی نشده است');
        return remote.listUsers(search: search);
      },
      rowBuilder: (context, item) {
        final id = adminStr(item, 'id');
        final name = adminStr(item, 'full_name', 'بدون نام');
        final phone = adminStr(item, 'phone');
        final blocked = adminBool(item, 'is_blocked');
        final seller = adminBool(item, 'is_seller');

        return AdminColorfulTile(
          title: name,
          accent: blocked ? const Color(0xFFD92D20) : _accent,
          icon: blocked ? Icons.block_rounded : Icons.person_rounded,
          muted: blocked,
          onTap: id.isEmpty ? null : () => context.push(RouteNames.userDetailPath(id)),
          subtitle: [
            if (phone.isNotEmpty)
              PhoneUtils.isValidAfghanPhone(phone)
                  ? PhoneUtils.formatForDisplay(phone)
                  : phone,
            if (seller) 'فروشنده',
            if (blocked) 'مسدود',
          ].join(' · '),
          trailing: blocked
              ? const AdminStatusChip(label: 'مسدود', tone: AdminChipTone.danger)
              : (seller
                  ? const AdminStatusChip(label: 'فروشنده')
                  : null),
        );
      },
    );
  }
}
