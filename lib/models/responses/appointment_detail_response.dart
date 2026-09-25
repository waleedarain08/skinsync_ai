import 'appointments_list_response.dart';
import 'base_response_model.dart';

class AppointmentDetailResponse extends BaseResponseModel {
  final AppointmentDetailData? data;

  AppointmentDetailResponse({super.isSuccess, super.message, this.data});

  factory AppointmentDetailResponse.fromJson(Map<String, dynamic> json) =>
      AppointmentDetailResponse(
        isSuccess: json["is_success"],
        message: json["message"],
        data: json["data"] != null
            ? AppointmentDetailData.fromJson(json["data"])
            : null,
      );

  Map<String, dynamic> toJson() => {
    "is_success": isSuccess,
    "message": message,
    "data": data?.toJson(),
  };
}

class AppointmentDetailData {
  int? id;
  String? appointmentKey;
  int? chatId;
  AppointmentClinic? clinic;
  Doctor? doctor;
  AppointmentPatient? patient;
  AppointmentType? appointmentType;
  int? date;
  int? startTime;
  int? endTime;
  bool? isInviteClinic;
  Simulations? simulations;
  List<DetailedAppointmentTreatment>? treatments;
  double? treatmentTotal;
  PaymentType? paymentType;
  String? discountType;
  double? discount;
  double? amountPaid;
  double? payable;
  String? bookingType;
  String? status;
  String? createdAt;

  AppointmentDetailData({
    this.id,
    this.appointmentKey,
    this.chatId,
    this.clinic,
    this.doctor,
    this.patient,
    this.appointmentType,
    this.date,
    this.startTime,
    this.endTime,
    this.isInviteClinic,
    this.simulations,
    this.treatments,
    this.treatmentTotal,
    this.paymentType,
    this.discountType,
    this.discount,
    this.amountPaid,
    this.payable,
    this.bookingType,
    this.status,
    this.createdAt,
  });

  AppointmentDetailData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    appointmentKey = json['appointment_key'];
    chatId = json['chat_id'];
    clinic = json['clinic'] != null
        ? AppointmentClinic.fromJson(json['clinic'])
        : null;
    doctor = json['doctor'] != null ? Doctor.fromJson(json['doctor']) : null;
    patient = json['patient'] != null
        ? AppointmentPatient.fromJson(json['patient'])
        : null;
    appointmentType = json['appointment_type'] != null
        ? AppointmentType.fromJson(json['appointment_type'])
        : null;
    date = json['date'];
    startTime = json['start_time'];
    endTime = json['end_time'];
    isInviteClinic = json['is_invite_clinic'];
    simulations = json['simulations'] != null
        ? Simulations.fromJson(json['simulations'])
        : null;
    if (json['treatments'] != null) {
      treatments = <DetailedAppointmentTreatment>[];
      json['treatments'].forEach((v) {
        treatments!.add(DetailedAppointmentTreatment.fromJson(v));
      });
    }
    treatmentTotal = (json['treatment_total'] as num?)?.toDouble();
    paymentType = json['payment_type'] != null
        ? PaymentType.fromJson(json['payment_type'])
        : null;
    discountType = json['discount_type'];
    discount = (json['discount'] as num?)?.toDouble();
    amountPaid = (json['amount_paid'] as num?)?.toDouble();
    payable = (json['payable'] as num?)?.toDouble();
    bookingType = json['booking_type'];
    status = json['status'];
    createdAt = json['created_at'];
  }

  AppointmentDetailData copyWith({
    int? id,
    String? appointmentKey,
    int? chatId,
    AppointmentClinic? clinic,
    Doctor? doctor,
    AppointmentPatient? patient,
    AppointmentType? appointmentType,
    int? date,
    int? startTime,
    int? endTime,
    bool? isInviteClinic,
    Simulations? simulations,
    List<DetailedAppointmentTreatment>? treatments,
    double? treatmentTotal,
    PaymentType? paymentType,
    String? discountType,
    double? discount,
    double? amountPaid,
    double? payable,
    String? bookingType,
    String? status,
    String? createdAt,
  }) {
    return AppointmentDetailData(
      id: id ?? this.id,
      appointmentKey: appointmentKey ?? this.appointmentKey,
      chatId: chatId ?? this.chatId,
      clinic: clinic ?? this.clinic,
      doctor: doctor ?? this.doctor,
      patient: patient ?? this.patient,
      appointmentType: appointmentType ?? this.appointmentType,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isInviteClinic: isInviteClinic ?? this.isInviteClinic,
      simulations: simulations ?? this.simulations,
      treatments: treatments ?? this.treatments,
      treatmentTotal: treatmentTotal ?? this.treatmentTotal,
      paymentType: paymentType ?? this.paymentType,
      discountType: discountType ?? this.discountType,
      discount: discount ?? this.discount,
      amountPaid: amountPaid ?? this.amountPaid,
      payable: payable ?? this.payable,
      bookingType: bookingType ?? this.bookingType,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['appointment_key'] = appointmentKey;
    data['chat_id'] = chatId;
    if (clinic != null) data['clinic'] = clinic!.toJson();
    if (doctor != null) data['doctor'] = doctor!.toJson();
    if (patient != null) data['patient'] = patient!.toJson();
    if (appointmentType != null)
      data['appointment_type'] = appointmentType!.toJson();
    data['date'] = date;
    data['start_time'] = startTime;
    data['end_time'] = endTime;
    data['is_invite_clinic'] = isInviteClinic;
    if (simulations != null) data['simulations'] = simulations!.toJson();
    if (treatments != null) {
      data['treatments'] = treatments!.map((v) => v.toJson()).toList();
    }
    data['treatment_total'] = treatmentTotal;
    if (paymentType != null) data['payment_type'] = paymentType!.toJson();
    data['discount_type'] = discountType;
    data['discount'] = discount;
    data['booking_type'] = bookingType;
    data['status'] = status;
    data['created_at'] = createdAt;
    return data;
  }

  AppointmentItem toAppointmentItem() {
    return AppointmentItem(
      appointmentKey: appointmentKey,
      appointmentId: id,
      status: status,
      appointmentType: appointmentType?.title,
      appointmentTypeId: appointmentType?.id,
      clinic: clinic,
      date: date,
      doctor: AppointmentDoctor(
        title: doctor?.title,
        name: doctor?.name,
        id: doctor?.id,
        cc: doctor?.cc,
        country: doctor?.country,
        email: doctor?.email,
        image: doctor?.image,
        phone: doctor?.phone,
      ),
      slot: AppointmentSlot(startTime: startTime, endTime: endTime),
      treatments: treatments
          ?.map(
            (t) => AppointmentTreatment(
              status: t.treatmentStatus,
              treatmentName: t.treatmentName,
              areaName: t.areaName,
              areaId: t.areaId,
              material: t.material,
              sessionId: t.sessionId,
              sessionName: t.sessionName,
              treatmentId: t.treatmentId,
              treatmentImage: t.treatmentImage,
            ),
          )
          .toList(),
    );
  }

  // Compatibility getter
  int? get appointmentId => id;
}

