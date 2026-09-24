class AppointmentStatusEvent {
  final int appointmentId;
  final String status;

  AppointmentStatusEvent({required this.appointmentId, required this.status});

  factory AppointmentStatusEvent.fromJson(Map<String, dynamic> json) {
    return AppointmentStatusEvent(
      appointmentId: json['appointment_id'],
      status: json['status'],
    );
  }
}
