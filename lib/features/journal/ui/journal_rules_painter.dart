import 'package:flutter/widgets.dart';
import 'package:relaxmate/core/theme/rb_size.dart';

/// Garis buku: satu garis tipis di dasar tiap baris, dari atas sampai tinggi yang tersedia.
/// Dipakai di belakang kolom menulis dan di bawah teks yang sedang ditulis.
class JournalRulesPainter extends CustomPainter {
  const JournalRulesPainter({required this.lineHeight, required this.color});

  final double lineHeight;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (lineHeight <= 0) {
      return;
    }
    final paint = Paint()
      ..color = color
      ..strokeWidth = RbSize.journalRuleStroke;
    final drop = lineHeight * RbSize.journalRuleDrop;
    for (var bottom = lineHeight; bottom <= size.height; bottom += lineHeight) {
      final y = bottom - drop;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(JournalRulesPainter oldDelegate) =>
      oldDelegate.lineHeight != lineHeight || oldDelegate.color != color;
}
