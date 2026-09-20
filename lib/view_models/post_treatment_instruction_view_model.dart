import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/base_state_model.dart';
import '../models/responses/post_treatment_instruction_model.dart';
import '../models/responses/pre_treatment_instruction_model.dart';

final postTreatmentInstructionProvider = NotifierProvider<
    PostTreatmentInstructionViewModel, PostTreatmentInstructionState>(() {
  return PostTreatmentInstructionViewModel();
});

class PostTreatmentInstructionViewModel
    extends Notifier<PostTreatmentInstructionState> {
  @override
  PostTreatmentInstructionState build() {
    return PostTreatmentInstructionState(
      instructions: _getDummyPostInstructions(),
    );
  }

  List<PostTreatmentInstructionItem> _getDummyPostInstructions() {
    return [
      PostTreatmentInstructionItem(
        treatmentId: 101,
        treatmentName: "Botox Anti-Wrinkle",
        areaName: "Cheeks",
        postTreatmentInstructions:
            "• Remain upright for 4 hours after treatment.\n• Do not massage or press on cheek area.\n• Avoid saunas, hot tubs, and intense heat for 24 hours.\n• Gently clean the area with mild cleanser.",
        postTreatmentAttachments: [
          InstructionAttachment(
            name: "Botox_Cheeks_Aftercare.pdf",
            url: "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf",
            type: "pdf",
          ),
        ],
      ),
      PostTreatmentInstructionItem(
        treatmentId: 102,
        treatmentName: "Dermal Fillers",
        areaName: "Forehead",
        postTreatmentInstructions:
            "• Avoid wearing hats or tight headwear for 48 hours.\n• Sleep with your head slightly elevated for 2 nights.\n• Apply cool compresses gently if minor swelling occurs.",
        postTreatmentAttachments: [
          InstructionAttachment(
            name: "Forehead_Filler_Aftercare.pdf",
            url: "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf",
            type: "pdf",
          ),
        ],
      ),
    ];
  }
}

@immutable
class PostTreatmentInstructionState extends BaseStateModel {
  final List<PostTreatmentInstructionItem> instructions;

  const PostTreatmentInstructionState({
    super.loading = false,
    super.errorMessage,
    this.instructions = const [],
  });

  @override
  PostTreatmentInstructionState copyWith({
    bool? loading,
    String? errorMessage,
    List<PostTreatmentInstructionItem>? instructions,
  }) {
    return PostTreatmentInstructionState(
      loading: loading ?? this.loading,
      errorMessage: errorMessage ?? this.errorMessage,
      instructions: instructions ?? this.instructions,
    );
  }
}
