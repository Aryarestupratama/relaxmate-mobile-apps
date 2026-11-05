import 'package:flutter/material.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_theme.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';

/// Ditampilkan bila konfigurasi build tidak valid (mis. `API_BASE_URL` kosong).
/// Tanpa detail teknis (RULE-M035).
class ConfigErrorApp extends StatelessWidget {
  const ConfigErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppTexts.appName,
      debugShowCheckedModeBanner: false,
      theme: RbTheme.light(),
      home: const _ConfigErrorBody(),
    );
  }
}

class _ConfigErrorBody extends StatelessWidget {
  const _ConfigErrorBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(context.rbSpace.lg),
            child: Text(
              AppTexts.configError,
              textAlign: TextAlign.center,
              style: context.rbText.body,
            ),
          ),
        ),
      ),
    );
  }
}
