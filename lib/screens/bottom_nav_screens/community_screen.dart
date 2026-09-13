import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import '../../models/social_post_model.dart';
import '../../utils/color_constant.dart';
import '../../utils/custom_fonts.dart';
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
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(exploreViewModel.notifier).fetchPosts();
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final state = ref.read(exploreViewModel);
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        state.postsCurrentPage < state.postsTotalPages &&
        !state.postsLoading) {
      ref
          .read(exploreViewModel.notifier)
          .fetchPosts(page: state.postsCurrentPage + 1);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(exploreViewModel);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // const PostUsageContainer(),
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
                    // SizedBox(width: context.w(12)),
                    // GestureDetector(
                    //   onTap: () {
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //         builder: (context) => const CreatePostScreen(),
                    //       ),
                    //     );
                    //   },
                    //   child: Container(
                    //     padding: EdgeInsets.all(context.w(8)),
                    //     decoration: const BoxDecoration(
                    //       shape: BoxShape.circle,
                    //       color: CustomColors.purpleColor,
                    //     ),
                    //     child: const Icon(Icons.add, color: Colors.white),
                    //   ),
                    // ),
               
                  ],
                ),
              ],
            ),
          ),
          // Horizontal Tags Filter Chips
          SizedBox(height: context.h(4)),
          SizedBox(
            height: context.h(36),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: context.w(20)),
              itemCount: state.tags.length,
              itemBuilder: (context, index) {
                final tag = state.tags[index];
                final isSelected = tag == state.selectedTag;
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
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: CustomColors.purpleColor
                                    .withValues(alpha: 0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        "#$tag",
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
            child: state.postsLoading && state.posts.isEmpty
                ? const Center(child: AppLoader())
                : state.posts.isEmpty
                    ? const Center(
                        child: Text(
                          "No posts yet",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.only(bottom: context.h(120)),
                        physics: const BouncingScrollPhysics(),
                        itemCount:
                            state.posts.length + (state.postsLoading ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index >= state.posts.length) {
                            return Padding(
                              padding:
                                  EdgeInsets.symmetric(vertical: context.h(20)),
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          return SocialPostCard(
                            post: SocialPost.fromCommunityPost(state.posts[index]),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}