import '../models/requests/save_history_request.dart';
import '../models/responses/clinical_journey_response.dart';
import '../models/responses/treatment_list_response.dart';
import '../models/responses/treatment_detail_response.dart';
import '../models/responses/materials_response.dart';
import '../models/responses/treatment_progress_detail_response.dart';
import '../models/responses/treatment_progress_response.dart';

abstract class TreatmentRepository {
  Future<TreatmentListResponse> getTreatments({
    String? search,
    int? categoryId,
    int? areaId,
    int page = 1,
    int limit = 10,
    bool? isSimulator,
  });
  Future<void> saveAiHistory(SaveHistoryRequest request);
  Future<TreatmentDetailResponse> getTreatmentDetail({
    required int treatmentId,
  });
  Future<MaterialsResponse> getMaterials({
    required String treatmentSku,
    required String areaSku,
  });
  Future<TreatmentProgressResponse> getTreatmentProgress({
    int page = 1,
    int limit = 10,
     int? treatmentId,
    int? areaId,
  });
  Future<TreatmentProgressDetailResponse> getTreatmentprogressDetail({
    required int progressID,
  });
   Future<ClinicalJourneyResponse> getClinicalJourney(
    {required int clinicId}
   );
}
