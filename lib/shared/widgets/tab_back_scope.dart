import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:relaxmate/core/router/app_routes.dart';

/// Tombol kembali sistem di layar tab selain Beranda membawa ke Beranda, bukan menutup aplikasi
/// (tab dibuka dengan `go`, jadi tumpukan layar hanya satu). Bila layar dibuka dengan `push`
/// (ada layar di bawahnya), kembali berjalan seperti biasa.
class TabBackScope extends StatelessWidget {
  const TabBackScope({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.go(AppRoutes.home);
        }
      },
      child: child,
    );
  }
}
