import '../models/requests/get_practitioners_request.dart';
import '../models/requests/practitioner_availability_request.dart';
import '../models/responses/availability_response.dart';
import '../models/responses/practitioner_list_response.dart';

abstract class DoctorRepository {
  Future<PractitionerListResponse> getPractitioners({
    required GetPractitionersRequest request,
  });
  Future<AvailabilityResponse> getPractitionerAvailability ({
    required PractitionerAvailabilityRequest  request,
  });

  Future<PractitionerListResponse> getDoctors({
    required int clinicId,
    required int treatmentId,
    required String sideAreaIdsList,
  });

  Future<List<Slot>> getAvailability({
    required int doctorId,
    required int clinicId,
    required DateTime date,
  });
}
