package com.gway.app

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.AudioManager
import android.media.RingtoneManager
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.net.VpnService
import android.os.Build
import android.os.Bundle
import android.os.VibrationEffect
import android.os.Vibrator
import android.telephony.TelephonyManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val keepAliveOwners = mutableSetOf<String>()

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
                NotificationChannel("gway_calls", "Sesli aramalar", NotificationManager.IMPORTANCE_HIGH).apply {
                    description = "Eşleştiğin kişilerden gelen sesli aramalar"
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
                "notificationSound" -> {
                    playNotificationSound()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
        // A voice call that goes on in the background (docs/ARCHITECTURE.md §8c, Arka planda görüşme).
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "gway/call").setMethodCallHandler { call, result ->
            when (call.method) {
                // A call and a live room each hold the service ("owner"); it stops when neither does.
                "keepAlive" -> {
                    keepAliveOwners.add(call.argument<String>("owner") ?: "call")
                    CallAudioService.start(
                        applicationContext,
                        call.argument<String>("title"),
                        call.argument<String>("text"),
                    )
                    result.success(null)
                }
                "release" -> {
                    keepAliveOwners.remove(call.argument<String>("owner") ?: "call")
                    if (keepAliveOwners.isEmpty()) CallAudioService.stop(applicationContext)
                    result.success(null)
                }
                // The back button during a call leaves the call running instead of hanging up.
                "toBackground" -> result.success(moveTaskToBack(true))
                else -> result.notImplemented()
            }
        }
    }

    override fun onDestroy() {
        // The app's screen is gone for good (not just in the background): its call has ended with it.
        if (isFinishing) CallAudioService.stop(applicationContext)
        super.onDestroy()
    }

    // A push while the app is open is not shown by Android, so the app rings it here (docs/ARCHITECTURE.md 3c,
    // Uygulama açıkken bildirim sesi): the phone's notification sound at notification volume, a short buzz in
    // vibrate mode, nothing in silent mode.
    private fun playNotificationSound() {
        when ((getSystemService(Context.AUDIO_SERVICE) as? AudioManager)?.ringerMode) {
            AudioManager.RINGER_MODE_NORMAL -> RingtoneManager.getRingtone(
                applicationContext,
                RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION),
            )?.apply {
                audioAttributes = AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_NOTIFICATION)
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .build()
                play()
            }
            AudioManager.RINGER_MODE_VIBRATE -> {
                @Suppress("DEPRECATION")
                val vibrator = getSystemService(Context.VIBRATOR_SERVICE) as? Vibrator ?: return
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    vibrator.vibrate(VibrationEffect.createOneShot(200, VibrationEffect.DEFAULT_AMPLITUDE))
                } else {
                    @Suppress("DEPRECATION")
                    vibrator.vibrate(200)
                }
            }
        }
    }
}
