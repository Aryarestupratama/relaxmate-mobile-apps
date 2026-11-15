import 'package:relaxmate/core/theme/rb_size.dart';

/// Ukuran `MateAvatar` (CMP-M01): 32 (profil di gelembung chat), 40, 56, 72 dp.
enum MateAvatarSize {
  tiny(RbSize.avatarTiny),
  small(RbSize.avatarSmall),
  medium(RbSize.avatarMedium),
  large(RbSize.avatarLarge);

  const MateAvatarSize(this.dimension);

  final double dimension;
}
