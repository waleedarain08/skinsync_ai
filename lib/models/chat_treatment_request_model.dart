class ChatTreatmentRequestModel {
  final String? text;
  final int id;
  final int userId;
  final int groupId;
  final String name;

  // Patient information
  final String? patientName;
  final String? patientImage;
  final String? patientEmail;

  final String? frontImageBefore;
  final String? frontImageAfter;

  final String? rightImageBefore;
  final String? rightImageAfter;

  final String? leftImageBefore;
  final String? leftImageAfter;

  final List<ChatTreatmentData> treatments;

  final String? createdAt;
  final String? updatedAt;

  ChatTreatmentRequestModel({
    this.text,
    required this.id,
    required this.userId,
    required this.groupId,
    required this.name,
    this.patientName,
    this.patientImage,
    this.patientEmail,
    this.frontImageBefore,
    this.frontImageAfter,
    this.rightImageBefore,
    this.rightImageAfter,
    this.leftImageBefore,
    this.leftImageAfter,
    required this.treatments,
    this.createdAt,
    this.updatedAt,
  });

  factory ChatTreatmentRequestModel.fromJson(Map<String, dynamic> json) {
    return ChatTreatmentRequestModel(
      text: json['text']?.toString() ?? '',
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      userId: json['user_id'] is int
          ? json['user_id']
          : int.tryParse('${json['user_id']}') ?? 0,
      groupId: json['group_id'] is int
          ? json['group_id']
          : int.tryParse('${json['group_id']}') ?? 0,
      name: json['name']?.toString() ?? '',
      patientName: json['patient_name']?.toString(),
      patientImage: json['patient_image']?.toString(),
      patientEmail: json['patient_email']?.toString(),
      frontImageBefore: json['front_image_before']?.toString(),
      frontImageAfter: json['front_image_after']?.toString(),
      rightImageBefore: json['right_image_before']?.toString(),
      rightImageAfter: json['right_image_after']?.toString(),
      leftImageBefore: json['left_image_before']?.toString(),
      leftImageAfter: json['left_image_after']?.toString(),
      treatments: (json['treatments'] as List<dynamic>?)
              ?.map(
                (e) => ChatTreatmentData.fromJson(
                  e is Map<String, dynamic> ? e : {},
                ),
              )
              .toList() ??
          [],
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'group_id': groupId,
    'name': name,
    'patient_name': patientName,
    'patient_image': patientImage,
    'patient_email': patientEmail,
    'front_image_before': frontImageBefore,
    'front_image_after': frontImageAfter,
    'right_image_before': rightImageBefore,
    'right_image_after': rightImageAfter,
    'left_image_before': leftImageBefore,
    'left_image_after': leftImageAfter,
    'treatments': treatments.map((e) => e.toJson()).toList(),
    'created_at': createdAt,
    'updated_at': updatedAt,
  };

  ChatTreatmentRequestModel copyWith({
    String? text,
    int? id,
    int? userId,
    int? groupId,
    String? name,
    String? patientName,
    String? patientImage,
    String? patientEmail,
    String? frontImageBefore,
    String? frontImageAfter,
    String? rightImageBefore,
    String? rightImageAfter,
    String? leftImageBefore,
    String? leftImageAfter,
    List<ChatTreatmentData>? treatments,
  }) {
    return ChatTreatmentRequestModel(
      text: text ?? this.text,
      id: id ?? this.id,
      userId: userId ?? this.userId,
      groupId: groupId ?? this.groupId,
      name: name ?? this.name,
      patientName: patientName ?? this.patientName,
      patientImage: patientImage ?? this.patientImage,
      patientEmail: patientEmail ?? this.patientEmail,
      frontImageBefore: frontImageBefore ?? this.frontImageBefore,
      frontImageAfter: frontImageAfter ?? this.frontImageAfter,
      rightImageBefore: rightImageBefore ?? this.rightImageBefore,
      rightImageAfter: rightImageAfter ?? this.rightImageAfter,
      leftImageBefore: leftImageBefore ?? this.leftImageBefore,
      leftImageAfter: leftImageAfter ?? this.leftImageAfter,
      treatments: treatments ?? this.treatments,
    );
  }
}

class ChatTreatmentData {
  final int treatmentId;
  final String treatmentName;
  final String? description;
  final String? image;
  final String? icon;
  final List<ChatTreatmentAreaData> areas;

  ChatTreatmentData({
    required this.treatmentId,
    required this.treatmentName,
    this.description,
    this.image,
    this.icon,
    required this.areas,
  });

  factory ChatTreatmentData.fromJson(Map<String, dynamic> json) {
    return ChatTreatmentData(
      treatmentId: json['treatment_id'] is int
          ? json['treatment_id']
          : int.tryParse('${json['treatment_id']}') ?? 0,
      treatmentName: json['treatment_name']?.toString() ?? '',
      description: json['treatment_desc']?.toString(),
      image: json['treatment_image']?.toString(),
      icon: json['treatment_icon']?.toString(),
      areas: (json['areas'] as List<dynamic>?)
              ?.map(
                (e) => ChatTreatmentAreaData.fromJson(
                  e is Map<String, dynamic> ? e : {},
                ),
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'treatment_id': treatmentId,
    'treatment_name': treatmentName,
    'treatment_desc': description,
    'treatment_image': image,
    'treatment_icon': icon,
    'areas': areas.map((e) => e.toJson()).toList(),
  };
}

class ChatTreatmentAreaData {
  final int areaId;
  final String areaName;
  final String? image;
  final String? icon;
  final List<ChatTreatmentMaterialData> materials;

  ChatTreatmentAreaData({
    required this.areaId,
    required this.areaName,
    this.image,
    this.icon,
    required this.materials,
  });

  factory ChatTreatmentAreaData.fromJson(Map<String, dynamic> json) {
    return ChatTreatmentAreaData(
      areaId: json['area_id'] is int
          ? json['area_id']
          : int.tryParse('${json['area_id']}') ?? 0,
      areaName: json['area_name']?.toString() ?? '',
      image: json['area_image']?.toString(),
      icon: json['area_icon']?.toString(),
      materials: (json['materials'] as List<dynamic>?)
              ?.map(
                (e) => ChatTreatmentMaterialData.fromJson(
                  e is Map<String, dynamic> ? e : {},
                ),
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'area_id': areaId,
    'area_name': areaName,
    'area_image': image,
    'area_icon': icon,
    'materials': materials.map((e) => e.toJson()).toList(),
  };
}

class ChatTreatmentMaterialData {
  final int id;
  final String name;
  final int selectedQuantity;

  ChatTreatmentMaterialData({
    required this.id,
    required this.name,
    required this.selectedQuantity,
  });

  factory ChatTreatmentMaterialData.fromJson(Map<String, dynamic> json) {
    return ChatTreatmentMaterialData(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      name: json['name']?.toString() ?? '',
      selectedQuantity: json['selected_quantity'] is int
          ? json['selected_quantity']
          : int.tryParse('${json['selected_quantity']}') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'selected_quantity': selectedQuantity,
  };
}
