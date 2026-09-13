import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/base_state_model.dart';
import '../models/explore_models.dart';
import '../repositories/explore_repository.dart';
import '../services/api_base_helper.dart';
import '../services/explore_service.dart';
import 'base_view_model.dart';

enum ExploreViewType { community, reels }

class ReelsMutedNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() {
    state = !state;
  }
}

final reelsMutedProvider = NotifierProvider<ReelsMutedNotifier, bool>(() {
  return ReelsMutedNotifier();
});

final exploreViewModel = NotifierProvider<ExploreViewModel, ExploreState>(() {
  final apiBaseHelper = ApiBaseHelper();
  final exploreService = ExploreService(apiClient: apiBaseHelper);
  return ExploreViewModel(repository: exploreService);
});

class ExploreState extends BaseStateModel {
  final List<ReelModel> reels;
  final List<CommunityPostModel> posts;

  final int reelsTotalPages;
  final int postsTotalPages;

  final int reelsCurrentPage;
  final int postsCurrentPage;

  final int pageSize;

  final ExploreViewType viewType;

  // Separate loading flags so Reels and Community fetches
  // never clobber each other's spinner state.
  final bool reelsLoading;
  final bool postsLoading;

  final String selectedTag;
  final List<String> tags;

  const ExploreState({
    super.loading,
    super.errorMessage,
    this.reels = const [],
    this.posts = const [],
    this.reelsTotalPages = 1,
    this.postsTotalPages = 1,
    this.reelsCurrentPage = 1,
    this.postsCurrentPage = 1,
    this.pageSize = 20,
    this.viewType = ExploreViewType.community,
    this.reelsLoading = false,
    this.postsLoading = false,
    this.selectedTag = 'All',
    this.tags = const [
      'All',
      'Skincare',
      'Botox',
      'Acne Treatment',
      'Anti-Aging',
      'Laser & Glow',
      'Dermatology',
      'Facials & Peels',
      'Fillers',
    ],
  });

  @override
  ExploreState copyWith({
    bool? loading,
    String? errorMessage,
    List<ReelModel>? signDocument,
    List<CommunityPostModel>? posts,
    int? totalPages,
    int? postsTotalPages,
    int? currentPage,
    int? postsCurrentPage,
    int? pageSize,
    ExploreViewType? viewType,
    bool? reelsLoading,
    bool? postsLoading,
    String? selectedTag,
    List<String>? tags,
  }) {
    return ExploreState(
      loading: loading ?? this.loading,
      errorMessage: errorMessage ?? this.errorMessage,
      reels: signDocument ?? reels,
      posts: posts ?? this.posts,
      reelsTotalPages: totalPages ?? reelsTotalPages,
      postsTotalPages: postsTotalPages ?? this.postsTotalPages,
      reelsCurrentPage: currentPage ?? reelsCurrentPage,
      postsCurrentPage: postsCurrentPage ?? this.postsCurrentPage,
      pageSize: pageSize ?? this.pageSize,
      viewType: viewType ?? this.viewType,
      reelsLoading: reelsLoading ?? this.reelsLoading,
      postsLoading: postsLoading ?? this.postsLoading,
      selectedTag: selectedTag ?? this.selectedTag,
      tags: tags ?? this.tags,
    );
  }

  ExploreState clearFiles() {
    return ExploreState(
      loading: loading,
      errorMessage: errorMessage,
      reels: reels,
      posts: posts,
      reelsTotalPages: reelsTotalPages,
      postsTotalPages: postsTotalPages,
      reelsCurrentPage: reelsCurrentPage,
      postsCurrentPage: postsCurrentPage,
      pageSize: pageSize,
      viewType: viewType,
      reelsLoading: reelsLoading,
      postsLoading: postsLoading,
      selectedTag: selectedTag,
      tags: tags,
    );
  }
}

class ExploreViewModel extends BaseViewModel<ExploreState> {
  final ExploreRepository _repository;
  ExploreViewModel({required this._repository})
    : super(initialState: const ExploreState());

 Future<void> fetchReels({int page = 1}) async {
  state = state.copyWith(reelsLoading: true);

  await runSafely(() async {
    final response = await _repository.fetchReels(
      page: page,
      limit: state.pageSize,
    );

    final List<ReelModel> newReels = page == 1
        ? (response.data ?? <ReelModel>[])
        : <ReelModel>[...state.reels, ...(response.data ?? <ReelModel>[])];

    state = state.copyWith(
      signDocument: newReels,
      totalPages: response.totalPages,
      currentPage: response.page,
      reelsLoading: false,
    );
  });

  if (state.reelsLoading) {
    state = state.copyWith(reelsLoading: false);
  }
}

Future<void> fetchPosts({int page = 1}) async {
  state = state.copyWith(postsLoading: true);

  await runSafely(() async {
    final response = await _repository.fetchPosts(
      page: page,
      limit: state.pageSize,
    );

    final List<CommunityPostModel> newPosts = page == 1
        ? (response.data ?? <CommunityPostModel>[])
        : <CommunityPostModel>[
            ...state.posts,
            ...(response.data ?? <CommunityPostModel>[]),
          ];

    state = state.copyWith(
      posts: newPosts,
      postsTotalPages: response.totalPages,
      postsCurrentPage: response.page,
      postsLoading: false,
    );
  });

  if (state.postsLoading) {
    state = state.copyWith(postsLoading: false);
  }
}
  void setViewType(ExploreViewType type) {
    state = state.copyWith(viewType: type);
  }

  void toggleViewType() {
    state = state.copyWith(
      viewType: state.viewType == ExploreViewType.community
          ? ExploreViewType.reels
          : ExploreViewType.community,
    );
  }

  void selectTag(String tag) {
    state = state.copyWith(selectedTag: tag);
  }
}