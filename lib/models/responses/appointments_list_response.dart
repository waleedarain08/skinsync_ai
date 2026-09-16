import 'base_response_model.dart';

class AppointmentsListResponse extends BaseResponseModel {
  AppointmentListData? data;

  AppointmentsListResponse({this.data, super.isSuccess, super.message});

  AppointmentsListResponse.fromJson(Map<String, dynamic> json) {
    isSuccess = json['is_success'];
    message = json['message'];
    data = json['data'] != null ? AppointmentListData.fromJson(json['data']) : null;
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

class AppointmentListData {
  List<AppointmentItem>? items;
  int? limit;
  int? page;
  int? total;
  int? totalPages;

  AppointmentListData({this.items, this.limit, this.page, this.total, this.totalPages});

  AppointmentListData.fromJson(Map<String, dynamic> json) {
    if (json['items'] != null) {
      items = <AppointmentItem>[];
      json['items'].forEach((v) {
        items!.add(AppointmentItem.fromJson(v));
      });
    }
    limit = json['limit'];
    page = json['page'];
    total = json['total'];
    totalPages = json['total_pages'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (items != null) {
      data['items'] = items!.map((v) => v.toJson()).toList();
    }
    data['limit'] = limit;
    data['page'] = page;
    data['total'] = total;
    data['total_pages'] = totalPages;
    return data;
  }
}

class AppointmentItem {
  int? appointmentId;
  int? date;
  AppointmentSlot? slot;
  String? appointmentType;
  int? appointmentTypeId;
  String? appointmentKey;
  String? status;
  List<AppointmentTreatment>? treatments;
  AppointmentDoctor? doctor;
  AppointmentClinic? clinic;

  AppointmentItem({
    this.appointmentId,
    this.date,
    this.slot,
    this.appointmentType,
    this.appointmentTypeId,
    this.appointmentKey,
    this.status,
    this.treatments,
    this.doctor,
    this.clinic,
  });

  AppointmentItem.fromJson(Map<String, dynamic> json) {
    appointmentId = json['id'];
    date = json['date'];
    slot = json['slot'] != null ? AppointmentSlot.fromJson(json['slot']) : null;
    appointmentType = json['appointment_type'] is Map ? json['appointment_type']['title'] : json['appointment_type'];
    appointmentTypeId = json['appointment_type_id'];
    appointmentKey = json['appointment_key'];
    status = json['status'];
    if (json['treatments'] != null) {
      treatments = <AppointmentTreatment>[];
      json['treatments'].forEach((v) {
        treatments!.add(AppointmentTreatment.fromJson(v));
      });
    }
    doctor = json['doctor'] != null ? AppointmentDoctor.fromJson(json['doctor']) : null;
    clinic = json['clinic'] != null ? AppointmentClinic.fromJson(json['clinic']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = appointmentId;
    data['date'] = date;
    if (slot != null) {
      data['slot'] = slot!.toJson();
    }
    data['appointment_type'] = appointmentType;
    data['appointment_type_id'] = appointmentTypeId;
    data['appointment_key'] = appointmentKey;
    data['status'] = status;
    if (treatments != null) {
      data['treatments'] = treatments!.map((v) => v.toJson()).toList();
    }
    if (doctor != null) {
      data['doctor'] = doctor!.toJson();
    }
    if (clinic != null) {
      data['clinic'] = clinic!.toJson();
    }
    return data;
  }
}

class AppointmentSlot {
  int? startTime;
  int? endTime;

  AppointmentSlot({this.startTime, this.endTime});

  AppointmentSlot.fromJson(Map<String, dynamic> json) {
    startTime = json['start_time'];
    endTime = json['end_time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['start_time'] = startTime;
    data['end_time'] = endTime;
    return data;
  }
}

class AppointmentTreatment {
  int? treatmentId;
  String? treatmentName;
  String? treatmentImage;
  int? areaId;
  String? areaName;
  AppointmentMaterial? material;
  String? status;
  int? startTime;
  int? endTime;

  AppointmentTreatment({
    this.treatmentId,
    this.treatmentName,
    this.treatmentImage,
    this.areaId,
    this.areaName,
    this.material,
    this.status,
    this.startTime,
    this.endTime,
  });

  AppointmentTreatment.fromJson(Map<String, dynamic> json) {
    treatmentId = json['treatment_id'];
    treatmentName = json['treatment_name'];
    treatmentImage = json['treatment_image'];
    areaId = json['area_id'];
    areaName = json['area_name'];
    material = json['material'] != null ? AppointmentMaterial.fromJson(json['material']) : null;
    status = json['status'];
    startTime = json['start_time'];
    endTime = json['end_time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['treatment_id'] = treatmentId;
    data['treatment_name'] = treatmentName;
    data['treatment_image'] = treatmentImage;
    data['area_id'] = areaId;
    data['area_name'] = areaName;
    if (material != null) {
      data['material'] = material!.toJson();
    }
    data['status'] = status;
    data['start_time'] = startTime;
    data['end_time'] = endTime;
    return data;
  }
}

class AppointmentMaterial {
  int? id;
  int? selectedQuantity;
  String? name;

  AppointmentMaterial({this.id, this.selectedQuantity, this.name});

  AppointmentMaterial.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    selectedQuantity = json['selected_quantity'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'selected_quantity': selectedQuantity,
    'name': name,
  };

  String? get materialName => name;
  String? get unitType => name;
}

class AppointmentDoctor {
  int? id;
  String? name;
  String? email;
  String? image;
  String? title;
  String? phone;
  String? cc;
  String? country;

  AppointmentDoctor({
    this.id,
    this.name,
    this.email,
    this.image,
    this.title,
    this.phone,
    this.cc,
    this.country,
  });

  AppointmentDoctor.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? json['doctor_id'];
    name = json['name'] ?? json['doctor_name'];
    email = json['email'];
    image = json['image'] ?? json['doctor_image'];
    title = json['title'];
    phone = json['phone'];
    cc = json['cc'];
    country = json['country'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['image'] = image;
    data['title'] = title;
    data['phone'] = phone;
    data['cc'] = cc;
    data['country'] = country;
    return data;
  }

  // To maintain backward compatibility
  int? get doctorId => id;
  String? get doctorName => name;
  String? get doctorImage => image;
  String? get specialization => title;
}

class AppointmentClinic {
  int? id;
  String? name;
  String? email;
  String? phone;
  String? address;
  String? logo;
  String? cc;
  String? country;
  double? latitude;
  double? longitude;

  AppointmentClinic({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.address,
    this.logo,
    this.cc,
    this.country,
    this.latitude,
    this.longitude,
  });

  AppointmentClinic.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? json['clinic_id'];
    name = json['name'] ?? json['clinic_name'];
    email = json['email'];
    phone = json['phone'];
    address = json['address'];
    logo = json['logo'] ?? json['clinic_image'];
    cc = json['cc'];
    country = json['country'];
    latitude = (json['latitude'] as num?)?.toDouble();
    longitude = (json['longitude'] as num?)?.toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['phone'] = phone;
    data['address'] = address;
    data['logo'] = logo;
    data['cc'] = cc;
    data['country'] = country;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    return data;
  }

  // To maintain backward compatibility
  int? get clinicId => id;
  String? get clinicName => name;
  String? get clinicImage => logo;
}
