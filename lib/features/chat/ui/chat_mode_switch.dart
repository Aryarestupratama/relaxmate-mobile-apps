import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_radius.dart';
import 'package:relaxmate/core/theme/rb_shadow.dart';
import 'package:relaxmate/core/theme/rb_size.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/features/settings/data/chat_view_mode.dart';

/// CMP-M46: pengalih tampilan chat di bilah atas. Pil berisi ikon dan nama tampilan yang
/// sedang dipakai plus panah ke bawah, supaya pengguna tahu bahwa tampilan bisa diganti;
/// diketuk membuka menu kecil berisi dua pilihan (Maskot, Obrolan) dengan yang aktif
/// ditandai. Bila teks sistem besar, nama disembunyikan dan tersisa ikon dan panah.
class ChatModeSwitch extends StatelessWidget {
  const ChatModeSwitch({
    required this.mode,
    required this.onChanged,
    super.key,
  });

  final ChatViewMode mode;
  final ValueChanged<ChatViewMode> onChanged;

  static String _label(ChatViewMode mode) => switch (mode) {
        ChatViewMode.mascot => AppTexts.chatModeMascot,
        ChatViewMode.conversation => AppTexts.chatModeConversation,
      };

  static IconData _icon(ChatViewMode mode) => switch (mode) {
        ChatViewMode.mascot => LucideIcons.smile,
        ChatViewMode.conversation => LucideIcons.messageCircle,
      };

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;
    final showLabel =
        MediaQuery.textScalerOf(context).scale(1) <= RbSize.homeRowMaxTextScale;

    return PopupMenuButton<ChatViewMode>(
        // Tooltip ikut dibaca pembaca layar sebagai label tombol.
        tooltip: AppTexts.chatModeSemantics(_label(mode)),
        position: PopupMenuPosition.under,
        offset: Offset(0, space.xxs),
        shape: const RoundedRectangleBorder(
          borderRadius: RbRadius.cardBorder,
        ),
        color: colors.card,
        elevation: 6,
        onSelected: (selected) {
          if (selected != mode) {
            onChanged(selected);
          }
        },
        itemBuilder: (context) => <PopupMenuEntry<ChatViewMode>>[
          for (final option in ChatViewMode.values)
            PopupMenuItem<ChatViewMode>(
              value: option,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    _icon(option),
                    size: RbSize.modeSwitchIcon,
                    color:
                        option == mode ? colors.primary : colors.textSecondary,
                  ),
                  SizedBox(width: space.sm),
                  Text(
                    _label(option),
                    style: text.body.copyWith(
                      fontWeight:
                          option == mode ? FontWeight.w800 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
        child: ExcludeSemantics(
          child: Container(
          height: RbSize.modeSwitchHeight,
          padding: EdgeInsets.symmetric(horizontal: space.sm),
          decoration: BoxDecoration(
            color: colors.card.withValues(alpha: 0.9),
            borderRadius: RbRadius.pillBorder,
            border: Border.all(color: colors.border),
            boxShadow: RbShadow.card(colors),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                _icon(mode),
                size: RbSize.modeSwitchIcon,
                color: colors.primary,
              ),
              if (showLabel) ...<Widget>[
                SizedBox(width: space.xs),
                Text(
                  _label(mode),
                  style: text.small.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
              SizedBox(width: space.xxs),
              Icon(
                LucideIcons.chevronDown,
                size: RbSize.modeSwitchIcon,
                color: colors.textSecondary,
              ),
            ],
          ),
        ),
      ),
      ),
    )
  }
}
