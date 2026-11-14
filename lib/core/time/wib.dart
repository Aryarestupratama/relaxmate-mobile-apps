import 'package:relaxmate/core/config/app_constants.dart';
import 'package:relaxmate/core/texts/app_texts.dart';

/// Waktu WIB tanpa paket zona waktu (RULE-M033). Server mengirim ISO UTC; tampilan memakai WIB.
///
/// Tanggal "saja" direpresentasikan sebagai `DateTime.utc(y, m, d)` agar perbandingan dan
/// selisih hari tidak terpengaruh zona waktu perangkat.
DateTime toWib(DateTime instant) =>
    instant.toUtc().add(const Duration(hours: AppConstants.wibOffsetHours));

/// Tanggal (tanpa jam) dari [instant] menurut WIB.
DateTime wibDate(DateTime instant) {
  final wib = toWib(instant);
  return DateTime.utc(wib.year, wib.month, wib.day);
}

/// Tanggal hari ini menurut WIB, dari jam perangkat. Dipakai hanya bila server belum
/// memberi tanggal (`range.to` di API-M019 lebih diutamakan).
DateTime wibToday() => wibDate(DateTime.now());

/// `YYYY-MM-DD` menjadi tanggal; `null` bila bentuknya salah.
DateTime? parseDateKey(Object? value) {
  if (value is! String) {
    return null;
  }
  final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(value);
  if (match == null) {
    return null;
  }
  final year = int.parse(match.group(1) ?? '');
  final month = int.parse(match.group(2) ?? '');
  final day = int.parse(match.group(3) ?? '');
  if (month < 1 || month > 12 || day < 1 || day > 31) {
    return null;
  }
  return DateTime.utc(year, month, day);
}

/// Jam WIB berbentuk `19.04`.
String wibTimeLabel(DateTime instant) {
  final wib = toWib(instant);
  final hour = wib.hour.toString().padLeft(2, '0');
  final minute = wib.minute.toString().padLeft(2, '0');
  return '$hour.$minute';
}

/// `Sabtu, 14 November` untuk sapaan di Beranda.
String longDateLabel(DateTime date) =>
    '${AppTexts.weekdays[date.weekday - 1]}, ${date.day} '
    '${AppTexts.months[date.month - 1]}';

/// `14 Nov`.
String shortDateLabel(DateTime date) =>
    '${date.day} ${AppTexts.monthsShort[date.month - 1]}';

/// Penanda hari untuk daftar dan ringkasan: `Hari ini`, nama hari untuk enam hari terakhir,
/// selain itu `8 Nov`.
String relativeDayLabel(DateTime date, DateTime today) {
  final diff = today.difference(date).inDays;
  if (diff == 0) {
    return AppTexts.today;
  }
  if (diff > 0 && diff < 7) {
    return AppTexts.weekdays[date.weekday - 1];
  }
  return shortDateLabel(date);
}
