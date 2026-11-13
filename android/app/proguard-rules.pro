# Aturan R8 untuk build rilis RelaxMate.
# Flutter dan plugin membawa aturan konsumen sendiri. Di sini hanya hal khusus aplikasi.

# Komponen yang dipanggil sistem lewat nama di AndroidManifest (overlay mengambang).
-keep class id.my.relaxboss.relaxmate.overlay.** { *; }

# Pustaka deferred components Flutter tidak dipakai.
-dontwarn com.google.android.play.core.**
