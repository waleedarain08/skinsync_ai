import 'base_response_model.dart';

class PerTreatmentPhotosResponse extends BaseResponseModel {
  final List<String> data;

  PerTreatmentPhotosResponse({
    required super.isSuccess,
    required super.message,
    required this.data,
  });

  factory PerTreatmentPhotosResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return PerTreatmentPhotosResponse(
      isSuccess: json['is_success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? List<String>.from(json['data'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_success': isSuccess,
      'message': message,
      'data': data,
    };
  }
}


