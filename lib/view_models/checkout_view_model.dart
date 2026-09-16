import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/base_state_model.dart';
import '../models/flat_selection_model.dart';
import '../models/requests/appointment_request.dart';
import '../models/requests/invite_clinic_request.dart';
import '../models/responses/appointment_response.dart';
import '../models/responses/appointment_type_list_response.dart';
import '../models/responses/availability_response.dart';
import '../models/responses/get_clinic_response.dart';
import '../models/responses/payment_options_response.dart';
import '../models/responses/practitioner_list_response.dart';
import '../models/responses/simulation_history_response.dart';
import '../models/responses/treatment_area_list_response.dart';
import '../models/responses/treatment_category_list_response.dart';
import '../models/responses/treatment_list_response.dart';
import '../models/selected_treatment_and_areas_model.dart';
import '../repositories/appointment_repository.dart';
import '../repositories/clinic_repository.dart';
import '../services/api_base_helper.dart';
import '../services/appointment_service.dart';
import '../services/clinic_service.dart';
import '../utils/date_time_utils.dart';
import '../utils/simulation_utils.dart';
import 'auth_view_model.dart';
import 'base_view_model.dart';
import 'doctor_view_model.dart';
import 'treatment_view_model.dart';

final checkoutViewModel = NotifierProvider(() => CheckoutViewModel());

class CheckoutViewModel extends BaseViewModel<CheckoutState> {
  CheckoutViewModel({
    ClinicRepository? clinicRepository,
    AppointmentRepository? appointmentRepository,
  }) : _clinicRepository =
           clinicRepository ?? ClinicService(apiClient: ApiBaseHelper()),
       _appointmentRepository =
           appointmentRepository ??
           AppointmentService(apiClient: ApiBaseHelper()),
       super(initialState: const CheckoutState());

  final ClinicRepository _clinicRepository;
  final AppointmentRepository _appointmentRepository;

  @override
  CheckoutState build() {
    ref.keepAlive();
    return super.build();
  }

  // ---------------------------------------------------------------------------
  // Selection Setters
  // ---------------------------------------------------------------------------

  void setSelectedClinic(Clinic clinic) {
    state = state.copyWith(selectedClinic: clinic);
  }

  void setSelectedAppointmentType(AppointmentTypeData type) {
    state = state.copyWith(selectedAppointmentType: type);
  }

  void setSelectedDoctor(PractitionerDoctor doctor) {
    state = state.copyWith(selectedDoctor: doctor);
  }

  void setSelectedDoctorObject(PractitionerDoctor? doctor) {
    state = state.copyWith(selectedDoctorObject: doctor);
  }

  void setSelectedDate(DateTime? date) {
    state = state.copyWith(selectedDate: date);
  }

  void setSelectedSlot(String? slot) {
    state = state.copyWith(selectedSlot: slot);
    createSlotFromSelected();
  }

  void createSlotFromSelected() {
    final date = state.selectedDate;
    final slotStr = state.selectedSlot;
    if (date != null && slotStr != null) {
      final slot = _createSlotFromDateAndString(date, slotStr);
      if (slot != null) {
        setSelectedSlotObject(slot);
      }
    }
  }

  Slot? _createSlotFromDateAndString(DateTime date, String slotStr) {
    try {
      final parts = slotStr.split(' - ');
      if (parts.length != 2) return null;

      final startTimeStr = parts[0];
      final endTimeStr = parts[1];

      DateTime parseTime(String timeStr) {
        final timeParts = timeStr.trim().split(' ');
        final hm = timeParts[0].split(':');
        int hour = int.parse(hm[0]);
        int minute = int.parse(hm[1]);
        final ampm = timeParts[1];

        if (ampm == 'PM' && hour < 12) hour += 12;
        if (ampm == 'AM' && hour == 12) hour = 0;

        return DateTime(date.year, date.month, date.day, hour, minute);
      }

      final start = parseTime(startTimeStr);
      final end = parseTime(endTimeStr);

      return Slot(startTime: start, endTime: end, isBooked: false);
    } catch (e) {
      return null;
    }
  }

  void setSelectedSlotObject(Slot? slot) {
    state = state.copyWith(selectedSlotObject: slot);
  }

  void setSelectedPaymentOption(PaymentOption? option) {
    state = state.copyWith(selectedPaymentOption: option);
  }

