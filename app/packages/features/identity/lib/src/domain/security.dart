import 'package:core/core.dart';

/// What the user must do before the app opens (docs/ARCHITECTURE.md §3h, Akış).
enum SecurityStep { location, phone, secondFactor, restricted, done }

class SecurityStatus {
  const SecurityStatus({
    required this.enforced,
    required this.sessionVerified,
    required this.step,
    this.allowedCountry,
    this.callingCode,
    this.phoneMasked,
    this.totpEnabled = false,
  });

  factory SecurityStatus.fromJson(Map<String, Object?> j) => SecurityStatus(
        enforced: j['enforced']! as bool,
        sessionVerified: j['sessionVerified']! as bool,
        step: switch (j['step']) {
          'location' => SecurityStep.location,
          'phone' => SecurityStep.phone,
          'second_factor' => SecurityStep.secondFactor,
          'restricted' => SecurityStep.restricted,
          _ => SecurityStep.done,
        },
        allowedCountry: j['allowedCountry'] as String?,
        callingCode: j['callingCode'] as int?,
        phoneMasked: j['phoneMasked'] as String?,
        totpEnabled: j['totpEnabled']! as bool,
      );

  final bool enforced;
  final bool sessionVerified;
  final SecurityStep step;

  /// The country the phone number must belong to; its dialling code is locked in the form.
  final String? allowedCountry;
  final int? callingCode;
  final String? phoneMasked;
  final bool totpEnabled;
}

/// What the device reports for a location check. The server derives the countries itself.
class DeviceSignals {
  const DeviceSignals({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.isMocked,
    required this.vpn,
    required this.simCountry,
    required this.platform,
  });

  final double latitude;
  final double longitude;
  final double? accuracy;
  final bool isMocked;
  final bool vpn;
  final String? simCountry;

  /// `android`, `ios` or `web`.
  final String platform;

  Map<String, Object?> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'accuracy': accuracy,
        'isMocked': isMocked,
        'vpn': vpn,
        'simCountry': simCountry,
        'platform': platform,
      };
}

/// The outcome of asking the device for its location.
sealed class LocationReading {
  const LocationReading();
}

final class LocationRead extends LocationReading {
  const LocationRead(this.signals);

  final DeviceSignals signals;
}

/// Permission refused. When [permanently], only the system settings can grant it.
final class LocationDenied extends LocationReading {
  const LocationDenied({required this.permanently});

  final bool permanently;
}

/// Location services are switched off on the device.
final class LocationServiceOff extends LocationReading {
  const LocationServiceOff();
}

/// The device side: permission, position and network signals.
abstract interface class DeviceSignalSource {
  /// True when permission is already granted, without asking.
  Future<bool> hasPermission();

  /// Asks for permission if needed, then reads the position.
  Future<LocationReading> read();

  Future<void> openSettings();
}

class TotpSetup {
  const TotpSetup({required this.secret, required this.uri});

  factory TotpSetup.fromJson(Map<String, Object?> j) =>
      TotpSetup(secret: j['secret']! as String, uri: j['uri']! as String);

  /// Base32, for typing into an authenticator app by hand.
  final String secret;

  /// `otpauth://` link, shown as a QR code and opened on the same phone.
  final String uri;
}

abstract interface class SecurityRepository {
  Future<Result<SecurityStatus>> status();

  Future<Result<SecurityStatus>> sendLocation(DeviceSignals signals);

  /// [phone] in E.164 (`+905321234567`).
  Future<Result<void>> startPhone(String phone);

  Future<Result<SecurityStatus>> verifyPhone(String phone, String code);

  Future<Result<void>> startSecondFactor();

  /// [method] is `sms` or `totp`.
  Future<Result<SecurityStatus>> verifySecondFactor(String method, String code);

  Future<Result<TotpSetup>> beginTotp();

  Future<Result<void>> confirmTotp(String code);

  Future<Result<void>> deleteTotp();
}
