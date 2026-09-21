import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:iconsax/iconsax.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../models/responses/treatment_progress_response.dart';
import '../../view_models/treatment_view_model.dart';
import '../../widgets/app_loader.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/horizontal_empty_state.dart';
import '../../widgets/treatment_progress/treatment_progress_card.dart';
import 'treatment_progress_detail_screen.dart';

class MyTreatmentProgressScreen extends ConsumerStatefulWidget {
  final int? treatmentId;
  final int? areaId;
  const MyTreatmentProgressScreen({super.key,this.treatmentId, this.areaId});

  static const String routeName = "/MyTreatmentProgressScreen";

  @override
  ConsumerState<MyTreatmentProgressScreen> createState() =>
      _MyTreatmentProgressScreenState();
}

class _MyTreatmentProgressScreenState
    extends ConsumerState<MyTreatmentProgressScreen> {
 late final _pagingController = PagingController<int, TreatmentProgressData>(
    getNextPageKey: (state) {
      final lastPageLength = state.pages?.lastOrNull?.length;
      if (lastPageLength == null) {
        return 1;
      }
      if (lastPageLength < 10) {
        return null;
      }
      return state.nextIntPageKey;
    },
    fetchPage: (page) async {
      if (!ref.context.mounted) {
        return [];
      }
      final items =
          await ref
              .read(treatmentViewModel.notifier)
              .getTreatmentProgress(
                page: page,
                treatmentId: widget.treatmentId,
                areaId: widget.areaId,
              ) ??
          [];
      return items;
    },
  );
  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(treatmentViewModel);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: "Treatment Progress"),
      body: PagingListener<int, TreatmentProgressData>(
        controller: _pagingController,
        builder: (_, state, fetchNextPage) {
          return PagedListView<int, TreatmentProgressData>(
            padding: EdgeInsets.symmetric(
              horizontal: context.w(24),
              vertical: context.h(20),
            ),
            state: state,
            fetchNextPage: fetchNextPage,
            builderDelegate: PagedChildBuilderDelegate<TreatmentProgressData>(
              itemBuilder: (_, treatment, _) {
                return TreatmentProgressCard(
                  treatmentProgress: treatment,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      TreatmentProgressDetailScreen.routeName,
                      arguments:treatment.id,
                    );
                  },
                );
              },
              noItemsFoundIndicatorBuilder: (_) => Center(
                child: HorizontalEmptyState(
                  icon: Iconsax.path,
                  title: "No progress yet",
                  subtitle: "You don't have any treatment progress yet.",
                  height: context.h(120),
                ),
              ),
              firstPageErrorIndicatorBuilder: (_) => Center(
                child: HorizontalEmptyState(
                  icon: Iconsax.path,
                  title: "No progress yet",
                  subtitle: "You don't have any treatment progress yet.",
                  height: context.h(120),
                ),
              ),
              firstPageProgressIndicatorBuilder: (_) => const AppLoader(),
              newPageProgressIndicatorBuilder: (_) => const AppLoader(),
            ),
          );
        },
      ),
    );
  }
}