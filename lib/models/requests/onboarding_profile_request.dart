class OnBoardingProfileRequest {
  final String name;
  final String phoneNumber;
  final String emailAddress;
  final String? location;
  final String? bio;
  final String? profileImageUrl;
  final String? cc;
  final String? country;
  final String? dob;
  final String? timezone;
  final String? utcOffset;

  OnBoardingProfileRequest({
    required this.name,
    required this.phoneNumber,
    required this.emailAddress,
    this.location,
    this.bio,
    this.profileImageUrl,
    this.cc,
    this.country,
    this.dob,
    this.timezone,
    this.utcOffset,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone_number': phoneNumber,
      'email_address': emailAddress,
      'location': location,
      'bio': bio,
      'profile_image_url': profileImageUrl,
      'cc': cc,
      'country': country,
      'dob': dob,
      if (timezone != null) 'timezone': timezone,
      if (utcOffset != null) 'utc_offset': utcOffset,
    };
  }
}
