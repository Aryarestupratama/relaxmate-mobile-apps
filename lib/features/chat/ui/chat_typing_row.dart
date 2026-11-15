import 'package:flutter/material.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_radius.dart';
import 'package:relaxmate/core/theme/rb_shadow.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/features/chat/ui/typing_indicator.dart';
import 'package:relaxmate/shared/widgets/mate_avatar.dart';
import 'package:relaxmate/shared/widgets/mate_avatar_size.dart';
import 'package:relaxmate/shared/widgets/rb_entrance.dart';

/// Penanda "RelaxMate sedang menulis" pada tampilan obrolan (TASK-M073 bagian 7): avatar kecil di kiri
/// dan gelembung putih berbayang berisi tiga titik, sama bentuknya dengan gelembung balasan
/// supaya peralihan ke teks terasa menyambung. Muncul dengan gerak masuk lembut. Teks
/// "RelaxMate sedang menulis" untuk pembaca layar.
class ChatTypingRow extends StatelessWidget {
  const ChatTypingRow({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final space = context.rbSpace;
    const radius = Radius.circular(RbRadius.bubble);
    const tail = Radius.circular(RbRadius.bubbleTail);

    return RbEntrance(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: space.xxs),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Semantics(
            container: true,
            liveRegion: true,
            label: AppTexts.chatTyping,
            child: ExcludeSemantics(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  const MateAvatar(size: MateAvatarSize.tiny),
                  SizedBox(width: space.xs),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: space.md,
                      vertical: space.sm + space.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: colors.card,
                      borderRadius: const BorderRadius.only(
                        topLeft: radius,
                        topRight: radius,
                        bottomLeft: tail,
                        bottomRight: radius,
                      ),
                      boxShadow: RbShadow.card(colors),
                    ),
                    child: const TypingDots(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
