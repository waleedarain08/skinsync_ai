import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/base_state_model.dart';
import '../models/requests/get_practitioners_request.dart';
import '../models/requests/practitioner_availability_request.dart';
import '../models/responses/availability_response.dart';
import '../models/responses/payment_options_response.dart';
import '../models/responses/practitioner_list_response.dart';
import '../models/responses/treatment_pricing_response.dart' hide Treatment;
import '../repositories/clinic_repository.dart';
import '../repositories/doctor_repository.dart';
import '../services/api_base_helper.dart';
import '../services/clinic_service.dart';
import '../services/doctor_service.dart';
import 'base_view_model.dart';
import 'checkout_view_model.dart';

final doctorProvider = NotifierProvider.autoDispose(() {
  final apiBaseHelper = ApiBaseHelper();
  final doctorService = DoctorService(apiClient: apiBaseHelper);
  final clinicService = ClinicService(apiClient: apiBaseHelper);
  return DoctorViewModel(
    doctorRepository: doctorService,
    clinicRepository: clinicService,
  );
});

class DoctorViewModel extends BaseViewModel<DoctorState> {
  DoctorViewModel({
    required this.doctorRepository,
    required this.clinicRepository,
  }) : super(initialState: const DoctorState());

  final DoctorRepository doctorRepository;
  final ClinicRepository clinicRepository;
  PricingData? pricingData;

  void setSelectedDoctor(PractitionerDoctor doctor) {
    state = state.copyWith(selectedDoctor: doctor);
  }

  Future<void> loadPractitioners({
    int page = 1,
    int limit = 10,
    bool isVirtual = false,
    String? search,
    bool showEasyLoading = false,
  }) async {
    await runSafely(() async {
      if (showEasyLoading) {
        EasyLoading.show(status: 'Loading...');
      }

      state = state.copyWith(doctorLoading: true);

      final checkoutState = ref.read(checkoutViewModel);
      final clinicId = checkoutState.selectedClinic?.id;

      // Extract only treatment IDs from checkout state
      // final treatmentIds = checkoutState.checkoutTreatmentsList
      //     .map((t) => t.treatmentId)
      //     .whereType<int>()
      //     .toSet()
      //     .toList();

      final request = GetPractitionersRequest(
        page: page,
        limit: limit,
        clinicId: clinicId,
        isVirtual: isVirtual,
        search: search,
        date: checkoutState.selectedDate == null
            ? null
            : checkoutState.selectedDate!.millisecondsSinceEpoch ~/ 1000,
        //   treatmentIds: treatmentIds.isEmpty ? null : treatmentIds,
      );

      final response = await doctorRepository.getPractitioners(
        request: request,
      );

      if (!ref.mounted) return;

      EasyLoading.dismiss();

      state = state.copyWith(doctorLoading: false, doctorResponse: response);
    });
  }

Future<void> getPractitionerAvailability({required DateTime date}) async {
  await runSafely(() async {
    EasyLoading.show(status: 'Loading...');

    final checkoutState = ref.read(checkoutViewModel);
    final clinicId = checkoutState.selectedClinic?.id;

    final treatments = checkoutState.checkoutTreatmentsList
        .map(
          (t) => PractitionerAvailabilityTreatmentRequest(
            treatmentId: t.treatmentId!,
            areaIds: [t.areaId!],
          ),
        )
        .toList();
    final docID = checkoutState.selectedDoctorObject?.id;

    if (docID == null || clinicId == null) {
      EasyLoading.dismiss();
      return;
    }

    final request = PractitionerAvailabilityRequest(
      doctorId: docID,
      date: date.millisecondsSinceEpoch ~/ 1000,
      clinicId: clinicId,
      treatments: treatments,
    );

    final availabilityResponse = await doctorRepository
        .getPractitionerAvailability(request: request);

    if (!ref.mounted) return;

    EasyLoading.dismiss();

    state = state.copyWith(availabilityResponse: availabilityResponse);
  });
}
 
