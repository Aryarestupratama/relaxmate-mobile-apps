package id.my.relaxboss.relaxmate.overlay

import android.Manifest
import android.app.Activity
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Jembatan izin untuk maskot mengambang (TASK-M032, Architecture-M 6.4). Hanya memeriksa dan
 * mengarahkan izin; tidak menampilkan apa pun (gelembung dibuat di TASK-M033).
 *
 * Metode:
 * - `status`: `{canDrawOverlays, notificationsGranted, running}`
 * - `start`: memulai `OverlayService` (hanya dari aksi pengguna saat aplikasi terbuka); `true` bila
 *   izin overlay ada dan permintaan dikirim
 * - `stop`: menghentikan `OverlayService`
 * - `openOverlaySettings`: membuka halaman "tampil di atas aplikasi lain" untuk aplikasi ini
 * - `requestNotifications`: meminta POST_NOTIFICATIONS (Android 13+); hasilnya `true` bila aktif
 * - `openNotificationSettings`: membuka pengaturan notifikasi aplikasi
 */
class OverlayChannel(
    private val activity: Activity,
    messenger: BinaryMessenger,
) : MethodChannel.MethodCallHandler {

    private val channel = MethodChannel(messenger, NAME)
    private var pendingNotificationResult: MethodChannel.Result? = null

    init {
        channel.setMethodCallHandler(this)
    }

    fun dispose() {
        channel.setMethodCallHandler(null)
        pendingNotificationResult = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "status" -> result.success(
                mapOf(
                    "canDrawOverlays" to Settings.canDrawOverlays(activity),
                    "notificationsGranted" to notificationsGranted(),
                    "running" to OverlayService.running,
                ),
            )

            "start" -> {
                if (!Settings.canDrawOverlays(activity)) {
                    result.success(false)
                } else {
                    val intent = Intent(activity, OverlayService::class.java)
                        .setAction(OverlayService.ACTION_START)
                    result.success(startService(intent))
                }
            }

            "stop" -> {
                activity.stopService(Intent(activity, OverlayService::class.java))
                result.success(true)
            }

            "openOverlaySettings" -> {
                val intent = Intent(
                    Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                    Uri.parse("package:${activity.packageName}"),
                )
                result.success(launch(intent))
            }

            "requestNotifications" -> requestNotifications(result)

            "openNotificationSettings" -> {
                val intent = Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS)
                    .putExtra(Settings.EXTRA_APP_PACKAGE, activity.packageName)
                result.success(launch(intent))
            }

            else -> result.notImplemented()
        }
    }

    /** Dipanggil `MainActivity` setelah pengguna menjawab dialog izin sistem. */
    fun onPermissionResult(requestCode: Int, grantResults: IntArray) {
        if (requestCode != REQUEST_NOTIFICATIONS) {
            return
        }
        val granted = grantResults.isNotEmpty() &&
            grantResults[0] == PackageManager.PERMISSION_GRANTED
        pendingNotificationResult?.success(granted)
        pendingNotificationResult = null
    }

    private fun requestNotifications(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
            // Sebelum Android 13 tidak ada izin runtime; notifikasi aktif kecuali dimatikan pengguna.
            result.success(notificationsGranted())
            return
        }
        if (notificationsGranted()) {
            result.success(true)
            return
        }
        if (pendingNotificationResult != null) {
            result.error("busy", "Permintaan izin notifikasi sedang berjalan.", null)
            return
        }
        pendingNotificationResult = result
        activity.requestPermissions(
            arrayOf(Manifest.permission.POST_NOTIFICATIONS),
            REQUEST_NOTIFICATIONS,
        )
    }

    private fun notificationsGranted(): Boolean {
        val manager = activity.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        return manager.areNotificationsEnabled()
    }

    private fun startService(intent: Intent): Boolean {
        return try {
            activity.startForegroundService(intent)
            true
        } catch (error: RuntimeException) {
            // Mis. ForegroundServiceStartNotAllowedException bila aplikasi tidak di depan layar.
            false
        }
    }

    private fun launch(intent: Intent): Boolean {
        return try {
            activity.startActivity(intent)
            true
        } catch (error: android.content.ActivityNotFoundException) {
            false
        }
    }

    companion object {
        const val NAME = "id.my.relaxboss.relaxmate/overlay"
        private const val REQUEST_NOTIFICATIONS = 4101
    }
}
