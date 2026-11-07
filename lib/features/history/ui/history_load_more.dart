import 'package:flutter/material.dart';
import 'package:relaxmate/core/texts/app_texts.dart';
import 'package:relaxmate/core/theme/rb_theme_context.dart';
import 'package:relaxmate/shared/widgets/error_alert.dart';

/// Kaki daftar riwayat dan detail hari: tombol memuat halaman berikutnya, indikator saat
/// memuat, atau galat ramah dengan "Coba lagi". Memuat selalu atas aksi pengguna.
class HistoryLoadMore extends StatelessWidget {
  const HistoryLoadMore({
    required this.label,
    required this.loading,
    required this.onPressed,
    this.error,
    super.key,
  });

  final String label;
  final bool loading;
  final VoidCallback onPressed;

  /// Pesan galat ramah dari server atau klien; `null` bila tidak ada.
  final String? error;

  @override
  Widget build(BuildContext context) {
    final space = context.rbSpace;
    final message = error;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: space.sm),
      child: message != null
          ? ErrorAlert(message: message, onRetry: onPressed)
          : Center(
              child: loading
                  ? const CircularProgressIndicator(
                      semanticsLabel: AppTexts.loading,
                    )
                  : TextButton(onPressed: onPressed, child: Text(label)),
            ),
    );
  }
}
