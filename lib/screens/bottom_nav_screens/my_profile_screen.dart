import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax/iconsax.dart';
import '../../services/websocket_service.dart';
import '../allergy_and_medical_history.dart';
import '../compliance_form_screen.dart';
import '../consent_forms_screen.dart';
import '../get_started_screen.dart';
import '../treatment_progress/my_treatment_progress_screen.dart';
import '../appointment_journey/appointment_journey_screen.dart';
import '../personal_detail_screen.dart';
import '../personal_document_screen.dart';
import '../saved_treatment_screen.dart';
import '../setting_screen.dart';
import '../../utils/assets.dart';
import '../../utils/color_constant.dart';
import '../../utils/date_time_utils.dart';
import '../../utils/string_utils.dart';
import '../../utils/custom_fonts.dart';
import '../../utils/secure_storage_service.dart';
import '../../view_models/auth_view_model.dart';
import '../../view_models/subscription_view_model.dart';
import '../../widgets/logout_dialog_box.dart';

import '../../main.dart';
import '../../widgets/dialogs/delete_account_dialog.dart';
import '../shared_treatment_requests_screen.dart';
import '../subscription_plans_screen.dart';
import 'appointments_screen.dart';

class MyProfileScreen extends StatelessWidget {
  const MyProfileScreen({super.key});

  static const String routeName = "/MyProfileScreen";

  @override
  Widget build(BuildContext context) {
    // Wrapper for group options inside a Card
    Widget buildOptionCard(List<Widget> children) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(context.r(24)),
          border: Border.all(
            color: CustomColors.greyColor.withValues(alpha: 0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.015),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(children: children),
      );
    }

    // Individual list option row inside a Card with Unified Colors
    Widget buildCardOption({
      required dynamic icon,
      required String title,
      required VoidCallback callBack,
      bool isLast = false,
    }) {
      // Single Unified Brand Color for all Icons (Consistent Aesthetic)
      const Color unifiedColor = CustomColors.purpleColor;

      return Column(
        children: [
          InkWell(
            onTap: callBack,
            borderRadius: BorderRadius.circular(context.r(24)),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.w(16),
                vertical: context.h(14),
              ),
              child: Row(
                children: [
                  // Unified soft background tint & icon color
                  Container(
                    padding: EdgeInsets.all(context.w(8)),
                    decoration: BoxDecoration(
                      color: unifiedColor.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: icon is String
                        ? SvgPicture.asset(
                            icon,
                            height: context.w(18),
                            width: context.w(18),
                            colorFilter: const ColorFilter.mode(
                              unifiedColor,
                              BlendMode.srcIn,
                            ),
                          )
                        : Icon(
                            icon as IconData,
                            size: context.w(18),
                            color: unifiedColor,
                          ),
                  ),
                  SizedBox(width: context.w(14)),
                  Expanded(
                    child: Text(
                      title.capitalize,
                      style: CustomFonts.black16w500,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.grey.shade400,
                    size: context.sp(20),
                  ),
                ],
              ),
            ),
          ),
          if (!isLast)
            Padding(
              padding: EdgeInsets.only(
                left: context.w(54),
                right: context.w(16),
              ),
              child: Divider(color: Colors.grey.shade100, height: context.h(1)),
            ),
        ],
      );
    }

