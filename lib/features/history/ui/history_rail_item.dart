import 'package:flutter/material.dart';
import 'package:relaxmate/core/theme/rb_size.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';

/// Jenis titik pada rel garis waktu Riwayat.
enum HistoryRailDot {
  /// Titik besar berisi navy: awal satu tanggal.
  date,

  /// Titik kecil lavender: satu percakapan di tanggal itu.
  entry,
}

/// CMP-M58: satu baris garis waktu Riwayat. Kolom rel di kiri memuat garis vertikal dan satu
/// titik; [child] mengisi sisanya. Garis menyambung antarbaris karena tiap baris
/// menggambarnya setinggi barisnya sendiri; baris pertama memulai garis dari titiknya dan
/// baris terakhir mengakhirinya di titiknya ([isFirst], [isLast]). Hanya dekorasi: rel tidak
/// punya semantik (RULE-M052, makna tanggal ada di teks).
class HistoryRailItem extends StatelessWidget {
  const HistoryRailItem({
    required this.dot,
    required this.child,
    this.isFirst = false,
    this.isLast = false,
    super.key,
  });

  final HistoryRailDot dot;
  final Widget child;
  final bool isFirst;
  final bool isLast;

  /// Tebal cincin pemisah titik dari garis.
  static const double _ringWidth = 2;

  /// Seberapa pekat garis rel dibanding `brandSoft`.
  static const double _lineStrength = 0.6;

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final isDate = dot == HistoryRailDot.date;
    final dotSize = isDate ? RbSize.historyDateDot : RbSize.historyEntryDot;
    final dotTop =
        isDate ? RbSize.historyDateDotTop : RbSize.historyEntryDotTop;
    final dotCenter = dotTop + dotSize / 2;
    final lineTop = isFirst ? dotCenter : 0.0;

    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Positioned(
          left: (RbSize.historyRailWidth - RbSize.historyRailLine) / 2,
          top: lineTop,
          bottom: isLast ? null : 0,
          height: isLast ? dotCenter - lineTop : null,
          width: RbSize.historyRailLine,
          child: ExcludeSemantics(
            child: ColoredBox(
              color: colors.brandSoft.withValues(alpha: _lineStrength),
            ),
          ),
        ),
        Positioned(
          left: (RbSize.historyRailWidth - dotSize) / 2,
          top: dotTop,
          width: dotSize,
          height: dotSize,
          child: ExcludeSemantics(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDate ? colors.primary : colors.brandSoft,
                border: Border.all(
                  color: isDate ? colors.softLavender : colors.card,
                  width: _ringWidth,
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsetsDirectional.only(start: RbSize.historyRailWidth),
          child: child,
        ),
      ],
    );
  }
}