  void setInviteClinic(bool value) {
    if (state.isInviteClinic == value) return;
    state = state.copyWith(isInviteClinic: value);
  }

  // ---------------------------------------------------------------------------
  // Treatment Selection Logic
  // ---------------------------------------------------------------------------

  void setSelectedTreatments(TreatmentData? treatment) {
    state = state.copyWith(selectedTreatments: treatment);
  }

  void addSelectedTreatment(TreatmentData treatment) {
    final updatedList = state.selectedTreatmentsAndAreas
        .where(
          (item) =>
              item.selectedAreas.isNotEmpty ||
              item.treatment.id == treatment.id,
        )
        .toList();

    if (!updatedList.any((item) => item.treatment.id == treatment.id)) {
      updatedList.add(
        SelectedTreatmentAndAreasModel(
          treatment: treatment,
          selectedAreas: const [],
        ),
      );
    }

    state = state.copyWith(
      selectedTreatments: treatment,
      selectedTreatmentsAndAreas: updatedList,
    );
    flatSelections();
  }

  void addSelectedCategory(TreatmentCategoryModel category) {
    final currentList = state.selectedCategories ?? [];
    if (!currentList.any((c) => c.id == category.id)) {
      state = state.copyWith(selectedCategories: [...currentList, category]);
    }
  }

  void removeTreatment(int treatmentId) {
    final currentList = List<SelectedTreatmentAndAreasModel>.from(
      state.selectedTreatmentsAndAreas,
    )..removeWhere((item) => item.treatment.id == treatmentId);

    final updatedActive = state.selectedTreatments?.id == treatmentId
        ? null
        : state.selectedTreatments;

    state = state.copyWith(
      selectedTreatmentsAndAreas: currentList,
      selectedTreatments: updatedActive,
    );
    flatSelections();
  }

  void clearSelectedTreatments() {
    state = state.copyWith(selectedTreatmentsAndAreas: []);
    flatSelections();
  }

  // ---------------------------------------------------------------------------
  // Area Selection Logic
  // ---------------------------------------------------------------------------

  void setSelectedAreas(TreatmentAreaModel? area) {
    state = state.copyWith(selectedAreas: area);
  }

  void addSelectedArea(TreatmentAreaModel area) {
    final activeTreatment = state.selectedTreatments;
    if (activeTreatment == null) return;

    _updateTreatmentAreaSelection(
      treatment: activeTreatment,
      area: area,
      updateAction: (existingAreas) {
        if (!existingAreas.any((a) => a.target.id == area.id)) {
          return [
            ...existingAreas,
            SelectedAreaModel(target: area, material: null),
          ];
        }
        return existingAreas;
      },
    );
  }

  void saveMaterialForArea({
    required TreatmentData treatment,
    required TreatmentAreaModel area,
    required SelectedMaterialModel? material,
  }) {
    _updateTreatmentAreaSelection(
      treatment: treatment,
      area: area,
      updateAction: (existingAreas) {
        final index = existingAreas.indexWhere((a) => a.target.id == area.id);
        final updated = List<SelectedAreaModel>.from(existingAreas);

        if (index != -1) {
          updated[index] = updated[index].copyWith(material: material);
        } else {
          updated.add(SelectedAreaModel(target: area, material: material));
        }
        return updated;
      },
    );
  }

  void removeArea(int areaId) {
    final updatedList = state.selectedTreatmentsAndAreas
        .map((item) {
          final filteredAreas = item.selectedAreas
              .where((a) => a.target.id != areaId)
              .toList();
          return item.copyWith(selectedAreas: filteredAreas);
        })
        .where((item) => item.selectedAreas.isNotEmpty)
        .toList();

    state = state.copyWith(
      selectedAreas: state.selectedAreas?.id == areaId
          ? null
          : state.selectedAreas,
      selectedTreatmentsAndAreas: updatedList,
    );
    flatSelections();
    ref.read(treatmentViewModel.notifier).removeSubArea(areaId);
  }

  void removeSubArea(int subAreaId) {
    if (state.selectedAreas == null) return;
    state = state.copyWith(
      selectedAreas: state.selectedAreas!.copyWith(
        subAreas: state.selectedAreas!.subAreas
            ?.where((element) => element.id != subAreaId)
            .toList(),
      ),
    );
  }

