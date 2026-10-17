import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kalbala_admin/core/theme/app_colors.dart';
import 'package:kalbala_admin/core/theme/app_spacing.dart';

/// Collect image URLs from common admin payload shapes.
List<String> adminImageUrls(
  Map<String, dynamic>? map, {
  List<String> keys = const [
    'images',
    'product_images',
    'photos',
    'gallery',
  ],
}) {
  if (map == null) return const [];
  final urls = <String>[];

  void add(dynamic value) {
    if (value is String) {
      final t = value.trim();
      if (t.startsWith('http')) urls.add(t);
    } else if (value is List) {
      for (final item in value) {
        if (item is String) {
          final t = item.trim();
          if (t.startsWith('http')) urls.add(t);
        } else if (item is Map) {
          final nested = item['url'] ?? item['image_url'] ?? item['src'];
          if (nested is String && nested.trim().startsWith('http')) {
            urls.add(nested.trim());
          }
        }
      }
    }
  }

  for (final key in keys) {
    add(map[key]);
  }

  // Nested product payload from listing/order joins.
  final product = map['product'] ?? map['products'];
  if (product is Map) {
    add(product['images']);
    add(product['product_images']);
  }

  return urls.toSet().toList();
}

String? adminImageUrl(
  Map<String, dynamic>? map, {
  List<String> keys = const [
    'avatar_url',
    'logo_url',
    'cover_url',
    'image_url',
    'photo_url',
    'thumbnail_url',
    'booth_logo_url',
  ],
}) {
  if (map == null) return null;
  for (final key in keys) {
    final value = map[key];
    if (value is String && value.trim().startsWith('http')) {
      return value.trim();
    }
  }
  final list = adminImageUrls(map);
  return list.isEmpty ? null : list.first;
}

class AdminNetworkImage extends StatelessWidget {
  const AdminNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.fallbackIcon = Icons.image_outlined,
  });

  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(AppSpacing.radiusMd);
    final hasUrl = url != null && url!.trim().isNotEmpty;

    Widget child;
    if (!hasUrl) {
      child = ColoredBox(
        color: AppColors.primarySoft,
        child: Center(
          child: Icon(fallbackIcon, color: AppColors.primary, size: 28),
        ),
      );
    } else {
      child = CachedNetworkImage(
        imageUrl: url!,
        fit: fit,
        width: width,
        height: height,
        placeholder: (_, _) => ColoredBox(
          color: AppColors.primarySoft,
          child: Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary.withValues(alpha: 0.7),
              ),
            ),
          ),
        ),
        errorWidget: (_, _, _) => ColoredBox(
          color: AppColors.primarySoft,
          child: Center(
            child: Icon(fallbackIcon, color: AppColors.inkMuted, size: 28),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(width: width, height: height, child: child),
    );
  }
}

class AdminAvatar extends StatelessWidget {
  const AdminAvatar({
    super.key,
    this.url,
    this.size = 72,
    this.fallbackIcon = Icons.person_rounded,
    this.accent = AppColors.primary,
    this.borderWidth = 3,
  });

  final String? url;
  final double size;
  final IconData fallbackIcon;
  final Color accent;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: borderWidth),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(
        child: AdminNetworkImage(
          url: url,
          width: size,
          height: size,
          fallbackIcon: fallbackIcon,
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}

class AdminImageGallery extends StatelessWidget {
  const AdminImageGallery({
    super.key,
    required this.urls,
    this.height = 168,
    this.title = 'تصاویر',
    this.accent = AppColors.primary,
  });

  final List<String> urls;
  final double height;
  final String title;
  final Color accent;

  void _openViewer(BuildContext context, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _AdminImageViewer(
          urls: urls,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (urls.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Row(
            children: [
              Icon(Icons.photo_library_outlined, size: 18, color: accent),
              const SizedBox(width: 8),
              Text(
                '$title (${urls.length})',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: accent,
                    ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: height,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: urls.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _openViewer(context, index),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: AdminNetworkImage(
                    url: urls[index],
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }
}

class _AdminImageViewer extends StatefulWidget {
  const _AdminImageViewer({
    required this.urls,
    required this.initialIndex,
  });

  final List<String> urls;
  final int initialIndex;

  @override
  State<_AdminImageViewer> createState() => _AdminImageViewerState();
}

class _AdminImageViewerState extends State<_AdminImageViewer> {
  late final PageController _controller;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('${_index + 1} / ${widget.urls.length}'),
      ),
      body: PageView.builder(
        controller: _controller,
        itemCount: widget.urls.length,
        onPageChanged: (i) => setState(() => _index = i),
        itemBuilder: (context, index) {
          return InteractiveViewer(
            child: Center(
              child: CachedNetworkImage(
                imageUrl: widget.urls[index],
                fit: BoxFit.contain,
                placeholder: (_, _) => const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
                errorWidget: (_, _, _) => const Icon(
                  Icons.broken_image_outlined,
                  color: Colors.white54,
                  size: 48,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
