import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kalbala_admin/core/constants/app_constants.dart';
import 'package:kalbala_admin/core/theme/app_spacing.dart';
import 'package:kalbala_admin/features/admin/data/admin_remote_datasource.dart';
import 'package:kalbala_admin/shared/widgets/admin_detail.dart';
import 'package:kalbala_admin/shared/widgets/admin_list_scaffold.dart';
import 'package:kalbala_admin/shared/widgets/admin_list_tile.dart';
import 'package:kalbala_admin/shared/widgets/admin_states.dart';

class CommissionScreen extends ConsumerStatefulWidget {
  const CommissionScreen({super.key});

  @override
  ConsumerState<CommissionScreen> createState() => _CommissionScreenState();
}

class _CommissionScreenState extends ConsumerState<CommissionScreen> {
  static const _accent = Color(0xFFCA8A04);

  late Future<Map<String, dynamic>> _configFuture;
  late Future<AdminListPage> _rulesFuture;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    final remote = ref.read(adminRemoteDataSourceProvider);
    _configFuture = remote?.getCommissionConfig() ?? Future.value({});
    _rulesFuture = remote?.listCommissionRules() ??
        Future.value(const AdminListPage(items: [], total: 0));
    setState(() {});
  }

  Future<void> _editConfig(Map<String, dynamic> config) async {
    var enabled = config['commission_enabled'] == true;
    final rate = TextEditingController(
      text: '${config['default_commission_rate'] ?? 0}',
    );
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocal) => AlertDialog(
          title: const Text('تنظیمات کمیسیون'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('فعال بودن کمیسیون'),
                value: enabled,
                onChanged: (v) => setLocal(() => enabled = v),
              ),
              TextField(
                controller: rate,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'نرخ پیش‌فرض (%)'),
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
    if (ok == true) {
      try {
        await ref.read(adminRemoteDataSourceProvider)?.updateCommissionConfig(
              enabled: enabled,
              defaultRate: num.tryParse(rate.text.trim()) ?? 0,
            );
        _reload();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
        }
      }
    }
    rate.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
      children: [
        const AdminPageBanner(
          title: 'کمیسیون',
          subtitle: 'نرخ پیش‌فرض و قوانین اختصاصی',
          icon: Icons.percent_rounded,
          accent: _accent,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            children: [
              FutureBuilder<Map<String, dynamic>>(
                future: _configFuture,
                builder: (context, snapshot) {
                  final config = snapshot.data ?? {};
                  return AdminInfoSection(
                    title: 'پیکربندی کلی',
                    accent: _accent,
                    icon: Icons.tune_rounded,
                    trailing: IconButton(
                      onPressed: () => _editConfig(config),
                      icon: Icon(Icons.edit_rounded, color: _accent),
                    ),
                    children: [
                      AdminInfoRow(
                        label: 'وضعیت',
                        value: config['commission_enabled'] == true ? 'فعال' : 'غیرفعال',
                      ),
                      AdminInfoRow(
                        label: 'نرخ پیش‌فرض',
                        value: '${config['default_commission_rate'] ?? '—'}٪',
                      ),
                    ],
                  );
                },
              ),
              const AdminSectionTitle(
                title: 'قوانین اختصاصی',
                accent: _accent,
                icon: Icons.rule_folder_outlined,
              ),
              FutureBuilder<AdminListPage>(
                future: _rulesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(color: _accent),
                    );
                  }
                  final items = snapshot.data?.items ?? const [];
                  if (items.isEmpty) {
                    return const AdminEmptyState(
                      message: 'قانون اختصاصی ثبت نشده',
                      icon: Icons.rule_outlined,
                      accent: _accent,
                    );
                  }
                  return Column(
                    children: [
                      for (final item in items) ...[
                        AdminColorfulTile(
                          title: 'غرفه ${adminStr(item, 'booth_id')}',
                          accent: _accent,
                          icon: Icons.storefront_outlined,
                          subtitle: '${item['rate_percent'] ?? '—'}٪',
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Color(0xFFD92D20)),
                            onPressed: () async {
                              final ok = await confirmAdminAction(
                                context,
                                title: 'حذف قانون',
                                message: 'این قانون کمیسیون حذف شود؟',
                                destructive: true,
                                confirmLabel: 'حذف',
                              );
                              if (!ok) return;
                              await ref
                                  .read(adminRemoteDataSourceProvider)
                                  ?.deleteCommissionRule(adminStr(item, 'id'));
                              _reload();
                            },
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                      ],
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ShippingScreen extends ConsumerStatefulWidget {
  const ShippingScreen({super.key});

  @override
  ConsumerState<ShippingScreen> createState() => _ShippingScreenState();
}

class _ShippingScreenState extends ConsumerState<ShippingScreen> {
  static const _accent = Color(0xFFEA580C);

  @override
  Widget build(BuildContext context) {
    final remote = ref.watch(adminRemoteDataSourceProvider);
    return AdminListScaffold(
      title: 'نرخ ارسال',
      subtitle: 'هزینه ارسال بر اساس شهر و وزن',
      icon: Icons.local_shipping_rounded,
      accent: _accent,
      emptyMessage: 'نرخی یافت نشد',
      fetcher: ({required search}) {
        if (remote == null) return Future.error('Supabase پیکربندی نشده است');
        return remote.listShippingRates(city: search);
      },
      rowBuilder: (context, item) {
        return AdminColorfulTile(
          title: adminStr(item, 'city', 'شهر'),
          accent: _accent,
          icon: Icons.local_shipping_rounded,
          subtitle:
              '${item['min_weight_grams'] ?? 0}-${item['max_weight_grams'] ?? 0}g · '
              '${item['rate_amount'] ?? '—'} ${AppConstants.currencySymbol}',
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline, color: Color(0xFFD92D20)),
            onPressed: () async {
                final ok = await confirmAdminAction(
                  context,
                  title: 'حذف نرخ',
                  message: 'این نرخ ارسال حذف شود؟',
                  destructive: true,
                  confirmLabel: 'حذف',
                );
                if (!ok) return;
                try {
                  await remote?.deleteShippingRate(adminStr(item, 'id'));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('حذف شد — لیست را رفرش کنید')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
                  }
                }
              },
            ),
            onTap: () async {
              final city = TextEditingController(text: adminStr(item, 'city'));
              final minW = TextEditingController(text: '${item['min_weight_grams'] ?? 0}');
              final maxW = TextEditingController(text: '${item['max_weight_grams'] ?? 0}');
              final amount = TextEditingController(text: '${item['rate_amount'] ?? 0}');
              final ok = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('ویرایش نرخ ارسال'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(controller: city, decoration: const InputDecoration(labelText: 'شهر')),
                      TextField(controller: minW, decoration: const InputDecoration(labelText: 'حداقل وزن')),
                      TextField(controller: maxW, decoration: const InputDecoration(labelText: 'حداکثر وزن')),
                      TextField(controller: amount, decoration: const InputDecoration(labelText: 'مبلغ')),
                    ],
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('انصراف')),
                    FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('ذخیره')),
                  ],
                ),
              );
              if (ok == true) {
                await remote?.upsertShippingRate(
                  id: adminStr(item, 'id'),
                  city: city.text.trim(),
                  minWeightGrams: int.tryParse(minW.text) ?? 0,
                  maxWeightGrams: int.tryParse(maxW.text) ?? 0,
                  rateAmount: num.tryParse(amount.text) ?? 0,
                  isActive: true,
                );
              }
              city.dispose();
              minW.dispose();
              maxW.dispose();
              amount.dispose();
            },
        );
      },
    );
  }
}

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  static const _accent = Color(0xFF475569);

  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<Map<String, dynamic>> _load() {
    final remote = ref.read(adminRemoteDataSourceProvider);
    if (remote == null) throw Exception('Supabase پیکربندی نشده است');
    return remote.getSettings();
  }

  Future<void> _save(Map<String, dynamic> settings) async {
    final name = TextEditingController(text: adminStr(settings, 'marketplace_name'));
    final phone = TextEditingController(text: adminStr(settings, 'support_phone'));
    final email = TextEditingController(text: adminStr(settings, 'support_email'));
    final message = TextEditingController(text: adminStr(settings, 'maintenance_message'));
    var maintenance = settings['maintenance_mode'] == true;
    var moderation = settings['require_product_moderation'] == true;

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocal) => AlertDialog(
          title: const Text('ویرایش تنظیمات'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: name, decoration: const InputDecoration(labelText: 'نام بازارگاه')),
                TextField(controller: phone, decoration: const InputDecoration(labelText: 'تلفن پشتیبانی')),
                TextField(controller: email, decoration: const InputDecoration(labelText: 'ایمیل پشتیبانی')),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('حالت تعمیرات'),
                  value: maintenance,
                  onChanged: (v) => setLocal(() => maintenance = v),
                ),
                TextField(
                  controller: message,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'پیام تعمیرات'),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('نیاز به تأیید محصول'),
                  value: moderation,
                  onChanged: (v) => setLocal(() => moderation = v),
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

    if (ok == true) {
      try {
        await ref.read(adminRemoteDataSourceProvider)?.updateSettings(
              marketplaceName: name.text.trim(),
              supportPhone: phone.text.trim(),
              supportEmail: email.text.trim(),
              maintenanceMode: maintenance,
              maintenanceMessage: message.text.trim(),
              requireProductModeration: moderation,
            );
        if (mounted) setState(() => _future = _load());
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
        }
      }
    }
    name.dispose();
    phone.dispose();
    email.dispose();
    message.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
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
        final settings = snapshot.data ?? {};
        return ListView(
          padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
          children: [
            const AdminPageBanner(
              title: 'تنظیمات',
              subtitle: 'نام بازارگاه، تعمیرات و تأیید محصول',
              icon: Icons.settings_rounded,
              accent: _accent,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: AdminInfoSection(
              title: 'تنظیمات پلتفرم',
              accent: _accent,
              icon: Icons.tune_rounded,
              trailing: IconButton(
                onPressed: () => _save(settings),
                icon: Icon(Icons.edit_rounded, color: _accent),
              ),
              children: [
                AdminInfoRow(label: 'نام', value: adminStr(settings, 'marketplace_name')),
                AdminInfoRow(label: 'تلفن', value: adminStr(settings, 'support_phone')),
                AdminInfoRow(label: 'ایمیل', value: adminStr(settings, 'support_email')),
                AdminInfoRow(
                  label: 'تعمیرات',
                  value: settings['maintenance_mode'] == true ? 'فعال' : 'غیرفعال',
                ),
                AdminInfoRow(
                  label: 'تأیید محصول',
                  value: settings['require_product_moderation'] == true ? 'الزامی' : 'اختیاری',
                ),
              ],
            ),
            ),
          ],
        );
      },
    );
  }
}

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  static const _accent = Color(0xFF2563EB);

  final _title = TextEditingController();
  final _body = TextEditingController();

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final remote = ref.watch(adminRemoteDataSourceProvider);
    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
      children: [
        const AdminPageBanner(
          title: 'اعلان‌ها',
          subtitle: 'ارسال اعلان به کاربران',
          icon: Icons.notifications_rounded,
          accent: _accent,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            children: [
        AdminInfoSection(
          title: 'ارسال اعلان',
          accent: _accent,
          icon: Icons.campaign_outlined,
          children: [
            TextField(controller: _title, decoration: const InputDecoration(labelText: 'عنوان')),
            const SizedBox(height: 10),
            TextField(
              controller: _body,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'متن'),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () async {
                if (_title.text.trim().isEmpty || _body.text.trim().isEmpty) return;
                try {
                  await remote?.sendNotification(
                    title: _title.text.trim(),
                    body: _body.text.trim(),
                    targetType: 'all',
                    notificationType: 'system',
                  );
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('اعلان ارسال شد')),
                  );
                  _title.clear();
                  _body.clear();
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
                }
              },
              child: const Text('ارسال به همه کاربران'),
            ),
          ],
        ),
        const AdminSectionTitle(
          title: 'کمپین‌های اخیر',
          accent: _accent,
          icon: Icons.history_rounded,
        ),
        FutureBuilder<AdminListPage>(
          future: remote?.listNotificationCampaigns(),
          builder: (context, snapshot) {
            final items = snapshot.data?.items ?? const [];
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: _accent));
            }
            if (items.isEmpty) {
              return const AdminEmptyState(
                message: 'کمپینی ثبت نشده',
                icon: Icons.notifications_none_rounded,
                accent: _accent,
              );
            }
            return Column(
              children: [
                for (final item in items) ...[
                  AdminColorfulTile(
                    title: adminStr(item, 'title'),
                    accent: _accent,
                    icon: Icons.notifications_active_outlined,
                    subtitle: adminStr(item, 'body'),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ],
            );
          },
        ),
            ],
          ),
        ),
      ],
    );
  }
}

