import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/clinical_journey/clinical_journey_model.dart';
import '../../models/responses/appointments_list_response.dart';
import '../../models/base_state_model.dart';
import 'package:flutter/foundation.dart';

final clinicalJourneyProvider = NotifierProvider<ClinicalJourneyViewModel, ClinicalJourneyState>(() {
  return ClinicalJourneyViewModel();
});

class ClinicalJourneyViewModel extends Notifier<ClinicalJourneyState> {
  @override
  ClinicalJourneyState build() {
    return ClinicalJourneyState(journey: _getDummyJourney());
  }

  ClinicalJourney _getDummyJourney() {
    // Dates
    final requestDate = DateTime(2026, 8, 20, 10, 30);
    final finalizedDate = DateTime(2026, 8, 21, 14, 0);
    final mainApptDate = DateTime(2026, 9, 2);
    final followUpDate = DateTime(2026, 9, 16);

    // Common Doctor and Clinic
    final doctor = AppointmentDoctor(
      id: 1,
      name: "Dr. Sarah Wilson",
      image: "https://via.placeholder.com/150",
      title: "Dermatologist",
    );
    final clinic = AppointmentClinic(
      id: 1,
      name: "SkinSync Clinic",
      logo: "https://via.placeholder.com/150",
      address: "123 Beauty St, London",
    );

    // Branch 1: Botox Cheeks
    final cheeksAppt = AppointmentItem(
      appointmentId: 101,
      date: mainApptDate.millisecondsSinceEpoch ~/ 1000,
      status: "Completed",
      appointmentType: "Treatment",
      slot: AppointmentSlot(
        startTime: (mainApptDate.millisecondsSinceEpoch ~/ 1000) + (11 * 3600),
        endTime: (mainApptDate.millisecondsSinceEpoch ~/ 1000) + (11 * 3600) + 1800,
      ),
      doctor: doctor,
      clinic: clinic,
      treatments: [
        AppointmentTreatment(
          treatmentName: "Botox",
          areaName: "Cheeks",
          status: "end",
          startTime: (mainApptDate.millisecondsSinceEpoch ~/ 1000) + (11 * 3600),
          endTime: (mainApptDate.millisecondsSinceEpoch ~/ 1000) + (11 * 3600) + 1800,
        )
      ],
    );

    final cheeksFollowUp = AppointmentItem(
      appointmentId: 201,
      date: followUpDate.millisecondsSinceEpoch ~/ 1000,
      status: "Completed",
      appointmentType: "Follow-up",
      slot: AppointmentSlot(
        startTime: (followUpDate.millisecondsSinceEpoch ~/ 1000) + (11 * 3600),
        endTime: (followUpDate.millisecondsSinceEpoch ~/ 1000) + (11 * 3600) + 900,
      ),
      doctor: doctor,
      clinic: clinic,
      treatments: [
        AppointmentTreatment(
          treatmentName: "Botox",
          areaName: "Cheeks",
          status: "end",
        )
      ],
    );

    // Branch 2: Botox Lips
    final lipsAppt = AppointmentItem(
      appointmentId: 102,
      date: mainApptDate.millisecondsSinceEpoch ~/ 1000,
      status: "Completed",
      appointmentType: "Treatment",
      slot: AppointmentSlot(
        startTime: (mainApptDate.millisecondsSinceEpoch ~/ 1000) + (12 * 3600),
        endTime: (mainApptDate.millisecondsSinceEpoch ~/ 1000) + (12 * 3600) + 1800,
      ),
      doctor: doctor,
      clinic: clinic,
      treatments: [
        AppointmentTreatment(
          treatmentName: "Botox",
          areaName: "Lips",
          status: "end",
          startTime: (mainApptDate.millisecondsSinceEpoch ~/ 1000) + (12 * 3600),
          endTime: (mainApptDate.millisecondsSinceEpoch ~/ 1000) + (12 * 3600) + 1800,
        )
      ],
    );

    final lipsFollowUp = AppointmentItem(
      appointmentId: 202,
      date: followUpDate.millisecondsSinceEpoch ~/ 1000,
      status: "Completed",
      appointmentType: "Follow-up",
      slot: AppointmentSlot(
        startTime: (followUpDate.millisecondsSinceEpoch ~/ 1000) + (12 * 3600),
        endTime: (followUpDate.millisecondsSinceEpoch ~/ 1000) + (12 * 3600) + 900,
      ),
      doctor: doctor,
      clinic: clinic,
      treatments: [
        AppointmentTreatment(
          treatmentName: "Botox",
          areaName: "Lips",
          status: "end",
        )
      ],
    );

    return ClinicalJourney(
      id: "journey_001",
      status: JourneyStepStatus.completed,
      requestedAt: requestDate,
      completedAt: followUpDate,
      patientRequest: PatientRequestStep(
        id: "req_001",
        treatments: ["Botox – Cheeks", "Botox – Lips"],
        requestedAt: requestDate,
        status: "Request Sent",
        preferredClinic: "SkinSync Clinic",
      ),
      doctorFinalized: DoctorFinalizedStep(
        doctorName: "Dr. Sarah Wilson",
        doctorImage: "https://via.placeholder.com/150",
        finalizedAt: finalizedDate,
        note: "Doctor reviewed the patient request and scheduled separate appointments for each treatment area.",
      ),
      treatmentBranches: [
        TreatmentBranch(
          treatmentName: "Botox",
          area: "Cheeks",
          mainAppointment: cheeksAppt,
          followUps: [cheeksFollowUp],
        ),
        TreatmentBranch(
          treatmentName: "Botox",
          area: "Lips",
          mainAppointment: lipsAppt,
          followUps: [lipsFollowUp],
        ),
      ],
    );
  }
}

@immutable
class ClinicalJourneyState extends BaseStateModel {
  final ClinicalJourney? journey;

  const ClinicalJourneyState({
    super.loading = false,
    super.errorMessage,
    this.journey,
  });

  @override
  ClinicalJourneyState copyWith({
    bool? loading,
    String? errorMessage,
    ClinicalJourney? journey,
  }) {
    return ClinicalJourneyState(
      loading: loading ?? this.loading,
      errorMessage: errorMessage ?? this.errorMessage,
      journey: journey ?? this.journey,
    );
  }
}
