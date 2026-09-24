import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../exceptions/app_exception.dart';
import '../models/base_state_model.dart';
import '../models/requests/change_payment_status_request.dart';
import '../models/requests/instructions_request.dart';
import '../models/requests/per_treatment_photos_request.dart';
import '../models/requests/post_treatment_photos_request.dart';
import '../models/requests/scan_qr_request.dart';
import '../models/responses/appointment_detail_response.dart';
import '../models/responses/appointment_status_event.dart';
import '../models/responses/appointment_type_list_response.dart';
import '../models/responses/appointments_list_response.dart';
import '../models/responses/instructions_response.dart';
import '../models/responses/post_treatment_photos_response.dart';
import '../models/responses/scan_qr_response.dart';
import '../models/responses/simulation_history_response.dart';
import '../repositories/appointment_repository.dart';
import '../services/api_base_helper.dart';
import '../services/appointment_service.dart';
import '../services/encryption_service.dart';
import '../services/media_service.dart';
import 'auth_view_model.dart';
import 'base_view_model.dart';

final appointmentProvider =
    NotifierProvider<AppointmentViewModel, AppointmentState>(
      () => AppointmentViewModel(
        repo: AppointmentService(apiClient: ApiBaseHelper()),
      ),
    );

class AppointmentViewModel extends BaseViewModel<AppointmentState> {
  AppointmentViewModel({required this.repo})
    : super(initialState: const AppointmentState());

  final AppointmentRepository repo;

  Future<List<AppointmentTypeData>?> getAppointmentTypes() async {
    return await runSafely(() async {
      state = state.copyWith(loading: true, errorMessage: null);
      final response = await repo.getAppointmentTypes();
      state = state.copyWith(
        loading: false,
        appointmentTypes: response.data ?? [],
      );
      return response.data ?? [];
    });
  }

  Future<void> fetchSimulationHistory() async {
    await runSafely(() async {
      state = state.copyWith(loading: true, errorMessage: null);
      final data = await repo.getSimulationHistory();
      state = state.copyWith(loading: false, simulations: data);
    });
  }

  Future<void> getAppointments({int page = 1, int limit = 10}) async {
    await runSafely(() async {
      state = state.copyWith(loading: true, errorMessage: null);
      final response = await repo.getAppointmentsApi(page: page, limit: limit);
      state = state.copyWith(loading: false, appointmentsResponse: response);
    });
  }

  void clearAppointmentDetail() {
    state = state.copyWith(appointmentDetail: null, loading: true);
  }

  Future<void> getAppointmentDetail(int appointmentId) async {
    await runSafely(() async {
      state = state.copyWith(
        loading: true,
        errorMessage: null,
        appointmentDetail: null,
      );
      final response = await repo.getAppointmentDetail(
        appointmentId: appointmentId,
      );
      state = state.copyWith(loading: false, appointmentDetail: response.data);
    });
  }

  Future<ScanQrResponse?> scanQrCode({
    required int clinicId,
    required int appointmentId,
  }) async {
    return await runSafely(() async {
      EasyLoading.show(status: 'Checking in...');
      final data = await repo.scanQrCode(
        request: ScanQrRequest(
          clinicId: clinicId,
          appointmentId: appointmentId,
        ),
      );
      state = state.copyWith(scanQrResponse: data);
      EasyLoading.dismiss();
      return data;
    });
  }

  Future<bool?> changePaymentStatus({
    required String paymentStatus,
    required int appointmentId,
  }) async {
    return await runSafely(() async {
      EasyLoading.show(status: 'Checking in...');
      await repo.changePaymentStatus(
        appointmentId: appointmentId,
        request: ChangePaymentStatusRequest(paymentStatus: paymentStatus),
      );
      EasyLoading.dismiss();
      await getAppointmentDetail(appointmentId);
      return true;
    });
  }

  Future<ScanQrResponse?> decodeQrCode(
    String qrCode, {
    required int appointmentId,
  }) async {
    return await runSafely(() async {
      final decrypted = await EncryptionService().decode(cipherText: qrCode);
      if (decrypted == null) {
        throw const AppException('Could not decode QR code');
      }

      final clinicId = int.tryParse(decrypted);
      if (clinicId == null) {
        throw const AppException('Invalid QR code');
      }

      return await scanQrCode(clinicId: clinicId, appointmentId: appointmentId);
    });
  }

  Future<String?> encryptAppointmentData(AppointmentDetailData? data) async {
    return await runSafely<String?>(() async {
      final appointmentId = data?.id;
      final doctorId = data?.doctor?.id;
      final clinicId = data?.clinic?.id;
      if (appointmentId == null || doctorId == null || clinicId == null) {
        throw const AppException('Could not generate QR Code!');
      }
      return await EncryptionService().encrypt(
        message: '$appointmentId/$doctorId/$clinicId',
      );
    });
  }

