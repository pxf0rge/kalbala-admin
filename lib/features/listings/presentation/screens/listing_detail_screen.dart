import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kalbala_admin/core/constants/app_constants.dart';
import 'package:kalbala_admin/core/theme/app_spacing.dart';
import 'package:kalbala_admin/features/admin/data/admin_remote_datasource.dart';
import 'package:kalbala_admin/shared/widgets/admin_detail.dart';
import 'package:kalbala_admin/shared/widgets/admin_media.dart';

class ListingDetailScreen extends ConsumerStatefulWidget {
  const ListingDetailScreen({super.key, required this.listingId});

  final String listingId;

  @override
  ConsumerState<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends ConsumerState<ListingDetailScreen> {
  static const _accent = Color(0xFFE2A116);

  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<Map<String, dynamic>> _load() {
    final remote = ref.read(adminRemoteDataSourceProvider);
    if (remote == null) throw Exception('Supabase پیکربندی نشده است');
    return remote.getListingDetail(widget.listingId);
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _future,
      builder: (context, snapshot) {
        final data = snapshot.data;
        final listing = adminMap(data?['listing'] ?? data) ?? data;
        final product = adminMap(listing?['product'] ?? listing?['products'] ?? data?['product']);
        final title = adminStr(
          listing,
          'title',
          adminStr(listing, 'name', adminStr(product, 'name', 'آگهی')),
        );
        final status = adminStr(listing, 'status', '—');
        final featured = adminBool(listing, 'is_featured');
        final price = listing?['price'] ?? listing?['base_price'];
        final images = {
          ...adminImageUrls(listing),
          ...adminImageUrls(product),
        }.toList();
        final primary = images.isEmpty ? null : images.first;

        return AdminDetailScaffold(
          title: title,
          accent: _accent,
          icon: Icons.sell_rounded,
          subtitle: status,
          isLoading: snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData,
          error: snapshot.hasError ? snapshot.error.toString() : null,
          onRetry: _reload,
          onRefresh: () async {
            final f = _load();
            setState(() => _future = f);
            await f;
          },
          body: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.xxl,
            ),
            children: [
              AdminDetailHero(
                title: title,
                subtitle: price == null
                    ? status
                    : '$price ${AppConstants.currencySymbol} · $status',
                accent: _accent,
                coverUrl: primary,
                avatarUrl: primary,
                fallbackIcon: Icons.sell_rounded,
                chips: [
                  AdminStatusChip(
                    label: featured ? 'ویژه' : status,
                    tone: featured ? AdminChipTone.warning : AdminChipTone.neutral,
                  ),
                ],
              ),
              AdminImageGallery(
                urls: images,
                accent: _accent,
                title: 'تصاویر آگهی',
              ),
              AdminInfoSection(
                title: 'جزئیات آگهی',
                accent: _accent,
                icon: Icons.description_outlined,
                children: [
                  AdminInfoField(
                    label: 'شناسه',
                    value: widget.listingId,
                    icon: Icons.fingerprint_rounded,
                    accent: _accent,
                    mono: true,
                  ),
                  AdminInfoField(
                    label: 'وضعیت',
                    value: status,
                    icon: Icons.flag_outlined,
                    accent: _accent,
                  ),
                  AdminInfoField(
                    label: 'قیمت',
                    value: price == null ? '—' : '$price ${AppConstants.currencySymbol}',
                    icon: Icons.payments_outlined,
                    accent: _accent,
                  ),
                  AdminInfoField(
                    label: 'موجودی',
                    value: '${listing?['stock'] ?? '—'}',
                    icon: Icons.inventory_outlined,
                    accent: _accent,
                  ),
                  AdminInfoField(
                    label: 'غرفه',
                    value: adminStr(listing, 'booth_id'),
                    icon: Icons.storefront_outlined,
                    accent: _accent,
                    mono: true,
                  ),
                  AdminInfoField(
                    label: 'محصول',
                    value: adminStr(listing, 'product_id', adminStr(product, 'id')),
                    icon: Icons.inventory_2_outlined,
                    accent: _accent,
                    mono: true,
                  ),
                ],
              ),
              AdminActionGroup(
                accent: _accent,
                children: [
                  Text(
                    'تغییر وضعیت',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: _accent,
                        ),
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final s in ['active', 'inactive', 'out_of_stock'])
                        OutlinedButton(
                          onPressed: () => _run(
                            (r) => r.setListingStatus(listingId: widget.listingId, status: s),
                          ),
                          child: Text(s),
                        ),
                    ],
                  ),
                  FilledButton.icon(
                    onPressed: () => _run(
                      (r) => r.setListingFeatured(
                        listingId: widget.listingId,
                        featured: !featured,
                      ),
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
