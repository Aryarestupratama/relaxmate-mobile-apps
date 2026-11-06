import 'package:flutter/material.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_radius.dart';
import 'package:relaxmate/core/theme/rb_size.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';

/// CMP-M13: kartu galat ramah. Latar `surfaceAlt`, ikon `danger`, pesan, dan tombol
/// "Coba lagi" bila [onRetry] diisi. Tidak memakai warna krisis agar merah krisis
/// hanya untuk keselamatan. [message] harus aman ditampilkan (tanpa detail teknis).
class ErrorAlert extends StatelessWidget {
  const ErrorAlert({required this.message, this.onRetry, super.key});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;

    return Semantics(
      container: true,
      liveRegion: true,
      child: Container(
        padding: EdgeInsets.all(space.md),
        decoration: BoxDecoration(
          color: colors.surfaceAlt,
          borderRadius: RbRadius.cardBorder,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ExcludeSemantics(
                  child: Icon(
                    Icons.error_outline,
                    color: colors.danger,
                    size: RbSize.icon,
                  ),
                ),
                SizedBox(width: space.sm),
                Expanded(child: Text(message, style: text.small)),
              ],
            ),
            if (onRetry != null) ...<Widget>[
              SizedBox(height: space.xs),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onRetry,
                  child: const Text(AppTexts.retry),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
