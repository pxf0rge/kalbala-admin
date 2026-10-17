import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kalbala_admin/core/routing/route_names.dart';
import 'package:kalbala_admin/core/theme/app_spacing.dart';
import 'package:kalbala_admin/features/admin/data/admin_remote_datasource.dart';
import 'package:kalbala_admin/shared/widgets/admin_detail.dart';
import 'package:kalbala_admin/shared/widgets/admin_list_scaffold.dart';
import 'package:kalbala_admin/shared/widgets/admin_list_tile.dart';

class ReviewsScreen extends ConsumerWidget {
  const ReviewsScreen({super.key});

  static const _accent = Color(0xFFDC6803);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remote = ref.watch(adminRemoteDataSourceProvider);
    return AdminListScaffold(
      title: 'نظرات',
      subtitle: 'نمایش یا مخفی کردن نظرات کاربران',
      icon: Icons.rate_review_rounded,
      accent: _accent,
      searchHint: 'جستجوی نظر…',
      emptyMessage: 'نظری یافت نشد',
      fetcher: ({required search}) {
        if (remote == null) return Future.error('Supabase پیکربندی نشده است');
        return remote.listReviews(search: search);
      },
      rowBuilder: (context, item) {
        final id = adminStr(item, 'id');
        final visible = item['is_visible'] != false;
        final text = adminStr(item, 'comment', 'بدون متن');
        return AdminColorfulTile(
          title: text.length > 60 ? '${text.substring(0, 60)}…' : text,
          accent: visible ? _accent : const Color(0xFF64748B),
          icon: Icons.rate_review_rounded,
          muted: !visible,
          onTap: id.isEmpty ? null : () => context.push(RouteNames.reviewDetailPath(id)),
          subtitle: [
            'امتیاز ${item['rating'] ?? '—'}',
            visible ? 'نمایش' : 'مخفی',
          ].join(' · '),
          trailing: AdminStatusChip(
            label: visible ? 'نمایش' : 'مخفی',
            tone: visible ? AdminChipTone.success : AdminChipTone.danger,
          ),
        );
      },
    );
  }
}

class ReviewDetailScreen extends ConsumerStatefulWidget {
  const ReviewDetailScreen({super.key, required this.reviewId});
  final String reviewId;

  @override
  ConsumerState<ReviewDetailScreen> createState() => _ReviewDetailScreenState();
}

class _ReviewDetailScreenState extends ConsumerState<ReviewDetailScreen> {
  static const _accent = Color(0xFFDC6803);

  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<Map<String, dynamic>> _load() {
    final remote = ref.read(adminRemoteDataSourceProvider);
    if (remote == null) throw Exception('Supabase پیکربندی نشده است');
    return remote.getReviewDetail(widget.reviewId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _future,
      builder: (context, snapshot) {
        final data = snapshot.data;
        final review = adminMap(data?['review'] ?? data) ?? data;
        final visible = review?['is_visible'] != false;

        return AdminDetailScaffold(
          title: 'جزئیات نظر',
          accent: _accent,
          icon: Icons.rate_review_rounded,
          isLoading: snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData,
          error: snapshot.hasError ? '${snapshot.error}' : null,
          onRetry: () => setState(() => _future = _load()),
          body: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              AdminInfoSection(
                title: 'نظر کاربر',
                accent: _accent,
                icon: Icons.chat_bubble_outline_rounded,
                trailing: AdminStatusChip(
                  label: visible ? 'نمایش' : 'مخفی',
                  tone: visible ? AdminChipTone.success : AdminChipTone.danger,
                ),
                children: [
                  AdminInfoField(
                    label: 'امتیاز',
                    value: '${review?['rating'] ?? '—'}',
                    icon: Icons.star_rounded,
                    accent: _accent,
                  ),
                  AdminInfoField(
                    label: 'متن',
                    value: adminStr(review, 'comment'),
                    icon: Icons.chat_bubble_outline_rounded,
                    accent: _accent,
                    multiline: true,
                  ),
                  AdminInfoField(
                    label: 'خریدار',
                    value: adminStr(review, 'buyer_name'),
                    icon: Icons.person_outline_rounded,
                    accent: _accent,
                  ),
                  AdminInfoField(
                    label: 'آگهی',
                    value: adminStr(review, 'listing_id'),
                    icon: Icons.sell_outlined,
                    accent: _accent,
                    mono: true,
                  ),
                ],
              ),
              FilledButton.icon(
                onPressed: () async {
                  try {
                    await ref.read(adminRemoteDataSourceProvider)?.hideReview(
                          reviewId: widget.reviewId,
                          isVisible: !visible,
                        );
                    if (mounted) setState(() => _future = _load());
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
                    }
                  }
                },
                icon: Icon(visible ? Icons.visibility_off : Icons.visibility),
                label: Text(visible ? 'مخفی کردن نظر' : 'نمایش نظر'),
              ),
            ],
          ),
        );
      },
    );
  }
}
