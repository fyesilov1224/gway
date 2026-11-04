package com.gway.app

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder
import android.util.Log

/**
 * Keeps a voice call's microphone and audio running while the app is in the background, the screen is locked or
 * another app is open (docs/ARCHITECTURE.md §8c, Arka planda görüşme): Android cuts a background app's microphone
 * unless a microphone foreground service runs. Started by the call screen once the audio connects, stopped when the
 * call ends.
 */
class CallAudioService : Service() {
    companion object {
        private const val TAG = "CallAudioService"
        private const val CHANNEL_ID = "gway_call_ongoing"
        private const val NOTIFICATION_ID = 0x6A11

        fun start(context: Context) {
            val intent = Intent(context, CallAudioService::class.java)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(intent)
            } else {
                context.startService(intent)
            }
        }

        fun stop(context: Context) {
            context.stopService(Intent(context, CallAudioService::class.java))
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        try {
            val notification = buildNotification()
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                startForeground(NOTIFICATION_ID, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_MICROPHONE)
            } else {
                startForeground(NOTIFICATION_ID, notification)
            }
        } catch (e: Exception) {
            // E.g. the microphone permission was taken away: the call goes on while the app is open.
            Log.w(TAG, "Could not keep the call running in the background", e)
            stopSelf()
        }
        // A killed app has no call to keep: never restarted without one.
        return START_NOT_STICKY
    }

    private fun buildNotification(): Notification {
        val manager = getSystemService(NotificationManager::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && manager?.getNotificationChannel(CHANNEL_ID) == null) {
            manager?.createNotificationChannel(
                NotificationChannel(CHANNEL_ID, "Süren görüşme", NotificationManager.IMPORTANCE_LOW).apply {
                    description = "Sesli görüşme sürerken görünür"
                    setShowBadge(false)
                },
            )
        }
        val open = packageManager.getLaunchIntentForPackage(packageName)?.apply {
            flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_REORDER_TO_FRONT
        }
        val tap = open?.let {
            PendingIntent.getActivity(this, 0, it, PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT)
        }
        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, CHANNEL_ID)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(this)
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            builder.setForegroundServiceBehavior(Notification.FOREGROUND_SERVICE_IMMEDIATE)
        }
        return builder
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle("Sesli görüşme sürüyor")
            .setContentText("Uçtan uca şifreli. Dönmek için dokun.")
            .setCategory(Notification.CATEGORY_CALL)
            .setOngoing(true)
            .setContentIntent(tap)
            .build()
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
