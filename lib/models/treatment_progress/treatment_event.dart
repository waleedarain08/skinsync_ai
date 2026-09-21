enum TreatmentEventStatus {
  completed,
  upcoming,
  pending
}

class TreatmentEvent {
  final String id;
  final String title;
  final DateTime? date;
  final TreatmentEventStatus status;
  final String? doctorName;
  final String? clinicName;
  final String? appointmentTime;

  TreatmentEvent({
    required this.id,
    required this.title,
    this.date,
    required this.status,
    this.doctorName,
    this.clinicName,
    this.appointmentTime,
  });

  bool get isCompleted => status == TreatmentEventStatus.completed;
  bool get isUpcoming => status == TreatmentEventStatus.upcoming;
}
