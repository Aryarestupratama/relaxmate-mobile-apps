import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:relaxmate/core/theme/rb_motion.dart';
import 'package:relaxmate/core/theme/rb_size.dart';

/// Gerak masuk satu gelembung pesan (TASK-M073 bagian 7): memudar, naik sedikit, dan membesar lembut
/// dari sisi pengirimnya ([alignment]). Dimainkan sekali per [entranceKey]: indeks yang sudah
/// ada di [played] (pesan lama, atau gelembung yang digulir keluar lalu masuk lagi) tampil
/// langsung. Bila pengguna mengurangi gerak (RULE-M055) juga langsung.
class ChatEntrance extends StatefulWidget {
  const ChatEntrance({
    required this.entranceKey,
    required this.played,
    required this.alignment,
    required this.child,
    super.key,
  });

  final int entranceKey;
  final Set<int> played;
  final Alignment alignment;
  final Widget child;

  @override
  State<ChatEntrance> createState() => _ChatEntranceState();
}

class _ChatEntranceState extends State<ChatEntrance> {
  bool _decided = false;
  bool _play = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_decided) {
      return;
    }
    _decided = true;
    final first = widget.played.add(widget.entranceKey);
    _play = first && !MediaQuery.disableAnimationsOf(context);
  }

  @override
  Widget build(BuildContext context) {
    if (!_play) {
      return widget.child;
    }
    return widget.child
        .animate()
        .fadeIn(duration: RbMotion.pop, curve: RbMotion.curve)
        .moveY(
          begin: RbSize.motionShift,
          end: 0,
          duration: RbMotion.enter,
          curve: RbMotion.curve,
        )
        .scaleXY(
          begin: RbMotion.popFrom,
          end: 1,
          alignment: widget.alignment,
          duration: RbMotion.pop,
          curve: RbMotion.curve,
        );
  }
}
