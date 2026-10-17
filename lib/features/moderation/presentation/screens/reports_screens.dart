import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kalbala_admin/core/routing/route_names.dart';
import 'package:kalbala_admin/core/theme/app_spacing.dart';
import 'package:kalbala_admin/features/admin/data/admin_remote_datasource.dart';
import 'package:kalbala_admin/shared/widgets/admin_detail.dart';
import 'package:kalbala_admin/shared/widgets/admin_list_scaffold.dart';
import 'package:kalbala_admin/shared/widgets/admin_list_tile.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  static const _accent = Color(0xFFD92D20);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remote = ref.watch(adminRemoteDataSourceProvider);
    return AdminListScaffold(
      title: 'گزارش‌ها',
      subtitle: 'رسیدگی به گزارش‌های کاربران',
      icon: Icons.flag_rounded,
      accent: _accent,
      searchHint: 'جستجوی گزارش…',
      emptyMessage: 'گزارشی یافت نشد',
      fetcher: ({required search}) {
        if (remote == null) return Future.error('Supabase پیکربندی نشده است');
        return remote.listReports(search: search);
      },
      rowBuilder: (context, item) {
        final id = adminStr(item, 'id');
        final status = adminStr(item, 'status');
        final reason = adminStr(item, 'reason');
        final targetType = adminStr(item, 'target_type');
        return AdminColorfulTile(
          title: reason.isEmpty ? 'گزارش' : reason,
          accent: _accent,
          icon: Icons.flag_rounded,
          onTap: id.isEmpty ? null : () => context.push(RouteNames.reportDetailPath(id)),
          subtitle: [targetType, status].where((e) => e.isNotEmpty).join(' · '),
        );
      },
    );
  }
}

class ReportDetailScreen extends ConsumerStatefulWidget {
  const ReportDetailScreen({super.key, required this.reportId});
  final String reportId;

  @override
  ConsumerState<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends ConsumerState<ReportDetailScreen> {
  static const _accent = Color(0xFFD92D20);

  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<Map<String, dynamic>> _load() {
    final remote = ref.read(adminRemoteDataSourceProvider);
    if (remote == null) throw Exception('Supabase پیکربندی نشده است');
    return remote.getReportDetail(widget.reportId);
  }

  Future<void> _run(Future<void> Function(AdminRemoteDataSource r) action) async {
    final remote = ref.read(adminRemoteDataSourceProvider);
    if (remote == null) return;
    try {
      await action(remote);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('انجام شد')),
      );
      setState(() => _future = _load());
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
        final report = adminMap(data?['report'] ?? data) ?? data;
        final status = adminStr(report, 'status', '—');

        return AdminDetailScaffold(
          title: 'جزئیات گزارش',
          subtitle: status,
          accent: _accent,
          icon: Icons.flag_rounded,
          isLoading: snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData,
          error: snapshot.hasError ? '${snapshot.error}' : null,
          onRetry: () => setState(() => _future = _load()),
          body: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              AdminInfoSection(
                title: 'گزارش',
                accent: _accent,
                icon: Icons.report_gmailerrorred_rounded,
                trailing: AdminStatusChip(label: status),
                children: [
                  AdminInfoRow(label: 'شناسه', value: widget.reportId, mono: true),
                  AdminInfoRow(label: 'نوع هدف', value: adminStr(report, 'target_type')),
                  AdminInfoRow(label: 'هدف', value: adminStr(report, 'target_id')),
                  AdminInfoRow(label: 'دلیل', value: adminStr(report, 'reason')),
                  AdminInfoRow(label: 'توضیح', value: adminStr(report, 'description')),
                  AdminInfoRow(label: 'وضعیت', value: status),
                ],
              ),
              FilledButton(
                onPressed: () async {
                  final note = await promptAdminText(
                    context,
                    title: 'تأیید رسیدگی',
                    label: 'یادداشت (اختیاری)',
                    maxLines: 3,
                    confirmLabel: 'رسیدگی شد',
                  );
                  if (note == null) return;
                  await _run((r) => r.moderateReport(
                        reportId: widget.reportId,
                        action: 'resolve',
                        note: note.isEmpty ? null : note,
                      ));
                },
                child: const Text('رسیدگی / تأیید'),
              ),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton(
                onPressed: () async {
                  final note = await promptAdminText(
                    context,
                    title: 'رد گزارش',
                    label: 'یادداشت',
                    maxLines: 2,
                    confirmLabel: 'رد',
                  );
                  if (note == null) return;
                  await _run((r) => r.resolveReport(
                        reportId: widget.reportId,
                        status: 'dismissed',
                        note: note.isEmpty ? null : note,
                      ));
                },
                child: const Text('رد / بستن گزارش'),
              ),
            ],
          ),
        );
      },
    );
  }
}
