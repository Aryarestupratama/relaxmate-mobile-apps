package id.my.relaxboss.relaxmate.overlay

import android.content.Context
import android.content.SharedPreferences

/**
 * Pengaturan maskot yang dibaca dan ditulis dua sisi. Memakai berkas dan awalan `flutter.` milik
 * plugin `shared_preferences` Dart (API `getInstance`), jadi Flutter membacanya setelah
 * `reload()`. Tidak sensitif.
 */
object OverlayPrefs {
    private const val FILE = "FlutterSharedPreferences"

    /** Sama dengan `AppConstants.settingsOverlayEnabledKey` di Dart. */
    const val KEY_ENABLED = "flutter.settings_overlay_enabled_v1"

    /** Epoch milidetik sampai kapan maskot istirahat; 0 = tidak istirahat. */
    const val KEY_SNOOZE_UNTIL = "flutter.overlay_snooze_until_v1"
    const val KEY_BUBBLE_Y = "flutter.overlay_bubble_y_v1"
    const val KEY_BUBBLE_RIGHT = "flutter.overlay_bubble_right_v1"

    private fun prefs(context: Context): SharedPreferences =
        context.getSharedPreferences(FILE, Context.MODE_PRIVATE)

    fun setEnabled(context: Context, enabled: Boolean) {
        prefs(context).edit().putBoolean(KEY_ENABLED, enabled).apply()
    }

    fun snoozeUntil(context: Context): Long = prefs(context).getLong(KEY_SNOOZE_UNTIL, 0L)

    fun setSnoozeUntil(context: Context, epochMillis: Long) {
        prefs(context).edit().putLong(KEY_SNOOZE_UNTIL, epochMillis).apply()
    }

    fun bubbleY(context: Context, fallback: Int): Int =
        prefs(context).getInt(KEY_BUBBLE_Y, fallback)

    fun bubbleOnRight(context: Context): Boolean =
        prefs(context).getBoolean(KEY_BUBBLE_RIGHT, true)

    fun setBubblePosition(context: Context, y: Int, onRight: Boolean) {
        prefs(context).edit()
            .putInt(KEY_BUBBLE_Y, y)
            .putBoolean(KEY_BUBBLE_RIGHT, onRight)
            .apply()
    }
}
