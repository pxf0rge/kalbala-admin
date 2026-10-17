import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kalbala_admin/core/config/supabase_config.dart';
import 'package:kalbala_admin/core/errors/exceptions.dart' as errors;
import 'package:kalbala_admin/features/auth/data/auth_remote_datasource.dart';
import 'package:kalbala_admin/features/auth/domain/admin_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum AuthStatus {
  unknown,
  unauthenticated,
  authenticated,
  unauthorized,
  blocked,
}

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource?>((ref) {
  if (!SupabaseConfig.isInitialized) return null;
  return AuthRemoteDataSource(SupabaseConfig.client);
});

final authSessionProvider = StreamProvider<Session?>((ref) {
  final remote = ref.watch(authRemoteDataSourceProvider);
  if (remote == null) {
    return Stream<Session?>.value(null);
  }
  return remote.authStateChanges.map((event) => event.session);
});

final currentAdminProvider = FutureProvider<AdminUser?>((ref) async {
  final session = ref.watch(authSessionProvider).valueOrNull;
  if (session == null) return null;

  final remote = ref.watch(authRemoteDataSourceProvider);
  if (remote == null) return null;

  try {
    return await remote.fetchAdminUser(session.user.id);
  } catch (_) {
    return null;
  }
});

final authStatusProvider = Provider<AuthStatus>((ref) {
  final sessionAsync = ref.watch(authSessionProvider);

  if (sessionAsync.isLoading && !sessionAsync.hasValue) {
    return AuthStatus.unknown;
  }

  final session = sessionAsync.valueOrNull;
  if (session == null) {
    return AuthStatus.unauthenticated;
  }

  final adminAsync = ref.watch(currentAdminProvider);
  if (adminAsync.isLoading && !adminAsync.hasValue) {
    return AuthStatus.unknown;
  }

  final admin = adminAsync.valueOrNull;
  if (admin == null) {
    return AuthStatus.unauthorized;
  }
  if (admin.isBlocked) {
    return AuthStatus.blocked;
  }
  if (!admin.isAdmin) {
    return AuthStatus.unauthorized;
  }

  return AuthStatus.authenticated;
});

final routerRefreshNotifierProvider = Provider<RouterRefreshNotifier>((ref) {
  final notifier = RouterRefreshNotifier();
  ref.listen(authStatusProvider, (_, _) => notifier.refresh());
  ref.onDispose(notifier.dispose);
  return notifier;
});

final class RouterRefreshNotifier extends ChangeNotifier {
  void refresh() => notifyListeners();
}

final loginActionProvider =
    AsyncNotifierProvider<LoginNotifier, AdminUser?>(LoginNotifier.new);

class LoginNotifier extends AsyncNotifier<AdminUser?> {
  @override
  Future<AdminUser?> build() async => null;

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    final remote = ref.read(authRemoteDataSourceProvider);
    if (remote == null) {
      state = AsyncError(
        'Supabase پیکربندی نشده است. فایل .env را تنظیم کنید.',
        StackTrace.current,
      );
      return false;
    }

    state = const AsyncLoading();
    try {
      final user = await remote.signInWithPassword(
        username: username,
        password: password,
      );
      state = AsyncData(user);
      ref.invalidate(currentAdminProvider);
      return true;
    } on errors.AppException catch (e) {
      state = AsyncError(e.message, StackTrace.current);
      return false;
    } catch (e) {
      state = AsyncError(e.toString(), StackTrace.current);
      return false;
    }
  }
}

final signOutActionProvider =
    AsyncNotifierProvider<SignOutNotifier, void>(SignOutNotifier.new);

class SignOutNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> signOut() async {
    final remote = ref.read(authRemoteDataSourceProvider);
    state = const AsyncLoading();
    try {
      await remote?.signOut();
      ref.invalidate(currentAdminProvider);
      state = const AsyncData(null);
    } catch (e) {
      state = AsyncError(e.toString(), StackTrace.current);
    }
  }
}
