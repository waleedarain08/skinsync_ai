import 'base_response_model.dart';

class SimulationHistoryResponse extends BaseResponseModel {
  final List<SimulationData>? data;

  SimulationHistoryResponse({super.isSuccess, super.message, this.data});

  factory SimulationHistoryResponse.fromJson(Map<String, dynamic> json) =>
      SimulationHistoryResponse(
        isSuccess: json["is_success"],
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<SimulationData>.from(
                json["data"]!.map((x) => SimulationData.fromJson(x)),
              ),
      );

  Map<String, dynamic> toJson() => {
    "is_success": isSuccess,
    "message": message,
    "data": data == null
        ? []
        : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class SimulationData {
  final int? id;
  final int? userId;

  final int? groupId;
  final String? name;
  final String? frontImageBefore;
  final String? frontImageAfter;
  final String? rightImageBefore;
  final String? rightImageAfter;
  final String? leftImageBefore;
  final String? leftImageAfter;
  final List<SimulationTreatment>? treatments;
  final bool? isShared;
   final ClinicData? clinic;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SimulationData({
    this.id,
    this.userId,
    this.groupId,
    this.name,
    this.frontImageBefore,
    this.frontImageAfter,
    this.rightImageBefore,
    this.rightImageAfter,
    this.leftImageBefore,
    this.leftImageAfter,
    this.treatments,
    this.isShared,
     this.clinic,
    this.createdAt,
    this.updatedAt,
  });

  factory SimulationData.fromJson(Map<String, dynamic> json) => SimulationData(
    id: json["id"],
    userId: json["user_id"],
    groupId: json["group_id"],
    name: json["name"],
    frontImageBefore: json["front_image_before"],
    frontImageAfter: json["front_image_after"],
    rightImageBefore: json["right_image_before"],
    rightImageAfter: json["right_image_after"],
    leftImageBefore: json["left_image_before"],
    leftImageAfter: json["left_image_after"],
    treatments: json["treatments"] == null
        ? []
        : List<SimulationTreatment>.from(
            json["treatments"]!.map((x) => SimulationTreatment.fromJson(x)),
          ),
    isShared: json["is_shared"],
     clinic: json["clinic"] == null
            ? null
            : ClinicData.fromJson(json["clinic"]),
    createdAt: json["created_at"] == null
        ? null
        : DateTime.parse(json["created_at"]).toLocal(),
    updatedAt: json["updated_at"] == null
        ? null
        : DateTime.parse(json["updated_at"]).toLocal(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "group_id": groupId,
    "name": name,
    "front_image_before": frontImageBefore,
    "front_image_after": frontImageAfter,
    "right_image_before": rightImageBefore,
    "right_image_after": rightImageAfter,
    "left_image_before": leftImageBefore,
    "left_image_after": leftImageAfter,
    "treatments": treatments == null
        ? []
        : List<dynamic>.from(treatments!.map((x) => x.toJson())),
    "is_shared": isShared,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}


class ClinicData {
  final int? clinicId;
  final String? image;
  final String? banner;
  final String? name;
  final String? email;
  final String? phoneNumber;

  const ClinicData({
    this.clinicId,
    this.image,
    this.banner,
    this.name,
    this.email,
    this.phoneNumber,
  });

  factory ClinicData.fromJson(Map<String, dynamic> json) {
    return ClinicData(
      clinicId: json["clinic_id"],
      image: json["image"],
      banner: json["banner"],
      name: json["name"],
      email: json["email"],
      phoneNumber: json["phone_number"],
    );
  }

  Map<String, dynamic> toJson() => {
        "clinic_id": clinicId,
        "image": image,
        "banner": banner,
        "name": name,
        "email": email,
        "phone_number": phoneNumber,
      };
}

class SimulationTreatment {
  final int? id;
  final String? name;
  final String? description;
  final String? image;
  final String? icon;
  final List<SimulationArea>? areas;

  const SimulationTreatment({
    this.id,
    this.name,
    this.description,
    this.image,
    this.icon,
    this.areas,
  });

  factory SimulationTreatment.fromJson(Map<String, dynamic> json) =>
      SimulationTreatment(
        id: json["treatment_id"],
        name: json["treatment_name"],
        description: json["treatment_desc"],
        image: json["treatment_image"],
        icon: json["treatment_icon"],
        areas: json["areas"] == null
            ? []
            : List<SimulationArea>.from(
                json["areas"].map((x) => SimulationArea.fromJson(x)),
              ),
      );

  Map<String, dynamic> toJson() => {
    "treatment_id": id,
    "treatment_name": name,
    "treatment_desc": description,
    "treatment_image": image,
    "treatment_icon": icon,
    "areas": areas == null
        ? []
        : List<dynamic>.from(areas!.map((x) => x.toJson())),
  };
}

class SimulationArea {
  final int? id;
  final String? name;
  final String? image;
  final String? icon;
  final num? price;
  final List<SimulationMaterial>? materials;

  const SimulationArea({
    this.id,
    this.name,
    this.image,
    this.icon,
    this.price,
    this.materials,
  });

  factory SimulationArea.fromJson(Map<String, dynamic> json) => SimulationArea(
    id: json["area_id"],
    name: json["area_name"],
    image: json["area_image"],
    icon: json["area_icon"],
    price: json['price'],
    materials: json["materials"] == null
        ? []
        : List<SimulationMaterial>.from(
            json["materials"].map((x) => SimulationMaterial.fromJson(x)),
          ),
  );

  Map<String, dynamic> toJson() => {
    "area_id": id,
    "area_name": name,
    "area_image": image,
    "area_icon": icon,
    "price": price,
    "materials": materials == null
        ? []
        : List<dynamic>.from(materials!.map((x) => x.toJson())),
  };
}

class SimulationMaterial {
  final int? id;
  final String? name;
  final int? selectedQuantity;

  const SimulationMaterial({this.id, this.name, this.selectedQuantity});

  factory SimulationMaterial.fromJson(Map<String, dynamic> json) =>
      SimulationMaterial(
        id: json["id"],
        name: json["name"],
        selectedQuantity: json["selected_quantity"],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "selected_quantity": selectedQuantity,
  };
}