  // ---------------------------------------------------------------------------
  // Instructions
  // ---------------------------------------------------------------------------

  Future<void> preInstructions({required InstructionsRequest request}) async {
    return await runSafely(() async {
      state = state.copyWith(loading: true);
      final response = await repo.preInstructions(request: request);
      state = state.copyWith(loading: false, preInstruction: response.data);
    });
  }

  Future<void> postInstructions({required InstructionsRequest request}) async {
    return await runSafely(() async {
      state = state.copyWith(loading: true);
      final response = await repo.postInstructions(request: request);
      state = state.copyWith(loading: false, postInstruction: response.data);
    });
  }

  Future<void> postTreatmentPhotos({
    required InstructionsRequest request,
  }) async {
    return await runSafely(() async {
      state = state.copyWith(loading: true);
      final response = await repo.postTreatmentPhotos(request: request);
      state = state.copyWith(loading: false, postTreatmentPhoto: response.data);
    });
  }

  Future<bool> updatPostTreatmentPhotos({
    required PostTreatmentPhotosRequest request,
    required InstructionsRequest insRequest,
  }) async {
    final ok = await runSafely<bool>(() async {
      state = state.copyWith(loading: true);
      final response = await repo.updatePostTreatmentPhotos(request: request);
      if (response.isSuccess != true) {
        throw AppException(response.message ?? 'Failed to save photo');
      }
      await postTreatmentPhotos(request: insRequest);
      state = state.copyWith(loading: false);
      return true;
    });
    return ok ?? false;
  }

  /// Clears old data so another appointment's instructions never flash.
  void clearTreatmentCare() {
    state = state.copyWith(
      postInstruction: const [],
      postTreatmentPhoto: const [],
    );
  }

  // ---------------------------------------------------------------------------
  // Image upload (shared)
  // ---------------------------------------------------------------------------

  /// Picks an image and uploads it to Firebase. Returns the download URL.
  /// [folder] decides the Firebase storage sub-path.
  Future<String?> uploadPostTreatmentImage({
    required ImageSource source,
    String folder = 'post-treatment-photos',
  }) async {
    return await runSafely<String?>(() async {
      final picked = await ImagePicker().pickImage(
        source: source,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.front,
      );
      if (picked == null) return null;

      EasyLoading.show(
        status: 'Uploading photo...',
        maskType: EasyLoadingMaskType.black,
      );

      final email = ref.read(authViewModel).authData?.user?.primaryEmail;
      if (email == null || email.isEmpty) {
        throw const AppException('User email not found');
      }

      final url = await MediaService().uploadImage(
        '$email/$folder/${DateTime.now().millisecondsSinceEpoch}_${picked.name}',
        picked,
      );
      if (url == null || url.isEmpty) {
        throw const AppException('Failed to upload image');
      }

      EasyLoading.dismiss();
      return url;
    });
  }

  // ---------------------------------------------------------------------------
  // Post-treatment milestone photos
  // ---------------------------------------------------------------------------

  /// Sends already-uploaded Firebase URLs (saved + newly added) to the API.
  Future<bool> submitMilestonePhotos({
    required int treatmentId,
    required int areaId,
    required PhotoMilestone milestone,
    required List<String> newPhotos,
    required InstructionsRequest insRequest,
  }) async {
    final photos = [...milestone.uploadedPhotos, ...newPhotos];
    final requiredPhotos = milestone.requiredPhotos ?? 0;

    EasyLoading.show(
      status: 'Saving photos...',
      maskType: EasyLoadingMaskType.black,
    );

    final ok = await updatPostTreatmentPhotos(
      request: PostTreatmentPhotosRequest(
        appointmentId: insRequest.appointmentId,
        treatmentId: treatmentId,
        areaId: areaId,
        photoMilestone: PhotoMilestoneRequest(
          title: milestone.title ?? '',
          isUpload: photos.length >= requiredPhotos,
          numberOfDays: milestone.numberOfDays ?? 0,
          requiredPhotos: requiredPhotos,
          uploadedPhotos: photos,
        ),
      ),
      insRequest: insRequest,
    );

    // On failure, onError already dismissed the loader and showed the message.
    if (ok) EasyLoading.showSuccess('Photos saved');
    return ok;
  }

  // ---------------------------------------------------------------------------
  // Pre-treatment (doctor) photos
  // ---------------------------------------------------------------------------

  Future<void> getPerTreatmentPhotos({required int appointmentId}) async {
    await runSafely(() async {
      state = state.copyWith(loading: true, errorMessage: null);

      final response = await repo.getPerTreatmentPhotos(
        appointmentId: appointmentId,
      );

      state = state.copyWith(loading: false, perTreatmentPhotos: response.data);
    });
  }