    Widget buildUpgradeBanner() {
      return Consumer(
        builder: (context, ref, _) {
          final subscriptionState = ref.watch(subscriptionProvider);
          final currentPlan = subscriptionState.currentPlan;

          final bool hasPlan = currentPlan != null;

          final String titleText = hasPlan
              ? (currentPlan.name ?? "Current Plan")
              : "Upgrade to Premium";

          String subtitleText;
          if (hasPlan) {
            final bool isLifetime = currentPlan.isLifetime ?? false;
            if (isLifetime) {
              subtitleText = "Lifetime";
            } else if (currentPlan.endDate != null) {
              subtitleText = "Expires: ${currentPlan.endDate!.formattedDate}";
            } else {
              subtitleText = "Active Plan";
            }
          } else {
            subtitleText =
                "Unlock unlimited AI simulations and premium support.";
          }

          final bool showUpgradeButton =
              !hasPlan || (currentPlan.price ?? 0) == 0;

          return InkWell(
            onTap: () {
              Navigator.pushNamed(context, SubscriptionPlansScreen.routeName);
            },
            borderRadius: BorderRadius.circular(context.r(24)),
            child: Container(
              padding: EdgeInsets.all(context.w(16)),
              decoration: BoxDecoration(
                gradient: CustomColors.purpleBlueGradient,
                borderRadius: BorderRadius.circular(context.r(24)),
                boxShadow: [
                  BoxShadow(
                    color: CustomColors.purpleColor.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(context.w(10)),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Iconsax.crown,
                      color: CustomColors.blackColor,
                      size: context.w(24),
                    ),
                  ),
                  SizedBox(width: context.w(16)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          titleText,
                          style: CustomFonts.white16w600.copyWith(
                            color: Colors.black87,
                            fontSize: context.sp(15),
                          ),
                        ),
                        SizedBox(height: context.h(2)),
                        Text(
                          subtitleText,
                          style: CustomFonts.white12w600.copyWith(
                            color: Colors.black54,
                            fontSize: context.sp(11),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (showUpgradeButton) ...[
                    SizedBox(width: context.w(12)),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          SubscriptionPlansScreen.routeName,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: context.w(14),
                          vertical: context.h(8),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(context.r(12)),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        "Upgrade",
                        style: CustomFonts.white14w600.copyWith(
                          fontSize: context.sp(12),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: context.h(16)),
            // Header: Title and Settings Button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: context.w(24)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("My Profile", style: CustomFonts.black26w600),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, SettingScreen.routeName);
                    },
                    child: Container(
                      height: context.w(42),
                      width: context.w(42),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: CustomColors.greyColor,
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Iconsax.setting_2,
                          size: context.sp(18),
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: context.h(24)),

            // Profile Avatar & Name Block
            Padding(
              padding: EdgeInsets.symmetric(horizontal: context.w(24)),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: CustomColors.purpleColor.withValues(alpha: 0.4),
                        width: context.w(4),
                      ),
                    ),
                    child: Consumer(
                      builder: (context, ref, _) {
                        final image = ref
                            .watch(authViewModel)
                            .authData
                            ?.user
                            ?.profileImageUrl;
                        return ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: image ?? "",
                            fit: BoxFit.cover,
                            height: context.w(80),
                            width: context.w(80),
                            placeholder: (context, url) => Container(
                              height: context.w(80),
                              width: context.w(80),
                              color: Colors.grey.shade100,
                              child: const Center(
                                child: CupertinoActivityIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              height: context.w(80),
                              width: context.w(80),
                              color: Colors.grey.shade100,
                              child: Icon(
                                Icons.person_outline_rounded,
                                size: context.sp(36),
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: context.w(18)),
                
                  Expanded(
                    child: Consumer(
                      builder: (context, ref, _) {
                        final name = ref
                            .watch(authViewModel)
                            .authData
                            ?.user
                            ?.name;
                        final currentPlan =
                            ref.watch(subscriptionProvider).currentPlan;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name?.capitalize ?? 'Guest User',
                              style: CustomFonts.black22w600,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: context.h(2)),
                            Text(
                              currentPlan?.name ?? "Free Plan",
                              style: CustomFonts.darkPurple12w600,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: context.h(20)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: context.w(24)),
              child: Divider(
                color: CustomColors.greyColor.withValues(alpha: 0.6),
                height: context.h(1),
              ),
            ),

            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  context.w(24),
                  context.h(20),
                  context.w(24),
                  context.h(100),
                ),
                children: [
                  if(!isDeploymentMode)
                  buildUpgradeBanner(),
                   if(!isDeploymentMode)
                  SizedBox(height: context.h(20)),
                  // CARD 1: Clinical Portal Section
                  buildOptionCard([
                    buildCardOption(
                      callBack: () {
                        Navigator.pushNamed(
                          context,
                          PersonalDetailScreen.routeName,
                        );
                      },
                      icon: SvgAssets.profileIcon,
                      title: "Personal Details",
                    ),
                     if(!isDeploymentMode)
                    buildCardOption(
                      callBack: () {
                        Navigator.pushNamed(
                          context,
                          PersonalDocumentScreen.routeName,
                          arguments: true,
                        );
                      },
                      icon: SvgAssets.receipts,
                      title: "Personal Documents",
                    ),
                    buildCardOption(
                      callBack: () {
                        Navigator.pushNamed(
                          context,
                          SharedTreatmentRequestsScreen.routeName,
                          arguments: 'My Clinics',
                        );
                      },
                      icon: SvgAssets.medical,
                      title: "My Clinics",
                    ),
                    buildCardOption(
                      callBack: () {
                        Navigator.pushNamed(
                          context,
                          MyTreatmentProgressScreen.routeName,
                        );
                      },
                      icon: SvgAssets.progress,
                      title: "Treatment Progress",
                    ),
                    buildCardOption(
                      callBack: () {
                        Navigator.pushNamed(
                          context,
                          AppointmentJourneyScreen.routeName,
                        );
                      },
                      icon: Iconsax.map,
                      title: "Journey",
                    ),
                    buildCardOption(
                      callBack: () {
                        Navigator.pushNamed(
                          context,
                          AppointmentsScreen.routeName,
                        );
                      },
                      icon: SvgAssets.appointment,
                      title: "Appointments",
                    ),
                     if(!isDeploymentMode)
                    buildCardOption(
                      callBack: () {
                        Navigator.pushNamed(
                          context,
                          SubscriptionPlansScreen.routeName,
                        );
                      },
                      icon: Iconsax.card,
                      title: "Subscription Plans",
                      isLast: true,
                    ),

                    buildCardOption(
                      callBack: () {
                        Navigator.pushNamed(
                          context,
                          AllergyAndMedicalHistory.routeName,
                          
                        );
                      },
                      icon: SvgAssets.medical,
                      title: "Medical History",
                    ),


                    // buildCardOption(
                    //   callBack: () {
                    //     Navigator.pushNamed(
                    //       context,
                    //       SimulationHistoryScreen.routeName,
                    //     );
                    //   },
                    //   icon: SvgAssets.appointments,
                    //   title: "Simulation History",
                    // ),
                  ]),
                  SizedBox(height: context.h(16)),

                  // CARD 2: Preferences & History Section
                  if (!isDeploymentMode) ...[
                    buildOptionCard([
                      buildCardOption(
                        callBack: () {
                          Navigator.pushNamed(
                            context,
                            SavedTreatmentScreen.routeName,
                          );
                        },
                        icon: SvgAssets.saveTreatment,
                        title: "Saved Treatments & Clinics",
                      ),
                      buildCardOption(
                        callBack: () {},
                        icon: SvgAssets.loyalty,
                        title: "Loyalty & Rewards",
                      ),
                      buildCardOption(
                        callBack: () {},
                        icon: SvgAssets.receipts,
                        title: "Treatment Receipts",
                      ),
                    ]),
                    SizedBox(height: context.h(16)),
                  ],

                  // Legal and Policy Section
                  buildOptionCard([
                    buildCardOption(
                      callBack: () {
                        Navigator.pushNamed(
                          context,
                          ConsentFormsScreen.routeName,
                        );
                      },
                      icon: Iconsax.security,
                      title: "Consent Forms",
                    ),
                    buildCardOption(
                      callBack: () {
                        Navigator.pushNamed(
                          context,
                          ComplianceFormsScreen.routeName,
                        );
                      },
                      icon: Iconsax.document_text,
                      title: "Compliance Forms",
                      isLast: true,
                    ),
                    // buildCardOption(
                    //   callBack: () {
                    //     Navigator.pushNamed(
                    //       context,
                    //       LegalDocumentScreen.routeName,
                    //       arguments: LegalDocumentArgs(
                    //         title: "Terms Of Service",
                    //         assetPath: 'assets/dummyassets/A_Terms_of_Service.pdf',
                    //         storageFileName: 'signed_terms_of_service.pdf',
                    //       ),
                    //     );
                    //   },
                    //   icon: Iconsax.document,
                    //   title: "Terms Of Service",
                    // ),
                    // buildCardOption(
                    //   callBack: () {
                    //     Navigator.pushNamed(
                    //       context,
                    //       LegalDocumentScreen.routeName,
                    //       arguments: LegalDocumentArgs(
                    //         title: "Privacy Policy",
                    //         assetPath: 'assets/dummyassets/B_Privacy_Policy.pdf',
                    //         storageFileName: 'signed_privacy_policy.pdf',
                    //       ),
                    //     );
                    //   },
                    //   icon: Iconsax.security,
                    //   title: "Privacy Policy",
                    // ),
                  ]),
                  SizedBox(height: context.h(16)),

                  // CARD 3: Account Security Section
                  Consumer(
                    builder: (_, ref, _) {
                      return buildOptionCard([
                        buildCardOption(
                          callBack: () {
                            ref.read(authViewModel.notifier);
                            showDeleteAccountDialog(
                              screenContext: context,
                              onSuccess: () async {
                                await SecureStorage().clearAllSecureStrings();
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  GetStartedScreen.routeName,
                                  (route) => false,
                                );
                              },
                            );
                          },
                          icon: Iconsax.user_remove,
                          title: "Delete Account",
                        ),
                        buildCardOption(
                          callBack: () {
                            showLogoutDialog(
                              screenContext: context,
                              desc: "Logout successful",
                              onSuccess: () async {
                                final navigator = Navigator.of(context);
                                SecureStorage secureStorage = SecureStorage();
                                await secureStorage.clearAllSecureStrings();
                                 final websokect =  WebSocketService();
                                 await websokect.disconnect();
                                navigator.pushNamedAndRemoveUntil(
                                  GetStartedScreen.routeName,
                                  (route) => false,
                                );
                              },
                            );
                          },
                          icon: SvgAssets.logOut,
                          title: "Log Out",
                          isLast: true,
                        ),
                      ]);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
