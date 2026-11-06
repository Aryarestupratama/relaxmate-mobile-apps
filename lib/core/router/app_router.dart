import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:relaxmate/core/router/app_routes.dart';
import 'package:relaxmate/core/router/auth_redirect.dart';
import 'package:relaxmate/features/auth/state/auth_controller.dart';
import 'package:relaxmate/features/auth/state/auth_state.dart';
import 'package:relaxmate/features/auth/ui/check_email_screen.dart';
import 'package:relaxmate/features/auth/ui/forgot_password_screen.dart';
import 'package:relaxmate/features/auth/ui/login_screen.dart';
import 'package:relaxmate/features/auth/ui/register_screen.dart';
import 'package:relaxmate/features/auth/ui/session_error_screen.dart';
import 'package:relaxmate/features/chat/ui/chat_screen.dart';
import 'package:relaxmate/features/startup/ui/splash_view.dart';

/// Memberi tahu router bahwa keadaan sesi berubah, agar `redirect` dijalankan ulang.
class _AuthRefreshNotifier extends ChangeNotifier {
  void ping() => notifyListeners();
}

/// Router aplikasi. Layar yang boleh tampil ditentukan oleh keadaan sesi lewat
/// [authRedirect]. Rute lain ditambahkan pada task fiturnya masing-masing.
final Provider<GoRouter> routerProvider = Provider<GoRouter>((ref) {
  final refresh = _AuthRefreshNotifier();
  ref.listen<AuthState>(
    authControllerProvider,
    (previous, next) => refresh.ping(),
  );

  final router = GoRouter(
    initialLocation: AppRoutes.chat,
    refreshListenable: refresh,
    redirect: (context, state) => authRedirect(
      ref.read(authControllerProvider),
      state.matchedLocation,
    ),
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.restoring,
        builder: (context, state) => const SplashView(),
      ),
      GoRoute(
        path: AppRoutes.sessionError,
        builder: (context, state) => const SessionErrorScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.checkEmail,
        builder: (context, state) => const CheckEmailScreen(),
      ),
      GoRoute(
        path: AppRoutes.chat,
        builder: (context, state) => const ChatScreen(),
      ),
    ],
  );

  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
});
