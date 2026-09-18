import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:iconsax/iconsax.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models/responses/appointments_list_response.dart';
import '../utils/assets.dart';
import '../utils/color_constant.dart';
import '../utils/custom_fonts.dart';
import '../utils/date_time_utils.dart';
import '../utils/string_utils.dart';
import '../view_models/appointment_view_model.dart';
import '../widgets/app_loader.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_button.dart';
import '../widgets/appointment_journey/summary_tile.dart';
import '../widgets/dialogs/appointment_details/financial_summary_dialog.dart';
import '../widgets/dialogs/appointment_details/clinic_details_dialog.dart';
import '../widgets/dialogs/appointment_details/doctor_details_dialog.dart';
import '../widgets/dialogs/appointment_details/treatment_details_dialog.dart';
import '../widgets/dialogs/appointment_details/simulation_details_dialog.dart';
import 'qr_scan_screen.dart';

class AppointmentDetailScreen extends ConsumerStatefulWidget {
  static const String routeName = '/AppointmentDetailScreen';
  final AppointmentItem appointment;

  const AppointmentDetailScreen({super.key, required this.appointment});

  @override
  ConsumerState<AppointmentDetailScreen> createState() =>
      _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState
    extends ConsumerState<AppointmentDetailScreen> {
  bool _hasAutoOpenedFinancialDialog = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (widget.appointment.appointmentId != null) {
        ref
            .read(appointmentProvider.notifier)
            .getAppointmentDetail(widget.appointment.appointmentId!);
      }
    });
  }

  void _showQrDialog({
    required BuildContext context,
    required int appointmentId,
    required String encryptedData,
  }) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.r(32)),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: context.w(24), vertical: context.h(32)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Check-in QR Code", style: CustomFonts.black18w600),
              SizedBox(height: context.h(24)),
              Container(
                padding: EdgeInsets.all(context.w(16)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(context.r(24)),
                  boxShadow: [
                    BoxShadow(
                      color: CustomColors.darkPurple.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: context.w(220),
                  height: context.w(220),
                  child: QrImageView(data: encryptedData, size: context.w(220)),
                ),
              ),
              SizedBox(height: context.h(24)),
              Text(
                "Please scan this code at the clinic reception to confirm your arrival.",
                textAlign: TextAlign.center,
                style: CustomFonts.textGrey13w400.copyWith(height: 1.4),
              ),
              SizedBox(height: context.h(32)),
              CustomButton(
                onPressed: () => Navigator.pop(context),
                text: "Dismiss",
                isBorder: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCheckInSuccessDialog(BuildContext context, String? message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(dialogContext.r(32)),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: context.w(24), vertical: context.h(32)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: context.w(72),
                  width: context.w(72),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green.withValues(alpha: 0.1),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: Colors.green,
                      size: dialogContext.sp(32),
                    ),
                  ),
                ),
                SizedBox(height: dialogContext.h(24)),
                Text(
                  "Checked In",
                  style: CustomFonts.black20w600,
                ),
                SizedBox(height: dialogContext.h(12)),
                Text(
                  message ?? "Successfully checked in.",
                  textAlign: TextAlign.center,
                  style: CustomFonts.textGrey14w400,
                ),
                SizedBox(height: dialogContext.h(32)),
                CustomButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    Navigator.pushNamed(context, '/NewPatientIntakeScreen');
                  },
                  text: "Continue",
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appointmentState = ref.watch(appointmentProvider);
    final detail = appointmentState.appointmentDetail;

    final isStale = detail == null || detail.id != widget.appointment.appointmentId;
    final isLoading = (appointmentState.loading || isStale) && appointmentState.errorMessage == null;

    final isPaymentPending = detail?.paymentType?.status == 'pending';

    if (detail != null &&
        detail.id == widget.appointment.appointmentId &&
        isPaymentPending &&
        !_hasAutoOpenedFinancialDialog) {
      _hasAutoOpenedFinancialDialog = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showFinancialDialog(context, detail);
        }
      });
    }

    // Data for detailed card
    final type = detail?.appointmentType?.title ?? widget.appointment.appointmentType ?? "consultation";
    final dateVal = detail?.date ?? widget.appointment.date;
    final dateStr = dateVal != null ? DateTimeUtils.formatTimestampToDayDate(dateVal) : "N/A";

    final startTimeVal = detail?.startTime ?? widget.appointment.slot?.startTime;
    final endTimeVal = detail?.endTime ?? widget.appointment.slot?.endTime;
    final startTime = startTimeVal != null ? DateTimeUtils.formatTimestampToTime(startTimeVal) : "--:--";
    final endTime = endTimeVal != null ? DateTimeUtils.formatTimestampToTime(endTimeVal) : "--:--";
    final timeString = "$startTime - $endTime";

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: CustomAppBar(
        title: "Appointment Details",
        actions: [
          if (detail != null)
            IconButton(
              onPressed: () async {
                final encryptedText = await ref.read(appointmentProvider.notifier).encryptAppointmentData(detail);
                if (encryptedText != null) {
                  _showQrDialog(context: context, appointmentId: detail.id!, encryptedData: encryptedText);
                }
              },
              icon: Icon(Icons.qr_code_scanner_rounded, color: CustomColors.darkPurple, size: context.sp(24)),
            ),
        ],
      ),
      body: isLoading
          ? const AppLoader()
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(context.w(20), context.h(10), context.w(20), context.h(40)),
              child: Column(
                children: [
                  _buildCheckInCard(context, detail?.id, isPaymentPending, detail?.paymentType?.status),
                  SizedBox(height: context.h(20)),
                  StaggeredGrid.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: context.h(16),
                    crossAxisSpacing: context.w(16),
                    children: [
                      // 1. Detailed Appointment Info Card (Replaces Tile)
                      StaggeredGridTile.count(
                        crossAxisCellCount: 2,
                        mainAxisCellCount: 1.3,
                        child: _buildDetailedInfoCard(
                          context,
                          type: type,
                          dateStr: dateStr,
                          timeString: timeString,
                          key: detail?.appointmentKey ?? widget.appointment.appointmentKey ?? "N/A",
                          status: detail?.status ?? widget.appointment.status ?? "Confirmed",
                        ),
                      ),
                      
                      // 2. Financial Summary
                      StaggeredGridTile.count(
                        crossAxisCellCount: 1,
                        mainAxisCellCount: 1.3,
                        child: SummaryTile(
                          title: "Financial",
                          subtitle: "Total: \$${detail?.treatmentTotal?.toStringAsFixed(2) ?? '0.00'}",
                          trailing: _buildStatusBadge(detail?.paymentType?.status ?? (isPaymentPending ? 'pending' : 'paid')),
                          icon: Iconsax.wallet_money,
                          color: Colors.green,
                          gradient: CustomColors.greenGradient,
                          backgroundImage: PngAssets.masterLogo,
                          onTap: () => _showFinancialDialog(context, detail),
                        ),
                      ),

                      // 3. Clinic Details
                      StaggeredGridTile.count(
                        crossAxisCellCount: 1,
                        mainAxisCellCount: 1.3,
                        child: SummaryTile(
                          title: "Clinic",
                          subtitle: detail?.clinic?.name ?? widget.appointment.clinic?.clinicName ?? "View Details",
                          icon: Iconsax.hospital,
                          color: CustomColors.blueColor,
                          gradient: CustomColors.blueGradient,
                          backgroundImage: PngAssets.mapIcon,
                          onTap: () => _showClinicDialog(context, detail?.clinic ?? widget.appointment.clinic),
                        ),
                      ),

                      // 4. Doctor Details
                      StaggeredGridTile.count(
                        crossAxisCellCount: 1,
                        mainAxisCellCount: 1.3,
                        child: SummaryTile(
                          title: "Doctor",
                          subtitle: detail?.doctor?.name ?? widget.appointment.doctor?.doctorName ?? "View Details",
                          icon: Iconsax.user,
                          color: CustomColors.pinkColor,
                          gradient: CustomColors.pinkGradient,
                          backgroundImage: PngAssets.face,
                          onTap: () => _showDoctorDialog(context, detail?.doctor ?? widget.appointment.doctor),
                        ),
                      ),

                      // 5. Treatment Details
                      StaggeredGridTile.count(
                        crossAxisCellCount: 1,
                        mainAxisCellCount: 1.3,
                        child: SummaryTile(
                          title: "Treatments",
                          subtitle: "${detail?.treatments?.length ?? 0} Items",
                          icon: Iconsax.mask,
                          color: Colors.orange,
                          gradient: CustomColors.orangeGradient,
                          backgroundImage: PngAssets.syringe,
                          onTap: () => _showTreatmentDialog(context, detail?.treatments),
                        ),
                      ),

                      // 6. Simulations
                      if (detail?.simulations != null)
                        StaggeredGridTile.count(
                          crossAxisCellCount: 2,
                          mainAxisCellCount: 0.85,
                          child: SummaryTile(
                            title: "Simulations",
                            subtitle: "View Before & After Results",
                            icon: Iconsax.magicpen,
                            color: Colors.teal,
                            gradient: CustomColors.tealGradient,
                            backgroundImage: PngAssets.beforeAfter,
                            onTap: () => _showSimulationDialog(context, detail!.simulations!),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: context.h(40)),
                ],
              ),
            ),
    );
  }

  Widget _buildDetailedInfoCard(
    BuildContext context, {
    required String type,
    required String dateStr,
    required String timeString,
    required String key,
    required String status,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: CustomColors.purpleBlueGradient,
        borderRadius: BorderRadius.circular(context.r(28)),
        boxShadow: CustomColors.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(context.r(28)),
        child: Stack(
          children: [
            Positioned(
              right: -context.w(10),
              bottom: -context.h(10),
              child: Opacity(
                opacity: 0.12,
                child: Image.asset(
                  PngAssets.laserTreatment,
                  height: context.h(150),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(context.w(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.all(context.w(10)),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1.5),
                        ),
                        child: Icon(Iconsax.calendar_tick, color: Colors.black87, size: context.sp(22)),
                      ),
                      _buildStatusBadge(status),
                    ],
                  ),
                  const Spacer(),
                  Text("Appointment Info", style: CustomFonts.black18w600.copyWith(fontSize: context.sp(19))),
                  SizedBox(height: context.h(12)),
                  Row(
                    children: [
                      _buildInfoItem(context, Iconsax.key, key),
                      SizedBox(width: context.w(16)),
                      _buildInfoItem(context, Iconsax.tag, type.capitalize),
                    ],
                  ),
                  SizedBox(height: context.h(8)),
                  Row(
                    children: [
                      _buildInfoItem(context, Iconsax.calendar, dateStr),
                      SizedBox(width: context.w(16)),
                      _buildInfoItem(context, Iconsax.clock, timeString),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: context.sp(14), color: Colors.black54),
        SizedBox(width: context.w(6)),
        Text(
          value,
          style: CustomFonts.black12w600.copyWith(color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildCheckInCard(
    BuildContext context, 
    int? appointmentId, 
    bool isPaymentPending,
    String? paymentStatus,
  ) {
    final rawStatus = paymentStatus ?? (isPaymentPending ? "pending" : "paid");

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.r(32)),
        boxShadow: CustomColors.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(context.r(32)),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: CustomColors.checkInGradient,
                ),
              ),
            ),
            Positioned(
              right: -context.w(10),
              bottom: -context.h(10),
              child: Opacity(
                opacity: 0.12,
                child: Image.asset(
                  PngAssets.vector2,
                  height: context.h(120),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(context.w(24)),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text("Ready to Check-in?", style: CustomFonts.black18w600),
                            SizedBox(width: context.w(8)),
                            _buildStatusBadge(rawStatus),
                          ],
                        ),
                        SizedBox(height: context.h(6)),
                        Text(
                          isPaymentPending 
                            ? "Please complete payment to check-in."
                            : "Scan the clinic QR code to start.", 
                          style: CustomFonts.black14w400.copyWith(color: Colors.black87.withValues(alpha: 0.7))
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: context.w(8)),
                  CustomButton(
                    width: context.w(100),
                    height: context.h(44),
                    onPressed: isPaymentPending ? null : () => _handleScanCheckIn(context, appointmentId),
                    text: 'Scan',
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.w(10), vertical: context.h(4)),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(context.r(20)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: Colors.black87, fontSize: context.sp(9), fontWeight: FontWeight.bold),
      ),
    );
  }

  // Dialog Handlers
  void _showFinancialDialog(BuildContext context, dynamic detail) {
    showDialog(context: context, builder: (_) => FinancialSummaryDialog(detail: detail));
  }

  void _showClinicDialog(BuildContext context, dynamic clinic) {
    showDialog(context: context, builder: (_) => ClinicDetailsDialog(clinic: clinic));
  }

  void _showDoctorDialog(BuildContext context, dynamic doctor) {
    showDialog(context: context, builder: (_) => DoctorDetailsDialog(doctor: doctor));
  }

  void _showTreatmentDialog(BuildContext context, dynamic treatments) {
    showDialog(context: context, builder: (_) => TreatmentDetailsDialog(treatments: treatments));
  }

  void _showSimulationDialog(BuildContext context, dynamic simulations) {
    showDialog(context: context, builder: (_) => SimulationDetailsDialog(simulations: simulations));
  }

  Future<void> _handleScanCheckIn(BuildContext context, int? appointmentId) async {
    if (appointmentId == null) return;
    final data = await Navigator.push<String?>(context, MaterialPageRoute(builder: (_) => const QrScanScreen()));
    if (data == null) return;

    final response = await ref.read(appointmentProvider.notifier).decodeQrCode(data, appointmentId: appointmentId);
    if (response != null) {
      _showCheckInSuccessDialog(context, response.message);
    } else {
      EasyLoading.showError(ref.read(appointmentProvider).errorMessage ?? 'Check-in failed');
    }
  }
}
