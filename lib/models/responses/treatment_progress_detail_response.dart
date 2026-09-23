import '../../utils/enums.dart';
import 'base_response_model.dart';

export '../../utils/enums.dart' show AppointmentType, AppointmentTypeExtension;

class TreatmentProgressDetailResponse extends BaseResponseModel {
  final TreatmentProgressDetailData? data;

  TreatmentProgressDetailResponse({
    super.isSuccess,
    super.message,
    this.data,
  });

  factory TreatmentProgressDetailResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return TreatmentProgressDetailResponse(
      isSuccess: json['is_success'],
      message: json['message'],
      data: json['data'] != null
          ? TreatmentProgressDetailData.fromJson(
              json['data'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'is_success': isSuccess,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class TreatmentProgressDetailData {
  final int? treatmentId;
  final int? areaId;
  final String? treatmentName;
  final String? areaName;
  final List<TreatmentProgressDetailItem>? progressData;

  TreatmentProgressDetailData({
    this.treatmentId,
    this.areaId,
    this.treatmentName,
    this.areaName,
    this.progressData,
  });

  factory TreatmentProgressDetailData.fromJson(
    Map<String, dynamic> json,
  ) {
    return TreatmentProgressDetailData(
      treatmentId: json['treatment_id'],
      areaId: json['area_id'],
      treatmentName: json['treatment_name'],
      areaName: json['area_name'],
      progressData: json['progress_data'] != null
          ? (json['progress_data'] as List)
              .map(
                (e) => TreatmentProgressDetailItem.fromJson(
                  e as Map<String, dynamic>,
                ),
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
      'progress_data':
          progressData?.map((e) => e.toJson()).toList(),
    };
  }
}

class TreatmentProgressDetailItem {
  final AppointmentType? appointmentType;
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

  TreatmentProgressDetailItem({
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

  factory TreatmentProgressDetailItem.fromJson(
    Map<String, dynamic> json,
  ) {
    return TreatmentProgressDetailItem(
      appointmentType:
          AppointmentTypeExtension.fromString(
        json['appointment_type'] as String?,
      ),
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
      'appointment_type': appointmentType?.value,
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