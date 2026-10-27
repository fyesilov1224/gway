package com.grupx.social_app

import android.content.Context
import android.telephony.TelephonyManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // SIM country for the security location check (docs/ARCHITECTURE.md 3h); needs no permission.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "grupx/device").setMethodCallHandler { call, result ->
            when (call.method) {
                "simCountry" -> result.success(
                    (getSystemService(Context.TELEPHONY_SERVICE) as? TelephonyManager)?.simCountryIso,
                )
                else -> result.notImplemented()
            }
        }
    }
}
