import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../models/base_state_model.dart';
import '../models/requests/create_group_request.dart';
import '../models/requests/preferred_slot.dart';
import '../models/requests/save_history_request.dart';
import '../models/requests/share_map_treatment_request.dart';
import '../models/requests/share_treatment_request.dart';
import '../models/requests/tj_options_request.dart';
import '../models/responses/get_clinic_response.dart';
import '../models/responses/groups_list_response.dart';
import '../models/responses/simulation_history_response.dart';
import '../models/responses/tj_options_list_response.dart';
import '../repositories/treatment_requests_repository.dart';
import '../services/api_base_helper.dart';
import '../services/treatment_requests_service.dart';
import '../utils/simulation_utils.dart';
import 'auth_view_model.dart';
import 'base_view_model.dart';
import 'checkout_view_model.dart';
import 'clinic_view_model.dart';
import 'treatment_view_model.dart';

final treatmentRequestsProvider =
    NotifierProvider.autoDispose<
      TreatmentRequestsViewModel,
      TreatmentRequestsState
    >(() => TreatmentRequestsViewModel());

class TreatmentRequestsViewModel extends BaseViewModel<TreatmentRequestsState> {
  final TreatmentRequestsRepository _repo;

  TreatmentRequestsViewModel({TreatmentRequestsRepository? repo})
    : _repo = repo ?? TreatmentRequestsService(apiClient: ApiBaseHelper()),
      super(initialState: const TreatmentRequestsState());

  final TextEditingController searchController = TextEditingController();

  Timer? _searchTimer;

  late final PagingController<int, TreatmentRequestGroup> pagingController =
      PagingController<int, TreatmentRequestGroup>(
        getNextPageKey: (pagingState) {
          final lastPageKey = pagingState.keys?.last ?? 0;
          final totalPages = state.totalPages ?? 1;

          final effectiveTotalPages = totalPages == 0 ? 1 : totalPages;

          return lastPageKey < effectiveTotalPages ? lastPageKey + 1 : null;
        },
        fetchPage: (pageKey) async {
          return await fetchGroupsPage(pageKey) ?? [];
        },
      );

void setSharedFilter(bool isShared) {
    if (state.isShared == isShared) return;
    state = state.copyWith(
      isShared: isShared,
      totalPages: null,
      groups: [],
    );
    pagingController.refresh(); // Triggers re-fetch from page 1
  }


