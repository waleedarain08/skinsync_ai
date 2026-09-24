import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:iconsax/iconsax.dart';
import '../utils/color_constant.dart';
import '../view_models/clinic_view_model.dart';
import '../widgets/care_card.dart';
import '../widgets/custom_app_bar.dart';
import 'clinical_journey/treatment_clinical_journey_screen.dart';
import 'shared_treatment_requests_screen.dart';
import 'treatment_requests_screen.dart';
import 'treatment_progress/my_treatment_progress_screen.dart';
import 'bottom_nav_screens/appointments_screen.dart';

class MyCareScreen extends ConsumerWidget {
  const MyCareScreen({super.key});

  static const String routeName = "/MyCareScreen";

  Future<void> _openTreatmentJourney(
    BuildContext context,
    WidgetRef ref,
  ) async {
    EasyLoading.show(
      status: 'Loading...',
      maskType: EasyLoadingMaskType.black, // blocks double taps
    );

    final clinics = await ref
        .read(clinicProvider.notifier)
        .fetchSharedClinic(1);

    // null means the request failed and onError already replaced the loader
    // with an error toast, so don't dismiss it here.
    if (clinics == null) return;
    EasyLoading.dismiss();
    if (!context.mounted) return;

    if (clinics.isEmpty) {
      EasyLoading.showInfo('No clinics found');
    } else if (clinics.length == 1) {
  final clinicId = clinics.first.id;
  if (clinicId == null) {
    EasyLoading.showError('Clinic not found');
    return;
  }
  Navigator.pushNamed(
    context,
    TreatmentClinicalJourneyScreen.routeName,
    arguments: clinicId,
  );
} else {
      Navigator.pushNamed(
        context,
        SharedTreatmentRequestsScreen.routeName,
        arguments: const SharedTreatmentRequestsArgs(
          title: 'My Clinics',
          openJourneyOnTap: true,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: "My Care", showBackButton: false),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          context.w(24),
          0,
          context.w(24),
          context.h(120),
        ),
        child: StaggeredGrid.count(
          crossAxisCount: 2,
          mainAxisSpacing: context.h(16),
          crossAxisSpacing: context.w(16),
          children: [
            // 1. Treatment Requests (Large Hero Card at TOP)
            StaggeredGridTile.count(
              crossAxisCellCount: 2,
              mainAxisCellCount: 1.2,
              child: CareCard(
                title: "Treatment Requests",
                subtitle: "Manage simulations and share choices with clinics.",
                icon: Iconsax.document_text,
                gradient: CustomColors.purpleBlueGradient,
                onTap: () => Navigator.pushNamed(
                  context,
                  TreatmentRequestsScreen.routeName,
                  arguments: true,
                ),
                isLarge: true,
              ),
            ),

            // 2. My Appointments (Wide Card)
            StaggeredGridTile.count(
              crossAxisCellCount: 2,
              mainAxisCellCount: 0.85,
              child: CareCard(
                title: "My Appointments",
                subtitle: "View and manage your upcoming visits.",
                icon: Iconsax.calendar,
                gradient: CustomColors.purpleBlueGradient,
                onTap: () =>
                    Navigator.pushNamed(context, AppointmentsScreen.routeName),
                isWide: true,
              ),
            ),

            // 3. Treatment Progress
            StaggeredGridTile.count(
              crossAxisCellCount: 1,
              mainAxisCellCount: 1.6,
              child: CareCard(
                title: "Treatment Progress",
                subtitle: "Track active sessions and milestones.",
                icon: Iconsax.status_up,
                gradient: CustomColors.purpleBlueGradient,
                onTap: () => Navigator.pushNamed(
                  context,
                  MyTreatmentProgressScreen.routeName,
                ),
              ),
            ),

            // 4. Clinical Journey
            StaggeredGridTile.count(
              crossAxisCellCount: 1,
              mainAxisCellCount: 1.6,
              child: CareCard(
                title: "Treatment Journey",
                subtitle: "Full lifecycle tracking.",
                icon: Iconsax.map,
                gradient: CustomColors.purpleBlueGradient,
                onTap: () => _openTreatmentJourney(context, ref),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
