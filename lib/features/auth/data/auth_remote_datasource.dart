import 'package:kalbala_admin/core/errors/exceptions.dart';
import 'package:kalbala_admin/features/auth/domain/admin_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;

/// Maps a display username to the email used in Supabase Auth.
String adminLoginEmail(String username) {
  final trimmed = username.trim();
  if (trimmed.contains('@')) return trimmed.toLowerCase();
  return '${trimmed.toLowerCase()}@kalbala.admin';
}

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._client);

  final SupabaseClient _client;

  Session? get currentSession => _client.auth.currentSession;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<AdminUser> signInWithPassword({
    required String username,
    required String password,
  }) async {
    final email = adminLoginEmail(username);
    if (email.isEmpty || password.isEmpty) {
      throw const ValidationException('نام کاربری و رمز عبور الزامی است.');
    }

    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final userId = response.user?.id ?? response.session?.user.id;
      if (userId == null) {
        throw const AuthException('ورود ناموفق بود. دوباره تلاش کنید.');
      }

      final admin = await fetchAdminUser(userId);
      if (!admin.isAdmin) {
        await signOut();
        throw const ForbiddenException(
          'این حساب دسترسی مدیریت ندارد.',
        );
      }
      return admin;
    } on AuthApiException catch (e) {
      throw AuthException(_mapAuthError(e.message));
    } on AppException {
      rethrow;
    } catch (e) {
      final message = e.toString();
      if (message.contains('SocketException') ||
          message.contains('Failed host lookup') ||
          message.contains('ClientException')) {
        throw const AuthException(
          'اتصال به سرور برقرار نشد. اینترنت و SUPABASE_URL را بررسی کنید.',
        );
      }
      throw ServerException(message);
    }
  }

  Future<AdminUser> fetchAdminUser(String userId) async {
    try {
      final isAdmin = await _client.rpc<bool>(
        'is_admin',
        params: {'check_user_id': userId},
      );

      final profile = await _client
          .from('profiles')
          .select('id, phone, full_name, avatar_url, is_blocked')
          .eq('id', userId)
          .maybeSingle();

      if (profile == null) {
        throw const AuthException('پروفایل کاربر یافت نشد.');
      }

      String? role;
      if (isAdmin == true) {
        final roleRow = await _client
            .from('admin_roles')
            .select('role')
            .eq('user_id', userId)
            .eq('is_active', true)
            .maybeSingle();
        role = roleRow?['role'] as String?;
      }

      return AdminUser.fromJson({
        ...profile,
        'is_admin': isAdmin == true,
        'admin_role': role,
      });
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  String _mapAuthError(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('invalid login') ||
        lower.contains('invalid credentials') ||
        lower.contains('email not confirmed')) {
      return 'نام کاربری یا رمز عبور نادرست است.';
    }
    if (lower.contains('rate') || lower.contains('too many')) {
      return 'تعداد درخواست‌ها بیش از حد مجاز است. بعداً تلاش کنید.';
    }
    return message;
  }
}
