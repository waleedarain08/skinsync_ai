import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../models/requests/preferred_slot.dart';
import '../models/responses/availability_response.dart';
import '../utils/color_constant.dart';
import '../utils/custom_fonts.dart';
import '../utils/date_time_utils.dart';
import '../view_models/checkout_view_model.dart';
import '../view_models/doctor_view_model.dart';
import '../view_models/treatment_requests_view_model.dart';
import '../widgets/bottom_sheets/before_you_book_bottomsheet.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_button.dart';
import 'treatment_review_screen.dart';

class SelectDateTimeScreen extends ConsumerStatefulWidget {
  static const routeName = '/select_date_time_screen';
  const SelectDateTimeScreen({super.key});

  @override
  ConsumerState<SelectDateTimeScreen> createState() =>
      _SelectDateTimeScreenState();
}

class _SelectDateTimeScreenState extends ConsumerState<SelectDateTimeScreen> {
  DateTime? _selectedDate;
  Slot? _selectedSlot;

  String _formatTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  String _slotLabel(Slot slot) =>
      '${_formatTime(slot.startTime)} - ${_formatTime(slot.endTime)}';

  List<PreferredSlot> _buildPreferredSlots() {
    return [
      PreferredSlot(
        date: _selectedDate!.secondsSinceEpoch,
        time: _selectedSlot!.startTime.secondsSinceEpoch,
      ),
    ];
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: CustomColors.pinkColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: CustomColors.pinkColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _selectedSlot = null; // clear stale selection from a previous date
      });

      await ref
          .read(doctorProvider.notifier)
          .getPractitionerAvailability(date: picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final slots = ref.watch(doctorProvider).availabilityResponse?.slots ?? [];
    final bool canContinue = _selectedDate != null && _selectedSlot != null;

    return Scaffold(
      backgroundColor: CustomColors.whiteColor,
      appBar: const CustomAppBar(showTitle: true, title: "Select Date & Time"),
      body: Container(
        decoration: const BoxDecoration(
          gradient: CustomColors.whiteBlueGradient,
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: context.w(24),
                  vertical: context.h(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Select Booking Date", style: CustomFonts.black18w600),
                    SizedBox(height: context.h(12)),

                    // Beautiful Calendar picker trigger field
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.w(18),
                          vertical: context.h(16),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(context.r(16)),
                          border: Border.all(
                            color: _selectedDate != null
                                ? CustomColors.pinkColor
                                : Colors.grey.shade200,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_month_rounded,
                              color: _selectedDate != null
                                  ? CustomColors.pinkColor
                                  : Colors.grey,
                            ),
                            SizedBox(width: context.w(14)),
                            Expanded(
                              child: Text(
                                _selectedDate != null
                                    ? _selectedDate!.formattedDayDate
                                    : "Choose a consultation date",
                                style: _selectedDate != null
                                    ? CustomFonts.black14w600
                                    : CustomFonts.grey14w400,
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: context.sp(14),
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: context.h(32)),

                    Text(
                      "Available Time Slots",
                      style: CustomFonts.black18w600,
                    ),
                    SizedBox(height: context.h(6)),
                    Text(
                      "Select an available 2-hour consultation slot below:",
                      style: CustomFonts.grey12w400,
                    ),
                    SizedBox(height: context.h(16)),

                    if (_selectedDate == null)
                      Text(
                        "Pick a date to see available slots.",
                        style: CustomFonts.grey12w400,
                      )
                    else if (slots.isEmpty)
                      Text(
                        "No slots available for this date.",
                        style: CustomFonts.grey12w400,
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: slots.length,
                        itemBuilder: (context, index) {
                          final slot = slots[index];
                          final isSelected = _selectedSlot == slot;
                          final isBooked = slot.isBooked;

                          return GestureDetector(
                            onTap: isBooked
                                ? null
                                : () {
                                    setState(() {
                                      _selectedSlot = slot;
                                    });
                                  },
                            child: Opacity(
                              opacity: isBooked ? 0.4 : 1,
                              child: Container(
                                margin: EdgeInsets.only(bottom: context.h(12)),
                                padding: EdgeInsets.symmetric(
                                  horizontal: context.w(18),
                                  vertical: context.h(16),
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? CustomColors.purpleColor.withValues(
                                          alpha: 0.08,
                                        )
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(
                                    context.r(16),
                                  ),
                                  border: Border.all(
                                    color: isSelected
                                        ? CustomColors.purpleColor
                                        : Colors.grey.shade100,
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.02,
                                      ),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.access_time_filled_rounded,
                                      color: isSelected
                                          ? CustomColors.purpleColor
                                          : Colors.grey.shade400,
                                      size: context.sp(18),
                                    ),
                                    SizedBox(width: context.w(14)),
                                    Text(
                                      _slotLabel(slot),
                                      style: isSelected
                                          ? CustomFonts.darkPurple12w600
                                              .copyWith(
                                                fontSize: context.sp(14),
                                              )
                                          : CustomFonts.black14w600.copyWith(
                                              color: Colors.grey.shade800,
                                            ),
                                    ),
                                    if (isBooked) ...[
                                      SizedBox(width: context.w(8)),
                                      Text(
                                        '(Booked)',
                                        style: CustomFonts.grey12w400,
                                      ),
                                    ],
                                    const Spacer(),
                                    Container(
                                      height: context.w(20),
                                      width: context.w(20),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isSelected
                                              ? CustomColors.purpleColor
                                              : Colors.grey.shade300,
                                          width: 2,
                                        ),
                                        color: isSelected
                                            ? CustomColors.purpleColor
                                            : Colors.transparent,
                                      ),
                                      child: isSelected
                                          ? Center(
                                              child: Icon(
                                                Icons.check,
                                                size: context.sp(12),
                                                color: Colors.white,
                                              ),
                                            )
                                          : null,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),

            // Continuous Button to Review Checkout Screen
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.w(24),
                vertical: context.h(20),
              ),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(context.r(24)),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 15,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: CustomButton(
                text: "Continue",
                borderRadius: context.r(26),
                onPressed: canContinue
                    ? () {
                        // Save Selected parameters to checkout ViewModel
                        ref
                            .read(checkoutViewModel.notifier)
                            .setSelectedDate(_selectedDate!);
                        ref
                            .read(checkoutViewModel.notifier)
                            .setSelectedSlot(_slotLabel(_selectedSlot!));
                        final clinic = ref
                            .read(checkoutViewModel)
                            .selectedClinic;
                        final simulations = ref
                            .read(treatmentRequestsProvider)
                            .simulations;
                        final slots = _buildPreferredSlots();

                        if (!ref.read(checkoutViewModel).isInviteClinic) {
                          Navigator.pushNamed(
                            context,
                            TreatmentReviewScreen.routeName,
                            arguments: {
                              'simulationData': simulations,
                              'preferredSlots': slots,
                              'clinic': clinic,
                            },
                          );
                        } else {
                          BeforeYouBookBottomSheet.show(
                            context,
                            onConfirm: () {
                              Navigator.pushNamed(
                                context,
                                TreatmentReviewScreen.routeName,
                                arguments: {
                                  'simulationData': simulations,
                                  'preferredSlots': slots,
                                  'clinic': clinic,
                                },
                              );
                            },
                          );
                        }
                      }
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}