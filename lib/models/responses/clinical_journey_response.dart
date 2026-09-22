import 'appointments_list_response.dart';
import 'base_response_model.dart';

class ClinicalJourneyResponse extends BaseResponseModel {
  ClinicalJourneyData? data;

  ClinicalJourneyResponse({
    this.data,
    super.isSuccess,
    super.message,
  });

  ClinicalJourneyResponse.fromJson(Map<String, dynamic> json) {
    isSuccess = json['is_success'];
    message = json['message'];
    data = json['data'] != null
        ? ClinicalJourneyData.fromJson(json['data'])
        : null;
  }

  Map<String, dynamic> toJson() {
    return {
      'is_success': isSuccess,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class ClinicalJourneyData {
  PatientRequest? patientRequest;
  List<TreatmentBranch>? treatmentBranches;
  int? requestedAt;
  bool? isCompleted;
  int? completedAt;

  ClinicalJourneyData({
    this.patientRequest,
    this.treatmentBranches,
    this.requestedAt,
    this.isCompleted,
    this.completedAt,
  });

  ClinicalJourneyData.fromJson(Map<String, dynamic> json) {
    patientRequest = json['patient_request'] != null
        ? PatientRequest.fromJson(json['patient_request'])
        : null;

    if (json['treatment_branches'] != null) {
      treatmentBranches = <TreatmentBranch>[];
      json['treatment_branches'].forEach((v) {
        treatmentBranches!.add(TreatmentBranch.fromJson(v));
      });
    }

    requestedAt = json['requested_at'];
    isCompleted = json['is_completed'];
    completedAt = json['completed_at'];
  }

  Map<String, dynamic> toJson() {
    return {
      'patient_request': patientRequest?.toJson(),
      'treatment_branches':
          treatmentBranches?.map((v) => v.toJson()).toList(),
      'requested_at': requestedAt,
      'is_completed': isCompleted,
      'completed_at': completedAt,
    };
  }
}

class PatientRequest {
  int? id;
  String? status;
  List<PatientRequestTreatment>? treatments;
  String? clinicName;
  int? clinicId;
  int? date;
  int? time;

 

  PatientRequest({
    this.id,
    this.status,
    this.treatments,
    this.clinicName,
    this.clinicId,
    this.date,
    this.time,
  });

  PatientRequest.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    status = json['status'];

    if (json['treatments'] != null) {
      treatments = <PatientRequestTreatment>[];
      json['treatments'].forEach((v) {
        treatments!.add(PatientRequestTreatment.fromJson(v));
      });
    }

    clinicName = json['clinic_name'];
    clinicId = json['clinic_id'];
    date = json['date'];
    time = json['time'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'treatments': treatments?.map((v) => v.toJson()).toList(),
      'clinic_name': clinicName,
      'clinic_id': clinicId,
      'date': date,
      'time': time,
    };
  }
}

class PatientRequestTreatment {
  int? treatmentId;
  String? treatmentName;
  List<PatientRequestArea>? areas;

  PatientRequestTreatment({
    this.treatmentId,
    this.treatmentName,
    this.areas,
  });

  PatientRequestTreatment.fromJson(Map<String, dynamic> json) {
    treatmentId = json['treatment_id'];
    treatmentName = json['treatment_name'];

    if (json['areas'] != null) {
      areas = <PatientRequestArea>[];
      json['areas'].forEach((v) {
        areas!.add(PatientRequestArea.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'treatment_id': treatmentId,
      'treatment_name': treatmentName,
      'areas': areas?.map((v) => v.toJson()).toList(),
    };
  }
}

class PatientRequestArea {
  int? areaId;
  String? areaName;

  PatientRequestArea({
    this.areaId,
    this.areaName,
  });

  PatientRequestArea.fromJson(Map<String, dynamic> json) {
    areaId = json['area_id'];
    areaName = json['area_name'];
  }

  Map<String, dynamic> toJson() {
    return {
      'area_id': areaId,
      'area_name': areaName,
    };
  }
}



class TreatmentBranch {
  int? treatmentId;
  String? treatmentName;
  int? areaId;
  String? area;
  AppointmentItem? mainAppointment;
  List<AppointmentItem>? followUps;

  TreatmentBranch({
    this.treatmentId,
    this.treatmentName,
    this.areaId,
    this.area,
    this.mainAppointment,
    this.followUps,
  });

  TreatmentBranch.fromJson(Map<String, dynamic> json) {
    treatmentId = json['treatment_id'];
    treatmentName = json['treatment_name'];
    areaId = json['area_id'];
    area = json['area'];

    mainAppointment = json['main_appointment'] != null
        ? AppointmentItem.fromJson(json['main_appointment'])
        : null;

    if (json['follow_ups'] != null) {
      followUps = <AppointmentItem>[];
      json['follow_ups'].forEach((v) {
        followUps!.add(AppointmentItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'treatment_id': treatmentId,
      'treatment_name': treatmentName,
      'area_id': areaId,
      'area': area,
      'main_appointment': mainAppointment?.toJson(),
      'follow_ups': followUps?.map((v) => v.toJson()).toList(),
    };
  }
}


  