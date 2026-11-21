import 'package:flutter/widgets.dart';
import 'package:relaxmate/core/theme/rb_text.dart';

/// Tinggi satu baris tulisan buku harian pada skala teks pengguna saat ini. Kolom menulis
/// dan halaman baca memaksa tinggi baris yang sama (`StrutStyle`), jadi garis buku jatuh
/// tepat di bawah tiap baris.
double journalLineHeight(BuildContext context) =>
    MediaQuery.textScalerOf(context).scale(RbText.journalFontSize) *
    RbText.journalLineFactor;

/// Tinggi baris dipaksa sama untuk semua baris, termasuk baris kosong.
const StrutStyle journalStrut = StrutStyle(
  fontFamily: RbText.journalFontFamily,
  fontSize: RbText.journalFontSize,
  height: RbText.journalLineFactor,
  forceStrutHeight: true,
);
