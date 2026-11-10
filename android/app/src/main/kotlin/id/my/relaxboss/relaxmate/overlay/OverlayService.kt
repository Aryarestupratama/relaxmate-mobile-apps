package id.my.relaxboss.relaxmate.overlay

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.ServiceInfo
import android.graphics.BitmapFactory
import android.graphics.PixelFormat
import android.graphics.drawable.AnimatedImageDrawable
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.graphics.drawable.Icon
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.provider.Settings
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.ViewConfiguration
import android.view.WindowManager
import android.widget.ImageView
import id.my.relaxboss.relaxmate.MainActivity
import id.my.relaxboss.relaxmate.R
import java.io.IOException
import java.util.Calendar

/**
 * Maskot mengambang (TASK-M033, Architecture-M 6.4, ADR-M15). Foreground service jenis
 * `specialUse` dengan notifikasi permanen ("Nonaktifkan"), satu jendela gelembung
 * `TYPE_APPLICATION_OVERLAY` yang dapat digeser dan menempel ke tepi, dan satu mini-panel.
 *
 * Aturan yang dijaga: hanya dimulai dari aksi pengguna saat aplikasi terbuka (Android 15), tidak
 * pernah dimulai ulang sistem (`START_NOT_STICKY`), tidak merekam, tidak memanggil jaringan,
 * tidak membawa data pengguna, tidak tampil di layar kunci.
 */
class OverlayService : Service(), OverlayPanel.Actions {

    private lateinit var windowManager: WindowManager
    private val handler = Handler(Looper.getMainLooper())

    private var bubble: ImageView? = null
    private var bubbleParams: WindowManager.LayoutParams? = null
    private var panel: OverlayPanel? = null

    /** Akhir istirahat 1 jam: gelembung tampil lagi (layanan tetap hidup selama istirahat). */
    private val resumeFromRest = Runnable {
        OverlayPrefs.setSnoozeUntil(this, 0L)
        updateNotification(getString(R.string.overlay_notification_text))
        showBubble()
    }

    private val screenReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            when (intent.action) {
                // Gelembung disembunyikan saat layar mati atau terkunci, dan muncul lagi setelah
                // dibuka. Tidak mengubah status istirahat.
                Intent.ACTION_SCREEN_OFF -> {
                    hidePanel()
                    bubble?.visibility = View.GONE
                }
                Intent.ACTION_USER_PRESENT -> bubble?.visibility = View.VISIBLE
            }
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager
        createNotificationChannel()
        val filter = IntentFilter().apply {
            addAction(Intent.ACTION_SCREEN_OFF)
            addAction(Intent.ACTION_USER_PRESENT)
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(screenReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            registerReceiver(screenReceiver, filter)
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_START -> {
                // Wajib memanggil startForeground segera setelah startForegroundService.
                startInForeground(getString(R.string.overlay_notification_text))
                if (!Settings.canDrawOverlays(this)) {
                    turnOff()
                    return START_NOT_STICKY
                }
                running = true
                OverlayPrefs.setSnoozeUntil(this, 0L)
                showBubble()
            }

            ACTION_TURN_OFF -> turnOff()
            else -> stopSelf()
        }
        return START_NOT_STICKY
    }

    override fun onDestroy() {
        handler.removeCallbacksAndMessages(null)
        hidePanel()
        removeBubble()
        try {
            unregisterReceiver(screenReceiver)
        } catch (error: IllegalArgumentException) {
            // Sudah dilepas.
        }
        running = false
        super.onDestroy()
    }

    // --- Notifikasi -----------------------------------------------------------------------

    private fun createNotificationChannel() {
        val channel = NotificationChannel(
            CHANNEL_ID,
            getString(R.string.overlay_notification_channel),
            NotificationManager.IMPORTANCE_LOW,
        )
        getSystemService(NotificationManager::class.java).createNotificationChannel(channel)
    }

