import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:iconsax/iconsax.dart';

import '../../models/responses/appointment_detail_response.dart';
import '../../models/responses/appointments_list_response.dart';
import '../../models/responses/messages_response.dart';
import '../../screens/appointment_detail_screen.dart';
import '../../utils/color_constant.dart';
import '../../utils/custom_fonts.dart';
import '../../utils/date_time_utils.dart';
import '../../view_models/appointment_view_model.dart';
import '../borderd_container_widget.dart';
import '../custom_button.dart';

// ---------------------------------------------------------------------------
// Custom Colors & Extensions for UI/UX alignment
// ---------------------------------------------------------------------------

class AppColors {
  static const Color white = CustomColors.whiteColor;
  static const Color purple = CustomColors.darkPurple;
  static const Color whiteGrey = Color(0xFFF7F7F8);
  static const Color grey = CustomColors.textGreyColor;
  static const Color border = CustomColors.greyColor;
  static const Color softGrey = Color(0xFFEEEEEE);
  static const Color palePurple = CustomColors.lightPurpleColor;
}

extension AppointmentBubbleContextExt on BuildContext {
  EdgeInsets appEdgeInsets({
    double? all,
    double? horizontal,
    double? vertical,
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    if (all != null) return EdgeInsets.all(r(all));
    return EdgeInsets.only(
      left: w(left ?? horizontal ?? 0),
      right: w(right ?? horizontal ?? 0),
      top: h(top ?? vertical ?? 0),
      bottom: h(bottom ?? vertical ?? 0),
    );
  }

  BorderRadius appBorderRadius({
    double? all,
    double? topLeft,
    double? topRight,
    double? bottomLeft,
    double? bottomRight,
  }) {
    if (all != null) return BorderRadius.circular(r(all));
    return BorderRadius.only(
      topLeft: Radius.circular(r(topLeft ?? 0)),
      topRight: Radius.circular(r(topRight ?? 0)),
      bottomLeft: Radius.circular(r(bottomLeft ?? 0)),
      bottomRight: Radius.circular(r(bottomRight ?? 0)),
    );
  }

  AppFontsExt get fonts => const AppFontsExt();

  void push(String routeName, {Object? extra}) {
    Navigator.pushNamed(this, routeName, arguments: extra);
  }
}

class AppFontsExt {
  const AppFontsExt();

  TextStyle get black14w600 => CustomFonts.black14w600;
  TextStyle get black16w600 => CustomFonts.black16w600;
  TextStyle get black13w600 => CustomFonts.black13w600;
  TextStyle get black12w600 => CustomFonts.black12w600;
  TextStyle get black14w400 => CustomFonts.black14w400;
  TextStyle get purple11w600 => CustomFonts.darkPurple12w600.copyWith(fontSize: 11.sp);
  TextStyle get grey12w400 => CustomFonts.grey12w400;
  TextStyle get grey13w500 => CustomFonts.grey13w400;
  TextStyle get white14w600 => CustomFonts.white14w600;
}

// ---------------------------------------------------------------------------
// AppointmentChatBubble Widget
// ---------------------------------------------------------------------------

class AppointmentChatBubble extends StatelessWidget {
  final Message message;

  const AppointmentChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMe;
    final appointment = message.appointmentData;

