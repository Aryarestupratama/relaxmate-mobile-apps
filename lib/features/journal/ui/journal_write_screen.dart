import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_motion.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/features/checkin/data/mood_arousal.dart';
import 'package:relaxmate/features/checkin/data/mood_level.dart';
import 'package:relaxmate/features/checkin/state/checkin_controller.dart';
import 'package:relaxmate/features/checkin/state/checkin_state.dart';
import 'package:relaxmate/features/checkin/ui/mood_blob_row.dart';
import 'package:relaxmate/features/journal/ui/ink_write_text.dart';
import 'package:relaxmate/features/journal/ui/journal_lined_field.dart';
import 'package:relaxmate/features/journal/ui/journal_paper.dart';
import 'package:relaxmate/shared/widgets/error_alert.dart';
import 'package:relaxmate/shared/widgets/floating_card.dart';
import 'package:relaxmate/shared/widgets/rb_app_bar.dart';
import 'package:relaxmate/shared/widgets/rb_entrance.dart';
import 'package:relaxmate/shared/widgets/soft_gradient_background.dart';

enum _Phase { composing, writing, closing }

/// SCR-M24: halaman menulis buku harian (FR-M032, TASK-M079). Dibuka setelah memilih blob mood
/// di Beranda atau layar Mood. Isi: pilihan mood (bisa diganti), tenaga opsional, halaman buku
/// bergaris untuk catatan, lalu "Simpan catatan" atau, bila tanpa catatan, "Simpan tanpa
/// catatan" (jalur cepat). Menyimpan lewat `CheckinController.submit` (API-M018).
///
/// Bila ada catatan, setelah tersimpan layar berubah menjadi buku yang menuliskan catatan itu
/// ([InkWriteText]), lalu menutup dan kembali; ketukan di mana saja menutup lebih cepat.
/// Isi catatan hanya di [TextEditingController] dan variabel layar ini (memori), dibuang saat
/// layar ditutup; tidak ditulis ke penyimpanan atau log (RULE-M074).
class JournalWriteScreen extends ConsumerStatefulWidget {
  const JournalWriteScreen({this.initialLevel, super.key});

  /// Mood yang sudah dipilih di layar asal; `null` bila belum ada.
  final MoodLevel? initialLevel;

  @override
  ConsumerState<JournalWriteScreen> createState() => _JournalWriteScreenState();
}

