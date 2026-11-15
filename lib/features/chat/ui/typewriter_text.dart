import 'package:flutter/material.dart';

/// Teks yang "diketik" huruf demi huruf (balasan RelaxMate yang baru tiba, TASK-M073 bagian 7).
/// Seluruh teks selalu ikut ditata (bagian yang belum tampil berwarna transparan), jadi
/// ukuran gelembung dan pemenggalan baris tidak berubah selama mengetik. Kecepatan
/// [_msPerChar] per huruf, dibatasi antara [_minDuration] dan [_maxDuration] supaya balasan
/// panjang tidak membuat pengguna menunggu. Bila pengguna mengurangi gerak
/// (`MediaQuery.disableAnimations`, RULE-M055) teks langsung utuh. [onDone] dipanggil sekali
/// setelah seluruh teks tampil.
class TypewriterText extends StatefulWidget {
  const TypewriterText({
    required this.text,
    required this.style,
    this.onDone,
    super.key,
  });

  final String text;
  final TextStyle style;
  final VoidCallback? onDone;

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText>
    with SingleTickerProviderStateMixin {
  static const int _msPerChar = 22;
  static const int _minDuration = 600;
  static const int _maxDuration = 3500;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: Duration(
      milliseconds: (widget.text.length * _msPerChar)
          .clamp(_minDuration, _maxDuration)
          .toInt(),
    ),
  );
  bool _started = false;
  bool _done = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) {
      return;
    }
    _started = true;
    if (MediaQuery.disableAnimationsOf(context) || widget.text.isEmpty) {
      _controller.value = 1;
      WidgetsBinding.instance.addPostFrameCallback((_) => _finish());
      return;
    }
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _finish();
      }
    });
    _controller.forward();
  }

  void _finish() {
    if (_done || !mounted) {
      return;
    }
    _done = true;
    widget.onDone?.call();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Memotong di [count] unit kode, tanpa membelah pasangan pengganti (emoji).
  int _safeCut(int count) {
    final text = widget.text;
    if (count > 0 &&
        count < text.length &&
        text.codeUnitAt(count - 1) >= 0xD800 &&
        text.codeUnitAt(count - 1) <= 0xDBFF) {
      return count + 1;
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final text = widget.text;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final cut = _safeCut((_controller.value * text.length).floor());
        return Text.rich(
          TextSpan(
            style: widget.style,
            children: <InlineSpan>[
              TextSpan(text: text.substring(0, cut)),
              TextSpan(
                text: text.substring(cut),
                style: const TextStyle(color: Colors.transparent),
              ),
            ],
          ),
        );
      },
    );
  }
}
