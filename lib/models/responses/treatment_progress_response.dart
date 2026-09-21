class TreatmentProgressResponse {
  final bool? isSuccess;
  final String? message;
  final List<TreatmentProgressData>? data;
  final int? page;
  final int? limit;
  final int? total;
  final int? totalPages;

  TreatmentProgressResponse({
    this.isSuccess,
    this.message,
    this.data,
    this.page,
    this.limit,
    this.total,
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
      page: json['page'],
      limit: json['limit'],
      total: json['total'],
      totalPages: json['total_pages'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_success': isSuccess,
      'message': message,
      'data': data?.map((e) => e.toJson()).toList(),
      'page': page,
      'limit': limit,
      'total': total,
      'total_pages': totalPages,
    };
  }
}

class TreatmentProgressData {
  final int? id;
  final String? treatmentName;
  final int? treatmentId;
  final String? areaName;
  final int? areaId;
  final String? status;
  final num? progress;
  final int? totalSteps;
  final int? currentStep;

  TreatmentProgressData({
    this.id,
    this.treatmentName,
    this.treatmentId,
    this.areaName,
    this.areaId,
    this.status,
    this.progress,
    this.totalSteps,
    this.currentStep,
  });

  factory TreatmentProgressData.fromJson(Map<String, dynamic> json) {
    return TreatmentProgressData(
      id: json['id'],
      treatmentName: json['treatment_name'],
      treatmentId: json['treatment_id'],
      areaName: json['area_name'],
      areaId: json['area_id'],
      status: json['status'],
      progress: json['progress'],
      totalSteps: json['total_steps'],
      currentStep: json['current_step'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'treatment_name': treatmentName,
      'treatment_id': treatmentId,
      'area_name': areaName,
      'area_id': areaId,
      'status': status,
      'progress': progress,
      'total_steps': totalSteps,
      'current_step': currentStep,
    };
  }
}