class AppointmentPatient {
  int? id;
  String? name;
  String? email;
  String? image;
  String? title;
  String? phone;
  String? cc;
  String? country;

  AppointmentPatient({
    this.id,
    this.name,
    this.email,
    this.image,
    this.title,
    this.phone,
    this.cc,
    this.country,
  });

  AppointmentPatient.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? json['patient_id'];
    name = json['name'] ?? json['patient_name'];
    email = json['email'];
    image = json['image'] ?? json['patient_image'];
    title = json['title'];
    phone = json['phone_number'];
    cc = json['cc'];
    country = json['country'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'image': image,
      'title': title,
      'phone': phone,
      'cc': cc,
      'country': country,
    };
  }

  String? get patientName => name;
}

class AppointmentType {
  final int? id;
  final String? title;
  final String? key;
  final String? icon;
  final int? maxDuration;

  AppointmentType({this.id, this.title, this.key, this.icon, this.maxDuration});

  factory AppointmentType.fromJson(Map<String, dynamic> json) =>
      AppointmentType(
        id: json["id"],
        title: json["title"],
        key: json["key"],
        icon: json["icon"],
        maxDuration: json["max_duration"] as int?,
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "key": key,
    "icon": icon,
    "max_duration": maxDuration,
  };
}

class Patient {
  final int? id;
  final String? name;
  final String? email;
  final String? phoneNumber;
  final String? profileImageUrl;
  final String? location;
  final String? bio;
  final String? cc;
  final String? country;

  Patient({
    this.id,
    this.name,
    this.email,
    this.phoneNumber,
    this.profileImageUrl,
    this.location,
    this.bio,
    this.cc,
    this.country,
  });

  factory Patient.fromJson(Map<String, dynamic> json) => Patient(
    id: json["id"],
    name: json["name"],
    email: json["email"],
    phoneNumber: json["phone_number"],
    profileImageUrl: json["profile_image_url"],
    location: json["location"],
    bio: json["bio"],
    cc: json["cc"],
    country: json["country"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "phone_number": phoneNumber,
    "profile_image_url": profileImageUrl,
    "location": location,
    "bio": bio,
    "cc": cc,
    "country": country,
  };
}

class PaymentType {
  final String? type;
  final String? status;

