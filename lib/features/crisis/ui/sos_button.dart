import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:relaxmate/core/router/app_routes.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_motion.dart';
import 'package:relaxmate/core/theme/rb_size.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';

/// CMP-M47: tombol SOS berbentuk pil merah pekat di tampilan maskot chat, muncul hanya selama
/// krisis terdeteksi di Percakapan hari itu (menggantikan `CrisisBanner` yang terlalu
/// memakan ruang di layar sempit). Membuka Kontak bantuan (SCR-M16), yang bekerja tanpa
/// internet (RULE-M034). Cincin di belakangnya berdenyut pelan agar terlihat tanpa
/// berteriak; bila gerak dikurangi (RULE-M055) cincin diam. Warna dan kontras dari token
/// krisis. Target sentuh >= 48dp.
///
/// Sejak revisi 2026-11-15 tombol ini juga menggantikan semua teks "Butuh bantuan sekarang"
/// di layar sesudah masuk: bentuk [compact] (hanya tulisan SOS, tanpa ikon telepon) dipasang
/// di bilah atas lewat [SosAppBarAction] dan di kepala Beranda. Cincin berdenyut ([pulse])
/// hanya dipakai saat krisis terdeteksi.
class SosButton extends StatefulWidget {
  const SosButton({this.compact = false, this.pulse = true, super.key});

  /// Hanya tulisan SOS, tanpa ikon telepon, dengan jarak samping lebih kecil.
  final bool compact;

  /// Cincin di belakang tombol berdenyut pelan (diam bila gerak dikurangi).
  final bool pulse;

  @override
  State<SosButton> createState() => _SosButtonState();
}

class _SosButtonState extends State<SosButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: RbMotion.sosPulse,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncPulse();
  }

  @override
  void didUpdateWidget(SosButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncPulse();
  }

  void _syncPulse() {
    if (!widget.pulse || MediaQuery.disableAnimationsOf(context)) {
      _pulse.stop();
    } else if (!_pulse.isAnimating) {
      _pulse.repeat();
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.rbColors;
    final text = context.rbText;
    final space = context.rbSpace;

    return Semantics(
      container: true,
      button: true,
      // Diumumkan otomatis hanya saat krisis (cincin berdenyut), bukan di tiap layar.
      liveRegion: widget.pulse,
      label: AppTexts.sosSemantics,
      excludeSemantics: true,
      onTap: () => context.push<void>(AppRoutes.crisisContacts),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: RbSize.minTouch),
        child: Center(
          widthFactor: 1,
          heightFactor: 1,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: <Widget>[
              if (widget.pulse)
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: _pulse,
                      builder: (context, _) {
                        final t = RbMotion.curve.transform(_pulse.value);
                        return Opacity(
                          opacity: (1 - t) * 0.45,
                          child: Transform.scale(
                            scale: 1 + (RbSize.sosRingScale - 1) * t,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  RbSize.sosHeight,
                                ),
                                color: colors.crisisText,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              Material(
                color: colors.crisisText,
                shape: const StadiumBorder(),
                elevation: 3,
                shadowColor: colors.crisisText.withValues(alpha: 0.5),
                child: InkWell(
                  customBorder: const StadiumBorder(),
                  onTap: () => context.push<void>(AppRoutes.crisisContacts),
                  child: Container(
                    height: widget.compact
                        ? RbSize.sosCompactHeight
                        : RbSize.sosHeight,
                    padding: EdgeInsets.symmetric(
                      horizontal: widget.compact ? space.sm : space.md,
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        if (!widget.compact) ...<Widget>[
                          Icon(
                            LucideIcons.phone,
                            size: RbSize.modeSwitchIcon,
                            color: colors.crisisBg,
                          ),
                          SizedBox(width: space.xs),
                        ],
                        Text(
                          AppTexts.sosLabel,
                          style: text.button.copyWith(
                            color: colors.crisisBg,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tombol SOS untuk `AppBar.actions` di semua layar sesudah masuk: tombol [SosButton]
/// bentuk ringkas dengan jarak ke tepi layar. [pulse] menyalakan cincin berdenyut (chat,
/// saat krisis terdeteksi).
class SosAppBarAction extends StatelessWidget {
  const SosAppBarAction({this.pulse = false, super.key});

  final bool pulse;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(end: context.rbSpace.sm),
      child: SosButton(compact: true, pulse: pulse),
    );
  }
}
