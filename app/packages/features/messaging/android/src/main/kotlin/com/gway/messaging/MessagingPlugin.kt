package com.gway.messaging

import android.content.Context
import android.media.AudioManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodChannel

/**
 * What the phone itself is doing (docs/ARCHITECTURE.md §8c, Başka görüşme sürerken). A plugin so that it also answers
 * in the background isolate that handles the ringing push, where the app's own channels do not exist.
 */
class MessagingPlugin : FlutterPlugin {
    private var channel: MethodChannel? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        val context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "gway/phone").apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "inOtherCall" -> result.success(inOtherCall(context))
                    else -> result.notImplemented()
                }
            }
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel?.setMethodCallHandler(null)
        channel = null
    }

    /**
     * A phone call (MODE_IN_CALL) or an app's voice call (MODE_IN_COMMUNICATION, e.g. WhatsApp) holds the audio.
     * No permission is needed, unlike the phone's call state.
     */
    private fun inOtherCall(context: Context): Boolean {
        val audio = context.getSystemService(Context.AUDIO_SERVICE) as? AudioManager ?: return false
        return audio.mode == AudioManager.MODE_IN_CALL || audio.mode == AudioManager.MODE_IN_COMMUNICATION
    }
}