  PaymentType({this.type, this.status});

  factory PaymentType.fromJson(Map<String, dynamic> json) =>
      PaymentType(type: json["type"], status: json["status"]);

  Map<String, dynamic> toJson() => {"type": type, "status": status};
}

class Simulations {
  final String? frontImageBefore;
  final String? frontImageAfter;
  final String? rightImageBefore;
  final String? rightImageAfter;
  final String? leftImageBefore;
  final String? leftImageAfter;

  Simulations({
    this.frontImageBefore,
    this.frontImageAfter,
    this.rightImageBefore,
    this.rightImageAfter,
    this.leftImageBefore,
    this.leftImageAfter,
  });

  factory Simulations.fromJson(Map<String, dynamic> json) => Simulations(
    frontImageBefore: json["front_image_before"],
    frontImageAfter: json["front_image_after"],
    rightImageBefore: json["right_image_before"],
    rightImageAfter: json["right_image_after"],
    leftImageBefore: json["left_image_before"],
    leftImageAfter: json["left_image_after"],
  );

  Map<String, dynamic> toJson() => {
    "front_image_before": frontImageBefore,
    "front_image_after": frontImageAfter,
    "right_image_before": rightImageBefore,
    "right_image_after": rightImageAfter,
    "left_image_before": leftImageBefore,
    "left_image_after": leftImageAfter,
  };
}

class DetailedAppointmentTreatment {
  final int? sessionId;
  final int? treatmentId;
  final String? treatmentName;
  final int? areaId;
  final String? areaName;
  final AppointmentMaterial? material;
  final num? treatmentCost;
  final String? treatmentImage;
  final String? treatmentStatus; // pending, start, end
  final String? sessionName;
  final int? startTime;
  final int? endTime;

  DetailedAppointmentTreatment({
    this.sessionId,
    this.treatmentId,
    this.treatmentName,
    this.areaId,
    this.areaName,
    this.treatmentCost,
    this.material,
    this.treatmentStatus,
    this.sessionName,
    this.treatmentImage,
    this.startTime,
    this.endTime,
  });

  factory DetailedAppointmentTreatment.fromJson(Map<String, dynamic> json) =>
      DetailedAppointmentTreatment(
        sessionId: json['session_id'],
        treatmentId: json["treatment_id"],
        treatmentName: json["treatment_name"],
        areaId: json["area_id"],
        areaName: json["area_name"],
        treatmentCost: json["treatment_cost"],
        treatmentStatus: json['treatment_status'],
        sessionName: json['session_name'],
        treatmentImage: json['treatment_image'],
        material: json["material"] != null
            ? AppointmentMaterial.fromJson(json["material"])
            : null,
        startTime: json["start_time"],
        endTime: json["end_time"],
      );

  Map<String, dynamic> toJson() => {
    "treatment_id": treatmentId,
    "treatment_name": treatmentName,
    "treatment_image": treatmentImage,
    "area_id": areaId,
    "area_name": areaName,
    "treatment_cost": treatmentCost,
    "treatment_status": treatmentStatus,
    "start_time": startTime,
    "end_time": endTime,
    "material": material?.toJson(),
    "session_id": sessionId,
  };
}

class Doctor {
  final int? id;
  final String? name;
  final String? email;
  final String? image;
  final String? title;
  final String? gender;
  final String? specialization;
  final int? yearsOfExperience;
  final List<String>? qualifications;
  final String? phone;
  final String? cc;
  final String? country;
  final int? consultationFee;

  Doctor({
    this.id,
    this.name,
    this.email,
    this.image,
    this.title,
    this.gender,
    this.specialization,
    this.yearsOfExperience,
    this.qualifications,
    this.phone,
    this.cc,
    this.country,
    this.consultationFee,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) => Doctor(
    id: json["id"],
    name: json["name"],
    email: json["email"],
    image: json["image"],
    title: json["title"],
    gender: json["gender"],
    specialization: json["specialization"],
    yearsOfExperience: json["years_of_experience"],
    qualifications: json["qualifications"] != null
        ? List<String>.from(json["qualifications"].map((x) => x))
        : null,
    phone: json["phone"],
    cc: json["cc"],
    country: json["country"],
    consultationFee: json["consultation_fee"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "image": image,
    "title": title,
    "gender": gender,
    "specialization": specialization,
    "years_of_experience": yearsOfExperience,
    "qualifications": qualifications != null
        ? List<dynamic>.from(qualifications!.map((x) => x))
        : null,
    "phone": phone,
    "cc": cc,
    "country": country,
    "consultation_fee": consultationFee,
  };
}
