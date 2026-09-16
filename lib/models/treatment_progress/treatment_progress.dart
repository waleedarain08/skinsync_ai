import 'treatment_event.dart';

enum TreatmentStatus {
  inProgress,
  completed,
  upcoming,
  paused
}

class TreatmentProgress {
  final String id;
  final String treatmentName;
  final String area;
  final TreatmentStatus status;
  final List<TreatmentEvent> events;
  final String? imageAsset;

  TreatmentProgress({
    required this.id,
    required this.treatmentName,
    required this.area,
    required this.status,
    required this.events,
    this.imageAsset,
  });

  int get totalSteps => events.length;
  int get completedSteps => events.where((e) => e.isCompleted).length;
  double get progress => totalSteps == 0 ? 0 : completedSteps / totalSteps;

  String get statusText {
    switch (status) {
      case TreatmentStatus.inProgress:
        return "In Progress";
      case TreatmentStatus.completed:
        return "Completed";
      case TreatmentStatus.upcoming:
        return "Upcoming";
      case TreatmentStatus.paused:
        return "Paused";
    }
  }
}
