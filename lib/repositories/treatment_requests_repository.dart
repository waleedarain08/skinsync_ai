import '../models/requests/create_group_request.dart';
import '../models/requests/share_map_treatment_request.dart';
import '../models/requests/share_treatment_request.dart';
import '../models/requests/tj_options_request.dart';
import '../models/responses/base_response_model.dart';
import '../models/responses/clinic_detail_response.dart';
import '../models/responses/groups_list_response.dart';
import '../models/responses/tj_option_simulations_response.dart';
import '../models/responses/tj_options_list_response.dart';

abstract class TreatmentRequestsRepository {
  Future<GroupsListResponse> getGroups({required int page,required String search,required bool isShared});
  Future<BaseResponseModel> createGroup(CreateGroupRequest request);
  Future<TJOptionsListResponse> getOptions(int groupId);
  Future<TJOptionSimulationsResponse> getOptionsDetail(int optionId);
  Future<BaseResponseModel> createTjOptions(TjOptionsRequest request);
  Future<BaseResponseModel> shareTreatmentRequest({
    required ShareTreatmentRequest request,
  });
  Future<BaseResponseModel> shareMapTreatmentRequest({
    required ShareMapTreatmentRequest request,
  });
  Future<ClinicDetailResponse> getClinicDetail(int clinicId);
  Future<BaseResponseModel> deleteGroup(int groupId);
  Future<BaseResponseModel> deleteOption(int optionId);
  Future<BaseResponseModel> updateTreatmantGroupName(int groupId , String name);
}
