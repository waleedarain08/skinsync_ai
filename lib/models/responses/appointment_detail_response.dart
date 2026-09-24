import 'base_response_model.dart';
import 'appointments_list_response.dart';
import 'appointment_type_list_response.dart';

typedef Doctor = AppointmentDoctor;
typedef TreatmentDetail = DetailedAppointmentTreatment;

class AppointmentDetailResponse extends BaseResponseModel {
  AppointmentDetailData? data;

  AppointmentDetailResponse({this.data, super.isSuccess, super.message});

  AppointmentDetailResponse.fromJson(Map<String, dynamic> json) {
    isSuccess = json['is_success'];
    message = json['message'];
    data = json['data'] != null ? AppointmentDetailData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['is_success'] = isSuccess;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class AppointmentPatient {
  int? id;
  String? name;
  String? email;
  String? phoneNumber;

  AppointmentPatient({this.id, this.name, this.email, this.phoneNumber});

  AppointmentPatient.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? json['patient_id'];
    name = json['name'] ?? json['patient_name'];
    email = json['email'] ?? json['patient_email'];
    phoneNumber =
        json['phone_number'] ?? json['phone'] ?? json['patient_phone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['phone_number'] = phoneNumber;
    return data;
  }
}

class AppointmentDetailData {
  int? id;
  int? chatId;
  String? appointmentKey;
  AppointmentClinic? clinic;
  AppointmentDoctor? doctor;
  AppointmentPatient? patient;
  AppointmentTypeData? appointmentType;
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
  String? bookingType;
  String? status;
  String? createdAt;

  AppointmentDetailData({
    this.id,
    this.chatId,
    this.appointmentKey,
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
    this.bookingType,
    this.status,
    this.createdAt,
  });

  AppointmentDetailData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    chatId = json['chat_id'];
    appointmentKey = json['appointment_key'];
    clinic = json['clinic'] != null ? AppointmentClinic.fromJson(json['clinic']) : null;
    doctor = json['doctor'] != null ? AppointmentDoctor.fromJson(json['doctor']) : null;
    patient = json['patient'] != null ? AppointmentPatient.fromJson(json['patient']) : null;
    appointmentType = json['appointment_type'] != null
        ? AppointmentTypeData.fromJson(json['appointment_type'])
        : null;
    date = json['date'];
    startTime = json['start_time'];
    endTime = json['end_time'];
    isInviteClinic = json['is_invite_clinic'];
    simulations = json['simulations'] != null ? Simulations.fromJson(json['simulations']) : null;
    if (json['treatments'] != null) {
      treatments = <DetailedAppointmentTreatment>[];
      json['treatments'].forEach((v) {
        treatments!.add(DetailedAppointmentTreatment.fromJson(v));
      });
    }
    treatmentTotal = (json['treatment_total'] as num?)?.toDouble();
    paymentType = json['payment_type'] != null ? PaymentType.fromJson(json['payment_type']) : null;
    discountType = json['discount_type'];
    discount = (json['discount'] as num?)?.toDouble();
    bookingType = json['booking_type'];
    status = json['status'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['appointment_key'] = appointmentKey;
    if (clinic != null) data['clinic'] = clinic!.toJson();
    if (doctor != null) data['doctor'] = doctor!.toJson();
    if (patient != null) data['patient'] = patient!.toJson();
    if (appointmentType != null) data['appointment_type'] = appointmentType!.toJson();
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

  // Compatibility getter
  int? get appointmentId => id;
}

class PaymentType {
  String? type;
  String? status;

  PaymentType({this.type, this.status});

  PaymentType.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['status'] = status;
    return data;
  }
}

class Simulations {
  String? frontImageBefore;
  String? frontImageAfter;
  String? rightImageBefore;
  String? rightImageAfter;
  String? leftImageBefore;
  String? leftImageAfter;

  Simulations({
    this.frontImageBefore,
    this.frontImageAfter,
    this.rightImageBefore,
    this.rightImageAfter,
    this.leftImageBefore,
    this.leftImageAfter,
  });

  Simulations.fromJson(Map<String, dynamic> json) {
    frontImageBefore = json['front_image_before'];
    frontImageAfter = json['front_image_after'];
    rightImageBefore = json['right_image_before'];
    rightImageAfter = json['right_image_after'];
    leftImageBefore = json['left_image_before'];
    leftImageAfter = json['left_image_after'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['front_image_before'] = frontImageBefore;
    data['front_image_after'] = frontImageAfter;
    data['right_image_before'] = rightImageBefore;
    data['right_image_after'] = rightImageAfter;
    data['left_image_before'] = leftImageBefore;
    data['left_image_after'] = leftImageAfter;
    return data;
  }
}

class DetailedAppointmentTreatment {
  int? treatmentId;
  String? treatmentName;
  String? treatmentImage;
  int? areaId;
  String? areaName;
  double? treatmentCost;
  String? treatmentStatus;
  String? sessionName;
  int? sessionId;
  AppointmentMaterial? material;

  DetailedAppointmentTreatment({
    this.treatmentId,
    this.treatmentName,
    this.treatmentImage,
    this.areaId,
    this.areaName,
    this.treatmentCost,
    this.treatmentStatus,
    this.sessionName,
    this.material,
    this.sessionId
  });

  DetailedAppointmentTreatment.fromJson(Map<String, dynamic> json) {
    treatmentId = json['treatment_id'];
    treatmentName = json['treatment_name'];
    treatmentImage = json['treatment_image'];
    areaId = json['area_id'];
    areaName = json['area_name'];
    treatmentCost = (json['treatment_cost'] as num?)?.toDouble();
    treatmentStatus = json['treatment_status'];
    sessionName = json['session_name'];
    sessionId = json['session_id'];
    material = json['material'] != null ? AppointmentMaterial.fromJson(json['material']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['treatment_id'] = treatmentId;
    data['treatment_name'] = treatmentName;
    data['treatment_image'] = treatmentImage;
    data['area_id'] = areaId;
    data['area_name'] = areaName;
    data['treatment_cost'] = treatmentCost;
    data['treatment_status'] = treatmentStatus;
    data['session_name'] = sessionName;
    data['session_id'] = sessionId;
    if (material != null) {
      data['material'] = material!.toJson();
    }
    return data;
  }
}
