import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:relaxmate/core/config/app_constants.dart';
import 'package:relaxmate/core/theme/rb_motion.dart';
import 'package:relaxmate/core/theme/rb_size.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/features/journal/ui/journal_line_height.dart';
import 'package:relaxmate/features/journal/ui/journal_rules_painter.dart';

/// Animasi menulis di buku (FR-M032, TASK-M079): teks muncul dari kiri ke kanan, baris demi
/// baris, di atas garis buku, dengan pena kecil mengikuti ujung tulisan. Lamanya sebanding
/// panjang teks, antara [RbMotion.inkMin] dan [RbMotion.inkMax]. [onWritten] dipanggil sekali
/// saat selesai. Bila gerak dikurangi (`MediaQuery.disableAnimations`, RULE-M055/M075) teks
/// langsung utuh dan [onWritten] dipanggil segera. Pembaca layar mendapat teks lengkap sejak
/// awal. Teks hanya dipegang di memori (RULE-M074).
class InkWriteText extends StatefulWidget {
  const InkWriteText({required this.text, required this.onWritten, super.key});

  final String text;
  final VoidCallback onWritten;

  @override
  State<InkWriteText> createState() => _InkWriteTextState();
}

class _InkWriteTextState extends State<InkWriteText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progress = AnimationController(vsync: this);
  bool _started = false;
  TextPainter? _painter;
  double? _paintedWidth;
  TextScaler? _paintedScaler;
  TextStyle? _paintedStyle;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) {
      return;
    }
    _started = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _progress.value = 1;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.onWritten();
        }
      });
      return;
    }
    final raw = RbMotion.inkPerChar * widget.text.length;
    _progress.duration = raw < RbMotion.inkMin
        ? RbMotion.inkMin
        : (raw > RbMotion.inkMax ? RbMotion.inkMax : raw);
    unawaited(
      _progress.forward().whenComplete(() {
        if (mounted) {
          widget.onWritten();
        }
      }),
    );
  }

  @override
  void dispose() {
    _progress.dispose();
    _painter?.dispose();
    super.dispose();
  }

  /// Satu `TextPainter` untuk seluruh teks, disusun ulang hanya bila lebar, skala teks, atau
  /// gaya berubah; dipakai untuk ukuran, posisi pena, dan gambar.
  TextPainter _layout(double width, TextScaler scaler, TextStyle style) {
    final cached = _painter;
    if (cached != null &&
        _paintedWidth == width &&
        _paintedScaler == scaler &&
        _paintedStyle == style) {
      return cached;
    }
    cached?.dispose();
    final painter = TextPainter(
      text: TextSpan(text: widget.text, style: style),
      textDirection: TextDirection.ltr,
      textScaler: scaler,
      strutStyle: journalStrut,
    )..layout(maxWidth: width);
    _painter = painter;
    _paintedWidth = width;
    _paintedScaler = scaler;
    _paintedStyle = style;
    return painter;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final style = context.rbText.journal;
    final scaler = MediaQuery.textScalerOf(context);
    final lineHeight = journalLineHeight(context);

    return Semantics(
      container: true,
      label: widget.text,
      child: ExcludeSemantics(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final painter = _layout(constraints.maxWidth, scaler, style);
            final height = math.max(
              painter.height,
              lineHeight * AppConstants.journalMinLines,
            );
            return SizedBox(
              width: constraints.maxWidth,
              height: height,
              child: AnimatedBuilder(
                animation: _progress,
                builder: (context, _) {
                  final shown = (_progress.value * widget.text.length).floor();
                  final caret = painter.getOffsetForCaret(
                    TextPosition(offset: shown),
                    Rect.zero,
                  );
                  final done = _progress.isCompleted;
                  return Stack(
                    clipBehavior: Clip.none,
                    children: <Widget>[
                      Positioned.fill(
                        child: CustomPaint(
                          painter: JournalRulesPainter(
                            lineHeight: lineHeight,
                            color: colors.border,
                          ),
                          foregroundPainter: _InkPainter(
                            painter: painter,
                            caret: caret,
                            lineHeight: lineHeight,
                            done: done,
                          ),
                        ),
                      ),
                      if (!done)
                        Positioned(
                          left: caret.dx,
                          top: caret.dy + lineHeight - RbSize.journalPenIcon,
                          child: Icon(
                            Icons.edit,
                            size: RbSize.journalPenIcon,
                            color: colors.primary,
                          ),
                        ),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Menggambar teks utuh, dipangkas sampai ujung tulisan: baris di atas baris aktif penuh,
/// baris aktif sampai posisi pena.
class _InkPainter extends CustomPainter {
  const _InkPainter({
    required this.painter,
    required this.caret,
    required this.lineHeight,
    required this.done,
  });

  final TextPainter painter;
  final Offset caret;
  final double lineHeight;
  final bool done;

  @override
  void paint(Canvas canvas, Size size) {
    if (done) {
      painter.paint(canvas, Offset.zero);
      return;
    }
    final reveal = Path()
      ..addRect(Rect.fromLTRB(0, 0, size.width, caret.dy))
      ..addRect(Rect.fromLTRB(0, caret.dy, caret.dx, caret.dy + lineHeight));
    canvas
      ..save()
      ..clipPath(reveal);
    painter.paint(canvas, Offset.zero);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_InkPainter oldDelegate) =>
      oldDelegate.painter != painter ||
      oldDelegate.caret != caret ||
      oldDelegate.lineHeight != lineHeight ||
      oldDelegate.done != done;
}
