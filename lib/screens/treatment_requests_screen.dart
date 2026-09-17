import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:iconsax/iconsax.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../models/responses/groups_list_response.dart';
import '../utils/assets.dart';
import '../utils/color_constant.dart';
import '../utils/custom_fonts.dart';
import '../utils/date_time_utils.dart';
import '../utils/string_utils.dart';
import '../view_models/treatment_requests_view_model.dart';
import '../widgets/app_loader.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_search_field.dart';
import '../widgets/dialogs/delete_confirmation_dialog.dart';
import 'treatment_request_detail_screen.dart';

class TreatmentRequestsScreen extends ConsumerStatefulWidget {
  final bool isTreatmentRequest;
  final bool isFromBottomNav;
  const TreatmentRequestsScreen({
    super.key,
    this.isFromBottomNav = false,
    this.isTreatmentRequest = true,
  });
  static const String routeName = '/TreatmentRequestsScreen';

  @override
  ConsumerState<TreatmentRequestsScreen> createState() =>
      _TreatmentRequestsScreenState();
}

class _TreatmentRequestsScreenState extends ConsumerState<TreatmentRequestsScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _groupNameController = TextEditingController();
  late bool isTreatmentRequest;
  late final PagingController<int, TreatmentRequestGroup> _pagingController;
  late TabController _tabController;
  bool _hasCheckedEmptyState = false;

  @override
  void initState() {
    super.initState();
    isTreatmentRequest = widget.isTreatmentRequest;
    _pagingController = ref
        .read(treatmentRequestsProvider.notifier)
        .pagingController;
    _pagingController.addListener(_maybeShowCreateDialogOnEmpty);

    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) return;
    // index 0 -> Unshared (isShared = false), index 1 -> Shared (isShared = true)
    final isShared = _tabController.index == 1;
    ref.read(treatmentRequestsProvider.notifier).setSharedFilter(isShared);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    _pagingController.removeListener(_maybeShowCreateDialogOnEmpty);
    _groupNameController.dispose();
    super.dispose();
  }

  void _maybeShowCreateDialogOnEmpty() {
    if (_hasCheckedEmptyState) return;

    final state = _pagingController.value;
    final firstPageLoaded =
        (state.pages?.isNotEmpty ?? false) &&
        !state.isLoading &&
        state.error == null;
    if (!firstPageLoaded) return;

    _hasCheckedEmptyState = true;
    if ((state.items?.isEmpty ?? true)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _showCreateGroupDialog();
      });
    }
  }

  void _showCreateGroupDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.r(24)),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.w(24),
            vertical: context.h(32),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon Container with Gradient Border
              Container(
                height: context.w(72),
                width: context.w(72),
                padding: EdgeInsets.all(context.w(2)),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: CustomColors.purpleBlueGradient,
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    color: CustomColors.whiteColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Iconsax.add_square,
                      size: context.sp(32),
                      color: CustomColors.darkPurple,
                    ),
                  ),
                ),
              ),
              SizedBox(height: context.h(24)),

              // Title
              Text(
                "Create New Group",
                textAlign: TextAlign.center,
                style: CustomFonts.black20w600,
              ),
              SizedBox(height: context.h(20)),

              // TextFormField (inheriting theme)
              TextFormField(
                controller: _groupNameController,
                style: CustomFonts.black18w400,
                decoration: const InputDecoration(hintText: "Enter group name"),
              ),
              SizedBox(height: context.h(28)),

              // Action Button
              CustomButton(
                onPressed: () async {
                  if (_groupNameController.text.trim().isNotEmpty) {
                    final success = await ref
                        .read(treatmentRequestsProvider.notifier)
                        .createGroup(_groupNameController.text.trim());
                    if (!mounted) return;
                    if (success ?? false) {
                      _groupNameController.clear();
                      Navigator.pop(context);
                    }
                  }
                },
                text: "Create",
              ),
              SizedBox(height: context.h(12)),

              // Cancel Button
              SizedBox(
                width: double.infinity,
                height: context.h(52),
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(context.r(26)),
                    ),
                  ),
                  child: Text(
                    "Cancel",
                    style: CustomFonts.black14w600.copyWith(
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(treatmentRequestsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        showTitle: true,
        showBackButton: !widget.isFromBottomNav,
        title: 'Treatment Requests',
        actions: [
          IconButton(
            onPressed: _showCreateGroupDialog,
            icon: const Icon(
              Icons.add_circle_outline_rounded,
              color: Colors.black,
            ),
            tooltip: "Create New Group",
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // TabBar for Unshared & Shared
            Padding(
              padding: EdgeInsets.symmetric(horizontal: context.w(24)),
              child: Container(
                height: context.h(45),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(context.r(25)),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(context.r(25)),
                    gradient: CustomColors.purpleBlueGradient,
                  ),
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey.shade600,
                  labelStyle: CustomFonts.black14w600,
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: "Unshared"),
                    Tab(text: "Shared"),
                  ],
                ),
              ),
            ),
            SizedBox(height: context.h(16)),

            // Main Content Area with PagingListener
            Expanded(
              child: PagingListener<int, TreatmentRequestGroup>(
                controller: _pagingController,
                builder: (context, state, fetchNextPage) {
                  final items = state.items ?? const [];
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: context.w(24)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (items.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(bottom: context.w(16)),
                            child: Text(
                              "Create a new request group or select an existing one to manage your simulations and share them with clinics.",
                              style: CustomFonts.grey14w400.copyWith(
                                height: 1.4,
                              ),
                            ),
                          ),
                        CustomSearchField(
                          controller: ref
                              .read(treatmentRequestsProvider.notifier)
                              .searchController,
                          hintText: "Search Groups...",
                          onChanged: (query) {
                            ref
                                .read(treatmentRequestsProvider.notifier)
                                .searchGroups(query);
                          },
                        ),
                      
                        SizedBox(height: context.h(16)),
                        Expanded(
                          child: SlidableAutoCloseBehavior(
                            child: PagedListView<int, TreatmentRequestGroup>(
                              state: state,
                              fetchNextPage: fetchNextPage,
                              physics: const BouncingScrollPhysics(),
                              padding: EdgeInsets.only(bottom: context.h(20)),
                              builderDelegate:
                                  PagedChildBuilderDelegate<
                                    TreatmentRequestGroup
                                  >(
                                    itemBuilder: (context, group, index) =>
                                        _buildGroupCard(context, group, index),
                                    firstPageProgressIndicatorBuilder:
                                        (context) =>
                                            const Center(child: AppLoader()),
                                    newPageProgressIndicatorBuilder:
                                        (context) => Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: context.h(16),
                                          ),
                                          child: const Center(
                                            child: AppLoader(),
                                          ),
                                        ),
                                    noItemsFoundIndicatorBuilder: (context) =>
                                        _buildEmptyGroupsView(),
                                    firstPageErrorIndicatorBuilder: (context) =>
                                        _buildEmptyGroupsView(),
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Center _buildEmptyGroupsView() {
    return Center(
      child: Text(
        ref.read(treatmentRequestsProvider).errorMessage ?? "No journeys found",
        style: CustomFonts.grey16w400,
      ),
    );
  }

  Widget _buildGroupCard(
    BuildContext context,
    TreatmentRequestGroup group,
    int index,
  ) {
    return Slidable(
      key: ValueKey(group.id ?? 'group_$index'),
      groupTag: 'treatment_request_groups',
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.22,
        children: [
          CustomSlidableAction(
            alignment: .center,
            onPressed: (_) {
              if (group.id != null) {
                showDeleteConfirmationDialog(
                  context: context,
                  title: "Delete Group?",
                  description:
                      "Are you sure you want to delete '${group.name}'? This action cannot be undone.",
                  onDelete: () {
                    ref
                        .read(treatmentRequestsProvider.notifier)
                        .callDeleteGroup(group.id!);
                  },
                );
              }
            },
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,

            padding: EdgeInsets.only(bottom: 10.h),
            child: Icon(
              Icons.delete_outline_rounded,
              color: Colors.red,
              size: context.sp(24),
            ),
          ),
        ],
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: context.h(16)),
        decoration: BoxDecoration(
          color: CustomColors.whiteColor,
          borderRadius: BorderRadius.circular(context.r(16)),
          border: Border.all(
            color: CustomColors.greyColor.withValues(alpha: 0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          onTap: () async {
            if (group.id != null) {
              ref.read(treatmentRequestsProvider.notifier).setGroup(group);
            }
            if (!isTreatmentRequest) {
              final success = await ref
                  .read(treatmentRequestsProvider.notifier)
                  .fetchOptions(group.id!);
              if (!mounted) return;
              if (success ?? false) {
                final result = await ref
                    .read(treatmentRequestsProvider.notifier)
                    .createTjOptions();
                if (!mounted) return;
                if (result == true) {
                  isTreatmentRequest = true;
                  final refetchSuccess = await ref
                      .read(treatmentRequestsProvider.notifier)
                      .fetchOptions(group.id!);
                  if (!mounted) return;
                  if (refetchSuccess ?? false) {
                    Navigator.pushNamed(
                      context,
                      TreatmentRequestDetailScreen.routeName,
                      arguments: {'groupId': group.id, 'groupName': group.name},
                    );
                  }
                }
              }
            } else {
              final success = await ref
                  .read(treatmentRequestsProvider.notifier)
                  .fetchOptions(group.id!);
              if (!mounted) return;
              if (success ?? false) {
                Navigator.pushNamed(
                  context,
                  TreatmentRequestDetailScreen.routeName,
                  arguments: {'groupId': group.id, 'groupName': group.name},
                );
              }
            }
          },
          borderRadius: BorderRadius.circular(context.r(16)),
          child: Padding(
            padding: EdgeInsets.all(context.w(16)),
            child: Row(
              children: [
                Container(
                  height: context.w(50),
                  width: context.w(50),
                  padding: EdgeInsets.all(
                    context.w(1.5),
                  ), // Gradient Border thickness
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: CustomColors.purpleBlueGradient,
                  ),
                  child: Container(
                    padding: EdgeInsets.all(context.w(8)),
                    decoration: const BoxDecoration(
                      color: CustomColors.whiteColor,
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      PngAssets.splashLogo,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                SizedBox(width: context.w(16)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.name?.capitalize ?? "Unnamed Journey",
                        style: CustomFonts.black18w600,
                      ),
                      SizedBox(height: context.h(4)),
                      Text(
                        "${group.totalOptions ?? 0} Simulations • ${group.createdAt?.formattedDate ?? ''}",
                        style: CustomFonts.grey14w400,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey.shade400,
                  size: context.sp(24),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