class AdminsScreen extends ConsumerStatefulWidget {
  const AdminsScreen({super.key});

  @override
  ConsumerState<AdminsScreen> createState() => _AdminsScreenState();
}

class _AdminsScreenState extends ConsumerState<AdminsScreen> {
  static const _accent = Color(0xFF0A4D3C);

  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Map<String, dynamic>>> _load() {
    final remote = ref.read(adminRemoteDataSourceProvider);
    if (remote == null) throw Exception('Supabase پیکربندی نشده است');
    return remote.listAdminAccounts();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
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
          return const AdminEmptyState(
            message: 'ادمینی ثبت نشده',
            icon: Icons.admin_panel_settings_outlined,
            accent: _accent,
          );
        }
        return RefreshIndicator(
          color: _accent,
          onRefresh: () async {
            final f = _load();
            setState(() => _future = f);
            await f;
          },
          child: ListView(
            padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
            children: [
              const AdminPageBanner(
                title: 'ادمین‌ها',
                subtitle: 'نقش‌های مدیریت',
                icon: Icons.admin_panel_settings_rounded,
                accent: _accent,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  0,
                ),
                child: Column(
                  children: [
                    for (final item in items) ...[
                      Builder(
                        builder: (context) {
                          final userId = adminStr(item, 'user_id', adminStr(item, 'id'));
                          final role = adminStr(item, 'role', 'admin');
                          return AdminColorfulTile(
                            title: adminStr(item, 'full_name', userId),
                            accent: role == 'super_admin' ? const Color(0xFFE2A116) : _accent,
                            icon: Icons.admin_panel_settings_rounded,
                            subtitle: role,
                            trailing: PopupMenuButton<String>(
                              icon: Icon(Icons.more_vert_rounded, color: _accent),
                              onSelected: (value) async {
                                try {
                                  await ref
                                      .read(adminRemoteDataSourceProvider)
                                      ?.updateAdminRole(userId: userId, role: value);
                                  if (mounted) setState(() => _future = _load());
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(content: Text('$e')));
                                  }
                                }
                              },
                              itemBuilder: (_) => const [
                                PopupMenuItem(value: 'admin', child: Text('admin')),
                                PopupMenuItem(value: 'super_admin', child: Text('super_admin')),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class AuditScreen extends ConsumerWidget {
  const AuditScreen({super.key});

  static const _accent = Color(0xFF64748B);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remote = ref.watch(adminRemoteDataSourceProvider);
    return AdminListScaffold(
      title: 'لاگ ممیزی',
      subtitle: 'تاریخچه اقدامات ادمین',
      icon: Icons.history_rounded,
      accent: _accent,
      emptyMessage: 'لاگی یافت نشد',
      fetcher: ({required search}) {
        if (remote == null) return Future.error('Supabase پیکربندی نشده است');
        return remote.listAuditLogs(search: search);
      },
      rowBuilder: (context, item) {
        return AdminColorfulTile(
          title: adminStr(item, 'action', 'اقدام'),
          accent: _accent,
          icon: Icons.history_rounded,
          subtitle: [
            adminStr(item, 'resource_type'),
            adminStr(item, 'created_at'),
          ].where((e) => e.isNotEmpty).join(' · '),
        );
      },
    );
  }
}