    private fun buildNotification(text: String): Notification {
        val openApp = PendingIntent.getActivity(
            this,
            0,
            Intent(this, MainActivity::class.java)
                .addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_REORDER_TO_FRONT),
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
        val turnOff = PendingIntent.getService(
            this,
            1,
            Intent(this, OverlayService::class.java).setAction(ACTION_TURN_OFF),
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
        val action = Notification.Action.Builder(
            Icon.createWithResource(this, R.mipmap.ic_launcher),
            getString(R.string.overlay_notification_turn_off),
            turnOff,
        ).build()

        return Notification.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(getString(R.string.overlay_notification_title))
            .setContentText(text)
            .setContentIntent(openApp)
            .setOngoing(true)
            .addAction(action)
            .build()
    }

    private fun startInForeground(text: String) {
        val notification = buildNotification(text)
        if (Build.VERSION.SDK_INT >= 34) {
            startForeground(
                NOTIFICATION_ID,
                notification,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE,
            )
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }
    }

    private fun updateNotification(text: String) {
        getSystemService(NotificationManager::class.java)
            .notify(NOTIFICATION_ID, buildNotification(text))
    }

    // --- Gelembung ------------------------------------------------------------------------

    private fun showBubble() {
        if (bubble != null || !Settings.canDrawOverlays(this)) {
            return
        }
        val metrics = resources.displayMetrics
        val width = dp(BUBBLE_WIDTH_DP)
        val height = (width * MASCOT_ASPECT).toInt()
        val onRight = OverlayPrefs.bubbleOnRight(this)
        val params = WindowManager.LayoutParams(
            width,
            height,
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL,
            PixelFormat.TRANSLUCENT,
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            x = if (onRight) metrics.widthPixels - width else 0
            y = OverlayPrefs.bubbleY(this@OverlayService, metrics.heightPixels / 3)
                .coerceIn(0, metrics.heightPixels - height)
        }

        val view = ImageView(this).apply {
            scaleType = ImageView.ScaleType.FIT_CENTER
            contentDescription = getString(R.string.overlay_bubble_description)
            setImageDrawable(loadMascot())
            setOnTouchListener(DragListener())
        }
        windowManager.addView(view, params)
        bubble = view
        bubbleParams = params
    }

    private fun removeBubble() {
        bubble?.let {
            (it.drawable as? AnimatedImageDrawable)?.stop()
            try {
                windowManager.removeView(it)
            } catch (error: IllegalArgumentException) {
                // Jendela sudah hilang.
            }
        }
        bubble = null
        bubbleParams = null
    }

    /**
     * Animasi `idle` yang sama dengan di aplikasi (WebP beranimasi di aset Flutter). Android 9+
     * memutarnya dengan `AnimatedImageDrawable`; di bawahnya, atau bila pengguna mematikan
     * animasi sistem, yang tampil gambar diam.
     */
    @android.annotation.TargetApi(Build.VERSION_CODES.P)
    private fun loadMascot(): Drawable? {
        val animate = Build.VERSION.SDK_INT >= Build.VERSION_CODES.P && animationsEnabled()
        try {
            if (animate) {
                val source = android.graphics.ImageDecoder.createSource(assets, MASCOT_ANIMATED)
                val drawable = android.graphics.ImageDecoder.decodeDrawable(source) { decoder, _, _ ->
                    decoder.setTargetSize(TARGET_WIDTH_PX, (TARGET_WIDTH_PX * MASCOT_ASPECT).toInt())
                }
                if (drawable is AnimatedImageDrawable) {
                    drawable.repeatCount = AnimatedImageDrawable.REPEAT_INFINITE
                    drawable.start()
                }
                return drawable
            }
            assets.open(MASCOT_STILL).use { stream ->
                return BitmapDrawable(resources, BitmapFactory.decodeStream(stream))
            }
        } catch (error: IOException) {
            return null
        }
    }

    private fun animationsEnabled(): Boolean =
        Settings.Global.getFloat(contentResolver, Settings.Global.ANIMATOR_DURATION_SCALE, 1f) != 0f

    /** Geser dengan jari; ketukan membuka panel; setelah dilepas, menempel ke tepi terdekat. */
    private inner class DragListener : View.OnTouchListener {
        private val slop = ViewConfiguration.get(this@OverlayService).scaledTouchSlop
        private var downRawX = 0f
        private var downRawY = 0f
        private var startX = 0
        private var startY = 0
        private var dragging = false

        override fun onTouch(view: View, event: MotionEvent): Boolean {
            val params = bubbleParams ?: return false
            when (event.actionMasked) {
                MotionEvent.ACTION_DOWN -> {
                    downRawX = event.rawX
                    downRawY = event.rawY
                    startX = params.x
                    startY = params.y
                    dragging = false
                }

                MotionEvent.ACTION_MOVE -> {
                    val dx = event.rawX - downRawX
                    val dy = event.rawY - downRawY
                    if (!dragging && (kotlin.math.abs(dx) > slop || kotlin.math.abs(dy) > slop)) {
                        dragging = true
                        hidePanel()
                    }
                    if (dragging) {
                        params.x = startX + dx.toInt()
                        params.y = startY + dy.toInt()
                        windowManager.updateViewLayout(view, params)
                    }
                }

                MotionEvent.ACTION_UP -> {
                    if (dragging) {
                        snapToEdge(view, params)
                    } else {
                        view.performClick()
                        togglePanel()
                    }
                }
            }
            return true
        }
    }

    private fun snapToEdge(view: View, params: WindowManager.LayoutParams) {
        val metrics = resources.displayMetrics
        val maxX = metrics.widthPixels - params.width
        val onRight = params.x + params.width / 2 > metrics.widthPixels / 2
        params.x = if (onRight) maxX else 0
        params.y = params.y.coerceIn(0, metrics.heightPixels - params.height)
        windowManager.updateViewLayout(view, params)
        OverlayPrefs.setBubblePosition(this, params.y, onRight)
    }

    // --- Panel ----------------------------------------------------------------------------

    private fun togglePanel() {
        if (panel != null) hidePanel() else showPanel()
    }

    private fun showPanel() {
        val anchor = bubbleParams ?: return
        val metrics = resources.displayMetrics
        val view = OverlayPanel(this, this)
        val width = dp(OverlayPanel.WIDTH_DP).coerceAtMost(metrics.widthPixels - dp(16))
        view.measure(
            View.MeasureSpec.makeMeasureSpec(width, View.MeasureSpec.EXACTLY),
            View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED),
        )
        val height = view.measuredHeight
        val gap = dp(8)
        val below = anchor.y + anchor.height + gap
        val y = if (below + height <= metrics.heightPixels) below else (anchor.y - gap - height).coerceAtLeast(0)
        val x = (anchor.x + anchor.width / 2 - width / 2).coerceIn(dp(8), metrics.widthPixels - width - dp(8))

        val params = WindowManager.LayoutParams(
            width,
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or
                WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH,
            PixelFormat.TRANSLUCENT,
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            this.x = x
            this.y = y
        }
        windowManager.addView(view, params)
        panel = view
    }

