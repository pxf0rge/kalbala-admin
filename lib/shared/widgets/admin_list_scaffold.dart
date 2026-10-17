import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kalbala_admin/core/theme/app_colors.dart';
import 'package:kalbala_admin/core/theme/app_spacing.dart';
import 'package:kalbala_admin/features/admin/data/admin_remote_datasource.dart';
import 'package:kalbala_admin/shared/widgets/admin_list_tile.dart';
import 'package:kalbala_admin/shared/widgets/admin_states.dart';

typedef AdminRowBuilder = Widget Function(
  BuildContext context,
  Map<String, dynamic> item,
);

class AdminListScaffold extends ConsumerStatefulWidget {
  const AdminListScaffold({
    super.key,
    required this.title,
    required this.fetcher,
    required this.rowBuilder,
    this.searchHint = 'جستجو…',
    this.emptyMessage = 'موردی یافت نشد',
    this.subtitle,
    this.icon = Icons.list_alt_rounded,
    this.accent = AppColors.primary,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final Color accent;
  final Future<AdminListPage> Function({required String? search}) fetcher;
  final AdminRowBuilder rowBuilder;
  final String searchHint;
  final String emptyMessage;

  @override
  ConsumerState<AdminListScaffold> createState() => _AdminListScaffoldState();
}

class _AdminListScaffoldState extends ConsumerState<AdminListScaffold> {
  final _searchController = TextEditingController();
  Future<AdminListPage>? _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _reload() {
    final query = _searchController.text.trim();
    setState(() {
      _future = widget.fetcher(search: query.isEmpty ? null : query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AdminPageBanner(
          title: widget.title,
          subtitle: widget.subtitle,
          icon: widget.icon,
          accent: widget.accent,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: widget.searchHint,
              prefixIcon: Icon(Icons.search_rounded, color: widget.accent),
              suffixIcon: IconButton(
                tooltip: 'به‌روزرسانی',
                onPressed: _reload,
                icon: Icon(Icons.refresh_rounded, color: widget.accent),
              ),
              filled: true,
              fillColor: AppColors.surfaceRaised,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                borderSide: BorderSide(
                  color: widget.accent.withValues(alpha: 0.18),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                borderSide: BorderSide(color: widget.accent, width: 1.5),
              ),
            ),
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _reload(),
          ),
        ),
        Expanded(
          child: FutureBuilder<AdminListPage>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(color: widget.accent),
                );
              }
              if (snapshot.hasError) {
                return AdminErrorState(
                  message: snapshot.error.toString(),
                  onRetry: _reload,
                );
              }

              final page = snapshot.data;
              if (page == null || page.items.isEmpty) {
                return AdminEmptyState(
                  message: widget.emptyMessage,
                  accent: widget.accent,
                  icon: widget.icon,
                );
              }

              return RefreshIndicator(
                color: widget.accent,
                onRefresh: () async {
                  _reload();
                  await _future;
                },
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.sm,
                    AppSpacing.lg,
                    AppSpacing.xxl,
                  ),
                  itemCount: page.items.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    return widget.rowBuilder(context, page.items[index]);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
