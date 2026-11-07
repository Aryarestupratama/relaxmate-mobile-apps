import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:relaxmate/core/config/app_config_provider.dart';
import 'package:relaxmate/core/error/api_exception.dart';
import 'package:relaxmate/features/auth/state/auth_controller.dart';
import 'package:relaxmate/features/auth/state/auth_state.dart';
import 'package:relaxmate/features/crisis/data/crisis_contact.dart';
import 'package:relaxmate/features/crisis/data/crisis_contact_set.dart';
import 'package:relaxmate/features/crisis/data/crisis_contacts_repository.dart';

/// Daftar kontak bantuan yang siap ditampilkan (FR-M010, M011). Selalu berhasil memuat dari
/// perangkat (salinan terakhir atau aset bawaan), jadi tetap jalan tanpa internet dan tanpa
/// masuk (RULE-M034). Setelah masuk, daftar disegarkan dari server di latar belakang; galat
/// jaringan diabaikan diam-diam karena daftar lokal sudah cukup.
///
/// Build `prod` tidak pernah menampilkan kontak bertanda `dummy` (RULE-M008, RULE-M048).
class CrisisContactsController extends AsyncNotifier<List<CrisisContact>> {
  String? _version;

  @override
  Future<List<CrisisContact>> build() async {
    // Dibaca ulang saat pengguna masuk atau keluar agar penyegaran jalan setelah masuk.
    final signedIn = ref.watch(
      authControllerProvider.select(
        (auth) => auth is AuthAuthenticated && auth.user.emailVerified,
      ),
    );

    final repository = ref.read(crisisContactsRepositoryProvider);
    final local = await repository.loadLocal();
    _version = local.version;
    if (signedIn) {
      // Dijalankan setelah `build` selesai agar `state` sudah terpasang.
      unawaited(Future<void>.microtask(_refresh));
    }
    return _visible(local);
  }

  /// Menyegarkan dari API-M011 bila versi di server berbeda dari salinan di perangkat.
  Future<void> _refresh() async {
    final repository = ref.read(crisisContactsRepositoryProvider);
    try {
      final remote = await repository.fetchRemote();
      if (!ref.mounted || remote == null || remote.version == _version) {
        return;
      }
      await repository.saveCache(remote);
      if (!ref.mounted) {
        return;
      }
      _version = remote.version;
      state = AsyncData<List<CrisisContact>>(_visible(remote));
    } on ApiException {
      // Daftar di perangkat tetap dipakai.
    }
  }

  List<CrisisContact> _visible(CrisisContactSet set) {
    final prod = ref.read(appConfigProvider).flavor.isProd;
    return prod
        ? set.contacts.where((contact) => !contact.dummy).toList()
        : set.contacts;
  }
}

final AsyncNotifierProvider<CrisisContactsController, List<CrisisContact>>
    crisisContactsProvider =
    AsyncNotifierProvider<CrisisContactsController, List<CrisisContact>>(
  CrisisContactsController.new,
);
