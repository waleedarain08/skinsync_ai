import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../models/base_state_model.dart';
import '../models/responses/doctor_treatment_photo_model.dart';
import '../models/responses/post_treatment_photo_model.dart';
import '../services/media_service.dart';
import 'auth_view_model.dart';

final postTreatmentPhotoProvider =
    NotifierProvider<PostTreatmentPhotoViewModel, PostTreatmentPhotoState>(() {
  return PostTreatmentPhotoViewModel();
});

class PostTreatmentPhotoViewModel extends Notifier<PostTreatmentPhotoState> {
  @override
  PostTreatmentPhotoState build() {
    return PostTreatmentPhotoState(photoItems: _getDummyPhotoItems());
  }

  Future<void> addPhotoToMilestone({
  required int treatmentId,
  required String milestoneTitle,
  required ImageSource source,
}) async {
  final pickedFile = await ImagePicker().pickImage(
    source: source,
    preferredCameraDevice: CameraDevice.front,
  );

  if (pickedFile == null) return;
  final authData = ref.read(authViewModel).authData;
  try {
    state = state.copyWith(loading: true, errorMessage: null);

    final email = authData?.user?.primaryEmail;

    if (email == null || email.isEmpty) {
      throw Exception('User email not found');
    }

    final imagePath =
        '$email/post-treatment-photos/${DateTime.now().millisecondsSinceEpoch}_${pickedFile.name}';

    final imageUrl = await MediaService().uploadImage(
      imagePath,
      pickedFile,
    );

    if (imageUrl == null || imageUrl.isEmpty) {
      throw Exception('Failed to upload image');
    }

    final newPhoto = UploadedPhoto(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      url: imageUrl,
      label: "New Upload",
      uploadedAt: DateTime.now(),
    );

    final updatedItems = state.photoItems.map((item) {
      if (item.treatmentId != treatmentId) {
        return item;
      }

      final updatedMilestones = item.photoMilestones.map((milestone) {
        if (milestone.title != milestoneTitle) {
          return milestone;
        }

        final newPhotos = [
          ...milestone.uploadedPhotos,
          newPhoto,
        ];

        return PhotoMilestoneItem(
          numberOfDays: milestone.numberOfDays,
          requiredPhotos: milestone.requiredPhotos,
          title: milestone.title,
          uploadedPhotos: newPhotos,
        );
      }).toList();

      return PostTreatmentPhotoItem(
        treatmentId: item.treatmentId,
        treatmentName: item.treatmentName,
        areaName: item.areaName,
        requirePostTreatmentPhotos: item.requirePostTreatmentPhotos,
        photoMilestones: updatedMilestones,
        doctorPhotos: item.doctorPhotos,
      );
    }).toList();

    state = state.copyWith(
      loading: false,
      photoItems: updatedItems,
    );
  } catch (e) {
    state = state.copyWith(
      loading: false,
      errorMessage: e.toString(),
    );
  }
}
  List<PostTreatmentPhotoItem> _getDummyPhotoItems() {
    return [
      PostTreatmentPhotoItem(
        treatmentId: 101,
        treatmentName: "Botox Anti-Wrinkle",
        areaName: "Cheeks",
        requirePostTreatmentPhotos: true,
        photoMilestones: [
          PhotoMilestoneItem(
            numberOfDays: 3,
            requiredPhotos: 2,
            title: "Day 3 Recovery Check",
            uploadedPhotos: [
              UploadedPhoto(
                id: "p1",
                url: "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400",
                label: "Frontal View",
                uploadedAt: DateTime.now().subtract(const Duration(days: 2)),
              ),
              UploadedPhoto(
                id: "p2",
                url: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400",
                label: "Right Profile 45°",
                uploadedAt: DateTime.now().subtract(const Duration(days: 2)),
              ),
            ],
          ),
          PhotoMilestoneItem(
            numberOfDays: 7,
            requiredPhotos: 2,
            title: "Day 7 Symmetry Progress",
            uploadedPhotos: [
              UploadedPhoto(
                id: "p3",
                url: "https://images.unsplash.com/photo-1517841905240-472988babdf9?w=400",
                label: "Frontal Smile",
                uploadedAt: DateTime.now().subtract(const Duration(hours: 12)),
              ),
            ],
          ),
          PhotoMilestoneItem(
            numberOfDays: 14,
            requiredPhotos: 2,
            title: "Day 14 Final Assessment",
            uploadedPhotos: [],
          ),
        ],
        doctorPhotos: [
          DoctorTreatmentPhoto(
            id: "dp101",
            url: "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=500",
            title: "Immediate Post-Treatment Result",
            doctorName: "Dr. Sarah Johnson",
            dateTaken: DateTime.now().subtract(const Duration(hours: 12)),
            note: "Right after injection. Minimal swelling, excellent symmetry.",
          ),
          DoctorTreatmentPhoto(
            id: "dp102",
            url: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500",
            title: "Day 7 Clinical Follow-Up",
            doctorName: "Dr. Sarah Johnson",
            dateTaken: DateTime.now().subtract(const Duration(days: 7)),
            note: "Volume evaluation and wrinkle smoothing confirmed.",
          ),
        ],
      ),
      PostTreatmentPhotoItem(
        treatmentId: 102,
        treatmentName: "Dermal Fillers",
        areaName: "Forehead",
        requirePostTreatmentPhotos: true,
        photoMilestones: [
          PhotoMilestoneItem(
            numberOfDays: 1,
            requiredPhotos: 1,
            title: "Day 1 Initial Healing",
            uploadedPhotos: [
              UploadedPhoto(
                id: "p4",
                url: "https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=400",
                label: "Forehead Close-Up",
                uploadedAt: DateTime.now().subtract(const Duration(days: 4)),
              ),
            ],
          ),
          PhotoMilestoneItem(
            numberOfDays: 7,
            requiredPhotos: 2,
            title: "Day 7 Volume Assessment",
            uploadedPhotos: [],
          ),
        ],
        doctorPhotos: [
          DoctorTreatmentPhoto(
            id: "dp103",
            url: "https://images.unsplash.com/photo-1517841905240-472988babdf9?w=500",
            title: "Clinical Post-Injection Baseline",
            doctorName: "Dr. Sarah Johnson",
            dateTaken: DateTime.now().subtract(const Duration(days: 1)),
            note: "Forehead filler placement check.",
          ),
        ],
      ),
    ];
  }
}

@immutable
class PostTreatmentPhotoState extends BaseStateModel {
  final List<PostTreatmentPhotoItem> photoItems;

  const PostTreatmentPhotoState({
    super.loading = false,
    super.errorMessage,
    this.photoItems = const [],
  });

  @override
  PostTreatmentPhotoState copyWith({
    bool? loading,
    String? errorMessage,
    List<PostTreatmentPhotoItem>? photoItems,
  }) {
    return PostTreatmentPhotoState(
      loading: loading ?? this.loading,
      errorMessage: errorMessage ?? this.errorMessage,
      photoItems: photoItems ?? this.photoItems,
    );
  }
}
