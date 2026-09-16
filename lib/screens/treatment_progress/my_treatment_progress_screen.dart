import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:iconsax/iconsax.dart';
import '../../view_models/treatment_progress/treatment_progress_view_model.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/treatment_progress/treatment_progress_card.dart';
import '../../widgets/horizontal_empty_state.dart';
import 'treatment_progress_detail_screen.dart';

class MyTreatmentProgressScreen extends ConsumerWidget {
  const MyTreatmentProgressScreen({super.key});

  static const String routeName = "/MyTreatmentProgressScreen";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressState = ref.watch(treatmentProgressProvider);
    final treatments = progressState.treatments;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(
        title: "Treatment Progress",
      ),
      body: progressState.loading
          ? const Center(child: CircularProgressIndicator())
          : treatments.isEmpty
              ? Center(
                  child: HorizontalEmptyState(
                    icon: Iconsax.path,
                    title: "No progress yet",
                    subtitle: "You don't have any treatment progress yet.",
                    height: context.h(120),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.w(24),
                    vertical: context.h(20),
                  ),
                  itemCount: treatments.length,
                  itemBuilder: (context, index) {
                    final treatment = treatments[index];
                    return TreatmentProgressCard(
                      treatmentProgress: treatment,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          TreatmentProgressDetailScreen.routeName,
                          arguments: treatment,
                        );
                      },
                    );
                  },
                ),
    );
  }
}