class _JournalWriteScreenState extends ConsumerState<JournalWriteScreen> {
  final TextEditingController _note = TextEditingController();
  final DateTime _openedAt = DateTime.now().toUtc();
  MoodLevel? _level;
  MoodArousal? _arousal;
  _Phase _phase = _Phase.composing;
  String _writtenNote = '';
  DateTime? _savedAt;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _level = widget.initialLevel;
    // Galat dari percobaan sebelumnya tidak ikut tampil di layar baru.
    unawaited(
      Future<void>.microtask(() {
        if (mounted) {
          ref.read(checkinControllerProvider.notifier).clearError();
        }
      }),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final level = _level;
    if (level == null) {
      return;
    }
    final note = _note.text.trim();
    final saved = await ref.read(checkinControllerProvider.notifier).submit(
          level,
          note: note.isEmpty ? null : note,
          arousal: _arousal,
        );
    if (!mounted || !saved) {
      return;
    }
    if (note.isEmpty) {
      context.pop();
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _phase = _Phase.writing;
      _writtenNote = note;
      _savedAt =
          ref.read(checkinControllerProvider).recorded?.loggedAt ?? _openedAt;
    });
  }

  /// Teks selesai ditulis: tahan sebentar, lalu halaman menutup dan layar kembali.
  void _onWritten() {
    _timer?.cancel();
    _timer = Timer(RbMotion.inkHold, () {
      if (!mounted) {
        return;
      }
      setState(() => _phase = _Phase.closing);
      _timer = Timer(RbMotion.enter, () {
        if (mounted) {
          context.pop();
        }
      });
    });
  }

  void _closeNow() {
    _timer?.cancel();
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final state = ref.watch(checkinControllerProvider);

    return Scaffold(
      backgroundColor: colors.pageBg,
      extendBodyBehindAppBar: true,
      appBar: const RbAppBar.pushed(title: AppTexts.journalWriteTitle),
      body: SoftGradientBackground(
        child: SafeArea(
          child: _phase == _Phase.composing
              ? _composing(context, state)
              : _book(context),
        ),
      ),
    );
  }

  Widget _composing(BuildContext context, CheckinState state) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;
    final busy = state.submitting;

    return ListView(
      padding: EdgeInsets.fromLTRB(space.md, space.xs, space.md, space.lg),
      children: <Widget>[
        RbEntrance(
          child: FloatingCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Semantics(
                  header: true,
                  child: Text(AppTexts.journalMoodTitle, style: text.h3),
                ),
                SizedBox(height: space.sm),
                MoodBlobRow(
                  selected: _level,
                  enabled: !busy,
                  onSelected: (level) => setState(() => _level = level),
                ),
                SizedBox(height: space.md),
                Text(
                  AppTexts.journalArousalTitle,
                  style: text.small.copyWith(color: colors.textSecondary),
                ),
                SizedBox(height: space.xs),
                Wrap(
                  spacing: space.xs,
                  runSpacing: space.xs,
                  children: <Widget>[
                    for (final arousal in MoodArousal.values)
                      FilterChip(
                        label: Text(arousal.label),
                        selected: _arousal == arousal,
                        showCheckmark: false,
                        onSelected: busy
                            ? null
                            : (on) =>
                                setState(() => _arousal = on ? arousal : null),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: space.md),
        RbEntrance(
          index: 1,
          child: JournalPaper(
            level: _level,
            when: _openedAt,
            arousal: _arousal,
            child: JournalLinedField(controller: _note, enabled: !busy),
          ),
        ),
        if (state.error case final String message) ...<Widget>[
          SizedBox(height: space.md),
          ErrorAlert(message: message),
        ],
        SizedBox(height: space.md),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _note,
          builder: (context, value, _) {
            final hasNote = value.text.trim().isNotEmpty;
            final ready = _level != null && !busy;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (_level == null)
                  Padding(
                    padding: EdgeInsets.only(bottom: space.xs),
                    child: Text(
                      AppTexts.journalPickMood,
                      textAlign: TextAlign.center,
                      style: text.small.copyWith(color: colors.textSecondary),
                    ),
                  ),
                FilledButton(
                  onPressed: ready && hasNote ? _save : null,
                  child: Text(
                    busy ? AppTexts.journalSaving : AppTexts.journalSave,
                  ),
                ),
                if (!hasNote) ...<Widget>[
                  SizedBox(height: space.xs),
                  TextButton(
                    onPressed: ready ? _save : null,
                    child: const Text(AppTexts.journalSaveNoNote),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _book(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;
    final closing = _phase == _Phase.closing;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final duration = reduceMotion ? Duration.zero : RbMotion.enter;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _closeNow,
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(space.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              AnimatedOpacity(
                opacity: closing ? 0 : 1,
                duration: duration,
                curve: RbMotion.curve,
                child: AnimatedScale(
                  scale: closing ? RbMotion.closeScale : 1,
                  duration: duration,
                  curve: RbMotion.curve,
                  child: JournalPaper(
                    level: _level,
                    when: _savedAt ?? _openedAt,
                    arousal: _arousal,
                    child: InkWriteText(
                      text: _writtenNote,
                      onWritten: _onWritten,
                    ),
                  ),
                ),
              ),
              SizedBox(height: space.md),
              Semantics(
                liveRegion: true,
                child: Text(
                  AppTexts.journalSavedAnnounce,
                  textAlign: TextAlign.center,
                  style: text.small.copyWith(color: colors.textSecondary),
                ),
              ),
              SizedBox(height: space.xxs),
              Semantics(
                button: true,
                onTap: _closeNow,
                child: Text(
                  AppTexts.journalTapToClose,
                  textAlign: TextAlign.center,
                  style: text.caption.copyWith(color: colors.textMuted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
