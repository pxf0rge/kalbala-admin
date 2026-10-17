import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kalbala_admin/core/config/supabase_config.dart';
import 'package:kalbala_admin/core/constants/app_constants.dart';
import 'package:kalbala_admin/core/routing/route_names.dart';
import 'package:kalbala_admin/core/theme/app_colors.dart';
import 'package:kalbala_admin/core/theme/app_text_styles.dart';
import 'package:kalbala_admin/features/auth/presentation/providers/auth_provider.dart';
import 'package:kalbala_admin/shared/widgets/kalbala_logo_mark.dart';

/// Admin login — same visual language as the marketplace client login.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final ok = await ref.read(loginActionProvider.notifier).login(
          username: _usernameController.text.trim(),
          password: _passwordController.text,
        );
    if (!mounted) return;

    if (ok) {
      context.go(RouteNames.dashboard);
      return;
    }

    final error = ref.read(loginActionProvider).error;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error?.toString() ?? 'ورود ناموفق بود')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final screenHeight = MediaQuery.sizeOf(context).height;
    const overlap = 22.0;
    final heroHeight = screenHeight * 0.38 + topInset * 0.2;
    final loggingIn = ref.watch(loginActionProvider).isLoading;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        // Keep layout full-height; keyboard overlays instead of crushing the form.
        resizeToAvoidBottomInset: false,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: heroHeight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF0E5C48),
                          AppColors.primary,
                          Color(0xFF06382C),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: topInset + 4,
                    left: 0,
                    right: 0,
                    child: Opacity(
                      opacity: 0.22,
                      child: Image.asset(
                        'assets/branding/login_skyline.png',
                        height: 88,
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                      ),
                    ),
                  ),
                  SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            flex: 5,
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Image.asset(
                                'assets/branding/login_hero.png',
                                height: 168,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 6,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 18),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Flexible(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              AppConstants.appName,
                                              textAlign: TextAlign.end,
                                              style: AppTextStyles.brandMark
                                                  .copyWith(
                                                color: Colors.white,
                                                fontSize: 26,
                                                height: 1.05,
                                              ),
                                            ),
                                            Text(
                                              AppConstants.appNameEn,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelMedium
                                                  ?.copyWith(
                                                    color: Colors.white70,
                                                    letterSpacing: 1.1,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      const KalBalaLogoMark(
                                        size: 48,
                                        useBrandAsset: true,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'ورود به پنل مدیریت بازارگاه',
                                    textAlign: TextAlign.end,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Colors.white
                                              .withValues(alpha: 0.82),
                                          height: 1.45,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: heroHeight - overlap,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(32),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      child: CustomPaint(
                        size: const Size(double.infinity, 96),
                        painter: _LoginWavePainter(),
                      ),
                    ),
                    SafeArea(
                      top: false,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          24,
                          32,
                          24,
                          16 + bottomInset * 0.2,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'ورود مدیر',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'نام کاربری و رمز عبور خود را وارد کنید.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: AppColors.inkMuted,
                                    ),
                              ),
                              const SizedBox(height: 28),
                              TextFormField(
                                controller: _usernameController,
                                textInputAction: TextInputAction.next,
                                textDirection: TextDirection.ltr,
                                autofillHints: const [AutofillHints.username],
                                decoration: InputDecoration(
                                  labelText: 'نام کاربری',
                                  hintText: 'admin',
                                  prefixIcon: const Icon(
                                    Icons.person_outline_rounded,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: AppColors.hairline,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(
                                      color: AppColors.primary,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if ((value ?? '').trim().isEmpty) {
                                    return 'نام کاربری را وارد کنید';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                textInputAction: TextInputAction.done,
                                textDirection: TextDirection.ltr,
                                autofillHints: const [AutofillHints.password],
                                onFieldSubmitted: (_) => _submit(),
                                decoration: InputDecoration(
                                  labelText: 'رمز عبور',
                                  hintText: '••••••••',
                                  prefixIcon: const Icon(
                                    Icons.lock_outline_rounded,
                                  ),
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: AppColors.hairline,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(
                                      color: AppColors.primary,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if ((value ?? '').isEmpty) {
                                    return 'رمز عبور را وارد کنید';
                                  }
                                  if ((value ?? '').length < 6) {
                                    return 'رمز عبور حداقل ۶ کاراکتر باشد';
                                  }
                                  return null;
                                },
                              ),
                              if (!SupabaseConfig.isInitialized) ...[
                                const SizedBox(height: 16),
                                Text(
                                  'Supabase پیکربندی نشده — فایل .env را تنظیم کنید',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                              const Spacer(),
                              SizedBox(
                                height: 56,
                                child: FilledButton(
                                  onPressed: loggingIn ? null : _submit,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor: AppColors.primary
                                        .withValues(alpha: 0.55),
                                    shape: const StadiumBorder(),
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                  ),
                                  child: loggingIn
                                      ? const SizedBox(
                                          height: 22,
                                          width: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Directionality(
                                          textDirection: TextDirection.ltr,
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.arrow_back_rounded,
                                                size: 22,
                                                color: Colors.white
                                                    .withValues(alpha: 0.95),
                                              ),
                                              const Expanded(
                                                child: Text(
                                                  'ورود به پنل',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 22),
                                            ],
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    paint.color = const Color(0xFFD7EDE6).withValues(alpha: 0.7);
    final back = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * 0.35)
      ..quadraticBezierTo(
        size.width * 0.78,
        size.height * 0.72,
        size.width * 0.5,
        size.height * 0.42,
      )
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.15,
        0,
        size.height * 0.55,
      )
      ..close();
    canvas.drawPath(back, paint);

    paint.color = const Color(0xFFBFE0D4).withValues(alpha: 0.75);
    final front = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * 0.22)
      ..quadraticBezierTo(
        size.width * 0.82,
        size.height * 0.55,
        size.width * 0.55,
        size.height * 0.38,
      )
      ..quadraticBezierTo(
        size.width * 0.3,
        size.height * 0.22,
        0,
        size.height * 0.48,
      )
      ..close();
    canvas.drawPath(front, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
