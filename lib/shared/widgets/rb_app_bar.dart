import 'package:flutter/material.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/features/crisis/ui/sos_button.dart';
import 'package:relaxmate/shared/widgets/mate_avatar.dart';
import 'package:relaxmate/shared/widgets/mate_avatar_size.dart';

/// CMP-M55: bilah atas satu-satunya untuk semua layar sesudah masuk, supaya bentuknya sama di
/// mana pun. Selalu tiga unsur: penanda di kiri, nama layar, dan tombol SOS di kanan.
///
/// - [RbAppBar.root] (layar tab: Beranda, Ngobrol, Latihan, Mood, Pengaturan): logo RelaxMate
///   (avatar maskot) lalu nama fitur.
/// - [RbAppBar.pushed] (layar lanjutan yang dibuka dari layar lain): tombol kembali lalu nama
///   layar. Logo tidak dipasang karena tombol kembali menempati sisi kiri.
///
/// Tanpa nama aplikasi, tagline, menu, atau tombol lain; kendali tambahan milik layar
/// diletakkan di badan layar. Latar transparan (layar yang memakai gradien memanjangkan badan
/// ke belakang bilah). [showSos] hanya dimatikan di layar Kontak bantuan itu sendiri;
/// [sosPulse] menyalakan cincin berdenyut (Ngobrol saat krisis terdeteksi).
class RbAppBar extends StatelessWidget implements PreferredSizeWidget {
  const RbAppBar.root({
    required this.title,
    this.sosPulse = false,
    super.key,
  })  : isRoot = true,
        showSos = true;

  const RbAppBar.pushed({
    required this.title,
    this.showSos = true,
    super.key,
  })  : isRoot = false,
        sosPulse = false;

  final String title;
  final bool isRoot;
  final bool showSos;
  final bool sosPulse;

  /// Lebar kotak logo di kiri: jarak tepi ditambah garis tengah avatar kecil.
  static const double _logoBoxWidth = 60;
  static const double _titleSpacing = 4;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final text = context.rbText;
    final space = context.rbSpace;

    return AppBar(
      backgroundColor: Colors.transparent,
      scrolledUnderElevation: 0,
      centerTitle: false,
      automaticallyImplyLeading: !isRoot,
      leadingWidth: isRoot ? _logoBoxWidth : null,
      titleSpacing: isRoot ? _titleSpacing : null,
      leading: isRoot
          ? Padding(
              padding: EdgeInsetsDirectional.only(start: space.md),
              child: const Center(
                child: ExcludeSemantics(
                  child: MateAvatar(size: MateAvatarSize.small),
                ),
              ),
            )
          : null,
      title: Semantics(
        header: true,
        child: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: text.h3,
        ),
      ),
      actions: <Widget>[
        if (showSos) SosAppBarAction(pulse: sosPulse),
      ],
    );
  }
}
