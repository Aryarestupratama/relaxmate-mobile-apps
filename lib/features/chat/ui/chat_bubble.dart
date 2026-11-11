import 'package:flutter/material.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_radius.dart';
import 'package:relaxmate/core/theme/rb_size.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/features/chat/data/chat_message.dart';

/// CMP-M02: gelembung pesan. Pengguna rata kanan (`softLavender`), RelaxMate rata kiri
/// (`surfaceAlt`). Balasan Crisis Response memakai warna krisis (`crisisBg`/`crisisText`)
/// dan tidak mengandalkan warna saja: banner dan teks tetap menyertainya. Isi ditampilkan
/// sebagai teks biasa. [announce] membuat pembaca layar mengumumkan pesan baru dengan sopan.
class ChatBubble extends StatelessWidget {
  const ChatBubble({
    required this.message,
    this.announce = false,
    this.fullWidth = false,
    super.key,
  });

  final ChatMessage message;
  final bool announce;

  /// Memenuhi lebar yang tersedia (tampilan maskot); bawaan dibatasi 80% lebar layar.
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;
    final isUser = message.role == ChatRole.user;
    const radius = Radius.circular(RbRadius.bubble);
    const tail = Radius.circular(RbRadius.bubbleTail);
    final maxWidth = fullWidth
        ? double.infinity
        : MediaQuery.sizeOf(context).width * RbSize.bubbleMaxWidthFactor;
    final speaker = isUser ? AppTexts.chatYouSaid : AppTexts.chatMateSaid;
    final crisis = message.isCrisis && !isUser;
    final background = isUser
        ? colors.softLavender
        : (crisis ? colors.crisisBg : colors.surfaceAlt);
    final foreground = crisis ? colors.crisisText : colors.text;

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
              width: fullWidth ? double.infinity : null,
              padding: EdgeInsets.symmetric(
                horizontal: space.md,
                vertical: space.sm,
              ),
              decoration: BoxDecoration(
                color: background,
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
                  Text(
                    message.content,
                    style: text.body.copyWith(color: foreground),
                  ),
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
