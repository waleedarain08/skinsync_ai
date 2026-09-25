import '../../utils/enums.dart';

abstract class BaseSignInRequest {
  final LoginProviders provider;
  final String deviceInfo;
  final String ipAddress;
  final String? timezone;
  final String? utcOffset;

  const BaseSignInRequest({
    required this.provider,
    required this.deviceInfo,
    required this.ipAddress,
    this.timezone,
    this.utcOffset,
  });

  BaseSignInRequest copyWith({String? timezone, String? utcOffset});

  Map<String, dynamic> toJson();
}

class SignInWithPhoneRequest extends BaseSignInRequest {
  final String phone;

  const SignInWithPhoneRequest({
    required this.phone,
    required super.provider,
    required super.deviceInfo,
    required super.ipAddress,
    super.timezone,
    super.utcOffset,
  });

  @override
  SignInWithPhoneRequest copyWith({String? timezone, String? utcOffset}) {
    return SignInWithPhoneRequest(
      phone: phone,
      provider: provider,
      deviceInfo: deviceInfo,
      ipAddress: ipAddress,
      timezone: timezone ?? this.timezone,
      utcOffset: utcOffset ?? this.utcOffset,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'provider': provider.name,
      'device_info': deviceInfo,
      'ip_address': ipAddress,
      if (timezone != null) 'timezone': timezone,
      if (utcOffset != null) 'utc_offset': utcOffset,
    };
  }
}

class SignInWithEmailRequest extends BaseSignInRequest {
  final String email;

  const SignInWithEmailRequest({
    required this.email,
    required super.provider,
    required super.deviceInfo,
    required super.ipAddress,
    super.timezone,
    super.utcOffset,
  });

  @override
  SignInWithEmailRequest copyWith({String? timezone, String? utcOffset}) {
    return SignInWithEmailRequest(
      email: email,
      provider: provider,
      deviceInfo: deviceInfo,
      ipAddress: ipAddress,
      timezone: timezone ?? this.timezone,
      utcOffset: utcOffset ?? this.utcOffset,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'provider': provider.name,
      'device_info': deviceInfo,
      'ip_address': ipAddress,
      if (timezone != null) 'timezone': timezone,
      if (utcOffset != null) 'utc_offset': utcOffset,
    };
  }
}

class SignInWithGoogleRequest extends BaseSignInRequest {
  final String email;
  final String googleUid;
  final String userName;

  const SignInWithGoogleRequest({
    required this.email,
    required this.googleUid,
    required this.userName,
    required super.provider,
    required super.deviceInfo,
    required super.ipAddress,
    super.timezone,
    super.utcOffset,
  });

  @override
  SignInWithGoogleRequest copyWith({String? timezone, String? utcOffset}) {
    return SignInWithGoogleRequest(
      email: email,
      googleUid: googleUid,
      userName: userName,
      provider: provider,
      deviceInfo: deviceInfo,
      ipAddress: ipAddress,
      timezone: timezone ?? this.timezone,
      utcOffset: utcOffset ?? this.utcOffset,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'google_uid': googleUid,
      'user_name': userName,
      'provider': provider.name,
      'device_info': deviceInfo,
      'ip_address': ipAddress,
      if (timezone != null) 'timezone': timezone,
      if (utcOffset != null) 'utc_offset': utcOffset,
    };
  }
}

class SignInWithAppleRequest extends BaseSignInRequest {
  final String email;
  final String appleUid;
  final String userName;

  const SignInWithAppleRequest({
    required this.email,
    required this.appleUid,
    required this.userName,
    required super.provider,
    required super.deviceInfo,
    required super.ipAddress,
    super.timezone,
    super.utcOffset,
  });

  @override
  SignInWithAppleRequest copyWith({String? timezone, String? utcOffset}) {
    return SignInWithAppleRequest(
      email: email,
      appleUid: appleUid,
      userName: userName,
      provider: provider,
      deviceInfo: deviceInfo,
      ipAddress: ipAddress,
      timezone: timezone ?? this.timezone,
      utcOffset: utcOffset ?? this.utcOffset,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'apple_uid': appleUid,
      'user_name': userName,
      'provider': provider.name,
      'device_info': deviceInfo,
      'ip_address': ipAddress,
      if (timezone != null) 'timezone': timezone,
      if (utcOffset != null) 'utc_offset': utcOffset,
    };
  }
}

class SocialLoginRequest {
  final String deviceType;
  final String idToken;
  final String fcmToken;
  final String? timezone;
  final String? utcOffset;

  const SocialLoginRequest({
    required this.deviceType,
    required this.idToken,
    required this.fcmToken,
    this.timezone,
    this.utcOffset,
  });

  SocialLoginRequest copyWith({
    String? deviceType,
    String? idToken,
    String? fcmToken,
    String? timezone,
    String? utcOffset,
  }) {
    return SocialLoginRequest(
      deviceType: deviceType ?? this.deviceType,
      idToken: idToken ?? this.idToken,
      fcmToken: fcmToken ?? this.fcmToken,
      timezone: timezone ?? this.timezone,
      utcOffset: utcOffset ?? this.utcOffset,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'device_type': deviceType,
      'id_token': idToken,
      'fcm_token': fcmToken,
      if (timezone != null) 'timezone': timezone,
      if (utcOffset != null) 'utc_offset': utcOffset,
    };
  }
}
