import 'package:flutter/material.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_radius.dart';
import 'package:relaxmate/core/theme/rb_size.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/features/chat/data/chat_message.dart';

/// CMP-M02: gelembung pesan. Pengguna rata kanan (`softLavender`), RelaxMate rata kiri
/// (`surfaceAlt`). Isi ditampilkan sebagai teks biasa. [announce] membuat pembaca layar
/// mengumumkan pesan baru dengan sopan.
class ChatBubble extends StatelessWidget {
  const ChatBubble({required this.message, this.announce = false, super.key});

  final ChatMessage message;
  final bool announce;

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;
    final isUser = message.role == ChatRole.user;
    const radius = Radius.circular(RbRadius.bubble);
    const tail = Radius.circular(RbRadius.bubbleTail);
    final maxWidth =
        MediaQuery.sizeOf(context).width * RbSize.bubbleMaxWidthFactor;
    final speaker = isUser ? AppTexts.chatYouSaid : AppTexts.chatMateSaid;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: space.xxs),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Semantics(
            container: true,
            liveRegion: announce,
            excludeSemantics: true,
            label: '$speaker: ${message.content}',
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: space.md,
                vertical: space.sm,
              ),
              decoration: BoxDecoration(
                color: isUser ? colors.softLavender : colors.surfaceAlt,
                borderRadius: BorderRadius.only(
                  topLeft: radius,
                  topRight: radius,
                  bottomLeft: isUser ? radius : tail,
                  bottomRight: isUser ? tail : radius,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(message.content, style: text.body),
                  if (message.time.isNotEmpty) ...<Widget>[
                    SizedBox(height: space.xxs),
                    Text(
                      message.time,
                      style: text.caption.copyWith(color: colors.textMuted),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
