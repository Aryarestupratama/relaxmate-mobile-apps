import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';

/// CMP-M06 (tanpa mikrofon, Fase 2): kolom teks 1 sampai 4 baris dan tombol kirim. Kolom
/// tetap bisa diketik saat [sendEnabled] false (pesan sebelumnya masih diproses) supaya
/// keyboard tidak tertutup. Panjang dibatasi [maxLength] dari server.
class ChatInputBar extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final space = context.rbSpace;

    return Padding(
      padding: EdgeInsets.fromLTRB(space.md, space.xs, space.xs, space.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: controller,
              minLines: 1,
              maxLines: 4,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              // Isi chat bersifat pribadi: keyboard tidak boleh mempelajarinya (RULE-M040).
              enableIMEPersonalizedLearning: false,
              inputFormatters: <TextInputFormatter>[
                LengthLimitingTextInputFormatter(maxLength),
              ],
              decoration:
                  const InputDecoration(hintText: AppTexts.chatInputHint),
            ),
          ),
          SizedBox(width: space.xs),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              final canSend = sendEnabled && value.text.trim().isNotEmpty;
              return IconButton.filled(
                onPressed: canSend ? onSend : null,
                tooltip: AppTexts.chatSend,
                icon: const Icon(LucideIcons.send),
              );
            },
          ),
        ],
      ),
    );
  }
}
