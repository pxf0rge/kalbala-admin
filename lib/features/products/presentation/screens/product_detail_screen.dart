import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kalbala_admin/core/theme/app_colors.dart';
import 'package:kalbala_admin/core/theme/app_spacing.dart';
import 'package:kalbala_admin/features/admin/data/admin_remote_datasource.dart';
import 'package:kalbala_admin/shared/widgets/admin_detail.dart';
import 'package:kalbala_admin/shared/widgets/admin_media.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final String productId;

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  static const _accent = Color(0xFF127A62);

  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<Map<String, dynamic>> _load() {
    final remote = ref.read(adminRemoteDataSourceProvider);
    if (remote == null) throw Exception('Supabase پیکربندی نشده است');
    return remote.getProductDetail(widget.productId);
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

  Future<void> _editFields(Map<String, dynamic> product) async {
    final nameCtrl = TextEditingController(text: adminStr(product, 'name'));
    final descCtrl = TextEditingController(text: adminStr(product, 'description'));
    final brandCtrl = TextEditingController(text: adminStr(product, 'brand'));

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ویرایش محصول'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'نام')),
              const SizedBox(height: 12),
              TextField(
                controller: brandCtrl,
                decoration: const InputDecoration(labelText: 'برند'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'توضیحات'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('انصراف')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('ذخیره')),
        ],
      ),
    );

    if (saved != true) {
      nameCtrl.dispose();
      descCtrl.dispose();
      brandCtrl.dispose();
      return;
    }

    await _run((r) async {
      await r.updateProduct(
        productId: widget.productId,
        name: nameCtrl.text.trim(),
        description: descCtrl.text.trim(),
        brand: brandCtrl.text.trim(),
        categoryId: adminStr(product, 'category_id').isEmpty
            ? null
            : adminStr(product, 'category_id'),
      );
    });
    nameCtrl.dispose();
    descCtrl.dispose();
    brandCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _future,
      builder: (context, snapshot) {
        final data = snapshot.data;
        final product = adminMap(data?['product'] ?? data) ?? data;
        final name = adminStr(product, 'name', 'محصول');
        final blocked = adminBool(product, 'is_blocked');
        final status = adminStr(product, 'approval_status', '—');
        final images = adminImageUrls(product);
        final primaryImage = images.isEmpty ? adminImageUrl(product) : images.first;

        return AdminDetailScaffold(
          title: name,
          accent: _accent,
          icon: Icons.inventory_2_rounded,
          subtitle: status,
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
              onPressed: product == null ? null : () => _editFields(product),
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
                subtitle: adminStr(product, 'brand').isEmpty
                    ? status
                    : '${adminStr(product, 'brand')} · $status',
                accent: _accent,
                coverUrl: primaryImage,
                avatarUrl: primaryImage,
                fallbackIcon: Icons.inventory_2_rounded,
                chips: [
                  AdminStatusChip(
                    label: blocked ? 'مسدود' : status,
                    tone: blocked
                        ? AdminChipTone.danger
                        : status == 'approved'
                            ? AdminChipTone.success
                            : AdminChipTone.warning,
                  ),
                ],
              ),
              AdminImageGallery(
                urls: images,
                accent: _accent,
                title: 'تصاویر محصول',
              ),
              AdminInfoSection(
                title: 'مشخصات محصول',
                accent: _accent,
                icon: Icons.info_outline_rounded,
                children: [
                  AdminInfoField(
                    label: 'شناسه',
                    value: widget.productId,
                    icon: Icons.fingerprint_rounded,
                    accent: _accent,
                    mono: true,
                  ),
                  AdminInfoField(
                    label: 'نام',
                    value: name,
                    icon: Icons.label_outline_rounded,
                    accent: _accent,
                  ),
                  AdminInfoField(
                    label: 'برند',
                    value: adminStr(product, 'brand'),
                    icon: Icons.verified_outlined,
                    accent: _accent,
                  ),
                  AdminInfoField(
                    label: 'دسته',
                    value: adminStr(product, 'category_id'),
                    icon: Icons.category_outlined,
                    accent: _accent,
                    mono: true,
                  ),
                  AdminInfoField(
                    label: 'توضیحات',
                    value: adminStr(product, 'description'),
                    icon: Icons.notes_rounded,
                    accent: _accent,
                    multiline: true,
                  ),
                ],
              ),
              AdminActionGroup(
                accent: _accent,
                children: [
                  FilledButton.icon(
                    onPressed: () => _run((r) => r.setProductBlocked(
                          productId: widget.productId,
                          blocked: !blocked,
                        )),
                    icon: Icon(blocked ? Icons.lock_open : Icons.block),
                    label: Text(blocked ? 'رفع مسدودیت محصول' : 'مسدود کردن محصول'),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _run((r) => r.reviewProduct(
                                productId: widget.productId,
                                status: 'approved',
                              )),
                          icon: const Icon(Icons.check_circle_outline),
                          label: const Text('تأیید'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
                          onPressed: () async {
                            final reason = await promptAdminText(
                              context,
                              title: 'دلیل رد محصول',
                              label: 'علت',
                              maxLines: 3,
                              confirmLabel: 'رد کردن',
                            );
                            if (reason == null || reason.isEmpty) return;
                            await _run((r) => r.reviewProduct(
                                  productId: widget.productId,
                                  status: 'rejected',
                                  rejectionReason: reason,
                                ));
                          },
                          icon: const Icon(Icons.cancel_outlined),
                          label: const Text('رد'),
                        ),
                      ),
                    ],
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
