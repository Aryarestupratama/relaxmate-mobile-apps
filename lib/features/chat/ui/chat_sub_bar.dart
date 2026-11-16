import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:relaxmate/core/router/app_routes.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_radius.dart';
import 'package:relaxmate/core/theme/rb_size.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/features/chat/ui/chat_mode_switch.dart';
import 'package:relaxmate/features/settings/data/chat_view_mode.dart';

/// CMP-M57: sub-baris Ngobrol tepat di bawah bilah atas: pengalih tampilan (`ChatModeSwitch`)
/// di kiri dan tombol Riwayat di kanan. Menggantikan pengalih, menu tiga titik, dan nama
/// RelaxMate beserta tagline yang dulu berdesakan di bilah atas (2026-11-15). Temani saja
/// pindah ke tab Latihan dan Pengaturan ke navigasi bawah. Pada teks sangat besar tombol
/// Riwayat tinggal ikon.
class ChatSubBar extends StatelessWidget {
  const ChatSubBar({
    required this.mode,
    required this.onModeChanged,
    super.key,
  });

  final ChatViewMode mode;
  final ValueChanged<ChatViewMode> onModeChanged;

  /// Lebar minimum sub-baris agar tombol Riwayat menampilkan teks di samping ikon.
  static const double _labelMinWidth = 320;

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;
    final showLabel =
        MediaQuery.textScalerOf(context).scale(1) <= RbSize.homeRowMaxTextScale;

    return Padding(
      padding: EdgeInsets.fromLTRB(space.md, space.xxs, space.md, space.xxs),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Layar sempit: tombol Riwayat tinggal ikon supaya pil pengalih tidak terjepit.
          final roomy = showLabel && constraints.maxWidth >= _labelMinWidth;
          return Row(
            children: <Widget>[
              // Pil mendapat seluruh sisa lebar di kiri Riwayat; `FittedBox` mengecilkannya
              // bila masih tidak muat, jadi segmen aktif tidak pernah keluar dari pil.
              Expanded(
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerStart,
                    child: ChatModeSwitch(mode: mode, onChanged: onModeChanged),
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () => context.push<void>(AppRoutes.history),
                icon: const Icon(Icons.history_rounded, size: RbSize.icon),
                label: roomy
                    ? Text(AppTexts.historyTooltip, style: text.button)
                    : const SizedBox.shrink(),
                style: TextButton.styleFrom(
                  foregroundColor: colors.primary,
                  minimumSize: const Size(RbSize.minTouch, RbSize.minTouch),
                  padding: EdgeInsets.symmetric(horizontal: space.sm),
                  shape: const RoundedRectangleBorder(
                    borderRadius: RbRadius.pillBorder,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
