import 'base_response_model.dart';

class InstructionsResponse extends BaseResponseModel {
  final List<InstructionData> data;

  InstructionsResponse({
    required super.isSuccess,
    required super.message,
    required this.data,
  });

  factory InstructionsResponse.fromJson(Map<String, dynamic> json) {
    return InstructionsResponse(
      isSuccess: json['is_success'],
      message: json['message'],
      data: json['data'] != null
          ? List<InstructionData>.from(
              json['data'].map(
                (x) => InstructionData.fromJson(x),
              ),
            )
          : [],
    );
  }
}

class InstructionData {
  final String? treatmentName;
  final int? treatmentId;
  final String? areaName;
  final int? areaId;
  final String instructions;
  final List<PreTreatmentAttachment> attachments;

  InstructionData({
    this.treatmentName,
    this.treatmentId,
    this.areaName,
    this.areaId,
    this.instructions = '',
    this.attachments = const [],
  });

  factory InstructionData.fromJson(Map<String, dynamic> json) {
    return InstructionData(
      treatmentName: json['treatment_name'],
      treatmentId: json['treatment_id'],
      areaName: json['area_name'],
      areaId: json['area_id'],

      // Check pre-treatment first, then post-treatment.
      // If both are null, use empty string.
      instructions:
          json['pre_treatment_instructions'] ??
          json['post_treatment_instructions'] ??
          '',

      attachments: json['pre_treatment_attachments'] != null
    ? List<PreTreatmentAttachment>.from(
        json['pre_treatment_attachments'].map(
          (x) => PreTreatmentAttachment.fromJson(x),
        ),
      )
    : json['post_treatment_attachments'] != null
        ? List<PreTreatmentAttachment>.from(
            json['post_treatment_attachments'].map(
              (x) => PreTreatmentAttachment.fromJson(x),
            ),
          )
        : [],
    );
  }
}

class PreTreatmentAttachment {
  final String? name;
  final String? url;
  final String? type;

  PreTreatmentAttachment({
    this.name,
    this.url,
    this.type,
  });

  factory PreTreatmentAttachment.fromJson(Map<String, dynamic> json) {
    return PreTreatmentAttachment(
      name: json['name'],
      url: json['url'],
      type: json['type'],
    );
  }
}