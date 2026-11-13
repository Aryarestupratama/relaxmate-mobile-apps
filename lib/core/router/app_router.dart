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
import 'package:relaxmate/features/consent/ui/consent_gate.dart';
import 'package:relaxmate/features/crisis/ui/crisis_contacts_screen.dart';
import 'package:relaxmate/features/exercises/ui/breathing_screen.dart';
import 'package:relaxmate/features/exercises/ui/exercises_screen.dart';
import 'package:relaxmate/features/exercises/ui/grounding_screen.dart';
import 'package:relaxmate/features/history/ui/conversation_screen.dart';
import 'package:relaxmate/features/history/ui/history_screen.dart';
import 'package:relaxmate/features/mascot/ui/companion_screen.dart';
import 'package:relaxmate/features/overlay/ui/overlay_settings_screen.dart';
import 'package:relaxmate/features/settings/ui/about_screen.dart';
import 'package:relaxmate/features/settings/ui/delete_account_screen.dart';
import 'package:relaxmate/features/settings/ui/settings_screen.dart';
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
        path: AppRoutes.crisisContacts,
        builder: (context, state) => const CrisisContactsScreen(),
      ),
      GoRoute(
        path: AppRoutes.chat,
        builder: (context, state) => const ConsentGate(child: ChatScreen()),
      ),
      // Latihan lokal: perlu masuk, tanpa ConsentGate (tanpa AI, FR-M014).
      GoRoute(
        path: AppRoutes.exercises,
        builder: (context, state) => const ExercisesScreen(),
      ),
      GoRoute(
        path: AppRoutes.breathing,
        builder: (context, state) => const BreathingScreen(),
      ),
      GoRoute(
        path: AppRoutes.grounding,
        builder: (context, state) => const GroundingScreen(),
      ),
      // Pengaturan dan Hapus akun: di luar ConsentGate agar yang menolak consent tetap bisa
      // keluar atau menghapus akun (OQ-MA12).
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.about,
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: AppRoutes.overlaySettings,
        builder: (context, state) => const OverlaySettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.deleteAccount,
        builder: (context, state) => const DeleteAccountScreen(),
      ),
      // Temani saja: perlu masuk, tanpa ConsentGate (tanpa AI, FR-M015).
      GoRoute(
        path: AppRoutes.companion,
        builder: (context, state) => const CompanionScreen(),
      ),
      GoRoute(
        path: AppRoutes.history,
        builder: (context, state) => const ConsentGate(child: HistoryScreen()),
        routes: <RouteBase>[
          GoRoute(
            path: ':id',
            builder: (context, state) => ConsentGate(
              child: ConversationScreen(
                conversationId: state.pathParameters['id'] ?? '',
              ),
            ),
          ),
        ],
      ),
    ],
  );

  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
});
