import 'package:relaxmate/core/theme/rb_size.dart';

/// Ukuran `MateAvatar` (CMP-M01): 40, 56, 72 dp.
enum MateAvatarSize {
  small(RbSize.avatarSmall),
  medium(RbSize.avatarMedium),
  large(RbSize.avatarLarge);

  const MateAvatarSize(this.dimension);

  final double dimension;
}
