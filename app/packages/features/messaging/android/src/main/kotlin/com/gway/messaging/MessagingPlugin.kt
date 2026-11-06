package com.gway.messaging

import android.content.Context
import android.content.Intent
import android.media.AudioManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry

/**
 * What the phone itself is doing (docs/ARCHITECTURE.md §8c, Başka görüşme sürerken). A plugin so that it also answers
 * in the background isolate that handles the ringing push, where the app's own channels do not exist.
 *
 * In the app's own engine it also reads Cevapla from the phone's incoming call screen off the intent that opens the
 * app (§8c, Cevapla her durumda açılır): the call plugin's own answer event can get lost (nobody listens yet, or its
 * receiver fails), the intent cannot.
 */
class MessagingPlugin : FlutterPlugin, ActivityAware, PluginRegistry.NewIntentListener {
    private var channel: MethodChannel? = null
    private var activity: ActivityPluginBinding? = null

    /** Answered calls not yet taken by the app. */
    private val answered = mutableListOf<String>()

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        val context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "gway/phone").apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "inOtherCall" -> result.success(inOtherCall(context))
                    "takeAnswered" -> {
                        result.success(answered.toList())
                        answered.clear()
                    }
                    else -> result.notImplemented()
                }
            }
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel?.setMethodCallHandler(null)
        channel = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding
        binding.addOnNewIntentListener(this)
        read(binding.activity.intent, notify = false)
    }

    override fun onDetachedFromActivityForConfigChanges() = onDetachedFromActivity()

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) = onAttachedToActivity(binding)

    override fun onDetachedFromActivity() {
        activity?.removeOnNewIntentListener(this)
        activity = null
    }

    override fun onNewIntent(intent: Intent): Boolean {
        read(intent, notify = true)
        return false
    }

    /**
     * The call plugin opens the app with its accept action and the call's data (AppUtils.getAppIntent). The action is
     * cleared once read, so the same intent (the activity coming back) does not answer twice.
     */
    private fun read(intent: Intent?, notify: Boolean) {
        if (intent?.action != ACCEPT) return
        val id = intent.getBundleExtra(CALL_DATA)?.getString(CALL_ID)
        intent.action = null
        if (id.isNullOrEmpty()) return
        val live = channel
        if (!notify || live == null) {
            answered.add(id)
            return
        }
        // Nobody listening yet in Dart: kept for takeAnswered at start.
        live.invokeMethod("answered", id, object : MethodChannel.Result {
            override fun success(result: Any?) {}

            override fun error(code: String, message: String?, details: Any?) {
                answered.add(id)
            }

            override fun notImplemented() {
                answered.add(id)
            }
        })
    }

    /**
     * A phone call (MODE_IN_CALL) or an app's voice call (MODE_IN_COMMUNICATION, e.g. WhatsApp) holds the audio.
     * No permission is needed, unlike the phone's call state.
     */
    private fun inOtherCall(context: Context): Boolean {
        val audio = context.getSystemService(Context.AUDIO_SERVICE) as? AudioManager ?: return false
        return audio.mode == AudioManager.MODE_IN_CALL || audio.mode == AudioManager.MODE_IN_COMMUNICATION
    }

    private companion object {
        // flutter_callkit_incoming 3.1.6: CallkitConstants.ACTION_CALL_ACCEPT, FlutterCallkitIncomingPlugin
        // .EXTRA_CALLKIT_CALL_DATA, CallkitConstants.EXTRA_CALLKIT_ID.
        const val ACCEPT = "com.hiennv.flutter_callkit_incoming.ACTION_CALL_ACCEPT"
        const val CALL_DATA = "EXTRA_CALLKIT_CALL_DATA"
        const val CALL_ID = "EXTRA_CALLKIT_ID"
    }
}
