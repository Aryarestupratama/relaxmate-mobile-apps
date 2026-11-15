import 'package:flutter/material.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_radius.dart';
import 'package:relaxmate/core/theme/rb_shadow.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/core/time/wib.dart';

/// CMP-M40: penanda tanggal di atas percakapan (TASK-M073 bagian 7), kapsul putih kecil di tengah:
/// "Hari ini · Minggu, 15 November 2026" (WIB, dari jam perangkat). Percakapan chat adalah
/// aliran hari ini, jadi satu penanda cukup di bagian paling atas.
class ChatDateChip extends StatelessWidget {
  const ChatDateChip({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;

    return Center(
      child: Padding(
        padding: EdgeInsets.only(top: space.xs, bottom: space.sm),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: RbRadius.pillBorder,
            boxShadow: RbShadow.card(colors),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: space.sm,
              vertical: space.xxs + 2,
            ),
            child: Text(
              AppTexts.chatDateLabel(fullDateLabel(wibToday())),
              textAlign: TextAlign.center,
              style: text.caption.copyWith(
                color: colors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
