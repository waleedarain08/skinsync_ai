import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:iconsax/iconsax.dart';
import '../utils/assets.dart';
import '../utils/color_constant.dart';
import '../utils/custom_fonts.dart';
import '../widgets/custom_app_bar.dart';
import 'clinical_journey/clinical_journey_screen.dart';
import 'treatment_requests_screen.dart';
import 'treatment_progress/my_treatment_progress_screen.dart';
import 'bottom_nav_screens/appointments_screen.dart';

class MyCareScreen extends StatelessWidget {
  const MyCareScreen({super.key});

  static const String routeName = "/MyCareScreen";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(
        title: "My Care",
        showBackButton: false,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(context.w(24), 0, context.w(24), context.h(120)),
        child: StaggeredGrid.count(
          crossAxisCount: 2,
          mainAxisSpacing: context.h(16),
          crossAxisSpacing: context.w(16),
          children: [
            // 1. Treatment Requests (Large Hero Card at TOP)
            StaggeredGridTile.count(
              crossAxisCellCount: 2,
              mainAxisCellCount: 1.2,
              child: _buildCareCard(
                context,
                title: "Treatment Requests",
                subtitle: "Manage simulations and share choices with clinics.",
                icon: Iconsax.document_text,
                gradient: CustomColors.blueGradient,
                onTap: () => Navigator.pushNamed(context, TreatmentRequestsScreen.routeName, arguments: true),
                image: PngAssets.syringe,
                isLarge: true,
              ),
            ),

            // 2. My Appointments (Wide Card)
            StaggeredGridTile.count(
              crossAxisCellCount: 2,
              mainAxisCellCount: 0.85,
              child: _buildCareCard(
                context,
                title: "My Appointments",
                subtitle: "View and manage your upcoming visits.",
                icon: Iconsax.calendar,
                gradient: CustomColors.blueWhitePurpleGradient,
                onTap: () => Navigator.pushNamed(context, AppointmentsScreen.routeName),
                image: PngAssets.notification,
                isWide: true,
              ),
            ),
            
            // 3. Treatment Progress
            StaggeredGridTile.count(
              crossAxisCellCount: 1,
              mainAxisCellCount: 1.6,
              child: _buildCareCard(
                context,
                title: "Treatment Progress",
                subtitle: "Track active sessions and milestones.",
                icon: Iconsax.status_up,
                gradient: CustomColors.pinkGradient,
                onTap: () => Navigator.pushNamed(context, MyTreatmentProgressScreen.routeName),
                image: PngAssets.hand,
              ),
            ),

            // 4. Clinical Journey
            StaggeredGridTile.count(
              crossAxisCellCount: 1,
              mainAxisCellCount: 1.6,
              child: _buildCareCard(
                context,
                title: "Clinical Journey",
                subtitle: "Full lifecycle tracking.",
                icon: Iconsax.map,
                gradient: CustomColors.purpleBlueGradient,
                onTap: () => Navigator.pushNamed(context, ClinicalJourneyScreen.routeName),
                image: PngAssets.laserTreatment,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCareCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
    required String image,
    bool isLarge = false,
    bool isWide = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.r(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(context.r(28)),
        child: InkWell(
          onTap: onTap,
          child: Stack(
            children: [
              // Gradient Background
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: gradient,
                  ),
                ),
              ),
              
              // Decorative Image
              Positioned(
                right: isWide ? context.w(10) : (isLarge ? -context.w(10) : -context.w(30)),
                bottom: isWide ? -context.h(10) : (isLarge ? -context.h(20) : -context.h(10)),
                child: Opacity(
                  opacity: 0.12,
                  child: Image.asset(
                    image,
                    height: isWide ? context.h(100) : (isLarge ? context.h(160) : context.h(130)),
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              // Content
              Padding(
                padding: EdgeInsets.all(context.w(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.all(context.w(10)),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1),
                      ),
                      child: Icon(
                        icon,
                        color: Colors.black,
                        size: context.sp(22),
                      ),
                    ),
                    
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: CustomFonts.black18w600.copyWith(
                            fontSize: isLarge ? context.sp(22) : (isWide ? context.sp(19) : context.sp(17)),
                            height: 1.1,
                          ),
                        ),
                        SizedBox(height: context.h(6)),
                        SizedBox(
                          width: isWide ? context.w(220) : null,
                          child: Text(
                            subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: CustomFonts.black14w400.copyWith(
                              color: Colors.black87.withValues(alpha: 0.7),
                              fontSize: isLarge ? context.sp(14) : context.sp(12),
                              height: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Corner Arrow
              Positioned(
                top: context.h(20),
                right: context.w(20),
                child: Icon(
                  Icons.arrow_outward_rounded,
                  size: context.sp(18),
                  color: Colors.black45,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
