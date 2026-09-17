import 'base_response_model.dart';

class GroupsListResponse extends BaseResponseModel {
  final List<TreatmentRequestGroup>? data;
  final int? page;
  final int? total;
  final int? totalPages;

  GroupsListResponse({
    super.isSuccess,
    super.message,
    this.data,
    this.page,
    this.total,
    this.totalPages,
  });

  factory GroupsListResponse.fromJson(Map<String, dynamic> json) {
    return GroupsListResponse(
      isSuccess: json["is_success"],
      message: json["message"],
      data: json["data"] == null
          ? []
          : List<TreatmentRequestGroup>.from(
              json["data"].map(
                (x) => TreatmentRequestGroup.fromJson(x),
              ),
            ),
      page: json["page"],
      total: json["total"],
      totalPages: json["total_pages"],
    );
  }
}

class TreatmentRequestGroup {
  final int? id;
  final String? name;
  final DateTime? createdAt;
  final int? totalOptions;

  const TreatmentRequestGroup({
    this.id,
    this.name,
    this.createdAt,
    this.totalOptions,
  });

  factory TreatmentRequestGroup.fromJson(Map<String, dynamic> json) {
    return TreatmentRequestGroup(
      id: json["id"],
      name: json["name"],
      createdAt: json["created_at"] == null
          ? null
          : DateTime.parse(json["created_at"]).toLocal(),
      totalOptions: json["total_options"],
    );
  }

  TreatmentRequestGroup copyWith({
    int? id,
    String? name,
    DateTime? createdAt,
    int? totalOptions,
  }) {
    return TreatmentRequestGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      totalOptions: totalOptions ?? this.totalOptions,
    );
  }
}
 