  void removeFlatSelection({required int treatmentId, required int areaId}) {
    final updatedList = state.selectedTreatmentsAndAreas
        .map((item) {
          if (item.treatment.id != treatmentId) return item;
          final updatedAreas = item.selectedAreas
              .where((areaItem) => (areaItem.target.id ?? 0) != areaId)
              .toList();
          return item.copyWith(selectedAreas: updatedAreas);
        })
        .where((item) => item.selectedAreas.isNotEmpty)
        .toList();

    state = state.copyWith(selectedTreatmentsAndAreas: updatedList);
    flatSelections();
  }

  void clearAreaSelection() {
    state = state.clearSelectedAreas();
  }

  void clearDateAndSlot() {
    state = state.copyWithNull(
      selectedDate: true,
      selectedDoctorObject: true,
      selectedSlot: true,
    );
  }

  void onTapTreatmentSubArea({required TreatmentAreaModel subArea}) {
    final activeArea = state.selectedAreas;
    final parentId = activeArea?.id ?? subArea.areaId ?? subArea.id ?? 0;
    final treatmentSubArea = subArea.copyWith(areaId: parentId);

    final alreadySelected =
        activeArea?.subAreas?.any((e) => e.id == treatmentSubArea.id) ?? false;

    final updatedSubAreas = alreadySelected
        ? activeArea?.subAreas ?? <TreatmentAreaModel>[]
        : <TreatmentAreaModel>[...activeArea?.subAreas ?? [], treatmentSubArea];

    state = state.copyWith(
      selectedAreas: treatmentSubArea.copyWith(subAreas: updatedSubAreas),
    );
    ref.read(treatmentViewModel.notifier).clearAiImage();
  }

  void flatSelections() {
    final list = state.selectedTreatmentsAndAreas.expand((item) {
      return item.selectedAreas.map(
        (areaItem) => FlatSelectionModel(
          treatmentId: item.treatment.id ?? 0,
          treatmentName: item.treatment.name ?? '',
          areaId: areaItem.target.id ?? 0,
          areaName: areaItem.target.name ?? '',
          treatmentCost: 120,
          material: areaItem.material,
        ),
      );
    }).toList();
    state = state.copyWith(checkoutTreatmentsList: list);
  }

  // ---------------------------------------------------------------------------
  // State Management
  // ---------------------------------------------------------------------------

  void updateCapturedImage(XFile? capturedImage) {
    state = state.copyWith(capturedImage: capturedImage);
  }

  void clearState() {
    state = const CheckoutState();
  }

  // ---------------------------------------------------------------------------
  // API Methods
  // ---------------------------------------------------------------------------

