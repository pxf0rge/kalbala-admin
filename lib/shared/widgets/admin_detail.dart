import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kalbala_admin/core/routing/route_names.dart';
import 'package:kalbala_admin/core/theme/app_colors.dart';
import 'package:kalbala_admin/core/theme/app_spacing.dart';
import 'package:kalbala_admin/shared/widgets/admin_media.dart';
import 'package:kalbala_admin/shared/widgets/admin_states.dart';

class AdminDetailScaffold extends StatelessWidget {
  const AdminDetailScaffold({
    super.key,
    required this.title,
    required this.body,
    this.subtitle,
    this.actions = const [],
    this.floatingActionButton,
    this.onRefresh,
    this.isLoading = false,
    this.error,
    this.onRetry,
    this.accent = AppColors.primary,
    this.icon,
  });

  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final Widget body;
  final Widget? floatingActionButton;
  final Future<void> Function()? onRefresh;
  final bool isLoading;
  final String? error;
  final VoidCallback? onRetry;
  final Color accent;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (isLoading) {
      content = Center(child: CircularProgressIndicator(color: accent));
    } else if (error != null) {
      content = AdminErrorState(message: error!, onRetry: onRetry);
    } else {
      content = body;
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'بازگشت',
          icon: const Icon(Icons.arrow_forward_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(RouteNames.dashboard);
            }
          },
        ),
        title: Row(
          children: [
            if (icon != null) ...[
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      accent.withValues(alpha: 0.9),
                      accent,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty)
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.inkMuted,
                          ),
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: actions,
      ),
      floatingActionButton: floatingActionButton,
      body: onRefresh == null
          ? content
          : RefreshIndicator(
              color: accent,
              onRefresh: onRefresh!,
              child: content is ListView || content is CustomScrollView
                  ? content
                  : ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.7,
                          child: content,
                        ),
                      ],
                    ),
            ),
    );
  }
}

/// Hero header for detail pages — cover + avatar + title + chips.
class AdminDetailHero extends StatelessWidget {
  const AdminDetailHero({
    super.key,
    required this.title,
    required this.accent,
    this.subtitle,
    this.coverUrl,
    this.avatarUrl,
    this.fallbackIcon = Icons.person_rounded,
    this.chips = const [],
    this.height = 148,
  });

  final String title;
  final String? subtitle;
  final Color accent;
  final String? coverUrl;
  final String? avatarUrl;
  final IconData fallbackIcon;
  final List<Widget> chips;
  final double height;

  @override
  Widget build(BuildContext context) {
    final hasCover = coverUrl != null && coverUrl!.trim().isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        children: [
          SizedBox(
            height: height + 52,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: height,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      boxShadow: [
                        BoxShadow(
                          color: accent.withValues(alpha: 0.18),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (hasCover)
                          AdminNetworkImage(
                            url: coverUrl,
                            fit: BoxFit.cover,
                            borderRadius: BorderRadius.zero,
                            fallbackIcon: fallbackIcon,
                          )
                        else
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topRight,
                                end: Alignment.bottomLeft,
                                colors: [
                                  Color.lerp(accent, Colors.white, 0.15)!,
                                  accent,
                                  Color.lerp(accent, Colors.black, 0.25)!,
                                ],
                              ),
                            ),
                          ),
                        if (hasCover)
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.05),
                                  Colors.black.withValues(alpha: 0.45),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: height - 44,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: AdminAvatar(
                      url: avatarUrl,
                      size: 88,
                      accent: accent,
                      fallbackIcon: fallbackIcon,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
          ),
          if (subtitle != null && subtitle!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.inkMuted,
                  ),
            ),
          ],
          if (chips.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: chips,
            ),
          ],
        ],
      ),
    );
  }
}

class AdminInfoSection extends StatelessWidget {
  const AdminInfoSection({
    super.key,
    required this.title,
    required this.children,
    this.trailing,
    this.accent = AppColors.primary,
    this.icon,
  });

