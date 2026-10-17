import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kalbala_admin/core/routing/route_names.dart';
import 'package:kalbala_admin/core/theme/app_colors.dart';
import 'package:kalbala_admin/core/theme/app_spacing.dart';
import 'package:kalbala_admin/features/admin/data/admin_remote_datasource.dart';
import 'package:kalbala_admin/shared/widgets/admin_detail.dart';
import 'package:kalbala_admin/shared/widgets/admin_list_scaffold.dart';
import 'package:kalbala_admin/shared/widgets/admin_list_tile.dart';
import 'package:kalbala_admin/shared/widgets/admin_states.dart';

class TicketsScreen extends ConsumerWidget {
  const TicketsScreen({super.key});

  static const _accent = Color(0xFF2563EB);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remote = ref.watch(adminRemoteDataSourceProvider);
    return AdminListScaffold(
      title: 'پشتیبانی',
      subtitle: 'پاسخ به تیکت‌های کاربران',
      icon: Icons.support_agent_rounded,
      accent: _accent,
      searchHint: 'جستجوی تیکت…',
      emptyMessage: 'تیکتی یافت نشد',
      fetcher: ({required search}) {
        if (remote == null) return Future.error('Supabase پیکربندی نشده است');
        return remote.listTickets(search: search);
      },
      rowBuilder: (context, item) {
        final id = adminStr(item, 'id');
        final subject = adminStr(item, 'subject', 'بدون موضوع');
        final status = adminStr(item, 'status');
        return AdminColorfulTile(
          title: subject,
          accent: _accent,
          icon: Icons.support_agent_rounded,
          onTap: id.isEmpty ? null : () => context.push(RouteNames.ticketDetailPath(id)),
          subtitle: status,
        );
      },
    );
  }
}

class TicketDetailScreen extends ConsumerStatefulWidget {
  const TicketDetailScreen({super.key, required this.ticketId});
  final String ticketId;

  @override
  ConsumerState<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends ConsumerState<TicketDetailScreen> {
  static const _accent = Color(0xFF2563EB);

  late Future<Map<String, dynamic>> _future;
  final _replyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> _load() {
    final remote = ref.read(adminRemoteDataSourceProvider);
    if (remote == null) throw Exception('Supabase پیکربندی نشده است');
    return remote.getTicketDetail(widget.ticketId);
  }

  Future<void> _reply() async {
    final text = _replyController.text.trim();
    if (text.isEmpty) return;
    final remote = ref.read(adminRemoteDataSourceProvider);
    if (remote == null) return;
    try {
      await remote.replyTicket(ticketId: widget.ticketId, content: text);
      _replyController.clear();
      if (!mounted) return;
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
        final ticket = adminMap(data?['ticket'] ?? data) ?? data;
        final messages = adminMapList(data?['messages'] ?? ticket?['messages']);
        final status = adminStr(ticket, 'status', '—');

        return AdminDetailScaffold(
          title: adminStr(ticket, 'subject', 'تیکت'),
          subtitle: status,
          accent: _accent,
          icon: Icons.support_agent_rounded,
          isLoading: snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData,
          error: snapshot.hasError ? '${snapshot.error}' : null,
          onRetry: () => setState(() => _future = _load()),
          body: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  children: [
                    AdminInfoSection(
                      title: 'اطلاعات تیکت',
                      accent: _accent,
                      icon: Icons.confirmation_number_outlined,
                      trailing: AdminStatusChip(label: status),
                      children: [
                        AdminInfoRow(label: 'شناسه', value: widget.ticketId, mono: true),
                        AdminInfoRow(label: 'وضعیت', value: status),
                        AdminInfoRow(label: 'کاربر', value: adminStr(ticket, 'user_id')),
                      ],
                    ),
                    AdminSectionTitle(
                      title: 'پیام‌ها',
                      accent: _accent,
                      icon: Icons.forum_outlined,
                    ),
                    if (messages.isEmpty)
                      const AdminEmptyState(
                        message: 'پیامی نیست',
                        icon: Icons.chat_bubble_outline,
                        accent: _accent,
                      )
                    else
                      for (final msg in messages)
                        Container(
                          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: adminBool(msg, 'is_admin_reply')
                                ? _accent.withValues(alpha: 0.08)
                                : AppColors.surfaceRaised,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                            border: Border.all(
                              color: adminBool(msg, 'is_admin_reply')
                                  ? _accent.withValues(alpha: 0.2)
                                  : AppColors.hairline,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                adminBool(msg, 'is_admin_reply') ? 'ادمین' : 'کاربر',
                                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                      color: adminBool(msg, 'is_admin_reply')
                                          ? _accent
                                          : AppColors.inkMuted,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(adminStr(msg, 'content')),
                            ],
                          ),
                        ),
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final s in ['open', 'in_progress', 'resolved', 'closed'])
                          OutlinedButton(
                            onPressed: () async {
                              try {
                                await ref.read(adminRemoteDataSourceProvider)?.updateTicketStatus(
                                      ticketId: widget.ticketId,
                                      status: s,
                                    );
                                if (mounted) setState(() => _future = _load());
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(content: Text('$e')));
                                }
                              }
                            },
                            child: Text(s),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _replyController,
                          decoration: InputDecoration(
                            hintText: 'پاسخ ادمین…',
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                              borderSide: const BorderSide(color: _accent, width: 1.5),
                            ),
                          ),
                          minLines: 1,
                          maxLines: 3,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        style: IconButton.styleFrom(
                          backgroundColor: _accent,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _reply,
                        icon: const Icon(Icons.send_rounded),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