    private fun hidePanel() {
        panel?.let {
            try {
                windowManager.removeView(it)
            } catch (error: IllegalArgumentException) {
                // Jendela sudah hilang.
            }
        }
        panel = null
    }

    // --- Aksi panel -----------------------------------------------------------------------

    override fun onChat() {
        hidePanel()
        val intent = Intent(this, MainActivity::class.java)
            .addFlags(
                Intent.FLAG_ACTIVITY_NEW_TASK or
                    Intent.FLAG_ACTIVITY_SINGLE_TOP or
                    Intent.FLAG_ACTIVITY_REORDER_TO_FRONT,
            )
        try {
            startActivity(intent)
        } catch (error: RuntimeException) {
            // Sistem menolak membuka dari latar belakang; pengguna tetap bisa lewat notifikasi.
        }
    }

    override fun onRestHour() {
        hidePanel()
        removeBubble()
        val until = System.currentTimeMillis() + HOUR_MILLIS
        OverlayPrefs.setSnoozeUntil(this, until)
        updateNotification(getString(R.string.overlay_notification_resting))
        handler.removeCallbacks(resumeFromRest)
        handler.postDelayed(resumeFromRest, HOUR_MILLIS)
    }

    /**
     * "Sampai besok": layanan berhenti dan waktu istirahat disimpan. Tidak ada pemulihan
     * otomatis dari latar belakang (Android 15); saat aplikasi dibuka lagi setelah waktunya,
     * pengguna menyalakan maskot kembali (TASK-M034).
     */
    override fun onRestTomorrow() {
        val tomorrow = Calendar.getInstance().apply {
            add(Calendar.DAY_OF_YEAR, 1)
            set(Calendar.HOUR_OF_DAY, 0)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
        }.timeInMillis
        shutDown(snoozeUntil = tomorrow)
    }

    override fun onTurnOff() = turnOff()

    override fun onDismissPanel() = hidePanel()

    private fun turnOff() = shutDown(snoozeUntil = 0L)

    /** Berhenti sepenuhnya; pilihan "tampilkan maskot" dimatikan agar layar Pengaturan jujur. */
    private fun shutDown(snoozeUntil: Long) {
        OverlayPrefs.setEnabled(this, false)
        OverlayPrefs.setSnoozeUntil(this, snoozeUntil)
        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
    }

    private fun dp(value: Int): Int = (value * resources.displayMetrics.density).toInt()

    companion object {
        const val ACTION_START = "id.my.relaxboss.relaxmate.overlay.START"
        const val ACTION_TURN_OFF = "id.my.relaxboss.relaxmate.overlay.TURN_OFF"

        private const val CHANNEL_ID = "overlay_mascot"
        private const val NOTIFICATION_ID = 4201

        /** Lebar gelembung 64dp (Design-M OVL-M01); tinggi mengikuti rasio gambar 360x491. */
        private const val BUBBLE_WIDTH_DP = 64
        private const val MASCOT_ASPECT = 491f / 360f
        private const val TARGET_WIDTH_PX = 192
        private const val HOUR_MILLIS = 60L * 60L * 1000L

        private const val MASCOT_ANIMATED = "flutter_assets/assets/images/mascot/anim/idle.webp"
        private const val MASCOT_STILL = "flutter_assets/assets/images/mascot/relaxmate-half.webp"

        /** Layanan sedang berjalan di proses ini. */
        @Volatile
        var running: Boolean = false
            private set
    }
}
