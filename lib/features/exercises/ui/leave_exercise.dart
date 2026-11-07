import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:relaxmate/core/router/app_routes.dart';

/// Keluar dari layar latihan: kembali ke layar sebelumnya (chat atau daftar latihan), atau ke
/// chat bila layar latihan dibuka langsung tanpa tumpukan layar.
void leaveExercise(BuildContext context) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go(AppRoutes.chat);
  }
}