    return Container(
      constraints: BoxConstraints(maxWidth: context.w(340)),
      padding: context.appEdgeInsets(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(context.r(16)),
          topRight: Radius.circular(context.r(16)),
          bottomLeft: Radius.circular(isMe ? context.r(16) : context.r(2)),
          bottomRight: Radius.circular(isMe ? context.r(2) : context.r(16)),
        ),
        border: Border.all(
          color: AppColors.purple.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: context.appEdgeInsets(all: 6),
                      decoration: BoxDecoration(
                        color: AppColors.purple.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Iconsax.calendar_tick,
                        size: context.sp(16),
                        color: AppColors.purple,
                      ),
                    ),
                    context.horizontalSpace(8),
                    Expanded(
                      child: Text(
                        'Appointment Receipt & Summary',
                        style: context.fonts.black14w600,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              if (appointment != null &&
                  appointment.status != null &&
                  appointment.status!.isNotEmpty) ...[
                context.horizontalSpace(6),
                Container(
                  padding: context.appEdgeInsets(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.purple.withValues(alpha: 0.1),
                    borderRadius: context.appBorderRadius(all: 12),
                  ),
                  child: Text(
                    appointment.status!.toUpperCase(),
                    style: context.fonts.purple11w600,
                  ),
                ),
              ],
            ],
          ),
          context.verticalSpace(14),
          if (appointment != null) ...[
            // Patient Header
            _buildPatientHeader(context, appointment),
            context.verticalSpace(16),

            // Practitioners Section
            if (appointment.doctor != null) ...[
              _buildPractitionersSection(context, appointment.doctor!),
              context.verticalSpace(16),
            ],

            // Treatments Section
            if (appointment.treatments != null &&
                appointment.treatments!.isNotEmpty) ...[
              _buildTreatmentsSection(context, appointment.treatments!),
              context.verticalSpace(16),
            ],

            // Financial Breakdown Section
            _buildFinancialSection(context, appointment),

            // Simulations Section
            if (appointment.simulations != null) ...[
              context.verticalSpace(16),
              _buildSimulationsSection(context, appointment.simulations!),
            ],

            context.verticalSpace(16),
            Consumer(
              builder: (_, ref, _) {
                return CustomButton(
                  text: 'View Appointment Details',
                  height: context.h(48),
                  borderRadius: context.r(12),
                  onPressed: () {
                    if (appointment.id != null) {
                      ref
                          .read(appointmentProvider.notifier)
                          .getAppointmentDetail(appointment.id!);
                      context.push(
                        AppointmentDetailScreen.routeName,
                        extra: AppointmentItem(
                          appointmentId: appointment.id,
                          appointmentKey: appointment.appointmentKey,
                          status: appointment.status,
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ] else if (message.content?.isNotEmpty ?? false) ...[
            Text(message.content!, style: context.fonts.black14w400),
          ],
        ],
      ),
    );
  }

  Widget _buildPatientHeader(BuildContext context, AppointmentDetailData appt) {
    final patient = appt.patient;
    final patientName = patient?.name ?? 'Patient';
    final patientEmail = patient?.email ?? '';
    final patientPhone = patient?.phoneNumber ?? '';
    final bookingMethod = appt.bookingType?.toUpperCase() ?? '';
    final appointmentType = appt.appointmentType?.title ?? '';

    final tagText = [
      if (bookingMethod.isNotEmpty) bookingMethod,
      if (appointmentType.isNotEmpty) appointmentType,
    ].join(' | ');

    final dateStr =
        appt.date != null ? DateTimeUtils.formatTimestamp(appt.date!) : '';
    final timeSlot = appt.startTime != null && appt.endTime != null
        ? '${DateTimeUtils.formatTimestampToTime(appt.startTime!)} - ${DateTimeUtils.formatTimestampToTime(appt.endTime!)}'
        : appt.startTime != null
            ? DateTimeUtils.formatTimestampToTime(appt.startTime!)
            : '';

    return BorderdContainerWidget(
      padding: context.appEdgeInsets(all: 16),
      backgroundColor: AppColors.whiteGrey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  patientName,
                  style: context.fonts.black16w600,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (tagText.isNotEmpty) ...[
                context.horizontalSpace(6),
                Container(
                  padding: context.appEdgeInsets(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.purple.withValues(alpha: 0.1),
                    borderRadius: context.appBorderRadius(all: 12),
                  ),
                  child: Text(
                    tagText,
                    style: context.fonts.purple11w600,
                  ),
                ),
              ],
            ],
          ),
          if (patientEmail.isNotEmpty || patientPhone.isNotEmpty) ...[
            context.verticalSpace(8),
            Row(
              children: [
                if (patientEmail.isNotEmpty) ...[
                  const Icon(Icons.email_outlined,
                      size: 14, color: AppColors.grey),
                  context.horizontalSpace(4),
                  Expanded(
                    child: Text(
                      patientEmail,
                      style: context.fonts.grey12w400,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  context.horizontalSpace(8),
                ],
                if (patientPhone.isNotEmpty) ...[
                  const Icon(Icons.phone_outlined,
                      size: 14, color: AppColors.grey),
                  context.horizontalSpace(4),
                  Text(patientPhone, style: context.fonts.grey12w400),
                ],
              ],
            ),
          ],
          const Divider(height: 20, color: AppColors.border),
          Row(
            children: [
              const Icon(Icons.calendar_month_outlined,
                  size: 16, color: AppColors.purple),
              context.horizontalSpace(6),
              Flexible(
                child: Text(
                  'Date: $dateStr',
                  style: context.fonts.black13w600,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              context.horizontalSpace(12),
              const Icon(Icons.access_time_rounded,
                  size: 16, color: AppColors.purple),
              context.horizontalSpace(6),
              Flexible(
                child: Text(
                  'Slot: $timeSlot',
                  style: context.fonts.black13w600,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPractitionersSection(BuildContext context, Doctor doctor) {
    final docName = doctor.name ?? 'Doctor';
    final roleOrSpec =
        doctor.specialization ?? doctor.title ?? 'Practitioner';

    return BorderdContainerWidget(
      padding: context.appEdgeInsets(all: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Assigned Practitioners', style: context.fonts.black14w600),
          context.verticalSpace(8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Container(
                padding: context.appEdgeInsets(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.purple.withValues(alpha: 0.08),
                  borderRadius: context.appBorderRadius(all: 8),
                  border: Border.all(
                    color: AppColors.purple.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.person,
                        size: 14, color: AppColors.purple),
                    context.horizontalSpace(6),
                    Text(
                      '$docName ($roleOrSpec)',
                      style: context.fonts.black12w600,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTreatmentsSection(
      BuildContext context, List<TreatmentDetail> treatments) {
    return BorderdContainerWidget(
      padding: context.appEdgeInsets(all: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Treatments & Services', style: context.fonts.black14w600),
          context.verticalSpace(10),
          ...treatments.map((t) {
            final treatmentName = t.treatmentName ?? 'Treatment';
            final areaName = t.areaName;
            final cost = t.treatmentCost ?? 0.0;
            final materialName = t.material?.materialName ?? t.material?.unitType;
            final materialQty = t.material?.selectedQuantity;
            final sessionName = t.sessionName;

            final details = [
              if (sessionName != null && sessionName.isNotEmpty)
                'Session: $sessionName',
              if (materialName != null && materialName.isNotEmpty)
                'Material: $materialName${materialQty != null ? ' [Qty: $materialQty]' : ''}'
              else if (materialQty != null)
                'Material Qty: $materialQty',
            ].join(' | ');

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          treatmentName +
                              (areaName != null && areaName.isNotEmpty
                                  ? ' - $areaName'
                                  : ''),
                          style: context.fonts.black13w600,
                        ),
                        if (details.isNotEmpty) ...[
                          context.verticalSpace(2),
                          Text(
                            details,
                            style: context.fonts.grey12w400,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Text(
                    '\$${cost.toStringAsFixed(2)}',
                    style: context.fonts.black13w600,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFinancialSection(
      BuildContext context, AppointmentDetailData appt) {
    final total = appt.treatmentTotal ?? 0.0;
    final discountType = (appt.discountType ?? 'FIXED').toUpperCase();
    final discountValue = appt.discount ?? 0.0;
    final discountAmount = appt.discountType?.toLowerCase() == 'percentage'
        ? total * (discountValue / 100)
        : discountValue;
    const amountPaid = 0.0;
    final remainingPayable =
        (total - discountAmount - amountPaid).clamp(0.0, double.infinity);

    final payment = appt.paymentType;
    final paymentTypeStr = payment?.type?.toUpperCase() ?? 'N/A';
    final paymentStatusStr = payment?.status?.toUpperCase() ?? 'N/A';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteGrey,
        borderRadius: context.appBorderRadius(all: 12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Padding(
            padding: context.appEdgeInsets(all: 16),
            child: Column(
              children: [
                _summaryRow(
                  context,
                  'Treatment Total',
                  '\$${total.toStringAsFixed(2)}',
                ),
                context.verticalSpace(8),
                _summaryRow(
                  context,
                  'Discount ($discountType)',
                  '-\$${discountAmount.toStringAsFixed(2)}',
                ),
                context.verticalSpace(8),
                _summaryRow(
                  context,
                  'Amount Paid',
                  '\$${amountPaid.toStringAsFixed(2)}',
                ),
                context.verticalSpace(8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Payment Details', style: context.fonts.grey12w400),
                    Text(
                      '$paymentTypeStr | $paymentStatusStr',
                      style: context.fonts.black12w600,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: context.appEdgeInsets(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.purple,
              borderRadius: context.appBorderRadius(
                bottomLeft: 12,
                bottomRight: 12,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Remaining Payable',
                  style: context.fonts.white14w600,
                ),
                Text(
                  '\$${remainingPayable.toStringAsFixed(2)}',
                  style: context.fonts.white14w600,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimulationsSection(BuildContext context, Simulations sims) {
    final simulationsMap = <String, String>{
      'Front Before': sims.frontImageBefore ?? '',
      'Front After': sims.frontImageAfter ?? '',
      'Right Before': sims.rightImageBefore ?? '',
      'Right After': sims.rightImageAfter ?? '',
      'Left Before': sims.leftImageBefore ?? '',
      'Left After': sims.leftImageAfter ?? '',
    }..removeWhere((k, v) => v.trim().isEmpty);

    if (simulationsMap.isEmpty) return const SizedBox.shrink();

    return BorderdContainerWidget(
      padding: context.appEdgeInsets(all: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Attached Simulations', style: context.fonts.black14w600),
          context.verticalSpace(10),
          Wrap(
            spacing: 12.w,
            runSpacing: 12.h,
            children: simulationsMap.entries.map((entry) {
              final label = entry.key;
              final url = entry.value.trim();

              return Container(
                width: context.w(110),
                padding: context.appEdgeInsets(all: 6),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: context.appBorderRadius(all: 8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: context.appBorderRadius(all: 6),
                      child: SizedBox(
                        width: double.infinity,
                        height: context.h(80),
                        child: url.startsWith('http')
                            ? CachedNetworkImage(
                                imageUrl: url,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: AppColors.softGrey,
                                  child: const Center(
                                    child: SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: AppColors.palePurple,
                                  child: const Icon(
                                    Icons.broken_image_outlined,
                                    size: 22,
                                    color: AppColors.grey,
                                  ),
                                ),
                              )
                            : Image.asset(
                                url,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  color: AppColors.palePurple,
                                  child: const Icon(
                                    Icons.broken_image_outlined,
                                    size: 22,
                                    color: AppColors.grey,
                                  ),
                                ),
                              ),
                      ),
                    ),
                    context.verticalSpace(6),
                    Text(
                      label,
                      style: context.fonts.purple11w600,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: context.fonts.grey13w500),
        Text(value, style: context.fonts.black13w600),
      ],
    );
  }
}
