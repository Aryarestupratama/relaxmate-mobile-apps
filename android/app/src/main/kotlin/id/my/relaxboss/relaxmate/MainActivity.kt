package id.my.relaxboss.relaxmate

import id.my.relaxboss.relaxmate.overlay.OverlayChannel
import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    private var overlayChannel: OverlayChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        overlayChannel = OverlayChannel(this, flutterEngine.dartExecutor.binaryMessenger)
        overlayChannel?.onLaunchIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        overlayChannel?.onLaunchIntent(intent)
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        overlayChannel?.dispose()
        overlayChannel = null
        super.cleanUpFlutterEngine(flutterEngine)
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        overlayChannel?.onPermissionResult(requestCode, grantResults)
    }
}
