class OtpRequest {
  final String email;
  final String otp;
  final String fcmToken;
  final String? timezone;
  final String? utcOffset;

  OtpRequest({
    required this.email,
    required this.otp,
    required this.fcmToken,
    this.timezone,
    this.utcOffset,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'otp': otp,
      'fcm_token': fcmToken,
      if (timezone != null) 'timezone': timezone,
      if (utcOffset != null) 'utc_offset': utcOffset,
    };
  }
}
