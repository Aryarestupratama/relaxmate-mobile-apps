import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:relaxmate/core/router/app_routes.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_motion.dart';
import 'package:relaxmate/core/theme/rb_radius.dart';
import 'package:relaxmate/core/theme/rb_size.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/features/chat/ui/typing_indicator.dart';
import 'package:relaxmate/features/mascot/data/mascot_state.dart';
import 'package:relaxmate/features/mascot/ui/mascot_view.dart';
import 'package:relaxmate/shared/widgets/floating_card.dart';

/// Tahap undangan: titik mengetik, gelembung, lalu tombol balasan.
enum _InviteStage { typing, bubble, replies }

/// Undangan sudah dimainkan sekali sejak aplikasi dibuka; kunjungan berikutnya ke Beranda
/// langsung menampilkan hasil akhirnya (dibuat ulang tiap layar tab, ADR-M16).
bool _invitePlayed = false;

/// CMP-M38: kartu "Mau cerita sedikit?" (TASK-M074, konsep K1 dan K2). RelaxMate menyapa lewat
/// gelembung obrolan: titik mengetik sebentar, gelembung muncul dengan efek pop lembut, lalu
/// dua tombol balasan ("Cerita ke RelaxMate", "Temani saja") muncul berurutan, sehingga
/// terasa membalas teman, bukan mengetuk spanduk. Maskot mengintip dari sudut kanan bawah di
/// atas gradien lavender hangat (animasi `idle` yang sudah ada, satu-satunya gerak
/// berulang di Beranda) dan disembunyikan pada teks besar. Tata letak akhir sudah
/// disisihkan sejak awal, jadi tidak ada lonjakan tinggi. Bila gerak dikurangi, semuanya
/// langsung tampil. Mood rendah memakai kalimat yang lebih menemani.
class HomeInviteCard extends StatefulWidget {
  const HomeInviteCard({required this.low, super.key});

  final bool low;

  @override
  State<HomeInviteCard> createState() => _HomeInviteCardState();
}

class _HomeInviteCardState extends State<HomeInviteCard> {
  _InviteStage _stage = _InviteStage.typing;
  bool _started = false;

  /// Hasil akhir tampil langsung: sudah pernah dimainkan atau gerak dikurangi.
  bool _instant = false;
  Timer? _timer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) {
      return;
    }
    _started = true;
    if (_invitePlayed || MediaQuery.disableAnimationsOf(context)) {
      _instant = true;
      _stage = _InviteStage.replies;
      _invitePlayed = true;
      return;
    }
    _timer = Timer(RbMotion.enter + RbMotion.typingPause, _showBubble);
  }

  void _showBubble() {
    if (!mounted) {
      return;
    }
    setState(() => _stage = _InviteStage.bubble);
    _timer = Timer(RbMotion.pop + RbMotion.repliesLead, _showReplies);
  }

  void _showReplies() {
    if (!mounted) {
      return;
    }
    _invitePlayed = true;
    setState(() => _stage = _InviteStage.replies);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Bagian yang belum waktunya tetap menempati ruangnya (tak terlihat, tanpa semantik dan
  /// sentuhan) agar kartu tidak melonjak; saat tiba waktunya ia muncul dengan [effects].
  Widget _reveal({
    required bool shown,
    required Widget child,
    required Widget Function(Widget) effects,
  }) {
    if (!shown) {
      return IgnorePointer(
        child: ExcludeSemantics(child: Opacity(opacity: 0, child: child)),
      );
    }
    if (_instant || MediaQuery.disableAnimationsOf(context)) {
      return child;
    }
    return effects(child);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;
    final showMascot =
        MediaQuery.textScalerOf(context).scale(1) <= RbSize.homeRowMaxTextScale;
    final bubbleShown = _stage != _InviteStage.typing;
    final repliesShown = _stage == _InviteStage.replies;
    final reservedRight = showMascot ? RbSize.mascotPeekWidth + space.xs : 0.0;

    final bubble = Container(
      padding: EdgeInsets.symmetric(horizontal: space.md, vertical: space.sm),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(RbRadius.bubbleTail),
          topRight: Radius.circular(RbRadius.bubble),
          bottomLeft: Radius.circular(RbRadius.bubble),
          bottomRight: Radius.circular(RbRadius.bubble),
        ),
      ),
      child: Text(
        widget.low ? AppTexts.homeInviteBubbleLow : AppTexts.homeInviteBubble,
        style: text.body.copyWith(fontWeight: FontWeight.w600),
      ),
    );

    final chatButton = FilledButton(
      onPressed: () => context.go(AppRoutes.chat),
      style: FilledButton.styleFrom(
        shape: const RoundedRectangleBorder(borderRadius: RbRadius.pillBorder),
      ),
      child: const Text(AppTexts.homeInviteChat),
    );
    final companionButton = OutlinedButton(
      onPressed: () => context.push<void>(AppRoutes.companion),
      style: OutlinedButton.styleFrom(
        backgroundColor: colors.card,
        shape: const RoundedRectangleBorder(borderRadius: RbRadius.pillBorder),
      ),
      child: const Text(AppTexts.homeInviteCompanion),
    );

    Widget slideIn(Widget child, Duration delay) => child
        .animate(delay: delay)
        .fadeIn(duration: RbMotion.enter, curve: RbMotion.curve)
        .moveY(
          begin: RbSize.motionShift,
          end: 0,
          duration: RbMotion.enter,
          curve: RbMotion.curve,
        );

    return FloatingCard(
      padding: EdgeInsets.zero,
      clip: Clip.antiAlias,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          colors.softLavender,
          Color.alphaBlend(
            colors.mood3.withValues(alpha: _warmth),
            colors.softLavender,
          ),
        ],
      ),
      child: Stack(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(
              space.md,
              space.md,
              space.md + reservedRight,
              space.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Semantics(
                  header: true,
                  child: Text(AppTexts.homeInviteTitle, style: text.h3),
                ),
                SizedBox(height: space.sm),
                Stack(
                  alignment: Alignment.topLeft,
                  children: <Widget>[
                    _reveal(
                      shown: bubbleShown,
                      child: bubble,
                      effects: (child) => child
                          .animate()
                          .fadeIn(duration: RbMotion.pop, curve: RbMotion.curve)
                          .scaleXY(
                            begin: RbMotion.popFrom,
                            end: 1,
                            alignment: Alignment.bottomLeft,
                            duration: RbMotion.pop,
                            curve: RbMotion.curve,
                          ),
                    ),
                    if (_stage == _InviteStage.typing) const TypingIndicator(),
                  ],
                ),
                SizedBox(height: space.sm),
                Wrap(
                  spacing: space.xs,
                  runSpacing: space.xs,
                  children: <Widget>[
                    _reveal(
                      shown: repliesShown,
                      child: chatButton,
                      effects: (child) => slideIn(child, Duration.zero),
                    ),
                    _reveal(
                      shown: repliesShown,
                      child: companionButton,
                      effects: (child) => slideIn(child, RbMotion.stagger),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (showMascot)
            Positioned(
              right: space.sm,
              bottom:
                  -RbSize.mascotPeekHeight * RbSize.mascotPeekHiddenFraction,
              child: const ExcludeSemantics(
                child: MascotView(
                  state: MascotState.idle,
                  height: RbSize.mascotPeekHeight,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Seberapa hangat (campuran `mood3`) gradien lavender kartu.
  static const double _warmth = 0.3;
}