  Future<bool> savePerTreatmentPhotos({
    required PerTreatmentPhotosRequest request,
  }) async {
    final result = await runSafely<bool>(() async {
      state = state.copyWith(loading: true, errorMessage: null);

      final response = await repo.savePerTreatmentPhotos(request: request);

      state = state.copyWith(
        loading: false,
        // Falls back to what we sent if the API returns no data.
        perTreatmentPhotos: response.data , // adjust
      );

      return true;
    });

    return result ?? false;
  }

  /// Uploads to Firebase first, then sends the URLs to savePerTreatmentPhotos.
  Future<bool> addPerTreatmentPhoto({
    required int appointmentId,
    required ImageSource source,
  }) async {
    final url = await uploadPostTreatmentImage(
      source: source,
      folder: 'pre-treatment-photos',
    );
    if (url == null) return false; // cancelled or failed (error already shown)

    EasyLoading.show(
      status: 'Saving photo...',
      maskType: EasyLoadingMaskType.black,
    );

    final ok = await savePerTreatmentPhotos(
      request: PerTreatmentPhotosRequest(
        appointmentId: appointmentId, // adjust
        imageUrls: [...state.perTreatmentPhotos, url], // adjust
      ),
    );

    if (ok) EasyLoading.showSuccess('Photo saved');
    return ok;
  }

  // ---------------------------------------------------------------------------

  void updateStatus(AppointmentStatusEvent event) {
    if (state.appointmentDetail == null) {
      log('Appointment detail not found');
      return;
    }
    if (state.appointmentDetail!.id != event.appointmentId) {
      log('Appointment details with different id found!');
      return;
    }
    state = state.copyWith(
      appointmentDetail: state.appointmentDetail!.copyWith(
        status: event.status,
      ),
    );
  }

  Future<bool?> updateAppointmentStatus({
    required int appointmentId,
    required String status,
  }) async {
    return await runSafely<bool?>(() async {
      EasyLoading.show(status: 'Updating status...');

      final response = await repo.updateAppointmentStatus(
        appointmentId: appointmentId,
        status: status,
      );

      if (response.isSuccess == true) {
        await getAppointmentDetail(appointmentId);
        EasyLoading.dismiss();
        EasyLoading.showSuccess(response.message ?? "Status updated successfully");
        return true;
      }

      EasyLoading.dismiss();
      EasyLoading.showError(response.message ?? "Failed to update status");
      return false;
    });
  }

  @override
  void onError(String message) {
    state = state.copyWith(loading: false, errorMessage: message);
    EasyLoading.dismiss();
    super.onError(message);
  }
}

@immutable
class AppointmentState extends BaseStateModel {
  final List<AppointmentTypeData> appointmentTypes;
  final List<SimulationData> simulations;
  final AppointmentsListResponse? appointmentsResponse;
  final AppointmentDetailData? appointmentDetail;
  final ScanQrResponse? scanQrResponse;
  final List<InstructionData> preInstruction;
  final List<InstructionData> postInstruction;
  final List<PostTreatmentPhotoData> postTreatmentPhoto;
  final List<String> perTreatmentPhotos;

  const AppointmentState({
    super.loading = false,
    super.errorMessage,
    this.appointmentTypes = const [],
    this.scanQrResponse,
    this.simulations = const [],
    this.appointmentsResponse,
    this.appointmentDetail,
    this.preInstruction = const [],
    this.postInstruction = const [],
    this.postTreatmentPhoto = const [],
    this.perTreatmentPhotos = const [],
  });

  @override
  AppointmentState copyWith({
    bool? loading,
    String? errorMessage,
    List<AppointmentTypeData>? appointmentTypes,
    List<SimulationData>? simulations,
    ScanQrResponse? scanQrResponse,
    AppointmentsListResponse? appointmentsResponse,
    AppointmentDetailData? appointmentDetail,
    List<InstructionData>? preInstruction,
    List<InstructionData>? postInstruction,
    List<PostTreatmentPhotoData>? postTreatmentPhoto,
    List<String>? perTreatmentPhotos,
  }) {
    return AppointmentState(
      loading: loading ?? this.loading,
      errorMessage: errorMessage ?? this.errorMessage,
      appointmentTypes: appointmentTypes ?? this.appointmentTypes,
      simulations: simulations ?? this.simulations,
      appointmentsResponse: appointmentsResponse ?? this.appointmentsResponse,
      appointmentDetail: appointmentDetail ?? this.appointmentDetail,
      scanQrResponse: scanQrResponse ?? this.scanQrResponse,
      preInstruction: preInstruction ?? this.preInstruction,
      postInstruction: postInstruction ?? this.postInstruction,
      postTreatmentPhoto: postTreatmentPhoto ?? this.postTreatmentPhoto,
      perTreatmentPhotos: perTreatmentPhotos ?? this.perTreatmentPhotos,
    );
  }
}