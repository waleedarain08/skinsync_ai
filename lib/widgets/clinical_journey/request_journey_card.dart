import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:iconsax/iconsax.dart';
import '../../models/responses/clinical_journey_response.dart';
import '../../screens/treatment_request_detail_screen.dart';
import '../../utils/color_constant.dart';
import '../../utils/custom_fonts.dart';
import '../../utils/date_time_utils.dart';
import '../../view_models/treatment_requests_view_model.dart';

class RequestJourneyCard extends ConsumerWidget {
  final PatientRequest request;
  final VoidCallback? onTap;

  const RequestJourneyCard({
    super.key,
    required this.request,
    this.onTap,
  });

  Future<void> _handleTap(BuildContext context, WidgetRef ref) async {
    if (onTap != null) {
      onTap!();
      return;
    }

    final requestId = request.id;
    if (requestId == null) return;

    EasyLoading.show(status: 'Loading request details...');
    try {
      final success = await ref
          .read(treatmentRequestsProvider.notifier)
          .fetchOptions(requestId);
      EasyLoading.dismiss();
      if (context.mounted && (success ?? false)) {
        Navigator.pushNamed(
          context,
          TreatmentRequestDetailScreen.routeName,
          arguments: {
            'groupId': requestId,
            'groupName': request.clinicName ?? 'Treatment Request',
          },
        );
      }
    } catch (_) {
      EasyLoading.dismiss();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.r(24)),
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
        boxShadow: CustomColors.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleTap(context, ref),
          borderRadius: BorderRadius.circular(context.r(24)),
          child: Padding(
            padding: EdgeInsets.all(context.w(18)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text("Original Request", style: CustomFonts.black18w600),
                        SizedBox(width: context.w(6)),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: context.sp(14),
                          color: Colors.black45,
                        ),
                      ],
                    ),
                    _buildBadge(
                      context,
                      (request.status ?? '').toUpperCase(),
                      CustomColors.blueColor,
                    ),
                  ],
                ),
                SizedBox(height: context.h(16)),

                Text("Treatments:", style: CustomFonts.grey14w400),
                SizedBox(height: context.h(8)),
                Wrap(
                  spacing: context.w(8),
                  runSpacing: context.h(8),
                  children: (request.treatments ?? [])
                      .map((t) => _buildTreatmentChip(context, t.treatmentName ?? ''))
                      .toList(),
                ),

                if (request.clinicName != null) ...[
                  SizedBox(height: context.h(16)),
                  Row(
                    children: [
                      Icon(Iconsax.hospital, size: context.sp(14), color: Colors.grey),
                      SizedBox(width: context.w(8)),
                      Text(
                        request.clinicName!,
                        style: CustomFonts.black12w600.copyWith(color: Colors.black54),
                      ),
                    ],
                  ),
                ],

                SizedBox(height: context.h(16)),
                const Divider(height: 1, color: Colors.black12),
                SizedBox(height: context.h(16)),

                Row(
                  children: [
                    if (request.date != null)
                      _buildMiniInfo(
                        context,
                        Iconsax.calendar,
                        DateTimeUtils.formatTimestampToDayDate(request.date!),
                      ),
                    const Spacer(),
                    if (request.time != null)
                      _buildMiniInfo(
                        context,
                        Iconsax.clock,
                        DateTimeUtils.formatTimestampToTime(request.time!),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(BuildContext context, String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.w(10), vertical: context.h(4)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(context.r(20)),
      ),
      child: Text(
        text,
        style: CustomFonts.blue10w700.copyWith(fontSize: context.sp(9), color: color),
      ),
    );
  }

  Widget _buildTreatmentChip(BuildContext context, String name) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.w(10), vertical: context.h(6)),
      decoration: BoxDecoration(
        color: CustomColors.greyColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(context.r(12)),
      ),
      child: Text(name, style: CustomFonts.black12w600),
    );
  }

  Widget _buildMiniInfo(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: context.sp(14), color: Colors.grey),
        SizedBox(width: context.w(6)),
        Text(text, style: CustomFonts.grey12w400),
      ],
    );
  }
}