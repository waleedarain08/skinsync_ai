import '../responses/appointments_list_response.dart';
import '../responses/simulation_history_response.dart';

enum JourneyStepStatus {
  sent,
  pending,
  finalized,
  scheduled,
  confirmed,
  completed,
  cancelled,
}

class ClinicalJourney {
  final String id;
  final JourneyStepStatus status;
  final DateTime requestedAt;
  final DateTime? completedAt;
  final PatientRequestStep patientRequest;
  final DoctorFinalizedStep? doctorFinalized;
  final List<TreatmentBranch> treatmentBranches;

  ClinicalJourney({
    required this.id,
    required this.status,
    required this.requestedAt,
    this.completedAt,
    required this.patientRequest,
    this.doctorFinalized,
    required this.treatmentBranches,
  });

  bool get isCompleted => status == JourneyStepStatus.completed;
}

class PatientRequestStep {
  final String id;
  final List<String> treatments;
  final DateTime requestedAt;
  final String status;
  final String? preferredClinic;
  final String? note;

  PatientRequestStep({
    required this.id,
    required this.treatments,
    required this.requestedAt,
    required this.status,
    this.preferredClinic,
    this.note,
  });
}

class DoctorFinalizedStep {
  final String doctorName;
  final String? doctorImage;
  final DateTime finalizedAt;
  final String note;

  DoctorFinalizedStep({
    required this.doctorName,
    this.doctorImage,
    required this.finalizedAt,
    required this.note,
  });
}

class TreatmentBranch {
  final String treatmentName;
  final String area;
  final AppointmentItem mainAppointment;
  final List<AppointmentItem> followUps;

  TreatmentBranch({
    required this.treatmentName,
    required this.area,
    required this.mainAppointment,
    this.followUps = const [],
  });

  bool get isBranchCompleted {
    if (mainAppointment.status?.toLowerCase() != 'completed') return false;
    if (followUps.isEmpty) return true;
    return followUps.every((f) => f.status?.toLowerCase() == 'completed');
  }
}