  Future<AppointmentRequest?> buildAppointmentRequest() async {
    final state = this.state;
    final clinicId = state.selectedClinic?.id;
    final doctorId =
        state.selectedDoctorObject?.doctorId ??
        state.selectedDoctor?.doctorId ??
        ref.read(doctorProvider).selectedDoctor?.doctorId;
    final date = state.selectedDate;
    final slot = state.selectedSlotObject;
    final appointmentType = state.selectedAppointmentType;
    final paymentOption = state.selectedPaymentOption;

    if (clinicId == null ||
        doctorId == null ||
        date == null ||
        slot == null ||
        appointmentType == null) {
      return null;
    }

    final treatmentViewModelState = ref.read(treatmentViewModel);
    final userId = ref.read(authViewModel).authData?.user?.id ?? 0;

    final uploadResults = await uploadSimulationImages(
      userId: userId,
      images: SimulationImages(
        frontBefore: treatmentViewModelState.frontPoseImage,
        frontAfter: treatmentViewModelState.frontAiImage,
        rightBefore: treatmentViewModelState.rightPoseImage,
        rightAfter: treatmentViewModelState.rightAiImage,
        leftBefore: treatmentViewModelState.leftPoseImage,
        leftAfter: treatmentViewModelState.leftAiImage,
      ),
    );

    int treatmentTotal = 0;
    List<TreatmentRequest> treatmentRequests = [];

    for (final item in state.checkoutTreatmentsList) {
      treatmentTotal += item.treatmentCost;
      treatmentRequests.add(
        TreatmentRequest(
          treatmentId: item.treatmentId,
          areaId: item.areaId,
          treatmentCost: item.treatmentCost,
          material: item.material != null
              ? MaterialRequest(
                  id: item.material!.id,
                  selectedQuantity: item.material!.selectedQuantity,
                )
              : null,
        ),
      );
    }

    // Default or existing pricing values
    int actualAmount = treatmentTotal;
    int amountPaid = paymentOption?.amount ?? 0;
    int amountPayable = actualAmount - amountPaid;
    int discount = 0;
    int loyalityPoints = 0;

    return AppointmentRequest(
      clinicId: clinicId,
      doctorId: doctorId,
      date: date.secondsSinceEpoch,
      startTime: slot.startTime.secondsSinceEpoch,
      endTime: slot.endTime.secondsSinceEpoch,
      appointmentTypeId: appointmentType.id!,
      isInviteClinic: state.isInviteClinic,
      simulations: SimulationsRequest(
        frontImageBefore: uploadResults.frontBefore,
        frontImageAfter: uploadResults.frontAfter,
        rightImageBefore: uploadResults.rightBefore,
        rightImageAfter: uploadResults.rightAfter,
        leftImageBefore: uploadResults.leftBefore,
        leftImageAfter: uploadResults.leftAfter,
      ),
      treatment: treatmentRequests,
      treatmentTotal: treatmentTotal,
      paymentType: PaymentTypeRequest(
        type: paymentOption?.title ?? "card",
        status: "completed",
      ),
      discountType: "percent",
      loyalityPoints: loyalityPoints,
      discount: discount,
      actualAmount: actualAmount,
      amountPaid: amountPaid,
      amountPayable: amountPayable,
    );
  }

  Future<void> createAppointment() async {
    return await runSafely(() async {
      state = state.copyWith(loading: true);
      EasyLoading.show(status: 'Uploading images and securing appointment...');

      final request = await buildAppointmentRequest();
      if (request == null) {
        throw Exception(
          'Incomplete appointment details. Please check selection.',
        );
      }

      // Print request for debugging as requested before
      debugPrint(const JsonEncoder.withIndent('  ').convert(request.toJson()));

      final data = await _appointmentRepository.createAppointment(
        request: request,
      );
      if (!ref.mounted) return;
      state = state.copyWith(loading: false, appointment: data);
      debugPrint("Appointment created successfully: ${data.appointmentId}");
      EasyLoading.dismiss();
    });
  }

  Future<bool> bookAppointment({
    required String selectedPaymentType,
    required double consultationFee,
  }) async {
    double paidAmount = 0.0;
    String paymentMethodName = "";

    if (selectedPaymentType == 'deposit') {
      paidAmount = consultationFee * 0.10;
      paymentMethodName = "10% Security Deposit";
    } else if (selectedPaymentType == 'full') {
      paidAmount = consultationFee;
      paymentMethodName = "Full Payment Pre-paid";
    } else {
      paidAmount = consultationFee;
      paymentMethodName = "Paid via Skinsync Wallet";
    }

    // Set payment option in ViewModel
    final dummyOption = PaymentOption(
      id: selectedPaymentType == 'deposit'
          ? 1
          : (selectedPaymentType == 'full' ? 2 : 3),
      title: selectedPaymentType,
      amount: paidAmount.toInt(),
      description: paymentMethodName,
    );
    setSelectedPaymentOption(dummyOption);

    bool isSuccess = false;

    if (state.isInviteClinic) {
      final success = await inviteClinic(
        clinic: state.selectedClinic!,
        consultationFees: consultationFee,
        initialDeposit: paidAmount,
        availability: [],
      );
      isSuccess = success ?? false;
    } else {
      // Regular booking via unified API
      await createAppointment();
      isSuccess = state.appointment != null;
    }
    return isSuccess;
  }

  Future<bool?> inviteClinic({
    required Clinic clinic,
    required num consultationFees,
    required num initialDeposit,
    required List<AvailabilityModel> availability,
  }) async {
    return await runSafely(() async {
      EasyLoading.show(status: 'Loading...');
      final request = await clinic.toInviteRequest(
        consultationFees: consultationFees,
        initialDeposit: initialDeposit,
        availability: availability,
      );
      if (!ref.mounted) return null;
      await _clinicRepository.inviteClinic(request);
      if (!ref.mounted) return null;
      EasyLoading.dismiss();
      return true;
    });
  }

