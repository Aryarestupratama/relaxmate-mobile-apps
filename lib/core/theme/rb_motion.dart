import 'package:flutter/animation.dart';

/// Token gerak (Design-M bagian 2). Hormati `MediaQuery.disableAnimations`
/// di tempat pemakaian.
abstract final class RbMotion {
  static const Duration feedback = Duration(milliseconds: 150);
  static const Duration screen = Duration(milliseconds: 250);
  static const Duration mascotBreath = Duration(milliseconds: 3500);

  /// Gerak masuk dan sentuhan (TASK-M074, `flutter_animate`): lambat dan tenang, 350 sampai
  /// 600 ms, kurva [curve], tanpa pantulan.
  static const Duration enter = Duration(milliseconds: 450);

  /// Jeda antarkartu saat tampil berurutan.
  static const Duration stagger = Duration(milliseconds: 70);
  static const Duration pop = Duration(milliseconds: 350);
  static const Duration ripple = Duration(milliseconds: 600);

  /// Grafik 7 hari: garis "tergambar", lalu titiknya muncul satu per satu.
  static const Duration chartLine = Duration(milliseconds: 600);
  static const Duration chartDots = Duration(milliseconds: 400);

  /// Undangan bercerita di Beranda: lama titik mengetik sebelum gelembung muncul, dan jeda
  /// sebelum tombol balasan muncul.
  static const Duration typingPause = Duration(milliseconds: 900);
  static const Duration repliesLead = Duration(milliseconds: 250);

  /// Skala awal gelembung yang "pop", skala puncak blob mood terpilih, dan skala akhir
  /// cincin riak.
  static const double popFrom = 0.9;
  static const double popPeak = 1.12;
  static const double rippleEnd = 1.6;

  /// Pergantian isi gelembung balasan di tampilan maskot chat (titik mengetik ke teks).
  static const Duration bubbleSwap = Duration(milliseconds: 300);

  /// Denyut cincin tombol SOS.
  static const Duration sosPulse = Duration(milliseconds: 1800);
  static const Curve curve = Curves.easeOut;

  /// Lingkaran napas: awal dan akhir yang lembut agar terasa seperti bernapas.
  static const Curve breathCurve = Curves.easeInOut;
}
