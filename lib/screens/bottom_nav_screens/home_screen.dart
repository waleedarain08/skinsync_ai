import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../../main.dart';
import '../../utils/color_constant.dart';
import '../../utils/custom_fonts.dart';
import '../../utils/enums.dart';
import '../../view_models/auth_view_model.dart';
import '../../view_models/bottom_nav_view_model.dart';
import '../../view_models/home_view_model.dart';
import '../../widgets/app_bar_with_action_icon.dart';
import '../../widgets/appointment_card.dart';
import '../../widgets/discount_card.dart';
import '../../widgets/grey_container.dart';
import '../../widgets/heading_with_right_arrow.dart';
import '../../widgets/home_horizontal_sections.dart';
import '../../widgets/points_earn_card.dart';
import '../../widgets/requested_clinic_treatment_widget.dart';
import '../../widgets/treatment_container.dart';
import '../appointment_detail_screen.dart';
import '../doctors_screen.dart';
import '../journey_clinics_screen.dart';
import '../notification_screen.dart';
import '../patient_treatment_requests_screen.dart';
import '../shared_treatment_requests_screen.dart';
import 'appointments_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});
  static const String routeName = "HomeScreen";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Promotions are still static as no API endpoint provides them yet
    const int promotionsCount =
        0; // Set to 0 to show empty state if not available

    final authData = ref.watch(authViewModel).authData;
    final dashboard = authData?.dashboard;
    final appointments = dashboard?.appointments ?? [];
    final homeState = ref.watch(homeViewModelProvider);
    final sections = homeState.sections;
    final isReorderMode = homeState.isReorderMode;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBarWithActionIcon(
        action: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isReorderMode)
              TextButton(
                onPressed: () => ref
                    .read(homeViewModelProvider.notifier)
                    .toggleReorderMode(),
                child: Text(
                  "Done",
                  style: CustomFonts.darkPurple12w600.copyWith(
                    fontSize: context.sp(14),
                  ),
                ),
              )
            else
              GreyContainer(
                icon: Icons.sort_rounded,
                onTap: () => ref
                    .read(homeViewModelProvider.notifier)
                    .toggleReorderMode(),
              ),

            SizedBox(width: context.w(12)),
            GreyContainer(
              icon: Icons.notifications_none_outlined,
              onTap: () {
                Navigator.of(context).pushNamed(NotificationScreen.routeName);
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: ReorderableListView(
          proxyDecorator: (child, index, animation) =>
              Material(color: Colors.transparent, child: child),
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(top: context.h(22), bottom: context.h(100)),
          onReorderItem: (oldIndex, newIndex) {
            ref
                .read(homeViewModelProvider.notifier)
                .reorderSections(oldIndex, newIndex);
          },
          buildDefaultDragHandles:
              false, // We'll show handles only in edit mode
          children: sections.map((section) {
            final Widget sectionWidget;
            switch (section) {
              case HomeSection.points:
                sectionWidget = isDeploymentMode
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.w(24),
                        ),
                        child: Column(
                          children: [
                            const PointsEarnCard(),
                            SizedBox(height: context.h(28)),
                          ],
                        ),
                      );
                break;

              case HomeSection.recentSimulations:
                sectionWidget = Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: context.w(24)),
                      child: HeadingWithRightArrow(
                        title: "Recent Simulations",
                        onTap: () {
                          ref.read(bottomNavViewModel.notifier).changePage(3);
                        },
                      ),
                    ),
                    SizedBox(height: context.h(12)),
                    (dashboard?.recentSimulations?.isEmpty ?? true)
                        ? _buildHorizontalEmptyState(
                            context: context,
                            height: context.h(100),
                            icon: Icons.auto_awesome_rounded,
                            title: "No Recent Simulations",
                            subtitle:
                                "Your facial AI scans and treatment simulations will appear here.",
                          )
                        : SizedBox(
                            height: context.h(200),
                            child: ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              clipBehavior: Clip.none,
                              itemCount: dashboard!.recentSimulations!.length,
                              itemBuilder: (context, index) => Padding(
                                padding: EdgeInsets.only(
                                  left: index == 0
                                      ? context.w(24)
                                      : context.w(16),
                                  right:
                                      index ==
                                          dashboard.recentSimulations!.length -
                                              1
                                      ? context.w(24)
                                      : context.w(0),
                                ),
                                child: DashboardSimulationCard(
                                  simulation:
                                      dashboard.recentSimulations![index],
                                ),
                              ),
                            ),
                          ),
                    SizedBox(height: context.h(12)),
                  ],
                );
                break;

              case HomeSection.sharedTreatmentRequests:
                sectionWidget = Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: context.w(24)),
                      child: HeadingWithRightArrow(
                        title: "Shared Treatment Requests",
                        showRightArrow: true,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            SharedTreatmentRequestsScreen.routeName,
                            arguments: 'Clinic Treatment Requests',
                          );
                        },
                      ),
                    ),
                    SizedBox(height: context.h(12)),
                    (dashboard?.requestTreatmentClinic?.isEmpty ?? true)
                        ? _buildHorizontalEmptyState(
                            context: context,
                            height: context.h(100),
                            icon: Icons.request_page_outlined,
                            title: "No Shared Treatment Requests",
                            subtitle:
                                "Shared treatment requests will appear here.",
                          )
                        : SizedBox(
                            height: context.h(160),
                            child: ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              clipBehavior: Clip.none,
                              itemCount:
                                  dashboard!.requestTreatmentClinic!.length,
                              itemBuilder: (context, index) {
                                final request =
                                    dashboard.requestTreatmentClinic![index];

                                return Padding(
                                  padding: EdgeInsets.only(
                                    left: index == 0
                                        ? context.w(24)
                                        : context.w(16),
                                    right:
                                        index ==
                                            dashboard
                                                    .requestTreatmentClinic!
                                                    .length -
                                                1
                                        ? context.w(24)
                                        : context.w(0),
                                  ),
                                  child: RequestClinicTreatmentCard(
                                    data: request,
                                    onTap: () {
                                      if (request.id != null) {
                                        Navigator.pushNamed(
                                          context,
                                          PatientTreatmentRequestsScreen
                                              .routeName,
                                          arguments: request.id,
                                        );
                                      }
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                    SizedBox(height: context.h(12)),
                  ],
                );
                break;

              case HomeSection.upcomingAppointments:
                sectionWidget = Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: context.w(24)),
                      child: HeadingWithRightArrow(
                        title: "Upcoming Appointments",
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppointmentsScreen.routeName,
                          );
                        },
                      ),
                    ),
                    SizedBox(height: context.h(12)),
                    appointments.isEmpty
                        ? _buildHorizontalEmptyState(
                            context: context,
                            height: context.h(100),
                            icon: Icons.calendar_today_rounded,
                            title: "No Upcoming Appointments",
                            subtitle:
                                "Your scheduled clinical treatments and session details will appear here.",
                          )
                        : SizedBox(
                            height: context.h(325),
                            child: ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              clipBehavior: Clip.none,
                              itemCount: appointments.length,
                              itemBuilder: (context, index) {
                                final appointment = appointments[index];

                                return Padding(
                                  padding: EdgeInsets.only(
                                    left: index == 0
                                        ? context.w(24)
                                        : context.w(16),
                                    right: index == appointments.length - 1
                                        ? context.w(24)
                                        : context.w(0),
                                  ),
                                  child: SizedBox(
                                    width: 0.8.sw,
                                    child: AppointmentCard(
                                      isTreatmentListHorizontal: true,
                                      appointment: appointment,
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          AppointmentDetailScreen.routeName,
                                          arguments: appointment,
                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                    SizedBox(height: context.h(12)),
                  ],
                );
                break;

              case HomeSection.suggestedTreatments:
                sectionWidget = Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: context.w(24)),
                      child: HeadingWithRightArrow(
                        title: "Suggested Treatments",
                        onTap: () {
                          ref.read(bottomNavViewModel.notifier).changePage(1);
                        },
                      ),
                    ),
                    SizedBox(height: context.h(12)),
                    SizedBox(
                      height: context.h(180),
                      child: Consumer(
                        builder: (context, ref, _) {
                          final suggestedTreatments =
                              dashboard?.suggestedTreatments ?? [];

                          if (suggestedTreatments.isEmpty) {
                            return _buildHorizontalEmptyState(
                              context: context,
                              height: context.h(100),
                              icon: Icons.auto_awesome_rounded,
                              title: "No Suggested Treatments",
                              subtitle:
                                  "Complete your facial AI scan to receive personalized clinical suggestions.",
                            );
                          }

                          return ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: suggestedTreatments.length,
                            scrollDirection: Axis.horizontal,
                            clipBehavior: Clip.none,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: EdgeInsets.only(
                                  left: index == 0
                                      ? context.w(24)
                                      : context.w(16),
                                  right: index == suggestedTreatments.length - 1
                                      ? context.w(24)
                                      : context.w(0),
                                ),
                                child: TreatmentContainer(
                                  width: context.w(350),
                                  treatments: suggestedTreatments[index],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    SizedBox(height: context.h(12)),
                  ],
                );
                break;

              case HomeSection.topDoctors:
                sectionWidget = isDeploymentMode
                    ? const SizedBox.shrink()
                    : Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: context.w(24),
                            ),
                            child: HeadingWithRightArrow(
                              title: "Top Doctors",
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  DoctorsScreen.routeName,
                                  arguments: {'isFromHome': true},
                                );
                              },
                            ),
                          ),
                          SizedBox(height: context.h(10)),
                          (dashboard?.topDoctors?.isEmpty ?? true)
                              ? _buildHorizontalEmptyState(
                                  context: context,
                                  height: context.h(70),
                                  icon: Icons.badge_outlined,
                                  title: "No Specialists Available",
                                  subtitle:
                                      "Specialist dermatologists and clinical practitioners will be listed here soon.",
                                )
                              : SizedBox(
                                  height: context.h(170),
                                  child: ListView.builder(
                                    physics: const BouncingScrollPhysics(),
                                    scrollDirection: Axis.horizontal,
                                    clipBehavior: Clip.none,
                                    itemCount: dashboard!.topDoctors!.length,
                                    itemBuilder: (context, index) => Padding(
                                      padding: EdgeInsets.only(
                                        left: index == 0
                                            ? context.w(24)
                                            : context.w(16),
                                        right:
                                            index ==
                                                dashboard.topDoctors!.length - 1
                                            ? context.w(24)
                                            : context.w(0),
                                      ),
                                      child: DashboardDoctorHomeCard(
                                        doctor: dashboard.topDoctors![index],
                                      ),
                                    ),
                                  ),
                                ),
                          SizedBox(height: context.h(12)),
                        ],
                      );
                break;

              case HomeSection.topClinics:
                sectionWidget = Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: context.w(24)),
                      child: HeadingWithRightArrow(
                        title: "Discover Clinics",
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            JourneyClinicsScreen.routeName,
                          );
                        },
                      ),
                    ),
                    SizedBox(height: context.h(12)),
                    (dashboard?.topClinics?.isEmpty ?? true)
                        ? _buildHorizontalEmptyState(
                            context: context,
                            height: context.h(100),
                            icon: Icons.storefront_rounded,
                            title: "No Clinics Available",
                            subtitle:
                                "Top-rated aesthetic clinics and wellness spas will be listed here soon.",
                          )
                        : SizedBox(
                            height: context.h(200),
                            child: ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              clipBehavior: Clip.none,
                              itemCount: dashboard!.topClinics!.length,
                              itemBuilder: (context, index) => Padding(
                                padding: EdgeInsets.only(
                                  left: index == 0
                                      ? context.w(24)
                                      : context.w(16),
                                  right:
                                      index == dashboard.topClinics!.length - 1
                                      ? context.w(24)
                                      : context.w(0),
                                ),
                                child: DashboardClinicHomeCard(
                                  clinic: dashboard.topClinics![index],
                                ),
                              ),
                            ),
                          ),
                    SizedBox(height: context.h(12)),
                  ],
                );
                break;

              case HomeSection.promotions:
                sectionWidget = isDeploymentMode
                    ? const SizedBox.shrink()
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: context.w(24),
                            ),
                            child: Text(
                              "Promotions & Discounts",
                              style: CustomFonts.black22w600,
                            ),
                          ),
                          SizedBox(height: context.h(10)),
                          promotionsCount == 0
                              ? _buildHorizontalEmptyState(
                                  context: context,
                                  height: context.h(100),
                                  icon: Icons.local_offer_outlined,
                                  title: "No Promotions Available",
                                  subtitle:
                                      "Exclusive clinical deals, seasonal discounts, and special offers are on their way.",
                                )
                              : SizedBox(
                                  height: context.h(200),
                                  child: ListView.builder(
                                    physics: const BouncingScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: promotionsCount,
                                    scrollDirection: Axis.horizontal,
                                    clipBehavior: Clip.none,
                                    padding: EdgeInsets.only(
                                      top: context.h(10),
                                      bottom: context.h(40),
                                    ),
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: EdgeInsets.only(
                                          left: index == 0
                                              ? context.w(24)
                                              : context.w(16),
                                          right: index == promotionsCount - 1
                                              ? context.w(24)
                                              : context.w(0),
                                        ),
                                        child: const DiscountCard(),
                                      );
                                    },
                                  ),
                                ),
                          SizedBox(height: context.h(10)),
                        ],
                      );
                break;
            }

            final item = Container(
              key: ValueKey(section),
              margin: EdgeInsets.only(left: isReorderMode ? context.w(48) : 0),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  AbsorbPointer(
                    absorbing: isReorderMode,
                    child: Opacity(
                      opacity: isReorderMode ? 0.6 : 1.0,
                      child: sectionWidget,
                    ),
                  ),
                  if (isReorderMode)
                    Positioned(
                      left: -context.w(42),
                      top: context.h(0),
                      child: Container(
                        padding: EdgeInsets.all(context.w(6)),
                        decoration: BoxDecoration(
                          color: CustomColors.purpleColor.withValues(
                            alpha: 0.12,
                          ),
                          borderRadius: BorderRadius.circular(context.r(10)),
                          border: Border.all(
                            color: CustomColors.purpleColor.withValues(
                              alpha: 0.2,
                            ),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.drag_handle_rounded,
                          color: CustomColors.purpleColor,
                          size: context.sp(24),
                        ),
                      ),
                    ),
                ],
              ),
            );

            if (isReorderMode) {
              return ReorderableDragStartListener(
                key: ValueKey(section),
                index: sections.indexOf(section),
                child: item,
              );
            }
            return item;
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildHorizontalEmptyState({
    required BuildContext context,
    required double height,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    const myLocalGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [CustomColors.lightPurpleColor, CustomColors.purpleColor],
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.w(24)),
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(context.r(24)),
          gradient: myLocalGradient, // Solid brand gradient background
          border: Border.all(
            color: CustomColors.lightPurpleColor.withValues(alpha: 0.4),
            width: 1.5,
          ),
          boxShadow: CustomColors.cardShadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(context.r(22)),
          child: Stack(
            children: [
              // 1. Translucent White Mask Tint Overlay
              Positioned.fill(
                child: Container(
                  color: Colors.white.withValues(
                    alpha: 0.85,
                  ), // Translucent premium white mask
                ),
              ),

              // 2. High-Contrast Content Layer (Sizes the parent container)
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.w(16),
                  vertical: context.h(12),
                ),
                child: Row(
                  children: [
                    // Glowing semi-transparent white circular badge icon
                    Container(
                      height: context.w(48),
                      width: context.w(48),
                      decoration: BoxDecoration(
                        color: CustomColors.purpleColor.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: CustomColors.purpleColor.withValues(
                            alpha: 0.15,
                          ),
                          width: context.w(1),
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          icon,
                          color: CustomColors.purpleColor,
                          size: context.sp(22),
                        ),
                      ),
                    ),
                    SizedBox(width: context.w(14)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            title,
                            style: CustomFonts.black14w700,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: context.h(4)),
                          Text(
                            subtitle,
                            style: CustomFonts.textGrey13w400,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
