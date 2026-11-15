import 'package:flutter/material.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_radius.dart';
import 'package:relaxmate/core/theme/rb_shadow.dart';
import 'package:relaxmate/core/theme/rb_size.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/features/chat/data/chat_suggestion.dart';
import 'package:relaxmate/features/chat/ui/suggestion_chips.dart';
import 'package:relaxmate/features/chat/ui/typewriter_text.dart';
import 'package:relaxmate/features/chat/ui/typing_indicator.dart';

/// CMP-M44: gelembung balasan RelaxMate di samping kanan kepala maskot (tampilan maskot chat).
/// Putih berbayang dengan ekor kecil yang menunjuk ke kepala. Tiga isi: tiga titik selagi
/// balasan ditulis ([typing]), teks yang "diketik" ([typewriter], balasan baru), atau teks
/// biasa. Balasan krisis ([crisis]) memakai warna krisis dan tidak diketik. Teks panjang
/// digulir di dalam gelembung (tinggi maksimum [maxHeight]); selama mengetik gulirannya
/// mengikuti teks sampai pengguna menggulir sendiri. Saran tindakan ([suggestion]) tampil di
/// kaki gelembung setelah balasan selesai diketik. Pembaca layar membaca balasan utuh sejak
/// awal, bukan huruf demi huruf.
class MascotReplyBubble extends StatefulWidget {
  const MascotReplyBubble({
    required this.maxHeight,
    this.text,
    this.typing = false,
    this.typewriter = false,
    this.crisis = false,
    this.onTyped,
    this.suggestion,
    this.onDismissSuggestion,
    super.key,
  });

  /// Isi balasan; diabaikan bila [typing].
  final String? text;
  final bool typing;
  final bool typewriter;
  final bool crisis;
  final VoidCallback? onTyped;
  final ChatSuggestion? suggestion;
  final VoidCallback? onDismissSuggestion;
  final double maxHeight;

  @override
  State<MascotReplyBubble> createState() => _MascotReplyBubbleState();
}

class _MascotReplyBubbleState extends State<MascotReplyBubble> {
  final ScrollController _scroll = ScrollController();
  bool _userScrolled = false;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  /// Menggulir sebanding dengan kemajuan mengetik, kecuali pengguna sudah menggulir sendiri.
  void _follow(double progress) {
    if (_userScrolled || !_scroll.hasClients) {
      return;
    }
    _scroll.jumpTo(_scroll.position.maxScrollExtent * progress);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;
    final fill = widget.crisis ? colors.crisisBg : colors.card;
    final body = text.body.copyWith(
      color: widget.crisis ? colors.crisisText : colors.text,
      height: 1.45,
    );
    final content = widget.text ?? '';
    final suggestion = widget.suggestion;

    final Widget message;
    if (widget.typing) {
      message = const Padding(
        padding: EdgeInsets.symmetric(vertical: 6),
        child: TypingDots(),
      );
    } else if (widget.typewriter) {
      message = TypewriterText(
        text: content,
        style: body,
        onDone: widget.onTyped,
        onProgress: _follow,
      );
    } else {
      message = Text(content, style: body);
    }

    return Semantics(
      container: true,
      liveRegion: true,
      excludeSemantics: true,
      label: widget.typing
          ? AppTexts.chatTyping
          : '${AppTexts.chatMateSaid}: $content',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: RbSize.replyTailTop),
            child: CustomPaint(
              size: const Size(RbSize.replyTailWidth, RbSize.replyTailHeight),
              painter: _TailPainter(fill),
            ),
          ),
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: widget.maxHeight),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: fill,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(RbRadius.bubbleTail),
                    topRight: Radius.circular(RbSize.mascotReplyRadius),
                    bottomLeft: Radius.circular(RbSize.mascotReplyRadius),
                    bottomRight: Radius.circular(RbSize.mascotReplyRadius),
                  ),
                  boxShadow: RbShadow.panel(colors),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: space.md,
                    vertical: space.sm,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Flexible(
                        child: NotificationListener<UserScrollNotification>(
                          onNotification: (notification) {
                            _userScrolled = true;
                            return false;
                          },
                          child: SingleChildScrollView(
                            controller: _scroll,
                            child: message,
                          ),
                        ),
                      ),
                      if (suggestion != null && !widget.typing)
                        SuggestionChips(
                          suggestion: suggestion,
                          onDismiss: widget.onDismissSuggestion ?? () {},
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Segitiga kecil di kiri gelembung yang runcingnya menghadap kepala maskot.
class _TailPainter extends CustomPainter {
  const _TailPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width, 0)
      ..lineTo(0, size.height / 2)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_TailPainter oldDelegate) => oldDelegate.color != color;
}
