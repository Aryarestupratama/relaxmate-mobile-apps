import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_motion.dart';
import 'package:relaxmate/core/theme/rb_shadow.dart';
import 'package:relaxmate/core/theme/rb_size.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';

/// CMP-M06 (tanpa mikrofon, Fase 2): kolom teks 1 sampai 4 baris dan tombol kirim. Kolom
/// tetap bisa diketik saat [sendEnabled] false (pesan sebelumnya masih diproses) supaya
/// keyboard tidak tertutup. Panjang dibatasi [maxLength] dari server.
///
/// Tampil sebagai kapsul putih berbayang (TASK-M073 bagian 7). Bingkainya memakai `inputBorder` (kontras
/// 3:1) dan menebal jadi `primary` saat kolom difokuskan; tombol kirim bulat membesar lembut
/// begitu ada teks yang bisa dikirim.
class ChatInputBar extends StatefulWidget {
  const ChatInputBar({
    required this.controller,
    required this.sendEnabled,
    required this.maxLength,
    required this.onSend,
    super.key,
  });

  final TextEditingController controller;
  final bool sendEnabled;
  final int maxLength;
  final VoidCallback onSend;

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final FocusNode _focus = FocusNode();

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final space = context.rbSpace;
    const pillRadius =
        BorderRadius.all(Radius.circular(RbSize.chatInputRadius));

    return Padding(
      padding: EdgeInsets.fromLTRB(space.md, space.xs, space.md, space.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Expanded(
            child: ListenableBuilder(
              listenable: _focus,
              builder: (context, child) => AnimatedContainer(
                duration: RbMotion.feedback,
                decoration: BoxDecoration(
                  color: colors.card,
                  borderRadius: pillRadius,
                  border: Border.all(
                    color:
                        _focus.hasFocus ? colors.primary : colors.inputBorder,
                    width: _focus.hasFocus ? 2 : 1,
                  ),
                  boxShadow: RbShadow.card(colors),
                ),
                child: child,
              ),
              child: TextField(
                controller: widget.controller,
                focusNode: _focus,
                minLines: 1,
                maxLines: 4,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                // Isi chat bersifat pribadi: keyboard tidak boleh mempelajarinya (RULE-M040).
                enableIMEPersonalizedLearning: false,
                inputFormatters: <TextInputFormatter>[
                  LengthLimitingTextInputFormatter(widget.maxLength),
                ],
                decoration: InputDecoration(
                  hintText: AppTexts.chatInputHint,
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: space.md,
                    vertical: space.sm,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: space.xs),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: widget.controller,
            builder: (context, value, _) {
              final canSend =
                  widget.sendEnabled && value.text.trim().isNotEmpty;
              return AnimatedScale(
                scale: canSend ? 1 : 0.92,
                duration: RbMotion.feedback,
                curve: RbMotion.curve,
                child: IconButton.filled(
                  onPressed: canSend ? widget.onSend : null,
                  tooltip: AppTexts.chatSend,
                  style: IconButton.styleFrom(
                    minimumSize: const Size.square(RbSize.minTouch),
                  ),
                  icon: const Icon(LucideIcons.send),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
