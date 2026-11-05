import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:relaxmate/core/router/app_routes.dart';
import 'package:relaxmate/features/chat/ui/chat_screen.dart';

/// Router aplikasi. Rute lain ditambahkan pada task fiturnya masing-masing.
final Provider<GoRouter> routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: AppRoutes.chat,
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.chat,
        builder: (context, state) => const ChatScreen(),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