  Future<List<TreatmentRequestGroup>?> fetchGroupsPage(int pageKey) async {
    return runSafely(() async {
      debugPrint(
        'Fetching groups => page: $pageKey, search: ${searchController.text}',
      );

      final response = await _repo.getGroups(
        page: pageKey,
        search: searchController.text.trim(),
        isShared:state.isShared,
      );

      if (!ref.mounted) return null;

      state = state.copyWith(
        totalPages: response.totalPages ?? 1,
        groups: response.data ?? [],
      );

      return response.data ?? [];
    });
  }

void searchGroups(String value) {
    _searchTimer?.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 500), () {
      if (!ref.mounted) return;
      state = state.copyWith(totalPages: null, groups: []);
      pagingController.refresh();
    });
  }

  Future<bool?> createGroup(String name) async {
    return await runSafely(() async {
      EasyLoading.show(status: 'Creating group...');
      final request = CreateGroupRequest(name: name);
      await _repo.createGroup(request);
      if (!ref.mounted) return null;
      pagingController.refresh();
      EasyLoading.dismiss();
      return true;
    });
  }

  Future<bool?> callShareTreatmentRequest(
    List<PreferredSlot> slots, {
    bool shareMedicalHistory = false,
  }) async {
    return await runSafely(() async {
      final clinicId = ref.read(clinicProvider).clinic?.id;
      if (state.selectedOptionId == null || clinicId == null) {
        EasyLoading.showError('Select a journey option to share!');
        return false;
      }
      EasyLoading.show(status: 'Loading');
      final request = ShareTreatmentRequest(
        clinicId: clinicId,
        optionId: state.selectedOptionId!,
        preferredSlots: slots,
        shareMedicalHistory: shareMedicalHistory,
      );

      await _repo.shareTreatmentRequest(request: request);
      await ref.read(authViewModel.notifier).callGetMe();
      if (!ref.mounted) return null;
      EasyLoading.dismiss();
      return true;
    });
  }

  Future<bool?> callShareMapTreatmentRequest(
    Clinic clinic,
    List<PreferredSlot> slots, {
    bool shareMedicalHistory = false,
  }) async {
    return await runSafely(() async {
      if (state.selectedOptionId == null) {
        EasyLoading.showError('Select a journey option to share!');
        return false;
      }
      EasyLoading.show(status: 'Loading');
      final request = ShareMapTreatmentRequest(
        clinic: clinic,
        optionId: state.selectedOptionId!,
        preferredSlots: slots,
        shareMedicalHistory: shareMedicalHistory,
      );

      await _repo.shareMapTreatmentRequest(request: request);
      await ref.read(authViewModel.notifier).callGetMe();
      if (!ref.mounted) return null;
      EasyLoading.dismiss();
      return true;
    });
  }

  void setOptionId(int id) {
    state = state.copyWith(selectedOptionId: id);
  }

  Future<bool?> fetchOptions(int groupId, {bool showloading = true}) async {
    return await runSafely(() async {
      if (showloading) {
        EasyLoading.show(status: 'Fetching Journey...');
      }

      final response = await _repo.getOptions(groupId);

      if (!ref.mounted) return null;
      state = state.copyWith(loading: false, options: response.data ?? []);
      if (state.options.isNotEmpty) {
        setOptionId(state.options.first.id!);
        await fetchOptionsDetail(state.options.first.id!);
      }
      if (showloading) {
        EasyLoading.dismiss();
      }
      return true;
    });
  }

  Future<SimulationData?> fetchOptionsDetail(int? optionId) async {
    return await runSafely(() async {
      if (optionId == null) return null;
      // EasyLoading.show(status: 'Fetching Options...');
      state = state.copyWith(isSimulationsLoading: true);
      final response = await _repo.getOptionsDetail(optionId);
      if (ref.mounted) {
        state = state.copyWith(
          loading: false,
          simulations: response.data,
          isSimulationsLoading: false,
        );
      }
      EasyLoading.dismiss();
      return response.data;
    });
  }

  Future<bool?> callDeleteGroup(int groupId) async {
    return await runSafely(() async {
      EasyLoading.show(status: 'Deleting Group...');
      final response = await _repo.deleteGroup(groupId);
      if (!ref.mounted) return null;
      if (response.isSuccess == true) {
        pagingController.refresh();
      }
      EasyLoading.dismiss();
      return true;
    });
  }

  Future<bool?> callUpdateGroupName(int groupId, String name) async {
    return await runSafely(() async {
      EasyLoading.show(status: 'Updating Group...');
      final response = await _repo.updateTreatmantGroupName(groupId, name);
      if (!ref.mounted) return null;
      if (response.isSuccess == true) {
        pagingController.refresh();
        if (state.selectedGroup != null) {
          state = state.copyWith(
            selectedGroup: state.selectedGroup!.copyWith(name: name),
          );
        }
      }
      EasyLoading.dismiss();
      return true;
    });
  }

  Future<bool?> callDeleteOption(int optionId) async {
    return await runSafely(() async {
      EasyLoading.show(status: 'Deleting Option...');
      final response = await _repo.deleteOption(optionId);
      if (!ref.mounted) return null;
      if (response.isSuccess == true) {
        if (state.selectedGroup?.id != null) {
          await fetchOptions(state.selectedGroup!.id!);
        }
      }
      EasyLoading.dismiss();
      return true;
    });
  }

  void setGroup(TreatmentRequestGroup group) {
    state = state.copyWith(selectedGroup: group);
  }

  void clearSelectedGroup({bool clearOptions = false}) {
    state = state.copyWith(clearSelectedGroup: true, clearSelectedOption: true);
  }

  Future<bool?> createTjOptions() async {
    return await runSafely(() async {
      EasyLoading.show(status: 'Creating Option...');
      final selectedTreatmentsAndAreas = ref
          .read(checkoutViewModel)
          .selectedTreatmentsAndAreas;
      if (selectedTreatmentsAndAreas.isEmpty) {
        EasyLoading.showError('No treatment selected');
        return false;
      }
      final treatmentState = ref.read(treatmentViewModel);
      if (treatmentState.frontPoseImage != null) {
        if (treatmentState.frontAiImage == null) {
          throw Exception('No AI image captured for front Pose!');
        }
      }
      if (treatmentState.rightPoseImage != null) {
        if (treatmentState.rightAiImage == null) {
          throw Exception('No AI image captured for right Pose!');
        }
      }
      if (treatmentState.leftPoseImage != null) {
        if (treatmentState.leftAiImage == null) {
          throw Exception('No AI image captured for left Pose!');
        }
      }

      final userId = ref.read(authViewModel).authData!.user!.id!;

      final uploadResults = await uploadSimulationImages(
        userId: userId,
        images: SimulationImages(
          frontBefore: treatmentState.frontPoseImage,
          frontAfter: treatmentState.frontAiImage,
          rightBefore: treatmentState.rightPoseImage,
          rightAfter: treatmentState.rightAiImage,
          leftBefore: treatmentState.leftPoseImage,
          leftAfter: treatmentState.leftAiImage,
        ),
      );

      final historyTreatments = selectedTreatmentsAndAreas.map((item) {
        return HistoryTreatmentRequest(
          treatmentId: item.treatment.id ?? 0,
          treatmentName: item.treatment.name ?? '',
          areas: item.selectedAreas.map((areaItem) {
            final area = areaItem.target;
            final List<HistoryMaterialRequest> historyMaterials = [];
            if (areaItem.material != null) {
              historyMaterials.add(
                HistoryMaterialRequest(
                  id: areaItem.material!.id,
                  name: areaItem.material!.name,
                  selectedQuantity: areaItem.material!.selectedQuantity,
                ),
              );
            }
            return HistoryAreaRequest(
              areaId: (area.id ?? 0),
              areaName: area.name ?? '',
              materials: historyMaterials,
            );
          }).toList(),
        );
      }).toList();
      final opitionNumber = state.options.length + 1;
      final request = TjOptionsRequest(
        groupId: state.selectedGroup!.id!,
        name: 'Option $opitionNumber',
        frontImageBefore: uploadResults.frontBefore,
        frontImageAfter: uploadResults.frontAfter,
        rightImageBefore: uploadResults.rightBefore,
        rightImageAfter: uploadResults.rightAfter,
        leftImageBefore: uploadResults.leftBefore,
        leftImageAfter: uploadResults.leftAfter,
        treatments: historyTreatments,
      );
      final response = await _repo.createTjOptions(request);
      if (response.isSuccess == true) {
        await ref.read(authViewModel.notifier).callGetMe();
        await EasyLoading.showSuccess('Option created successfully');
        clearSelectedGroup();
      }
      return true;
    });
  }

  @override
  void onError(String message) {
    EasyLoading.dismiss();
    if (ref.mounted) {
      state = state.copyWith(
        loading: false,
        errorMessage: message,
        isSimulationsLoading: false,
      );
    }
    super.onError(message);
  }

  @override
  void dispose() {
    super.dispose();
    _searchTimer?.cancel();
    searchController.dispose();
    pagingController.dispose();
  }
}

