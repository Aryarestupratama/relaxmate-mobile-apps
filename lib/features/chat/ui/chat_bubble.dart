import 'package:flutter/material.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_motion.dart';
import 'package:relaxmate/core/theme/rb_radius.dart';
import 'package:relaxmate/core/theme/rb_shadow.dart';
import 'package:relaxmate/core/theme/rb_size.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/features/chat/data/chat_message.dart';
import 'package:relaxmate/features/chat/ui/typewriter_text.dart';
import 'package:relaxmate/shared/widgets/mate_avatar.dart';
import 'package:relaxmate/shared/widgets/mate_avatar_size.dart';

/// CMP-M02: gelembung pesan. Pengguna rata kanan, RelaxMate rata kiri. Balasan Crisis
/// Response memakai warna krisis (`crisisBg`/`crisisText`) dan tidak mengandalkan warna saja:
/// banner dan teks tetap menyertainya. Isi ditampilkan sebagai teks biasa. [announce]
/// membuat pembaca layar mengumumkan pesan baru dengan sopan.
///
/// Dua gaya. Bawaan (tampilan maskot, riwayat): pengguna `softLavender`, RelaxMate
/// `surfaceAlt`. [conversation] (tampilan obrolan, TASK-M073 bagian 7): gelembung pengguna bergradien
/// lavender, gelembung RelaxMate putih berbayang dengan avatar kecil dan nama "RelaxMate"
/// (seperti profil di WhatsApp; pengguna tanpa profil), jam di pojok kanan bawah, dan pesan
/// yang masih tertunda sedikit pudar. Bila [typewriter] aktif, teks balasan "diketik" lalu
/// memanggil [onTyped].
class ChatBubble extends StatelessWidget {
  const ChatBubble({
    required this.message,
    this.announce = false,
    this.fullWidth = false,
    this.conversation = false,
    this.typewriter = false,
    this.onTyped,
    super.key,
  });

  final ChatMessage message;
  final bool announce;

  /// Memenuhi lebar yang tersedia (tampilan maskot); bawaan dibatasi 80% lebar layar.
  final bool fullWidth;

  /// Gaya tampilan obrolan (avatar, nama, bayangan, gradien).
  final bool conversation;

  /// Teks balasan RelaxMate muncul seperti diketik (hanya berlaku di gaya [conversation]).
  final bool typewriter;
  final VoidCallback? onTyped;

  /// Seberapa kuat `brandSoft` dicampur ke `softLavender` di ujung gradien gelembung pengguna.
  static const double _userGradientStrength = 0.55;

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;
    final isUser = message.role == ChatRole.user;
    const radius = Radius.circular(RbRadius.bubble);
    const tail = Radius.circular(RbRadius.bubbleTail);
    final width = MediaQuery.sizeOf(context).width;
    final maxWidth =
        fullWidth ? double.infinity : width * RbSize.bubbleMaxWidthFactor;
    final speaker = isUser ? AppTexts.chatYouSaid : AppTexts.chatMateSaid;
    final crisis = message.isCrisis && !isUser;
    final foreground = crisis ? colors.crisisText : colors.text;
    final bodyStyle = text.body.copyWith(color: foreground);

    final BoxDecoration decoration;
    if (conversation) {
      decoration = BoxDecoration(
        color: isUser ? null : (crisis ? colors.crisisBg : colors.card),
        gradient: isUser
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  colors.softLavender,
                  Color.alphaBlend(
                    colors.brandSoft.withValues(alpha: _userGradientStrength),
                    colors.softLavender,
                  ),
                ],
              )
            : null,
        borderRadius: BorderRadius.only(
          topLeft: radius,
          topRight: radius,
          bottomLeft: isUser ? radius : tail,
          bottomRight: isUser ? tail : radius,
        ),
        border: crisis
            ? Border.all(color: colors.crisisText.withValues(alpha: 0.25))
            : null,
        boxShadow: RbShadow.card(colors),
      );
    } else {
      decoration = BoxDecoration(
        color: isUser
            ? colors.softLavender
            : (crisis ? colors.crisisBg : colors.surfaceAlt),
        borderRadius: BorderRadius.only(
          topLeft: radius,
          topRight: radius,
          bottomLeft: isUser ? radius : tail,
          bottomRight: isUser ? tail : radius,
        ),
      );
    }

    final Widget content = conversation
        ? IntrinsicWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (typewriter && !isUser)
                  TypewriterText(
                    text: message.content,
                    style: bodyStyle,
                    onDone: onTyped,
                  )
                else
                  Text(message.content, style: bodyStyle),
                if (message.time.isNotEmpty) ...<Widget>[
                  SizedBox(height: space.xxs),
                  Text(
                    message.time,
                    textAlign: TextAlign.right,
                    style: text.caption.copyWith(color: colors.textMuted),
                  ),
                ],
              ],
            ),
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(message.content, style: bodyStyle),
              if (message.time.isNotEmpty) ...<Widget>[
                SizedBox(height: space.xxs),
                Text(
                  message.time,
                  style: text.caption.copyWith(color: colors.textMuted),
                ),
              ],
            ],
          );

    final bubble = AnimatedOpacity(
      opacity: message.isPending ? 0.7 : 1,
      duration: RbMotion.feedback,
      child: Container(
        width: fullWidth ? double.infinity : null,
        padding: EdgeInsets.symmetric(
          horizontal: space.md,
          vertical: space.sm,
        ),
        decoration: decoration,
        child: content,
      ),
    );

    final Widget body;
    if (conversation && !isUser) {
      body = ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: width * RbSize.bubbleProfileMaxWidthFactor,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            const MateAvatar(size: MateAvatarSize.tiny),
            SizedBox(width: space.xs),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                      left: space.xxs,
                      bottom: space.xxs,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          AppTexts.appName,
                          style: text.caption.copyWith(
                            color: colors.textSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: space.xxs),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: space.xxs + 2),
                          decoration: BoxDecoration(
                            color: colors.softLavender,
                            borderRadius: RbRadius.pillBorder,
                          ),
                          child: Text(AppTexts.aiBadge, style: text.caption),
                        ),
                      ],
                    ),
                  ),
                  bubble,
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      body = ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: bubble,
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: space.xxs),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Semantics(
          container: true,
          liveRegion: announce,
          excludeSemantics: true,
          label: '$speaker: ${message.content}',
          child: body,
        ),
      ),
    );
  }
}
