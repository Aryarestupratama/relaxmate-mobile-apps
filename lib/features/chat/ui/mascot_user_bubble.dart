import 'package:flutter/material.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_motion.dart';
import 'package:relaxmate/core/theme/rb_shadow.dart';
import 'package:relaxmate/core/theme/rb_size.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/features/chat/data/chat_message.dart';

/// CMP-M45: pesan terakhir pengguna di tengah, tepat di bawah maskot (tampilan maskot chat).
/// Kapsul navy bergradien (`primary` ke `navHover`) dengan teks putih rata tengah, jadi
/// serasi dengan garis tepi gelap maskot dan jelas bedanya dari gelembung balasan yang
/// putih. Pesan panjang digulir di dalamnya (tinggi maksimum [RbSize.userBubbleMaxHeight]).
/// Pesan yang belum terkonfirmasi sedikit pudar.
class MascotUserBubble extends StatelessWidget {
  const MascotUserBubble({required this.message, super.key});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;
    final width = MediaQuery.sizeOf(context).width;

    return Semantics(
      container: true,
      excludeSemantics: true,
      label: '${AppTexts.chatYouSaid}: ${message.content}',
      child: AnimatedOpacity(
        opacity: message.isPending ? 0.7 : 1,
        duration: RbMotion.feedback,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: width * RbSize.userBubbleMaxWidthFactor,
            maxHeight: RbSize.userBubbleMaxHeight,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[colors.primary, colors.navHover],
              ),
              borderRadius: BorderRadius.circular(RbSize.mascotUserRadius),
              boxShadow: RbShadow.panel(colors),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(RbSize.mascotUserRadius),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: space.md,
                  vertical: space.sm,
                ),
                child: Text(
                  message.content,
                  textAlign: TextAlign.center,
                  style: text.body.copyWith(
                    color: colors.onPrimary,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
