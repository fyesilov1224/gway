import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

import '../domain/security.dart';

/// Reads the location check signals on this device (docs/ARCHITECTURE.md §3h, Sinyaller).
class PlatformDeviceSignalSource implements DeviceSignalSource {
  /// Android only: `MainActivity` answers `simCountry` (TelephonyManager), `vpnActive` (the active network has
  /// TRANSPORT_VPN) and `vpnApps` (apps offering android.net.VpnService).
  static const _device = MethodChannel('grupx/device');

  static const _timeout = Duration(seconds: 20);

  @override
  Future<bool> hasPermission() async =>
      switch (await Geolocator.checkPermission()) {
        LocationPermission.always || LocationPermission.whileInUse => true,
        _ => false,
      };

  @override
  Future<LocationReading> read() async {
    if (!kIsWeb && !await Geolocator.isLocationServiceEnabled()) return const LocationServiceOff();

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.deniedForever) return const LocationDenied(permanently: true);
    if (permission == LocationPermission.denied || permission == LocationPermission.unableToDetermine) {
      return const LocationDenied(permanently: false);
    }

    final Position position;
    try {
      position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium, timeLimit: _timeout),
      );
    } on LocationServiceDisabledException {
      return const LocationServiceOff();
    } on PermissionDeniedException {
      return const LocationDenied(permanently: false);
    }

    final network = await Connectivity().checkConnectivity();
    final sim = await _android<String>('simCountry');
    return LocationRead(DeviceSignals(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      isMocked: position.isMocked,
      vpn: await _android<bool>('vpnActive') ?? network.contains(ConnectivityResult.vpn),
      vpnApps: (await _android<List<Object?>>('vpnApps'))?.whereType<String>().toList() ?? const [],
      simCountry: sim == null || sim.isEmpty ? null : sim.toUpperCase(),
      platform: kIsWeb
          ? 'web'
          : defaultTargetPlatform == TargetPlatform.iOS
              ? 'ios'
              : 'android',
    ));
  }

  @override
  Future<void> openSettings() async {
    if (!kIsWeb) await Geolocator.openAppSettings();
  }

  /// Null off Android or when the platform cannot answer; the check then goes on without that signal.
  static Future<T?> _android<T>(String method) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return null;
    try {
      return await _device.invokeMethod<T>(method);
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }
}
