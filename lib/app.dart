import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:relaxmate/core/router/app_router.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_theme.dart';
import 'package:relaxmate/features/startup/ui/startup_gate.dart';

/// Akar aplikasi: tema token, Bahasa Indonesia, router, dan pemeriksaan versi awal.
class RelaxMateApp extends ConsumerWidget {
  const RelaxMateApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: AppTexts.appName,
      debugShowCheckedModeBanner: false,
      theme: RbTheme.light(),
      locale: const Locale('id'),
      supportedLocales: const <Locale>[Locale('id')],
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: ref.watch(routerProvider),
      builder: (context, child) => StartupGate(
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