@immutable
class TreatmentRequestsState extends BaseStateModel {
  final List<TreatmentRequestGroup> groups;
  final List<TJOption> options;
  final SimulationData? simulations;
  final bool isSimulationsLoading;
  final int? selectedOptionId;
  final TreatmentRequestGroup? selectedGroup;
  final String? price;
  final int? totalPages;
  final bool isShared;
  const TreatmentRequestsState({
    super.loading = false,
    super.errorMessage,
    this.selectedGroup,
    this.groups = const [],
    this.options = const [],
    this.simulations,
    this.isSimulationsLoading = false,
    this.selectedOptionId,
    this.price,
    this.totalPages,
    this.isShared = false,
  });

  @override
  TreatmentRequestsState copyWith({
    bool? loading,
    String? errorMessage,
    TreatmentRequestGroup? selectedGroup,
    bool clearSelectedGroup = false,
    bool clearSelectedOption = false,
    List<TreatmentRequestGroup>? groups,
    List<TJOption>? options,
    SimulationData? simulations,
    bool? isSimulationsLoading,
    int? selectedOptionId,
    String? price,
    int? totalPages,
    bool? isShared,
  }) {
    return TreatmentRequestsState(
      loading: loading ?? this.loading,
      errorMessage: errorMessage ?? this.errorMessage,
      groups: groups ?? this.groups,
      selectedGroup: clearSelectedGroup
          ? null
          : (selectedGroup ?? this.selectedGroup),
      options: options ?? this.options,
      simulations: simulations ?? this.simulations,
      isSimulationsLoading: isSimulationsLoading ?? this.isSimulationsLoading,
      selectedOptionId: clearSelectedOption
          ? null
          : (selectedOptionId ?? this.selectedOptionId),
      price: price ?? this.price,
      totalPages: totalPages ?? this.totalPages,
      isShared: isShared ?? this.isShared,
    );
  }
}