  final String title;
  final List<Widget> children;
  final Widget? trailing;
  final Color accent;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: accent.withValues(alpha: 0.14)),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
                colors: [
                  accent.withValues(alpha: 0.14),
                  accent.withValues(alpha: 0.04),
                ],
              ),
            ),
            child: Row(
              children: [
                if (icon != null) ...[
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, size: 18, color: accent),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: accent,
                        ),
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

/// Modern field card used inside AdminInfoSection.
class AdminInfoField extends StatelessWidget {
  const AdminInfoField({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.accent = AppColors.primary,
    this.mono = false,
    this.multiline = false,
  });

  final String label;
  final String value;
  final IconData? icon;
  final Color accent;
  final bool mono;
  final bool multiline;

  @override
  Widget build(BuildContext context) {
    final display = value.trim().isEmpty ? '—' : value;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: accent.withValues(alpha: 0.1)),
      ),
      child: Row(
        crossAxisAlignment:
            multiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, size: 18, color: accent),
            ),
            const SizedBox(width: AppSpacing.md),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.inkMuted,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 3),
                Text(
                  display,
                  textDirection: mono ? TextDirection.ltr : null,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                        height: 1.35,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AdminInfoRow extends StatelessWidget {
  const AdminInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.mono = false,
  });

  final String label;
  final String value;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    return AdminInfoField(
      label: label,
      value: value,
      mono: mono,
    );
  }
}

class AdminActionGroup extends StatelessWidget {
  const AdminActionGroup({
    super.key,
    required this.children,
    this.title = 'اقدامات',
    this.accent = AppColors.primary,
  });

  final List<Widget> children;
  final String title;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return AdminInfoSection(
      title: title,
      accent: accent,
      icon: Icons.bolt_rounded,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.sm),
          children[i],
        ],
      ],
    );
  }
}

class AdminStatusChip extends StatelessWidget {
  const AdminStatusChip({
    super.key,
    required this.label,
    this.tone = AdminChipTone.neutral,
  });

  final String label;
  final AdminChipTone tone;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (tone) {
      AdminChipTone.success => (
          AppColors.success.withValues(alpha: 0.12),
          AppColors.success
        ),
      AdminChipTone.danger => (AppColors.errorSoft, AppColors.error),
      AdminChipTone.warning => (
          AppColors.warning.withValues(alpha: 0.14),
          AppColors.warning
        ),
      AdminChipTone.neutral => (AppColors.primarySoft, AppColors.primary),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: fg.withValues(alpha: 0.18)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: fg,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

enum AdminChipTone { success, danger, warning, neutral }

Future<bool> confirmAdminAction(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'تأیید',
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('انصراف'),
        ),
        FilledButton(
          style: destructive
              ? FilledButton.styleFrom(backgroundColor: AppColors.error)
              : null,
          onPressed: () => Navigator.pop(context, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result == true;
}

Future<String?> promptAdminText(
  BuildContext context, {
  required String title,
  String? label,
  String? initial,
  String confirmLabel = 'ذخیره',
  int maxLines = 1,
}) async {
  final controller = TextEditingController(text: initial ?? '');
  final result = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('انصراف'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, controller.text.trim()),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  controller.dispose();
  return result;
}

String adminStr(Map<String, dynamic>? map, String key, [String fallback = '']) {
  if (map == null) return fallback;
  final value = map[key];
  if (value == null) return fallback;
  final text = value.toString().trim();
  return text.isEmpty ? fallback : text;
}

bool adminBool(Map<String, dynamic>? map, String key) => map?[key] == true;

Map<String, dynamic>? adminMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}

List<Map<String, dynamic>> adminMapList(dynamic value) {
  if (value is! List) return const [];
  return [
    for (final item in value)
      if (item is Map) Map<String, dynamic>.from(item),
  ];
}
