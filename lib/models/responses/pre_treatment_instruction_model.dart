class InstructionAttachment {
  final String name;
  final String url;
  final String type; // e.g. 'pdf', 'image', 'document'

  InstructionAttachment({
    required this.name,
    required this.url,
    required this.type,
  });

  factory InstructionAttachment.fromJson(Map<String, dynamic> json) {
    return InstructionAttachment(
      name: json['name'] as String? ?? 'Attachment',
      url: json['url'] as String? ?? '',
      type: json['type'] as String? ?? 'document',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'url': url,
        'type': type,
      };
}

class PreTreatmentInstructionItem {
  final int treatmentId;
  final String treatmentName;
  final String? areaName;
  final String? preTreatmentInstructions;
  final List<InstructionAttachment> preTreatmentAttachments;

  PreTreatmentInstructionItem({
    required this.treatmentId,
    required this.treatmentName,
    this.areaName,
    this.preTreatmentInstructions,
    this.preTreatmentAttachments = const [],
  });

  List<String> get parsedPreInstructions {
    if (preTreatmentInstructions == null ||
        preTreatmentInstructions!.trim().isEmpty) {
      return [];
    }
    final lines = preTreatmentInstructions!
        .split(RegExp(r'[\r\n]+|(?<=\.)\s+'))
        .map((e) => e.replaceAll(RegExp(r'^[•\-*\d.\s]+'), '').trim())
        .where((e) => e.isNotEmpty)
        .toList();
    return lines.isNotEmpty ? lines : [preTreatmentInstructions!];
  }

  factory PreTreatmentInstructionItem.fromJson(Map<String, dynamic> json) {
    return PreTreatmentInstructionItem(
      treatmentId: json['treatment_id'] as int? ?? 0,
      treatmentName: json['treatment_name'] as String? ?? 'Treatment Care',
      areaName: json['area_name'] as String?,
      preTreatmentInstructions: json['pre_treatment_instructions'] as String?,
      preTreatmentAttachments: json['pre_treatment_attachments'] != null
          ? List<InstructionAttachment>.from(
              (json['pre_treatment_attachments'] as List)
                  .map((x) => InstructionAttachment.fromJson(x)),
            )
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
        'treatment_id': treatmentId,
        'treatment_name': treatmentName,
        'area_name': areaName,
        'pre_treatment_instructions': preTreatmentInstructions,
        'pre_treatment_attachments':
            preTreatmentAttachments.map((x) => x.toJson()).toList(),
      };
}
