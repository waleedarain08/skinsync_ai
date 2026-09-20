import 'pre_treatment_instruction_model.dart';

class PostTreatmentInstructionItem {
  final int treatmentId;
  final String treatmentName;
  final String? areaName;
  final String? postTreatmentInstructions;
  final List<InstructionAttachment> postTreatmentAttachments;

  PostTreatmentInstructionItem({
    required this.treatmentId,
    required this.treatmentName,
    this.areaName,
    this.postTreatmentInstructions,
    this.postTreatmentAttachments = const [],
  });

  List<String> get parsedPostInstructions {
    if (postTreatmentInstructions == null ||
        postTreatmentInstructions!.trim().isEmpty) {
      return [];
    }
    final lines = postTreatmentInstructions!
        .split(RegExp(r'[\r\n]+|(?<=\.)\s+'))
        .map((e) => e.replaceAll(RegExp(r'^[•\-*\d.\s]+'), '').trim())
        .where((e) => e.isNotEmpty)
        .toList();
    return lines.isNotEmpty ? lines : [postTreatmentInstructions!];
  }

  factory PostTreatmentInstructionItem.fromJson(Map<String, dynamic> json) {
    return PostTreatmentInstructionItem(
      treatmentId: json['treatment_id'] as int? ?? 0,
      treatmentName: json['treatment_name'] as String? ?? 'Aftercare',
      areaName: json['area_name'] as String?,
      postTreatmentInstructions: json['post_treatment_instructions'] as String?,
      postTreatmentAttachments: json['post_treatment_attachments'] != null
          ? List<InstructionAttachment>.from(
              (json['post_treatment_attachments'] as List)
                  .map((x) => InstructionAttachment.fromJson(x)),
            )
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
        'treatment_id': treatmentId,
        'treatment_name': treatmentName,
        'area_name': areaName,
        'post_treatment_instructions': postTreatmentInstructions,
        'post_treatment_attachments':
            postTreatmentAttachments.map((x) => x.toJson()).toList(),
      };
}
