import '../models/requests/appointment_request.dart';
import '../models/requests/change_payment_status_request.dart';
import '../models/requests/scan_qr_request.dart';
import '../models/responses/appointment_detail_response.dart';
import '../models/responses/appointment_response.dart';
import '../models/responses/appointment_type_list_response.dart';
import '../models/responses/appointments_list_response.dart';
import '../models/responses/base_response_model.dart';
import '../models/responses/scan_qr_response.dart';
import '../models/responses/simulation_history_response.dart';

abstract class AppointmentRepository {
  Future<AppointmentsListResponse> getAppointmentsApi({
    required int page,
    required int limit,
  });
  Future<AppointmentDetailResponse> getAppointmentDetail({
    required int appointmentId,
  });
  Future<List<SimulationData>> getSimulationHistory();
  Future<AppointmentTypeListResponse> getAppointmentTypes();
  Future<AppointmentData> createAppointment({
    required AppointmentRequest request,
  });
   Future<ScanQrResponse> scanQrCode({
    required ScanQrRequest request,
  });
   Future<BaseResponseModel> changePaymentStatus({
    required int appointmentId,
    required ChangePaymentStatusRequest request,
  });
}
