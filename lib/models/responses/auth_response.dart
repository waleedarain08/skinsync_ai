import 'dart:io';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:version/version.dart';

import 'appointments_list_response.dart';
import 'base_response_model.dart';
import 'practitioner_list_response.dart';
import 'treatment_list_response.dart';

class AuthResponse extends BaseResponseModel {
  final AuthData? data;

  AuthResponse({super.isSuccess, super.message, this.data});

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
    isSuccess: json["is_success"],
    message: json["message"],
    data: json["data"] == null ? null : AuthData.fromJson(json["data"]),
  );
}

class AuthData {
  final bool? isFirstLogin;
  final bool? pushNotification;
  final bool? isActive;
  final String? accessToken;
  final String? refreshToken;
  final int? isActiveExpiry;
  final int? refreshTokenExpiry;
  final AppVersionInfo? android;
  final AppVersionInfo? ios;
  final List<TreatmentData>? treatment;
  final User? user;
  final DashboardData? dashboard;

  AuthData({
    this.isFirstLogin,
    this.isActive,
    this.pushNotification,
    this.accessToken,
    this.refreshToken,
    this.isActiveExpiry,
    this.refreshTokenExpiry,
    this.user,
    this.dashboard,
    this.treatment,
    this.android,
    this.ios,
  });

  factory AuthData.fromJson(Map<String, dynamic> json) => AuthData(
    isFirstLogin: json["is_first_login"],
    isActive: json["is_active"],
    pushNotification: json['push_notification'],
    accessToken: json["access_token"],
    refreshToken: json["refresh_token"],
    isActiveExpiry: json["is_active_expiry"],
    refreshTokenExpiry: json["refresh_token_expiry"],
    treatment: json["treatment"] == null
        ? []
        : List<TreatmentData>.from(
            json["treatment"]!.map((x) => TreatmentData.fromJson(x)),
          ),
    user: json["user"] == null ? null : User.fromJson(json["user"]),
    dashboard: json["dashboard"] == null || json["dashboard"] is String
        ? null
        : DashboardData.fromJson(json["dashboard"]),
    android: json["android"] == null
        ? null
        : AppVersionInfo.fromJson(json["android"]),
    ios: json["ios"] == null ? null : AppVersionInfo.fromJson(json["ios"]),
  );

  Future<bool> isUpdateAvailable() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final int currentBuildNumber = int.tryParse(packageInfo.buildNumber) ?? 0;
    int? serverBuildNumber;
    String? versionNumber;

    if (Platform.isAndroid) {
      serverBuildNumber = android?.build;
      versionNumber = android?.version;
    } else if (Platform.isIOS) {
      serverBuildNumber = ios?.build;
      versionNumber = ios?.version;
    }
    if (versionNumber != null) {
      final serverVersion = Version.parse(versionNumber);
      final currentVersion = Version.parse(packageInfo.version);
      if (serverVersion > currentVersion) {
        return true;
      }
    }
    if (serverBuildNumber != null && serverBuildNumber > currentBuildNumber) {
      return true;
    }
    return false;
  }

  AuthData copyWith({
    bool? isFirstLogin,
    bool? pushNotification,
    bool? isActive,
    String? accessToken,
    String? refreshToken,
    int? isActiveExpiry,
    int? refreshTokenExpiry,
    AppVersionInfo? android,
    AppVersionInfo? ios,
    List<TreatmentData>? treatment,
    User? user,
    DashboardData? dashboard,
  }) {
    return AuthData(
      isFirstLogin: isFirstLogin ?? this.isFirstLogin,
      pushNotification: pushNotification ?? this.pushNotification,
      isActive: isActive ?? this.isActive,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      isActiveExpiry: isActiveExpiry ?? this.isActiveExpiry,
      refreshTokenExpiry: refreshTokenExpiry ?? this.refreshTokenExpiry,
      android: android ?? this.android,
      ios: ios ?? this.ios,
      treatment: treatment ?? this.treatment,
      user: user ?? this.user,
      dashboard: dashboard ?? this.dashboard,
    );
  }
}

class AppVersionInfo {
  final String? version;
  final int? build;

  AppVersionInfo({this.version, this.build});

  factory AppVersionInfo.fromJson(Map<String, dynamic> json) =>
      AppVersionInfo(version: json["version"], build: json["build"]);

  Map<String, dynamic> toJson() => {"version": version, "build": build};
}

class User {
  final int? id;
  final String? name;
  final String? email;
  final String? role;
  final String? profileImageUrl;
  final String? primaryEmail;
  final String? phoneNumber;
  final String? location;
  final String? bio;
  final String? dob;
  final String? cc;
  final String? country;

