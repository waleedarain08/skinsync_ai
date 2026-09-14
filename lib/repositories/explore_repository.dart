import '../models/responses/community_posts_list_response.dart';
import '../models/responses/filter_status.dart';
import '../models/responses/reels_list_response.dart';

abstract class ExploreRepository {

   Future<ReelsListResponse> fetchReels({
    int page = 1,
    int limit = 20,
  });
  Future<FilterStatusResponse> fetchPostTags();

  Future<CommunityPostsListResponse> fetchPosts({
    int page = 1,
    int limit = 20,
    int? filter,
  });
}