  // ---------------------------------------------------------------------------
  // Private Helpers
  // ---------------------------------------------------------------------------
  void setSelectedTreatmentAndAreasModel(SimulationData simulation) {
    final selectedTreatments = (simulation.treatments ?? []).map((treatment) {
      final selectedAreas = (treatment.areas ?? []).map((area) {
        final simulationMaterial = (area.materials ?? []).isNotEmpty
            ? area.materials!.first
            : null;

        return SelectedAreaModel(
          target: TreatmentAreaModel(
            id: area.id,
            name: area.name,
            icon: area.icon,
            image: area.image,
          ),
          material: simulationMaterial?.id == null
              ? null
              : SelectedMaterialModel(
                  id: simulationMaterial!.id!,
                  name: simulationMaterial.name ?? '',
                  selectedQuantity: simulationMaterial.selectedQuantity ?? 1,
                  minQty: 1,
                  maxQty: simulationMaterial.selectedQuantity ?? 1,
                ),
        );
      }).toList();

      return SelectedTreatmentAndAreasModel(
        treatment: TreatmentData(
          id: treatment.id,
          name: treatment.name,
          icon: treatment.icon,
          image: treatment.image,
        ),
        selectedAreas: selectedAreas,
      );
    }).toList();

    state = state.copyWith(selectedTreatmentsAndAreas: selectedTreatments);
    flatSelections();
  }

  void _updateTreatmentAreaSelection({
    required TreatmentData treatment,
    required TreatmentAreaModel area,
    required List<SelectedAreaModel> Function(List<SelectedAreaModel>)
    updateAction,
  }) {
    final currentList = List<SelectedTreatmentAndAreasModel>.from(
      state.selectedTreatmentsAndAreas,
    );

    final index = currentList.indexWhere(
      (item) => item.treatment.id == treatment.id,
    );

    if (index != -1) {
      currentList[index] = currentList[index].copyWith(
        selectedAreas: updateAction(currentList[index].selectedAreas),
      );
    } else {
      currentList.add(
        SelectedTreatmentAndAreasModel(
          treatment: treatment,
          selectedAreas: updateAction(const []),
        ),
      );
    }

    state = state.copyWith(
      selectedAreas: area,
      selectedTreatments: treatment,
      selectedTreatmentsAndAreas: currentList,
    );

    flatSelections();
    onTapTreatmentSubArea(subArea: area);
  }
}

// ---------------------------------------------------------------------------
// State Class
// ---------------------------------------------------------------------------

class CheckoutState extends BaseStateModel {
  final List<SelectedTreatmentAndAreasModel> selectedTreatmentsAndAreas;
final List<FlatSelectionModel> checkoutTreatmentsList;
final List<TreatmentCategoryModel>? selectedCategories;
  final TreatmentData? selectedTreatments;
  final TreatmentAreaModel? selectedAreas;
  final AppointmentData? appointment;

  final Clinic? selectedClinic;
  final AppointmentTypeData? selectedAppointmentType;
  final PractitionerDoctor? selectedDoctor;
  final PractitionerDoctor? selectedDoctorObject;
  final DateTime? selectedDate;
  final String? selectedSlot;
  final Slot? selectedSlotObject;
  final PaymentOption? selectedPaymentOption;
  final bool isInviteClinic;

  const CheckoutState({
    super.loading = false,
    super.errorMessage,
    this.selectedTreatmentsAndAreas = const [],
    this.checkoutTreatmentsList = const [],
    this.selectedCategories = const [],
    this.selectedTreatments,
    this.selectedAreas,
    this.appointment,
    this.selectedClinic,
    this.selectedAppointmentType,
    this.selectedDoctor,
    this.selectedDoctorObject,
    this.selectedDate,
    this.selectedSlot,
    this.selectedSlotObject,
    this.selectedPaymentOption,
    this.isInviteClinic = false,
  });

