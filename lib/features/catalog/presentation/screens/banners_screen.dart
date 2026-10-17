import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kalbala_admin/core/theme/app_colors.dart';
import 'package:kalbala_admin/core/theme/app_spacing.dart';
import 'package:kalbala_admin/features/admin/data/admin_remote_datasource.dart';
import 'package:kalbala_admin/shared/widgets/admin_detail.dart';
import 'package:kalbala_admin/shared/widgets/admin_list_tile.dart';
import 'package:kalbala_admin/shared/widgets/admin_media.dart';
import 'package:kalbala_admin/shared/widgets/admin_states.dart';

class BannersScreen extends ConsumerStatefulWidget {
  const BannersScreen({super.key});

  @override
  ConsumerState<BannersScreen> createState() => _BannersScreenState();
}

class _BannersScreenState extends ConsumerState<BannersScreen> {
  static const _accent = Color(0xFF9333EA);

  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Map<String, dynamic>>> _load() {
    final remote = ref.read(adminRemoteDataSourceProvider);
    if (remote == null) throw Exception('Supabase پیکربندی نشده است');
    return remote.listBanners();
  }

  Future<void> _upsert([Map<String, dynamic>? existing]) async {
    final title = TextEditingController(text: adminStr(existing, 'title'));
    final imageUrl = TextEditingController(text: adminStr(existing, 'image_url'));
    final linkUrl = TextEditingController(text: adminStr(existing, 'link_url'));
    var isActive = existing == null ? true : adminBool(existing, 'is_active');

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocal) => AlertDialog(
          title: Text(existing == null ? 'بنر جدید' : 'ویرایش بنر'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: title, decoration: const InputDecoration(labelText: 'عنوان')),
                const SizedBox(height: 10),
                TextField(
                  controller: imageUrl,
                  decoration: const InputDecoration(labelText: 'آدرس تصویر'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: linkUrl,
                  decoration: const InputDecoration(labelText: 'لینک'),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('فعال'),
                  value: isActive,
                  onChanged: (v) => setLocal(() => isActive = v),
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
      try {
        await ref.read(adminRemoteDataSourceProvider)?.upsertBanner(
              id: existing == null ? null : adminStr(existing, 'id'),
              title: title.text.trim(),
              imageUrl: imageUrl.text.trim(),
              linkUrl: linkUrl.text.trim(),
              linkType: 'url',
              isActive: isActive,
            );
        if (mounted) setState(() => _future = _load());
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
        }
      }
    }
    title.dispose();
    imageUrl.dispose();
    linkUrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _accent,
        foregroundColor: Colors.white,
        onPressed: () => _upsert(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('بنر جدید'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: _accent));
          }
          if (snapshot.hasError) {
            return AdminErrorState(
              message: '${snapshot.error}',
              onRetry: () => setState(() => _future = _load()),
            );
          }
          final items = snapshot.data ?? const [];
          if (items.isEmpty) {
            return Column(
              children: [
                const AdminPageBanner(
                  title: 'بنرها',
                  subtitle: 'بنرهای صفحه اصلی',
                  icon: Icons.view_carousel_rounded,
                  accent: _accent,
                ),
                const Expanded(
                  child: AdminEmptyState(
                    message: 'بنری وجود ندارد',
                    icon: Icons.view_carousel_outlined,
                    accent: _accent,
                  ),
                ),
              ],
            );
          }

          return RefreshIndicator(
            color: _accent,
            onRefresh: () async {
              final f = _load();
              setState(() => _future = f);
              await f;
            },
            child: ListView.separated(
              padding: const EdgeInsets.only(bottom: AppSpacing.xxl + 56),
              itemCount: items.length + 1,
              separatorBuilder: (_, index) =>
                  index == 0 ? const SizedBox(height: AppSpacing.sm) : const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return const AdminPageBanner(
                    title: 'بنرها',
                    subtitle: 'بنرهای صفحه اصلی',
                    icon: Icons.view_carousel_rounded,
                    accent: _accent,
                  );
                }
                final item = items[index - 1];
                final active = adminBool(item, 'is_active');
                final imageUrl = adminStr(item, 'image_url');
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _upsert(item),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      child: Ink(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceRaised,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                          border: Border.all(
                            color: (active ? _accent : const Color(0xFF64748B))
                                .withValues(alpha: 0.14),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _accent.withValues(alpha: 0.06),
                              blurRadius: 14,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AspectRatio(
                              aspectRatio: 16 / 7,
                              child: AdminNetworkImage(
                                url: imageUrl.isEmpty ? null : imageUrl,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(AppSpacing.radiusMd),
                                ),
                                fallbackIcon: Icons.view_carousel_outlined,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          adminStr(item, 'title', 'بدون عنوان'),
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall
                                              ?.copyWith(fontWeight: FontWeight.w700),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          active ? 'فعال' : 'غیرفعال',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(color: AppColors.inkMuted),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: AppColors.error),
                                    onPressed: () async {
                                      final ok = await confirmAdminAction(
                                        context,
                                        title: 'حذف بنر',
                                        message: 'این بنر حذف شود؟',
                                        confirmLabel: 'حذف',
                                        destructive: true,
                                      );
                                      if (!ok) return;
                                      try {
                                        await ref
                                            .read(adminRemoteDataSourceProvider)
                                            ?.deleteBanner(adminStr(item, 'id'));
                                        if (mounted) setState(() => _future = _load());
                                      } catch (e) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(content: Text('$e')));
                                        }
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
