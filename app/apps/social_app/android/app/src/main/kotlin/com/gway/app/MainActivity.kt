package com.gway.app

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.net.VpnService
import android.os.Build
import android.os.Bundle
import android.telephony.TelephonyManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        createNotificationChannels()
    }

    // Push goes to these channels (docs/ARCHITECTURE.md 3c, Android bildirim kanalları): high importance rings with
    // the phone's notification sound and pops up, also while the app is closed. Creating them again changes nothing.
    private fun createNotificationChannels() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val manager = getSystemService(NotificationManager::class.java) ?: return
        manager.createNotificationChannels(
            listOf(
                NotificationChannel("gway_messages", "Mesajlar", NotificationManager.IMPORTANCE_HIGH).apply {
                    description = "Sohbetlerine ve grup sohbetlerine gelen mesajlar"
                },
                NotificationChannel("gway_general", "Bildirimler", NotificationManager.IMPORTANCE_HIGH).apply {
                    description = "Takip, beğeni, yorum, organizasyon ve canlı yayın bildirimleri"
                },
            ),
        )
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Signals for the security location check (docs/ARCHITECTURE.md 3h); none needs a runtime permission.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "gway/device").setMethodCallHandler { call, result ->
            when (call.method) {
                "simCountry" -> result.success(
                    (getSystemService(Context.TELEPHONY_SERVICE) as? TelephonyManager)?.simCountryIso,
                )
                "vpnActive" -> {
                    val connectivity = getSystemService(Context.CONNECTIVITY_SERVICE) as? ConnectivityManager
                    val capabilities = connectivity?.getNetworkCapabilities(connectivity.activeNetwork)
                    result.success(capabilities?.hasTransport(NetworkCapabilities.TRANSPORT_VPN) ?: false)
                }
                // Visible through the <queries> entry for android.net.VpnService in the manifest.
                "vpnApps" -> result.success(
                    packageManager.queryIntentServices(Intent(VpnService.SERVICE_INTERFACE), 0)
                        .map { it.serviceInfo.packageName }
                        .filter { it != packageName }
                        .distinct()
                        .take(20),
                )
                else -> result.notImplemented()
            }
        }
    }
}
