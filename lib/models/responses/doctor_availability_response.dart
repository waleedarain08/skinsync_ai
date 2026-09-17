import 'treatment_area_list_response.dart';

class AvailabilityResponse extends BaseApiResponseModel {
  final List<AvailabilitySlot> slots;
  AvailabilityResponse({
    required super.isSuccess,
    required super.message,
    required this.slots,
  });

  factory AvailabilityResponse.fromJson(Map<String, dynamic> json) {
    return AvailabilityResponse(
      isSuccess: json['is_success'] ?? false,
      message: json['message'] ?? '',
      slots:
          (json['slots'] as List<dynamic>?)
              ?.map((e) => AvailabilitySlot.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_success': isSuccess,
      'message': message,
      'slots': slots.map((e) => e.toJson()).toList(),
    };
  }
}

class AvailabilitySlot {
  final int startTime;
  final int endTime;
  final bool isBooked;

  AvailabilitySlot({
    required this.startTime,
    required this.endTime,
    required this.isBooked,
  });

  factory AvailabilitySlot.fromJson(Map<String, dynamic> json) {
    return AvailabilitySlot(
      startTime: json['start_time'] ?? 0,
      endTime: json['end_time'] ?? 0,
      isBooked: json['is_booked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'start_time': startTime,
      'end_time': endTime,
      'is_booked': isBooked,
    };
  }
}
