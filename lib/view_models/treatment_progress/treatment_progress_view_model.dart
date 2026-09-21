// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../models/treatment_progress/treatment_progress.dart';
// import '../../models/treatment_progress/treatment_event.dart';
// import '../../models/base_state_model.dart';
// import 'package:flutter/foundation.dart';

// final treatmentProgressProvider = NotifierProvider<TreatmentProgressViewModel, TreatmentProgressState>(() {
//   return TreatmentProgressViewModel();
// });

// class TreatmentProgressViewModel extends Notifier<TreatmentProgressState> {
//   @override
//   TreatmentProgressState build() {
//     return TreatmentProgressState(treatments: _getDummyTreatments());
//   }

//   List<TreatmentProgress> _getDummyTreatments() {
//     // Treatment 1: Botox Cheeks
//     final treatment1 = TreatmentProgress(
//       id: "j1",
//       treatmentName: "Botox",
//       area: "Cheeks",
//       status: TreatmentStatus.inProgress,
//       events: [
//         TreatmentEvent(
//           id: "j1e1",
//           title: "Consultation",
//           date: DateTime(2026, 9, 18),
//           status: TreatmentEventStatus.completed,
//         ),
//         TreatmentEvent(
//           id: "j1e2",
//           title: "Session 1",
//           date: DateTime(2026, 9, 25),
//           status: TreatmentEventStatus.completed,
//           appointmentTime: "10:00 AM",
//           doctorName: "Dr. Sarah Smith",
//           clinicName: "Skin Sync Clinic",
//         ),
//         TreatmentEvent(
//           id: "j1e3",
//           title: "Follow-up",
//           date: DateTime(2026, 10, 10),
//           status: TreatmentEventStatus.upcoming,
//           appointmentTime: "11:30 AM",
//         ),
//         TreatmentEvent(
//           id: "j1e4",
//           title: "Session 2",
//           date: DateTime(2026, 10, 25),
//           status: TreatmentEventStatus.upcoming,
//         ),
//       ],
//     );

//     // Treatment 2: Botox Lips
//     final treatment2 = TreatmentProgress(
//       id: "j2",
//       treatmentName: "Botox",
//       area: "Lips",
//       status: TreatmentStatus.inProgress,
//       events: [
//         TreatmentEvent(
//           id: "j2e1",
//           title: "Consultation",
//           date: DateTime(2026, 9, 18),
//           status: TreatmentEventStatus.completed,
//         ),
//         TreatmentEvent(
//           id: "j2e2",
//           title: "Session 1",
//           date: DateTime(2026, 9, 25),
//           status: TreatmentEventStatus.completed,
//           appointmentTime: "10:00 AM",
//           doctorName: "Dr. Sarah Smith",
//           clinicName: "Skin Sync Clinic",
//         ),
//         TreatmentEvent(
//           id: "j2e3",
//           title: "Follow-up",
//           date: DateTime(2026, 10, 15),
//           status: TreatmentEventStatus.upcoming,
//           appointmentTime: "02:00 PM",
//         ),
//         TreatmentEvent(
//           id: "j2e4",
//           title: "Session 2",
//           date: DateTime(2026, 10, 30),
//           status: TreatmentEventStatus.upcoming,
//         ),
//       ],
//     );

//     // Treatment 3: Dermal Filler Cheeks
//     final treatment3 = TreatmentProgress(
//       id: "j3",
//       treatmentName: "Dermal Filler",
//       area: "Cheeks",
//       status: TreatmentStatus.upcoming,
//       events: [
//         TreatmentEvent(
//           id: "j3e1",
//           title: "Consultation",
//           status: TreatmentEventStatus.completed,
//           date: DateTime(2026, 9, 10),
//         ),
//         TreatmentEvent(
//           id: "j3e2",
//           title: "Session 1",
//           status: TreatmentEventStatus.upcoming,
//         ),
//       ],
//     );

//     return [treatment1, treatment2, treatment3];
//   }

//   void refresh() {
//     state = state.copyWith(loading: true);
//     // Simulate API delay
//     Future.delayed(const Duration(milliseconds: 500), () {
//       state = state.copyWith(loading: false, treatments: _getDummyTreatments());
//     });
//   }
// }

// @immutable
// class TreatmentProgressState extends BaseStateModel {
//   final List<TreatmentProgress> treatments;

//   const TreatmentProgressState({
//     super.loading = false,
//     super.errorMessage,
//     this.treatments = const [],
//   });

//   @override
//   TreatmentProgressState copyWith({
//     bool? loading,
//     String? errorMessage,
//     List<TreatmentProgress>? treatments,
//   }) {
//     return TreatmentProgressState(
//       loading: loading ?? this.loading,
//       errorMessage: errorMessage ?? this.errorMessage,
//       treatments: treatments ?? this.treatments,
//     );
//   }
// }
