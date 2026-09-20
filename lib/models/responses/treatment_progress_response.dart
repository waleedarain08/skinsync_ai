import 'base_response_model.dart';

class TreatmentProgressResponse extends BaseResponseModel {
 
  final List<TreatmentProgressData>? data;
  final int? totalPages; 

  TreatmentProgressResponse({
    super.isSuccess,
    super.message,
    this.data,
    this.totalPages,
  });

  factory TreatmentProgressResponse.fromJson(Map<String, dynamic> json) {
    return TreatmentProgressResponse(
      isSuccess: json['is_success'],
      message: json['message'],
      data: json['data'] != null
          ? (json['data'] as List)
              .map((e) => TreatmentProgressData.fromJson(e))
              .toList()
          : null,
      totalPages: json['total_pages'], // ADD
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_success': isSuccess,
      'message': message,
      'data': data?.map((e) => e.toJson()).toList(),
      'total_pages': totalPages,
    };
  }
}
class TreatmentProgressData {
  final int? treatmentId;
  final int? areaId;
  final String? treatmentName;
  final String? areaName;
  final List<TreatmentProgressItem>? progressData;

  TreatmentProgressData({
    this.treatmentId,
    this.areaId,
    this.treatmentName,
    this.areaName,
    this.progressData,
  });

  factory TreatmentProgressData.fromJson(Map<String, dynamic> json) {
    return TreatmentProgressData(
      treatmentId: json['treatment_id'],
      areaId: json['area_id'],
      treatmentName: json['treatment_name'],
      areaName: json['area_name'],
      progressData: json['progress_data'] != null
          ? (json['progress_data'] as List)
              .map(
                (e) => TreatmentProgressItem.fromJson(e),
              )
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'treatment_id': treatmentId,
      'area_id': areaId,
      'treatment_name': treatmentName,
      'area_name': areaName,
      'progress_data': progressData
          ?.map((e) => e.toJson())
          .toList(),
    };
  }
}

class TreatmentProgressItem {
  final String? appointmentType;
  final String? status;

  // Consultation / Follow-up
  final int? date;
  final int? time;

  // Treatment session
  final String? sessionName;
  final int? sessionTime;
  final int? sessionDate;
  final String? doctorName;
  final int? doctorId;
  final int? clinicId;
  final String? clinicName;
  final int? sessionId;

  TreatmentProgressItem({
    this.appointmentType,
    this.status,
    this.date,
    this.time,
    this.sessionName,
    this.sessionTime,
    this.sessionDate,
    this.doctorName,
    this.doctorId,
    this.clinicId,
    this.clinicName,
    this.sessionId,
  });

  factory TreatmentProgressItem.fromJson(Map<String, dynamic> json) {
    return TreatmentProgressItem(
      appointmentType: json['appointment_type'],
      status: json['status'],
      date: json['date'],
      time: json['time'],
      sessionName: json['session_name'],
      sessionTime: json['session_time'],
      sessionDate: json['session_date'],
      doctorName: json['doctor_name'],
      doctorId: json['doctor_id'],
      clinicId: json['clinic_id'],
      clinicName: json['clinic_name'],
      sessionId: json['session_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appointment_type': appointmentType,
      'status': status,
      'date': date,
      'time': time,
      'session_name': sessionName,
      'session_time': sessionTime,
      'session_date': sessionDate,
      'doctor_name': doctorName,
      'doctor_id': doctorId,
      'clinic_id': clinicId,
      'clinic_name': clinicName,
      'session_id': sessionId,
    };
  }
}