import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kalbala_admin/core/theme/app_spacing.dart';
import 'package:kalbala_admin/features/admin/data/admin_remote_datasource.dart';
import 'package:kalbala_admin/shared/widgets/admin_detail.dart';
import 'package:kalbala_admin/shared/widgets/admin_list_tile.dart';
import 'package:kalbala_admin/shared/widgets/admin_states.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  static const _accent = Color(0xFF7C3AED);

  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Map<String, dynamic>>> _load() {
    final remote = ref.read(adminRemoteDataSourceProvider);
    if (remote == null) throw Exception('Supabase پیکربندی نشده است');
    return remote.listCategories();
  }

  Future<void> _upsert([Map<String, dynamic>? existing]) async {
    final name = TextEditingController(text: adminStr(existing, 'name'));
    final slug = TextEditingController(text: adminStr(existing, 'slug'));
    var isActive = existing == null ? true : adminBool(existing, 'is_active');
    final sort = TextEditingController(
      text: '${existing?['sort_order'] ?? 0}',
    );

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocal) => AlertDialog(
          title: Text(existing == null ? 'دسته جدید' : 'ویرایش دسته'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: name, decoration: const InputDecoration(labelText: 'نام')),
              const SizedBox(height: 10),
              TextField(controller: slug, decoration: const InputDecoration(labelText: 'اسلاگ')),
              const SizedBox(height: 10),
              TextField(
                controller: sort,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'ترتیب'),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('فعال'),
                value: isActive,
                onChanged: (v) => setLocal(() => isActive = v),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('انصراف')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('ذخیره')),
          ],
        ),
      ),
    );

    if (saved == true) {
      final remote = ref.read(adminRemoteDataSourceProvider);
      try {
        await remote?.upsertCategory(
          id: existing == null ? null : adminStr(existing, 'id'),
          name: name.text.trim(),
          slug: slug.text.trim().isEmpty ? null : slug.text.trim(),
          sortOrder: int.tryParse(sort.text.trim()),
          isActive: isActive,
        );
        if (mounted) setState(() => _future = _load());
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
        }
      }
    }
    name.dispose();
    slug.dispose();
    sort.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _accent,
        foregroundColor: Colors.white,
        onPressed: () => _upsert(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('دسته جدید'),
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
                  title: 'دسته‌ها',
                  subtitle: 'مدیریت دسته‌بندی محصولات',
                  icon: Icons.category_rounded,
                  accent: _accent,
                ),
                const Expanded(
                  child: AdminEmptyState(
                    message: 'دسته‌ای ثبت نشده',
                    icon: Icons.category_outlined,
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
                    title: 'دسته‌ها',
                    subtitle: 'مدیریت دسته‌بندی محصولات',
                    icon: Icons.category_rounded,
                    accent: _accent,
                  );
                }
                final item = items[index - 1];
                final active = adminBool(item, 'is_active');
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: AdminColorfulTile(
                    title: adminStr(item, 'name', 'بدون نام'),
                    accent: active ? _accent : const Color(0xFF64748B),
                    icon: Icons.category_rounded,
                    muted: !active,
                    onTap: () => _upsert(item),
                    subtitle: [
                      adminStr(item, 'slug'),
                      'ترتیب ${item['sort_order'] ?? 0}',
                      active ? 'فعال' : 'غیرفعال',
                    ].where((e) => e.isNotEmpty).join(' · '),
                    trailing: Icon(Icons.edit_outlined, color: _accent.withValues(alpha: 0.8)),
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
