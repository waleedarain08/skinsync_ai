import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../models/explore_models.dart';
import '../../models/social_post_model.dart';
import '../../utils/color_constant.dart';
import '../../utils/custom_fonts.dart';
import '../../utils/string_utils.dart';
import '../../view_models/explore_view_model.dart';
import '../../widgets/app_loader.dart';
import '../../widgets/social_post_card.dart';
import '../../widgets/social_toggle_button.dart';

class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> {
  late final PagingController<int, CommunityPostModel> _pagingController;

  @override
  void initState() {
    super.initState();
    _pagingController =
        ref.read(exploreViewModel.notifier).postsPagingController;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(exploreViewModel.notifier).fetchPostTags();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(exploreViewModel);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.w(20),
              vertical: context.h(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Community",
                        style: CustomFonts.black30w600.copyWith(
                          fontSize: context.sp(28),
                        ),
                      ),
                      SizedBox(height: context.h(4)),
                      Text(
                        'Discover educational content from registered providers',
                        style: CustomFonts.grey14w400.copyWith(height: 1.3),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    SocialToggleButton(
                      onTap: () =>
                          ref.read(exploreViewModel.notifier).toggleViewType(),
                      icon: Icons.play_circle_outline_rounded,
                      isReels: false,
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: context.h(4)),
          SizedBox(
            height: context.h(36),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: context.w(20)),
              itemCount: state.postTags.length,
              itemBuilder: (context, index) {
                final tag = state.postTags[index];
                final isSelected = tag.name == state.selectedTag;

                return GestureDetector(
                  onTap: () {
                    ref.read(exploreViewModel.notifier).selectTag(tag);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.only(right: context.w(8)),
                    padding: EdgeInsets.symmetric(
                      horizontal: context.w(14),
                      vertical: context.h(6),
                    ),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? CustomColors.purpleBlueGradient
                          : null,
                      color: isSelected ? null : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(context.r(20)),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        tag.name == 'All' ? tag.name : "#${tag.name.capitalize}",
                        style: isSelected
                            ? CustomFonts.black14w600.copyWith(
                                fontSize: context.sp(13),
                              )
                            : CustomFonts.grey14w400.copyWith(
                                fontSize: context.sp(13),
                                color: CustomColors.textGreyColor,
                              ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: context.h(10)),
          Expanded(
            child: PagingListener<int, CommunityPostModel>(
              controller: _pagingController,
              builder: (context, pagingState, fetchNextPage) {
                return PagedListView<int, CommunityPostModel>(
                  state: pagingState,
                  fetchNextPage: fetchNextPage,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(bottom: context.h(120)),
                  builderDelegate: PagedChildBuilderDelegate<CommunityPostModel>(
                    itemBuilder: (context, post, index) => SocialPostCard(
                      post: SocialPost.fromCommunityPost(post),
                    ),
                    firstPageProgressIndicatorBuilder: (context) =>
                        const Center(child: AppLoader()),
                    newPageProgressIndicatorBuilder: (context) => Padding(
                      padding: EdgeInsets.symmetric(vertical: context.h(20)),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    noItemsFoundIndicatorBuilder: (context) => const Center(
                      child: Text(
                        "No posts yet",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}