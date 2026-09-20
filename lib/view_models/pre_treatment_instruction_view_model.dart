import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/base_state_model.dart';
import '../models/responses/doctor_treatment_photo_model.dart';
import '../models/responses/pre_treatment_instruction_model.dart';

final preTreatmentInstructionProvider = NotifierProvider<
    PreTreatmentInstructionViewModel, PreTreatmentInstructionState>(() {
  return PreTreatmentInstructionViewModel();
});

class PreTreatmentInstructionViewModel
    extends Notifier<PreTreatmentInstructionState> {
  @override
  PreTreatmentInstructionState build() {
    return PreTreatmentInstructionState(
        instructions: _getDummyPreInstructions());
  }

  List<PreTreatmentInstructionItem> _getDummyPreInstructions() {
    return [
      PreTreatmentInstructionItem(
        treatmentId: 101,
        treatmentName: "Botox Anti-Wrinkle",
        areaName: "Cheeks",
        preTreatmentInstructions:
            "• Avoid alcohol, aspirin, ibuprofen, and blood thinners 48 hours prior to treatment.\n• Do not apply blush, cheek contour, or active skin creams on appointment day.\n• Avoid facial massages or intense cardiovascular workouts 24 hours before.\n• Arrive with clean skin free of makeup, moisturizers, or sunscreen.",
        preTreatmentAttachments: [
          InstructionAttachment(
            name: "Botox_Cheeks_Prep_Guide.pdf",
            url: "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf",
            type: "pdf",
          ),
        ],
        doctorPhotos: [
          DoctorTreatmentPhoto(
            id: "dp1",
            url: "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=500",
            title: "Baseline Frontal Angle",
            doctorName: "Dr. Sarah Johnson",
            dateTaken: DateTime.now().subtract(const Duration(days: 3)),
            note: "Pre-procedure facial mapping photo.",
          ),
          DoctorTreatmentPhoto(
            id: "dp2",
            url: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500",
            title: "Baseline Profile 45°",
            doctorName: "Dr. Sarah Johnson",
            dateTaken: DateTime.now().subtract(const Duration(days: 3)),
            note: "Pre-procedure side symmetry analysis.",
          ),
        ],
      ),
      PreTreatmentInstructionItem(
        treatmentId: 102,
        treatmentName: "Dermal Fillers",
        areaName: "Forehead",
        preTreatmentInstructions:
            "• Avoid wearing tight headbands, caps, or helmets on the day of treatment.\n• Discontinue active forehead skin exfoliants (AHAs, BHAs, Retin-A) 5 days prior.\n• Ensure forehead skin is thoroughly cleansed and free from makeup, hair products, or oils.\n• Avoid anti-inflammatory drugs (ibuprofen, naproxen, aspirin) for 48 hours to minimize forehead bruising.",
        preTreatmentAttachments: [
          InstructionAttachment(
            name: "Forehead_Filler_PreCare.pdf",
            url: "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf",
            type: "pdf",
          ),
        ],
        doctorPhotos: [
          DoctorTreatmentPhoto(
            id: "dp3",
            url: "https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=500",
            title: "Forehead Baseline Close-Up",
            doctorName: "Dr. Sarah Johnson",
            dateTaken: DateTime.now().subtract(const Duration(days: 4)),
            note: "Baseline wrinkle depth assessment.",
          ),
        ],
      ),
    ];
  }
}

@immutable
class PreTreatmentInstructionState extends BaseStateModel {
  final List<PreTreatmentInstructionItem> instructions;

  const PreTreatmentInstructionState({
    super.loading = false,
    super.errorMessage,
    this.instructions = const [],
  });

  @override
  PreTreatmentInstructionState copyWith({
    bool? loading,
    String? errorMessage,
    List<PreTreatmentInstructionItem>? instructions,
  }) {
    return PreTreatmentInstructionState(
      loading: loading ?? this.loading,
      errorMessage: errorMessage ?? this.errorMessage,
      instructions: instructions ?? this.instructions,
    );
  }
}
