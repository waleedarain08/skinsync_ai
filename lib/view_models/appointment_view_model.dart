import 'package:flutter/foundation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../exceptions/app_exception.dart';
import '../models/base_state_model.dart';
import '../models/requests/change_payment_status_request.dart';
import '../models/requests/scan_qr_request.dart';
import '../models/responses/appointment_detail_response.dart';
import '../models/responses/appointment_type_list_response.dart';
import '../models/responses/appointments_list_response.dart';
import '../models/responses/scan_qr_response.dart';
import '../models/responses/simulation_history_response.dart';
import '../repositories/appointment_repository.dart';
import '../services/api_base_helper.dart';
import '../services/appointment_service.dart';
import '../services/encryption_service.dart';
import 'base_view_model.dart';

final appointmentProvider = NotifierProvider<AppointmentViewModel, AppointmentState>(
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
        request: ChangePaymentStatusRequest(
          paymentStatus: paymentStatus
         
        ),
      );
      EasyLoading.dismiss();
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
  const AppointmentState({
    super.loading = false,
    super.errorMessage,
    this.appointmentTypes = const [],
    this.scanQrResponse,
    this.simulations = const [],
    this.appointmentsResponse,
    this.appointmentDetail,
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
  }) {
    return AppointmentState(
      loading: loading ?? this.loading,
      errorMessage: errorMessage ?? this.errorMessage,
      appointmentTypes: appointmentTypes ?? this.appointmentTypes,
      simulations: simulations ?? this.simulations,
      appointmentsResponse: appointmentsResponse ?? this.appointmentsResponse,
      appointmentDetail: appointmentDetail ?? this.appointmentDetail,
      scanQrResponse:scanQrResponse?? this.scanQrResponse
    );
  }
}
