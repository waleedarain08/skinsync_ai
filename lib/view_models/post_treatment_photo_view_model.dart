import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../models/base_state_model.dart';
import '../models/responses/post_treatment_photo_model.dart';

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

    final newPhoto = UploadedPhoto(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      url: pickedFile.path,
      label: "New Upload",
      uploadedAt: DateTime.now(),
    );

    final updatedItems = state.photoItems.map((item) {
      if (item.treatmentId == treatmentId || item.treatmentName == milestoneTitle) {
        final updatedMilestones = item.photoMilestones.map((m) {
          if (m.title == milestoneTitle) {
            final newPhotos = [...m.uploadedPhotos, newPhoto];
            return PhotoMilestoneItem(
              numberOfDays: m.numberOfDays,
              requiredPhotos: m.requiredPhotos,
              title: m.title,
              uploadedPhotos: newPhotos,
            );
          }
          return m;
        }).toList();

        return PostTreatmentPhotoItem(
          treatmentId: item.treatmentId,
          treatmentName: item.treatmentName,
          areaName: item.areaName,
          requirePostTreatmentPhotos: item.requirePostTreatmentPhotos,
          photoMilestones: updatedMilestones,
        );
      }
      return item;
    }).toList();

    state = state.copyWith(photoItems: updatedItems);
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