  @override
  CheckoutState copyWith({
    bool? loading,
    String? errorMessage,
    XFile? capturedImage,
    List<SelectedTreatmentAndAreasModel>? selectedTreatmentsAndAreas,
    List<FlatSelectionModel>? checkoutTreatmentsList,
    List<TreatmentCategoryModel>? selectedCategories,
    TreatmentData? selectedTreatments,
    TreatmentAreaModel? selectedAreas,
    AppointmentData? appointment,
    Clinic? selectedClinic,
    AppointmentTypeData? selectedAppointmentType,
    PractitionerDoctor? selectedDoctor,
    PractitionerDoctor? selectedDoctorObject,
    DateTime? selectedDate,
    String? selectedSlot,
    Slot? selectedSlotObject,
    PaymentOption? selectedPaymentOption,
    bool? isInviteClinic,
  }) {
    return CheckoutState(
      loading: loading ?? this.loading,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedTreatmentsAndAreas:
          selectedTreatmentsAndAreas ?? this.selectedTreatmentsAndAreas,
      checkoutTreatmentsList:
          checkoutTreatmentsList ?? this.checkoutTreatmentsList,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      selectedTreatments: selectedTreatments ?? this.selectedTreatments,
      selectedAreas: selectedAreas ?? this.selectedAreas,
      appointment: appointment ?? this.appointment,
      selectedClinic: selectedClinic ?? this.selectedClinic,
      selectedAppointmentType:
          selectedAppointmentType ?? this.selectedAppointmentType,
      selectedDoctor: selectedDoctor ?? this.selectedDoctor,
      selectedDoctorObject: selectedDoctorObject ?? this.selectedDoctorObject,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedSlot: selectedSlot ?? this.selectedSlot,
      selectedSlotObject: selectedSlotObject ?? this.selectedSlotObject,
      selectedPaymentOption:
          selectedPaymentOption ?? this.selectedPaymentOption,
      isInviteClinic: isInviteClinic ?? this.isInviteClinic,
    );
  }

  CheckoutState clearSelectedAreas() {
    return CheckoutState(
      loading: loading,
      errorMessage: errorMessage,
      selectedTreatmentsAndAreas: selectedTreatmentsAndAreas,
      checkoutTreatmentsList: checkoutTreatmentsList,
      selectedCategories: selectedCategories,
      selectedTreatments: selectedTreatments,
      selectedAreas: null,
      appointment: appointment,
      selectedClinic: selectedClinic,
      selectedAppointmentType: selectedAppointmentType,
      selectedDoctor: selectedDoctor,
      selectedDoctorObject: selectedDoctorObject,
      selectedDate: selectedDate,
      selectedSlot: selectedSlot,
      selectedSlotObject: selectedSlotObject,
      selectedPaymentOption: selectedPaymentOption,
      isInviteClinic: isInviteClinic,
    );
  }

  CheckoutState copyWithNull({
    bool errorMessage = false,
    bool capturedImage = false,
    bool selectedCategories = false,
    bool selectedTreatments = false,
    bool selectedAreas = false,
    bool appointment = false,
    bool selectedClinic = false,
    bool selectedAppointmentType = false,
    bool selectedDoctor = false,
    bool selectedDoctorObject = false,
    bool selectedDate = false,
    bool selectedSlot = false,
    bool selectedSlotObject = false,
    bool selectedPaymentOption = false,
  }) {
    return CheckoutState(
      loading: loading,
      errorMessage: errorMessage ? null : this.errorMessage,
      selectedTreatmentsAndAreas: selectedTreatmentsAndAreas,
      checkoutTreatmentsList: checkoutTreatmentsList,
      selectedCategories: selectedCategories ? null : this.selectedCategories,
      selectedTreatments: selectedTreatments ? null : this.selectedTreatments,
      selectedAreas: selectedAreas ? null : this.selectedAreas,
      appointment: appointment ? null : this.appointment,
      selectedClinic: selectedClinic ? null : this.selectedClinic,
      selectedAppointmentType: selectedAppointmentType
          ? null
          : this.selectedAppointmentType,
      selectedDoctor: selectedDoctor ? null : this.selectedDoctor,
      selectedDoctorObject: selectedDoctorObject
          ? null
          : this.selectedDoctorObject,
      selectedDate: selectedDate ? null : this.selectedDate,
      selectedSlot: selectedSlot ? null : this.selectedSlot,
      selectedSlotObject: selectedSlotObject ? null : this.selectedSlotObject,
      selectedPaymentOption: selectedPaymentOption
          ? null
          : this.selectedPaymentOption,
      isInviteClinic: isInviteClinic,
    );
  }
}
