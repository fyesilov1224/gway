import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

import '../domain/security.dart';

/// Reads the location check signals on this device (docs/ARCHITECTURE.md §3h, Sinyaller).
class PlatformDeviceSignalSource implements DeviceSignalSource {
  /// Android only: `MainActivity` answers `simCountry` with TelephonyManager's SIM country.
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
    return LocationRead(DeviceSignals(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      isMocked: position.isMocked,
      vpn: network.contains(ConnectivityResult.vpn),
      simCountry: await _simCountry(),
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

  static Future<String?> _simCountry() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return null;
    try {
      final code = await _device.invokeMethod<String>('simCountry');
      return code == null || code.isEmpty ? null : code.toUpperCase();
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }
}
