import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../models/responses/auth_response.dart';
import '../models/responses/get_clinic_response.dart';
import '../models/responses/practitioner_list_response.dart';
import '../screens/ar_face_model_preview_screen.dart';
import '../screens/journey_clinic_detail_screen.dart';
import '../utils/assets.dart';
import '../utils/color_constant.dart';
import '../utils/custom_fonts.dart';
import '../view_models/treatment_requests_view_model.dart';
import '../view_models/treatment_view_model.dart';
import 'doctor_card.dart';

class DoctorHomeCard extends StatelessWidget {
  final PractitionerDoctor doctor;
  const DoctorHomeCard({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return DoctorCard(doctor: doctor);
  }
}

// class DashboardAppointmentDateSection extends StatelessWidget {
//   final String dateTitle;
//   final List<DashboardAppointment> appointments;
//   const DashboardAppointmentDateSection({
//     super.key,
//     required this.dateTitle,
//     required this.appointments,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: EdgeInsets.only(right: context.w(16)),
//       padding: EdgeInsets.fromLTRB(context.w(16), context.h(10), context.w(10), context.h(10)),
//       decoration: BoxDecoration(
//         gradient: CustomColors.purpleBlueGradient,
//         borderRadius: BorderRadius.circular(context.r(22)),
//         border: Border.all(
//           color: CustomColors.greyColor.withValues(alpha: 0.6),
//           width: 1.2,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.02),
//             blurRadius: 16,
//             offset: const Offset(0, 6),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisAlignment: MainAxisAlignment.center,
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Row(
//             children: [
//               const Icon(
//                 Icons.calendar_today_rounded,
//                 color: CustomColors.blackColor,
//                 size: 13,
//               ),
//               SizedBox(width: context.w(6)),
//               Text(dateTitle, style: CustomFonts.black13w600),
//             ],
//           ),
//           SizedBox(height: context.h(10)),
//           Row(
//             mainAxisSize: MainAxisSize.min,
//             children: appointments
//                 .map(
//                   (appointment) =>
//                       DashboardAppointmentHomeCard(appointment: appointment),
//                 )
//                 .toList(),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class DashboardAppointmentHomeCard extends StatelessWidget {
//   final DashboardAppointment appointment;
//   const DashboardAppointmentHomeCard({super.key, required this.appointment});

//   Color _getTypeAccentColor(String? type) {
//     switch (type?.toLowerCase()) {
//       case "consultation":
//         return CustomColors.blueColor;
//       case "treatment session":
//       case "sessions":
//         return CustomColors.pinkColor;
//       default:
//         return CustomColors.purpleColor;
//     }
//   }

//   TextStyle _getTimeStyle(String? type) {
//     switch (type?.toLowerCase()) {
//       case "consultation":
//         return CustomFonts.blue10w700;
//       case "treatment session":
//       case "sessions":
//         return CustomFonts.pink10w700;
//       default:
//         return CustomFonts.blue10w700;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final type = appointment.appointmentType ?? "consultation";
//     final accentColor = _getTypeAccentColor(type);
//     final timeStyle = _getTimeStyle(type);

//     final treatment = appointment.treatments?.firstOrNull;
//     final treatmentName = treatment?.treatmentName ?? "Consultation";
//     final areaName = treatment?.areaName ?? "Full Face";

//     final bgImage = treatmentName.toLowerCase().contains("botox")
//         ? "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQl-cyJqFlcZav1TlRMEuajtrg2RJlWY3rTQA&s"
//         : "https://movelmedspa.com/storage/2024/05/Cheek-Filler-Treatment-at-Movel-Med-Spa.webp";

//     final timeString = appointment.date != null
//         ? DateTimeUtils.formatTimestampToTime(appointment.date!)
//         : "--:--";

//     return GestureDetector(
//       onTap: () {
//         Navigator.pushNamed(
//           context,
//           AppointmentDetailScreen.routeName,
//           arguments: appointment.toAppointmentItem(),
//         );
//       },
//       child: Container(
//         width: context.w(245),
//         height: context.h(135),
//         margin: EdgeInsets.only(right: context.w(8)),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(context.r(16)),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withValues(alpha: 0.08),
//               blurRadius: 8,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(context.r(16)),
//           child: Stack(
//             children: [
//               Positioned.fill(
//                 child: CachedNetworkImage(
//                   imageUrl: bgImage,
//                   fit: BoxFit.cover,
//                   placeholder: (context, url) => Container(
//                     color: Colors.grey.shade100,
//                     child: const Center(child: CupertinoActivityIndicator()),
//                   ),
//                   errorWidget: (context, url, error) => Container(
//                     color: Colors.grey.shade100,
//                     child: const Icon(
//                       Icons.broken_image_rounded,
//                       color: Colors.grey,
//                     ),
//                   ),
//                 ),
//               ),
//               Positioned.fill(
//                 child: Container(color: Colors.white.withValues(alpha: 0.75)),
//               ),
//               Positioned(
//                 left: 0,
//                 top: 0,
//                 bottom: 0,
//                 width: context.w(4),
//                 child: Container(color: accentColor),
//               ),
//               Positioned.fill(
//                 child: Padding(
//                   padding: EdgeInsets.fromLTRB(context.w(14), context.h(10), context.w(10), context.h(10)),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   treatmentName,
//                                   style: CustomFonts.black13w600,
//                                   maxLines: 1,
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                                 SizedBox(height: context.h(1)),
//                                 Text(
//                                   areaName,
//                                   style: CustomFonts.grey700_10w400,
//                                   maxLines: 1,
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                               ],
//                             ),
//                           ),
//                           SizedBox(width: context.w(6)),
//                           Container(
//                             padding: EdgeInsets.symmetric(
//                               horizontal: context.w(8),
//                               vertical: context.h(3),
//                             ),
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(context.r(20)),
//                               border: Border.all(
//                                 color: Colors.black12,
//                                 width: 0.5,
//                               ),
//                             ),
//                             child: Text(
//                               type,
//                               style: timeStyle.copyWith(fontSize: context.sp(8)),
//                             ),
//                           ),
//                         ],
//                       ),
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               Icon(
//                                 Icons.business_rounded,
//                                 size: 12,
//                                 color: Colors.grey.shade600,
//                               ),
//                               SizedBox(width: context.w(6)),
//                               Expanded(
//                                 child: Text(
//                                   appointment.clinic?.clinicName ??
//                                       "Awaiting Confirmation",
//                                   style: CustomFonts.textGrey13w400,
//                                   maxLines: 1,
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           SizedBox(height: context.h(2)),
//                           Row(
//                             children: [
//                               Icon(
//                                 Icons.person_rounded,
//                                 size: 12,
//                                 color: Colors.grey.shade600,
//                               ),
//                               SizedBox(width: context.w(6)),
//                               Expanded(
//                                 child: Text(
//                                   appointment.doctor?.doctorName ?? "Pending",
//                                   style: CustomFonts.textGrey13w400,
//                                   maxLines: 1,
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                       Container(
//                         padding: EdgeInsets.symmetric(
//                           horizontal: context.w(8),
//                           vertical: context.h(3),
//                         ),
//                         decoration: BoxDecoration(
//                           color: Colors.black.withValues(alpha: 0.05),
//                           borderRadius: BorderRadius.circular(context.r(20)),
//                         ),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Icon(
//                               Icons.access_time_filled_rounded,
//                               size: 10,
//                               color: Colors.grey.shade600,
//                             ),
//                             SizedBox(width: context.w(4)),
//                             Text(
//                               timeString,
//                               style: CustomFonts.black10w600,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

class DashboardDoctorHomeCard extends StatelessWidget {
  final TopDoctor doctor;
  const DashboardDoctorHomeCard({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return DoctorCard(
      doctor: doctor.toPractitionerDoctor(),
      width: context.w(160),
      margin: EdgeInsets.only(
        bottom: context.h(8),
        top: context.h(4),
      ),
    );
  }
}

class DashboardClinicHomeCard extends StatelessWidget {
  final TopClinic clinic;
  const DashboardClinicHomeCard({super.key, required this.clinic});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.w(245),
      margin: EdgeInsets.only(
        bottom: context.h(20),
        top: context.h(4),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.r(16)),
        boxShadow: CustomColors.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(context.r(16)),
        child: Material(
          color: Colors.white,
          child: InkWell(
            onTap: () {
              Navigator.pushNamed(
                context,
                JourneyClinicDetailScreen.routeName,
                arguments: Clinic(
                  id: clinic.clinicId,
                  name: clinic.clinicName,
                  address: clinic.address,
                ),
              );
            },
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(context.r(16)),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: clinic.banner ?? "",
                        height: context.h(100),
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey.shade100,
                          child: const Center(
                            child: CupertinoActivityIndicator(),
                          ),
                        ),
                        errorWidget: (_, _, _) => DecoratedBox(
                          decoration: const BoxDecoration(
                            gradient: CustomColors.purpleBlueGradient,
                          ),
                          child: Image.asset(
                            PngAssets.splashLogo,
                            opacity: const AlwaysStoppedAnimation(0.4),
                            fit: .cover,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.w(12),
                        vertical: context.h(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  clinic.clinicName ?? "Unknown Clinic",
                                  style: CustomFonts.black14w600,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: context.w(8),
                                  vertical: context.h(4),
                                ),
                                decoration: BoxDecoration(
                                  color: CustomColors.purpleColor.withValues(
                                    alpha: 0.12,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    context.r(20),
                                  ),
                                ),
                                child: Text(
                                  "${clinic.doctorCount ?? 0} Doctors",
                                  style: CustomFonts.darkPurple12w600,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: context.h(6)),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: context.sp(12),
                                color: Colors.grey,
                              ),
                              SizedBox(width: context.w(4)),
                              Expanded(
                                child: Text(
                                  clinic.address ?? "No address provided",
                                  style: CustomFonts.grey700_10w400,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: context.h(8),
                  left: context.w(8),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: clinic.clinicImage ?? "",
                        height: context.w(40),
                        width: context.w(40),
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          height: context.w(40),
                          width: context.w(40),
                          color: Colors.grey.shade100,
                          child: const CupertinoActivityIndicator(radius: 8),
                        ),
                        errorWidget: (context, url, error) => Container(
                          height: context.w(40),
                          width: context.w(40),
                          color: Colors.grey.shade100,
                          child: Icon(
                            Icons.storefront_rounded,
                            size: context.w(20),
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DashboardSimulationCard extends ConsumerWidget {
  final DashboardSimulation simulation;

  const DashboardSimulationCard({super.key, required this.simulation});

  Future<void> _onModifyTap(WidgetRef ref) async {
    EasyLoading.show(status: 'Loading...');
    final sim = await ref
        .read(treatmentRequestsProvider.notifier)
        .fetchOptionsDetail(simulation.id);
    if (sim != null) {
      await ref.read(treatmentViewModel.notifier).initializeSimulation(sim);
      if (ref.context.mounted) {
        Navigator.pushNamed(ref.context, ArFaceModelPreviewScreen.routeName);
      }
    } else {
      EasyLoading.showError('Failed to load simulation. Please try again.');
    }
  }

  Widget _buildImage(BuildContext context, String label, String? imageUrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: CustomFonts.black14w600),
        SizedBox(height: context.h(4)),
        ClipRRect(
          borderRadius: BorderRadius.circular(context.r(12)),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(context.r(12)),
            ),
            child: CachedNetworkImage(
              imageUrl: imageUrl ?? '',
              height: context.h(120),
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: context.h(120),
                color: Colors.white.withValues(alpha: 0.2),
                child: const Center(
                  child: CupertinoActivityIndicator(radius: 8),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                height: context.h(150),
                color: Colors.white.withValues(alpha: 0.2),
                child: Icon(
                  Icons.broken_image_rounded,
                  size: context.w(20),
                  color: Colors.black26,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final _ = ref.watch(treatmentRequestsProvider.select((s) => s.loading));
    return Container(
      width: context.w(380),
      margin: EdgeInsets.only(
        bottom: context.h(20),
        top: context.h(4),
      ),
      decoration: BoxDecoration(
        color: CustomColors.whiteColor,
        borderRadius: BorderRadius.circular(context.r(16)),
        boxShadow: CustomColors.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(context.r(16)),
        child: Material(
          color: Colors.white,
          child: InkWell(
            onTap: () => _onModifyTap(ref),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    context.w(12),
                    context.h(12),
                    context.w(12),
                    context.h(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildImage(
                          context,
                          'Before',
                          simulation.frontImageBefore,
                        ),
                      ),
                      SizedBox(width: context.w(10)),
                      Expanded(
                        child: _buildImage(
                          context,
                          'After',
                          simulation.frontImageAfter,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
