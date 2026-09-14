import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../models/base_state_model.dart';
import '../models/explore_models.dart';
import '../models/responses/filter_status.dart';
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
  final List<CommunityPostModel> posts; // kept for reference/back-compat if used elsewhere

  final int reelsTotalPages;
  final int postsTotalPages;

  final int reelsCurrentPage;

  final int pageSize;

  final ExploreViewType viewType;

  final bool reelsLoading;
  final List<FilterStatus> postTags;
  final String selectedTag;
  final int? selectedTagId;

  const ExploreState({
    super.loading,
    super.errorMessage,
    this.reels = const [],
    this.posts = const [],
    this.postTags = const [],
    this.reelsTotalPages = 1,
    this.postsTotalPages = 1,
    this.reelsCurrentPage = 1,
    this.pageSize = 20,
    this.viewType = ExploreViewType.community,
    this.reelsLoading = false,
    this.selectedTag = 'All',
    this.selectedTagId,
  });

  @override
  ExploreState copyWith({
    bool? loading,
    String? errorMessage,
    List<ReelModel>? signDocument,
    List<CommunityPostModel>? posts,
    List<FilterStatus>? postTags,
    int? totalPages,
    int? postsTotalPages,
    int? currentPage,
    int? pageSize,
    ExploreViewType? viewType,
    bool? reelsLoading,
    String? selectedTag,
    int? selectedTagId,
    bool clearSelectedTagId = false,
  }) {
    return ExploreState(
      loading: loading ?? this.loading,
      errorMessage: errorMessage ?? this.errorMessage,
      reels: signDocument ?? reels,
      posts: posts ?? this.posts,
      reelsTotalPages: totalPages ?? reelsTotalPages,
      postsTotalPages: postsTotalPages ?? this.postsTotalPages,
      reelsCurrentPage: currentPage ?? reelsCurrentPage,
      pageSize: pageSize ?? this.pageSize,
      viewType: viewType ?? this.viewType,
      reelsLoading: reelsLoading ?? this.reelsLoading,
      selectedTag: selectedTag ?? this.selectedTag,
      selectedTagId: clearSelectedTagId ? null : (selectedTagId ?? this.selectedTagId),
      postTags: postTags ?? this.postTags,
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
      pageSize: pageSize,
      viewType: viewType,
      reelsLoading: reelsLoading,
      selectedTag: selectedTag,
      selectedTagId: selectedTagId,
      postTags: postTags,
    );
  }
}

class ExploreViewModel extends BaseViewModel<ExploreState> {
  final ExploreRepository _repository;
  ExploreViewModel({required ExploreRepository repository})
      : _repository = repository,
        super(initialState: const ExploreState());

  // Posts pagination, driven by infinite_scroll_pagination.
  late final PagingController<int, CommunityPostModel> postsPagingController =
      PagingController<int, CommunityPostModel>(
    getNextPageKey: (pagingState) {
      final lastPageKey = pagingState.keys?.last ?? 0;
      final totalPages = state.postsTotalPages == 0 ? 1 : state.postsTotalPages;
      return lastPageKey < totalPages ? lastPageKey + 1 : null;
    },
    fetchPage: (pageKey) async {
      return await _fetchPostsPage(pageKey) ?? [];
    },
  );

  Future<List<CommunityPostModel>?> _fetchPostsPage(int pageKey) async {
    return runSafely(() async {
      final response = await _repository.fetchPosts(
        page: pageKey,
        limit: state.pageSize,
        filter: state.selectedTagId,
      );

      if (!ref.mounted) return null;

      state = state.copyWith(postsTotalPages: response.totalPages ?? 1);

      return response.data ?? [];
    });
  }

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

  Future<void> fetchPostTags() async {
    state = state.copyWith(reelsLoading: true);

    await runSafely(() async {
      final response = await _repository.fetchPostTags();

      final tags = <FilterStatus>[
        FilterStatus(id: 0, name: 'All'),
        ...response.data,
      ];

      state = state.copyWith(
        postTags: tags,
        reelsLoading: false,
      );
    });

    if (state.reelsLoading) {
      state = state.copyWith(reelsLoading: false);
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

  void selectTag(FilterStatus tag) {
    final isAll = tag.name == 'All';

    state = state.copyWith(
      selectedTag: tag.name,
      selectedTagId: isAll ? null : tag.id,
      clearSelectedTagId: isAll,
    );

    postsPagingController.refresh(); // resets to page 1 with new filter
  }

  @override
  void dispose() {
    postsPagingController.dispose();
    super.dispose();
  }
}