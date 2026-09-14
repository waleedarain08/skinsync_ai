import 'dart:convert';

import '../models/responses/community_posts_list_response.dart';
import '../models/responses/filter_status.dart';
import '../models/responses/reels_list_response.dart';
import '../repositories/explore_repository.dart';
import '../utils/enums.dart';
import 'api_base_helper.dart';

class ExploreService implements ExploreRepository {
  final ApiBaseHelper _apiClient;

  ExploreService({required this._apiClient});


 @override
Future<CommunityPostsListResponse> fetchPosts({
  int page = 1,
  int limit = 20,
  int? filter,
  String? search,
  String? category,
}) async {
  final Map<String, String> queryParams = {
    'page': page.toString(),
    'limit': limit.toString(),
  };
  if (filter != null) queryParams['filter'] = filter.toString();
  if (search != null && search.isNotEmpty) queryParams['search'] = search;
  if (category != null && category.isNotEmpty) queryParams['category'] = category;

  final paramsString = queryParams.entries
      .map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}')
      .join('&');

  final response = await _apiClient.httpRequest(
    requestType: RequestType.get,
    endPoint: EndPoints.explorerCommunity,
    params: paramsString,
  );
  final parsed = json.decode(response.body);
  return CommunityPostsListResponse.fromJson(parsed);
}


 @override
  Future<FilterStatusResponse> fetchPostTags() async {
   
    final response = await _apiClient.httpRequest(
      requestType: RequestType.get,
      endPoint:
      EndPoints.postTags,
     
      
          );
            final parsed = json.decode(response.body);
    return FilterStatusResponse.fromJson(parsed);
  }
 
 
 
   @override
  Future<ReelsListResponse> fetchReels({
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    final Map<String, String> queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (search != null && search.isNotEmpty) queryParams['search'] = search;

    final response = await _apiClient.httpRequest(
      requestType: RequestType.get,
      endPoint: EndPoints.explorerReels,
      params: 'page=$page&limit=$limit',
    );
    final parsed = json.decode(response.body);
    return ReelsListResponse.fromJson(parsed);
  }
}