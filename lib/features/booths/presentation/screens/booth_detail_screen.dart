import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kalbala_admin/core/theme/app_spacing.dart';
import 'package:kalbala_admin/features/admin/data/admin_remote_datasource.dart';
import 'package:kalbala_admin/shared/widgets/admin_detail.dart';
import 'package:kalbala_admin/shared/widgets/admin_media.dart';

class BoothDetailScreen extends ConsumerStatefulWidget {
  const BoothDetailScreen({super.key, required this.boothId});

  final String boothId;

  @override
  ConsumerState<BoothDetailScreen> createState() => _BoothDetailScreenState();
}

class _BoothDetailScreenState extends ConsumerState<BoothDetailScreen> {
  static const _accent = Color(0xFF1A8FB8);

  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<Map<String, dynamic>> _load() {
    final remote = ref.read(adminRemoteDataSourceProvider);
    if (remote == null) throw Exception('Supabase پیکربندی نشده است');
    return remote.getBoothDetail(widget.boothId);
  }

  void _reload() => setState(() => _future = _load());

  Future<void> _run(Future<void> Function(AdminRemoteDataSource r) action) async {
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

  Future<void> _edit(Map<String, dynamic> booth) async {
    final name = TextEditingController(text: adminStr(booth, 'name'));
    final desc = TextEditingController(text: adminStr(booth, 'description'));
    final city = TextEditingController(text: adminStr(booth, 'city'));
    final phone = TextEditingController(text: adminStr(booth, 'phone'));
    final address = TextEditingController(text: adminStr(booth, 'address'));
    var isActive = adminBool(booth, 'is_active');
    var isFeatured = adminBool(booth, 'is_featured');

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocal) => AlertDialog(
          title: const Text('ویرایش غرفه'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: name, decoration: const InputDecoration(labelText: 'نام')),
                const SizedBox(height: 10),
                TextField(controller: city, decoration: const InputDecoration(labelText: 'شهر')),
                const SizedBox(height: 10),
                TextField(controller: phone, decoration: const InputDecoration(labelText: 'تلفن')),
                const SizedBox(height: 10),
                TextField(controller: address, decoration: const InputDecoration(labelText: 'آدرس')),
                const SizedBox(height: 10),
                TextField(
                  controller: desc,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'توضیحات'),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('فعال'),
                  value: isActive,
                  onChanged: (v) => setLocal(() => isActive = v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('ویژه'),
                  value: isFeatured,
                  onChanged: (v) => setLocal(() => isFeatured = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('انصراف')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('ذخیره')),
          ],
        ),
      ),
    );

    if (saved == true) {
      await _run((r) => r.updateBooth(
            boothId: widget.boothId,
            name: name.text.trim(),
            description: desc.text.trim(),
            city: city.text.trim(),
            phone: phone.text.trim(),
            address: address.text.trim(),
            isActive: isActive,
            isFeatured: isFeatured,
          ));
    }

    name.dispose();
    desc.dispose();
    city.dispose();
    phone.dispose();
    address.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _future,
      builder: (context, snapshot) {
        final data = snapshot.data;
        final booth = adminMap(data?['booth'] ?? data) ?? data;
        final name = adminStr(booth, 'name', 'غرفه');
        final blocked = adminBool(booth, 'is_blocked');
        final featured = adminBool(booth, 'is_featured');
        final city = adminStr(booth, 'city');
        final logoUrl = adminImageUrl(booth, keys: const ['logo_url', 'photo_url', 'image_url']);
        final coverUrl = adminImageUrl(booth, keys: const ['cover_url', 'banner_url']);

        return AdminDetailScaffold(
          title: name,
          accent: _accent,
          icon: Icons.storefront_rounded,
          subtitle: city.isEmpty ? null : city,
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
              onPressed: booth == null ? null : () => _edit(booth),
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
                subtitle: city.isEmpty ? null : city,
                accent: _accent,
                coverUrl: coverUrl,
                avatarUrl: logoUrl,
                fallbackIcon: Icons.storefront_rounded,
                chips: [
                  AdminStatusChip(
                    label: blocked ? 'مسدود' : (featured ? 'ویژه' : 'عادی'),
                    tone: blocked
                        ? AdminChipTone.danger
                        : featured
                            ? AdminChipTone.warning
                            : AdminChipTone.success,
                  ),
                  AdminStatusChip(
                    label: adminBool(booth, 'is_active') ? 'فعال' : 'غیرفعال',
                    tone: adminBool(booth, 'is_active')
                        ? AdminChipTone.success
                        : AdminChipTone.neutral,
                  ),
                ],
              ),
              if (coverUrl != null || logoUrl != null)
                AdminInfoSection(
                  title: 'تصاویر غرفه',
                  accent: _accent,
                  icon: Icons.photo_library_outlined,
                  children: [
                    if (coverUrl != null) ...[
                      Text(
                        'کاور',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: _accent,
                            ),
                      ),
                      const SizedBox(height: 8),
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: AdminNetworkImage(
                          url: coverUrl,
                          fallbackIcon: Icons.image_outlined,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    if (logoUrl != null)
                      Row(
                        children: [
                          AdminAvatar(
                            url: logoUrl,
                            size: 64,
                            accent: _accent,
                            fallbackIcon: Icons.storefront_rounded,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          const Expanded(
                            child: Text('لوگوی غرفه'),
                          ),
                        ],
                      ),
                  ],
                ),
              AdminInfoSection(
                title: 'اطلاعات غرفه',
                accent: _accent,
                icon: Icons.store_mall_directory_outlined,
                children: [
                  AdminInfoField(
                    label: 'شناسه',
                    value: widget.boothId,
                    icon: Icons.fingerprint_rounded,
                    accent: _accent,
                    mono: true,
                  ),
                  AdminInfoField(
                    label: 'نام',
                    value: name,
                    icon: Icons.storefront_outlined,
                    accent: _accent,
                  ),
                  AdminInfoField(
                    label: 'توضیحات',
                    value: adminStr(booth, 'description'),
                    icon: Icons.notes_rounded,
                    accent: _accent,
                    multiline: true,
                  ),
                  AdminInfoField(
                    label: 'شهر',
                    value: city,
                    icon: Icons.location_city_rounded,
                    accent: _accent,
                  ),
                  AdminInfoField(
                    label: 'تلفن',
                    value: adminStr(booth, 'phone'),
                    icon: Icons.phone_rounded,
                    accent: _accent,
                  ),
                  AdminInfoField(
                    label: 'آدرس',
                    value: adminStr(booth, 'address'),
                    icon: Icons.place_outlined,
                    accent: _accent,
                    multiline: true,
                  ),
                ],
              ),
              AdminActionGroup(
                accent: _accent,
                children: [
                  FilledButton.icon(
                    onPressed: () => _run(
                      (r) => r.setBoothBlocked(boothId: widget.boothId, blocked: !blocked),
                    ),
                    icon: Icon(blocked ? Icons.lock_open : Icons.block),
                    label: Text(blocked ? 'رفع مسدودیت' : 'مسدود کردن غرفه'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _run(
                      (r) => r.setBoothFeatured(boothId: widget.boothId, featured: !featured),
                    ),
                    icon: Icon(featured ? Icons.star : Icons.star_border),
                    label: Text(featured ? 'حذف از ویژه' : 'افزودن به ویژه'),
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