 Future<bool?> getDoctors({
    required int treatmentId,
    required List<int> sideAreaIds,
    required int? clinicId,
    required DateTime date,
  }) async {
    return runSafely(() async {
      state = state.copyWith(doctorLoading: true);
      final String sideAreas = sideAreaIds.join(',');
      final response = await doctorRepository.getDoctors(
        clinicId: clinicId ?? 0,
        treatmentId: treatmentId,
        sideAreaIdsList: sideAreas,
      );
      final doctor = response.data?.doctors?.firstOrNull;
      List<Slot> availability = [];
      if (doctor != null && clinicId != null) {
        availability = await doctorRepository.getAvailability(
          doctorId: doctor.doctorId!,
          clinicId: clinicId,
          date: date,
        );
      }
      state = state.copyWith(
        doctorLoading: false,
        doctorResponse: response,
        selectedDoctor: response.data?.doctors?.firstOrNull,
        slots: availability,
      );
      return response.status == true;
    });
  }

  Future<void> fetchAvailability({
    required DateTime date,
    required int clinicId,
  }) async {
    return await runSafely(() async {
      if (state.selectedDoctor == null) {
        return;
      }
      EasyLoading.show(status: 'Loading...');
      state = state.copyWith(loading: true);
      final availability = await doctorRepository.getAvailability(
        doctorId: state.selectedDoctor!.doctorId!,
        clinicId: clinicId,
        date: date,
      );
      if (!ref.mounted) return;
      state = state.copyWith(
        doctorLoading: false,
        loading: false,
        slots: availability,
      );
      EasyLoading.dismiss();
    });
  }

  Future<void> getPaymentOptions({
    required int clinicId,
    required int doctorId,
  }) async {
    return await runSafely(() async {
      final checkoutState = ref.read(checkoutViewModel);
      if (checkoutState.selectedTreatments == null ||
          (checkoutState.selectedAreas?.subAreas?.isEmpty ?? false)) {
        return;
      }
      state = state.copyWith(loading: true);
      final pricing = await clinicRepository.getTreatmentPricing(
        clinicId: clinicId,
        treatmentId: checkoutState.selectedTreatments!.id!,
        treatmentSubsectionIds: checkoutState.selectedAreas!.subAreas!
            .map((area) => area.id!)
            .toList(),
      );
      if (!ref.mounted) return;
      pricingData = pricing;
      final amount = pricing.treatment!.price! * pricing.subSections!.length;
      final paymentOptions = await clinicRepository.getPaymentOptions(
        clinicId: clinicId,
        doctorId: doctorId,
        amount: amount,
      );
      if (!ref.mounted) return;
      state = state.copyWith(loading: false, paymentOptions: paymentOptions);
    });
  }

  void clearState() {
    state = const DoctorState();
  }

  @override
  void onError(String message) {
    state = state.copyWith(doctorLoading: false, loading: false);
    super.onError(message);
    EasyLoading.showError(message);
  }
}


@immutable
class DoctorState extends BaseStateModel {
  final PractitionerListResponse? doctorResponse;
  final bool doctorLoading;
  final PractitionerDoctor? selectedDoctor;
  final List<Slot> slots;
  final List<PaymentOption> paymentOptions;
  final AvailabilityResponse? availabilityResponse;

  const DoctorState({
    super.loading = false,
    super.errorMessage,
    this.doctorResponse,
    this.doctorLoading = false,
    this.selectedDoctor,
    this.slots = const [],
    this.paymentOptions = const [],
    this.availabilityResponse,
  });

  @override
  DoctorState copyWith({
    bool? loading,
    String? errorMessage,
    PractitionerListResponse? doctorResponse,
    bool? doctorLoading,
    PractitionerDoctor? selectedDoctor,
    List<Slot>? slots,
    List<PaymentOption>? paymentOptions,
    AvailabilityResponse? availabilityResponse,
  }) {
    return DoctorState(
      loading: loading ?? this.loading,
      errorMessage: errorMessage ?? this.errorMessage,
      doctorResponse: doctorResponse ?? this.doctorResponse,
      doctorLoading: doctorLoading ?? this.doctorLoading,
      selectedDoctor: selectedDoctor ?? this.selectedDoctor,
      slots: slots ?? this.slots,
      paymentOptions: paymentOptions ?? this.paymentOptions,
      availabilityResponse: availabilityResponse ?? this.availabilityResponse,
    );
  }
}