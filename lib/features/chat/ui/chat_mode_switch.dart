import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_size.dart';
import 'package:relaxmate/features/settings/data/chat_view_mode.dart';
import 'package:relaxmate/shared/widgets/pill_segments.dart';

/// CMP-M46: pengalih tampilan chat (Maskot atau Obrolan) berupa pil dua segmen yang selalu
/// terlihat di sub-baris Ngobrol (`ChatSubBar`), bukan menu tersembunyi (2026-11-15). Segmen
/// terpilih berwarna utama. Bila teks sistem besar, nama disembunyikan dan tersisa ikon;
/// pembaca layar tetap membacakan nama tampilan.
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
    final showLabel =
        MediaQuery.textScalerOf(context).scale(1) <= RbSize.homeRowMaxTextScale;

    return PillSegments<ChatViewMode>(
      expand: false,
      selected: mode,
      onChanged: (selected) {
        if (selected != mode) {
          onChanged(selected);
        }
      },
      segments: <PillSegment<ChatViewMode>>[
        for (final option in ChatViewMode.values)
          PillSegment<ChatViewMode>(
            value: option,
            icon: _icon(option),
            label: showLabel ? _label(option) : null,
            semanticLabel: _label(option),
          ),
      ],
    );
  }
}
