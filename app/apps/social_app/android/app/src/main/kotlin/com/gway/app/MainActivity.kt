package com.gway.app

import android.content.Context
import android.content.Intent
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.net.VpnService
import android.telephony.TelephonyManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
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
