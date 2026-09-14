import 'base_response_model.dart';

class FilterStatusResponse extends BaseResponseModel {
  final List<FilterStatus> data;
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  FilterStatusResponse({
    required super.isSuccess,
    required super.message,
    required this.data,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory FilterStatusResponse.fromJson(Map<String, dynamic> json) {
    return FilterStatusResponse(
      isSuccess: (json['is_success'] as bool?) ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map(
                (e) => FilterStatus.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          [],
      page: json['page'] as int? ?? 1,
      limit: json['limit'] as int? ?? 10,
      total: json['total'] as int? ?? 0,
      totalPages:
          json['total_pages'] as int? ??
          json['totalPages'] as int? ??
          0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_success': isSuccess,
      'message': message,
      'data': data.map((e) => e.toJson()).toList(),
      'page': page,
      'limit': limit,
      'total': total,
      'total_pages': totalPages,
    };
  }
}

class FilterStatus {
  final int id;
  final String name;

  FilterStatus({
    required this.id,
    required this.name,
  });

  factory FilterStatus.fromJson(Map<String, dynamic> json) {
    return FilterStatus(
      id: json['id'] as int? ?? 0,
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}