  User({
    this.id,
    this.name,
    this.email,
    this.role,
    this.profileImageUrl,
    this.primaryEmail,
    this.dob,
    this.phoneNumber,
    this.location,
    this.bio,
    this.country,
    this.cc,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    name: json["name"],
    email: json["email"],
    role: json["role"],
    profileImageUrl: json["profile_image_url"],
    primaryEmail: json["primary_email"] ?? json["email"],
    phoneNumber: json["phone_number"],
    location: json["location"],
    bio: json["bio"],
    dob: json['dob'],
    country: json["country"],
    cc: json["cc"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "role": role,
    "profile_image_url": profileImageUrl,
    "primary_email": primaryEmail,
    "phone_number": phoneNumber,
    "location": location,
    "bio": bio,
    "country": country,
    "cc": cc,
    "dob": dob,
  };
}

class DashboardData {
  final List<AppointmentItem>? appointments;
  final List<TreatmentData>? suggestedTreatments;
  final List<TopDoctor>? topDoctors;
  final List<TopClinic>? topClinics;
  final List<RequestClinicTreatmentModel>? requestTreatmentClinic;
  final List<DashboardSimulation>? recentSimulations;

  DashboardData({
    this.appointments,
    this.suggestedTreatments,
    this.topDoctors,
    this.topClinics,
    this.requestTreatmentClinic,
    this.recentSimulations,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) => DashboardData(
    appointments: json["appointments"] == null
        ? []
        : List<AppointmentItem>.from(
            json["appointments"]!.map((x) => AppointmentItem.fromJson(x)),
          ),
    suggestedTreatments: json["suggested_treatments"] == null
        ? []
        : List<TreatmentData>.from(
            json["suggested_treatments"]!.map((x) => TreatmentData.fromJson(x)),
          ),
    topDoctors: json["top_doctors"] == null
        ? []
        : List<TopDoctor>.from(
            json["top_doctors"]!.map((x) => TopDoctor.fromJson(x)),
          ),
    topClinics: json["top_clinics"] == null
        ? []
        : List<TopClinic>.from(
            json["top_clinics"]!.map((x) => TopClinic.fromJson(x)),
          ),
    requestTreatmentClinic: json["request_clinic_treatments"] == null
        ? []
        : List<RequestClinicTreatmentModel>.from(
            json["request_clinic_treatments"].map(
              (x) => RequestClinicTreatmentModel.fromJson(x),
            ),
          ),
    recentSimulations: json['recent_simulations'] == null
        ? []
        : List<DashboardSimulation>.from(
            json['recent_simulations'].map(
              (x) => DashboardSimulation.fromJson(x),
            ),
          ),
  );

  Map<String, dynamic> toJson() => {
    "appointments": appointments?.map((x) => x.toJson()).toList(),
    "suggested_treatments": suggestedTreatments
        ?.map((x) => x.toJson())
        .toList(),
    "top_doctors": topDoctors?.map((x) => x.toJson()).toList(),
    "top_clinics": topClinics?.map((x) => x.toJson()).toList(),
    "request_clinic_treatments": requestTreatmentClinic
        ?.map((x) => x.toJson())
        .toList(),
  };

  DashboardData copyWith({
    List<AppointmentItem>? appointments,
    List<TreatmentData>? suggestedTreatments,
    List<TopDoctor>? topDoctors,
    List<TopClinic>? topClinics,
    List<RequestClinicTreatmentModel>? requestTreatmentClinic,
    List<DashboardSimulation>? recentSimulations,
  }) {
    return DashboardData(
      appointments: appointments ?? this.appointments,
      suggestedTreatments: suggestedTreatments ?? this.suggestedTreatments,
      topDoctors: topDoctors ?? this.topDoctors,
      topClinics: topClinics ?? this.topClinics,
      requestTreatmentClinic:
          requestTreatmentClinic ?? this.requestTreatmentClinic,
      recentSimulations: recentSimulations ?? this.recentSimulations,
    );
  }
}

class RequestClinicTreatmentModel {
  final int? id;
  final String? clinicName;
  final String? clinicEmail;
  final String? image;
  final String? address;
  final int? chatId;
  final int? totalTreatmentCount;

  RequestClinicTreatmentModel({
    this.id,
    this.clinicName,
    this.clinicEmail,
    this.image,
    this.address,
    this.chatId,
    this.totalTreatmentCount,
  });

  factory RequestClinicTreatmentModel.fromJson(Map<String, dynamic> json) {
    return RequestClinicTreatmentModel(
      id: json['id'],
      clinicName: json['clinic_name'],
      clinicEmail: json['clinic_email'],
      image: json['image'],
      address: json['address'],
      chatId: json['chat_id'],
      totalTreatmentCount: json['total_treatment_count'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'clinic_name': clinicName,
    'clinic_email': clinicEmail,
    'image': image,
    'address': address,
    'total_treatment_count': totalTreatmentCount,
  };

  RequestClinicTreatmentModel copyWith({
    int? id,
    String? clinicName,
    String? clinicEmail,
    String? image,
    String? address,
    int? chatId,
    int? totalTreatmentCount,
  }) {
    return RequestClinicTreatmentModel(
      id: id ?? this.id,
      clinicName: clinicName ?? this.clinicName,
      clinicEmail: clinicEmail ?? this.clinicEmail,
      image: image ?? this.image,
      address: address ?? this.address,
      chatId: chatId ?? this.chatId,
      totalTreatmentCount: totalTreatmentCount ?? this.totalTreatmentCount,
    );
  }
}

class DashboardSimulation {
  final int? id;
  final String? name;
  final String? frontImageBefore;
  final String? frontImageAfter;

  const DashboardSimulation({
    this.id,
    this.name,
    this.frontImageBefore,
    this.frontImageAfter,
  });

  factory DashboardSimulation.fromJson(Map<String, dynamic> json) =>
      DashboardSimulation(
        id: json["id"],
        name: json["name"],
        frontImageBefore: json["front_image_before"],
        frontImageAfter: json["front_image_after"],
      );
}

class DashboardDoctor {
  final int? doctorId;
  final String? doctorName;
  final String? doctorImage;

  DashboardDoctor({this.doctorId, this.doctorName, this.doctorImage});

  factory DashboardDoctor.fromJson(Map<String, dynamic> json) =>
      DashboardDoctor(
        doctorId: json["doctor_id"],
        doctorName: json["doctor_name"],
        doctorImage: json["doctor_image"],
      );

  Map<String, dynamic> toJson() => {
    "doctor_id": doctorId,
    "doctor_name": doctorName,
    "doctor_image": doctorImage,
  };
}

class DashboardClinic {
  final int? clinicId;
  final String? clinicName;
  final String? clinicImage;

  DashboardClinic({this.clinicId, this.clinicName, this.clinicImage});

  factory DashboardClinic.fromJson(Map<String, dynamic> json) =>
      DashboardClinic(
        clinicId: json["clinic_id"],
        clinicName: json["clinic_name"],
        clinicImage: json["clinic_image"],
      );

  Map<String, dynamic> toJson() => {
    "clinic_id": clinicId,
    "clinic_name": clinicName,
    "clinic_image": clinicImage,
  };
}

class TopDoctor {
  final int? doctorId;
  final String? doctorImage;
  final num? doctorRating;
  final String? doctorName;
  final String? specialization;
  final DashboardClinic? clinic;

  TopDoctor({
    this.doctorId,
    this.doctorImage,
    this.doctorRating,
    this.doctorName,
    this.specialization,
    this.clinic,
  });

  factory TopDoctor.fromJson(Map<String, dynamic> json) => TopDoctor(
    doctorId: json["doctor_id"],
    doctorImage: json["doctor_image"],
    doctorRating: json["doctor_rating"],
    doctorName: json["doctor_name"],
    specialization: json["specialization"],
    clinic: json["clinic"] == null
        ? null
        : DashboardClinic.fromJson(json["clinic"]),
  );

  Map<String, dynamic> toJson() => {
    "doctor_id": doctorId,
    "doctor_image": doctorImage,
    "doctor_rating": doctorRating,
    "doctor_name": doctorName,
    "specaialization": specialization,
    "clinic": clinic?.toJson(),
  };

  PractitionerDoctor toPractitionerDoctor() {
    return PractitionerDoctor(
      id: doctorId,
      image: doctorImage,
      rating: doctorRating,
      name: doctorName,
      specialization: specialization,
      clinic: clinic != null
          ? PractitionerClinic(
              clinicId: clinic!.clinicId,
              clinicName: clinic!.clinicName,
            )
          : null,
    );
  }
}

class TopClinic {
  final int? clinicId;
  final String? clinicImage;
  final num? clinicRating;
  final String? clinicName;
  final String? address;
  final int? doctorCount;
  final String? banner;

  TopClinic({
    this.clinicId,
    this.clinicImage,
    this.clinicRating,
    this.clinicName,
    this.address,
    this.doctorCount,
    this.banner,
  });

  factory TopClinic.fromJson(Map<String, dynamic> json) => TopClinic(
    clinicId: json["clinic_id"],
    clinicImage: json["clinic_image"],
    clinicRating: json["clinic_rating"],
    clinicName: json["clinic_name"],
    address: json["address"],
    doctorCount: json["doctor_count"],
    banner: json["banner"],
  );

  Map<String, dynamic> toJson() => {
    "clinic_id": clinicId,
    "clinic_image": clinicImage,
    "clinic_rating": clinicRating,
    "clinic_name": clinicName,
    "address": address,
    "doctor_count": doctorCount,
    "banner": banner,
  };
}
