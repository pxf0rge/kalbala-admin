import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kalbala_admin/core/theme/app_colors.dart';
import 'package:kalbala_admin/core/theme/app_spacing.dart';
import 'package:kalbala_admin/core/utils/phone_utils.dart';
import 'package:kalbala_admin/features/admin/data/admin_remote_datasource.dart';
import 'package:kalbala_admin/shared/widgets/admin_detail.dart';
import 'package:kalbala_admin/shared/widgets/admin_media.dart';

class UserDetailScreen extends ConsumerStatefulWidget {
  const UserDetailScreen({super.key, required this.userId});

  final String userId;

  @override
  ConsumerState<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends ConsumerState<UserDetailScreen> {
  static const _accent = Color(0xFF0A4D3C);

  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<Map<String, dynamic>> _load() {
    final remote = ref.read(adminRemoteDataSourceProvider);
    if (remote == null) throw Exception('Supabase پیکربندی نشده است');
    return remote.getUserDetail(widget.userId);
  }

  void _reload() => setState(() => _future = _load());

  Future<void> _run(Future<void> Function(AdminRemoteDataSource remote) action) async {
    final remote = ref.read(adminRemoteDataSourceProvider);
    if (remote == null) return;
    try {
      await action(remote);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('با موفقیت ذخیره شد')),
      );
      _reload();
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
        final profile = adminMap(data?['profile'] ?? data?['user'] ?? data) ?? data;
        final name = adminStr(profile, 'full_name', 'بدون نام');
        final phone = adminStr(profile, 'phone');
        final phoneDisplay = phone.isEmpty
            ? null
            : (PhoneUtils.isValidAfghanPhone(phone)
                ? PhoneUtils.formatForDisplay(phone)
                : phone);
        final blocked = adminBool(profile, 'is_blocked');
        final seller = adminBool(profile, 'is_seller');
        final avatarUrl = adminImageUrl(profile);
        final accent = blocked ? const Color(0xFFD92D20) : _accent;

        return AdminDetailScaffold(
          title: name,
          accent: accent,
          icon: Icons.person_rounded,
          subtitle: phoneDisplay,
          isLoading: snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData,
          error: snapshot.hasError ? snapshot.error.toString() : null,
          onRetry: _reload,
          onRefresh: () async {
            final f = _load();
            setState(() => _future = f);
            await f;
          },
          actions: [
            IconButton(
              tooltip: 'ویرایش نام',
              onPressed: profile == null
                  ? null
                  : () async {
                      final value = await promptAdminText(
                        context,
                        title: 'ویرایش نام کاربر',
                        label: 'نام کامل',
                        initial: adminStr(profile, 'full_name'),
                      );
                      if (value == null) return;
                      await _run((r) async {
                        await r.updateUserProfile(
                          userId: widget.userId,
                          fullName: value,
                          isSeller: seller,
                        );
                      });
                    },
              icon: const Icon(Icons.edit_rounded),
            ),
          ],
          body: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.xxl,
            ),
            children: [
              AdminDetailHero(
                title: name,
                subtitle: phoneDisplay,
                accent: accent,
                avatarUrl: avatarUrl,
                fallbackIcon: Icons.person_rounded,
                chips: [
                  AdminStatusChip(
                    label: blocked ? 'مسدود' : 'فعال',
                    tone: blocked ? AdminChipTone.danger : AdminChipTone.success,
                  ),
                  if (seller)
                    const AdminStatusChip(
                      label: 'فروشنده',
                      tone: AdminChipTone.warning,
                    ),
                ],
              ),
              AdminInfoSection(
                title: 'مشخصات پروفایل',
                accent: accent,
                icon: Icons.badge_outlined,
                children: [
                  AdminInfoField(
                    label: 'شناسه',
                    value: widget.userId,
                    icon: Icons.fingerprint_rounded,
                    accent: accent,
                    mono: true,
                  ),
                  AdminInfoField(
                    label: 'نام کامل',
                    value: name,
                    icon: Icons.person_outline_rounded,
                    accent: accent,
                  ),
                  AdminInfoField(
                    label: 'موبایل',
                    value: phoneDisplay ?? '—',
                    icon: Icons.phone_iphone_rounded,
                    accent: accent,
                  ),
                  AdminInfoField(
                    label: 'نقش فروشنده',
                    value: seller ? 'بله' : 'خیر',
                    icon: Icons.storefront_outlined,
                    accent: accent,
                  ),
                ],
              ),
              AdminActionGroup(
                accent: accent,
                children: [
                  FilledButton.icon(
                    onPressed: () => _run((r) async {
                      await r.updateUserProfile(
                        userId: widget.userId,
                        fullName: adminStr(profile, 'full_name').isEmpty
                            ? null
                            : adminStr(profile, 'full_name'),
                        isSeller: !seller,
                      );
                    }),
                    icon: Icon(seller ? Icons.storefront_outlined : Icons.storefront),
                    label: Text(seller ? 'لغو نقش فروشنده' : 'تبدیل به فروشنده'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final ok = await confirmAdminAction(
                        context,
                        title: blocked ? 'رفع مسدودیت' : 'مسدود کردن',
                        message: blocked
                            ? 'کاربر دوباره بتواند وارد شود؟'
                            : 'کاربر دیگر نتواند وارد اپ کلاینت شود؟',
                        confirmLabel: blocked ? 'رفع مسدودیت' : 'مسدود کن',
                        destructive: !blocked,
                      );
                      if (!ok) return;
                      await _run(
                        (r) => r.setUserBlocked(userId: widget.userId, blocked: !blocked),
                      );
                    },
                    icon: Icon(blocked ? Icons.lock_open_rounded : Icons.block),
                    label: Text(blocked ? 'رفع مسدودیت' : 'مسدود کردن'),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      final ok = await confirmAdminAction(
                        context,
                        title: 'حذف نرم کاربر',
                        message: 'حساب کاربر soft-delete می‌شود. ادامه؟',
                        confirmLabel: 'حذف',
                        destructive: true,
                      );
                      if (!ok) return;
                      await _run((r) async {
                        await r.softDeleteUser(widget.userId);
                      });
                    },
                    style: TextButton.styleFrom(foregroundColor: AppColors.error),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('حذف نرم حساب'),
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
