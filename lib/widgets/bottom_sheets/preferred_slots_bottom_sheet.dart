import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:iconsax/iconsax.dart';

import '../../models/requests/preferred_slot.dart';
import '../../utils/color_constant.dart';
import '../../utils/custom_fonts.dart';
import '../../utils/date_time_utils.dart';
import '../custom_button.dart';

class PreferredSlotsBottomSheet extends StatefulWidget {
  final Function(List<PreferredSlot>) onConfirm;

  const PreferredSlotsBottomSheet({super.key, required this.onConfirm});

  static void show({
    required BuildContext context,
    required Function(List<PreferredSlot>) onConfirm,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      constraints: .new(minWidth: 1.sw),
      backgroundColor: Colors.transparent,
      builder: (context) => PreferredSlotsBottomSheet(onConfirm: onConfirm),
    );
  }

  @override
  State<PreferredSlotsBottomSheet> createState() =>
      _PreferredSlotsBottomSheetState();
}

class _PreferredSlotsBottomSheetState extends State<PreferredSlotsBottomSheet> {
  final List<DateTime?> _selectedDates = [null, null, null];
  final List<TimeOfDay?> _selectedTimes = [null, null, null];

  Future<void> _selectDate(int index) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDates[index] ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: CustomColors.purpleColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDates[index] = picked;
      });
    }
  }

  Future<void> _selectTime(int index) async {
    TimeOfDay selectedTime = _selectedTimes[index] ?? TimeOfDay.now();

    Duration selectedDuration = Duration(
      hours: selectedTime.hour,
      minutes: selectedTime.minute,
    );

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(context.r(20)),
          ),
          content: SizedBox(
            width: context.w(320),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    context.w(20),
                    context.h(20),
                    context.w(20),
                    context.h(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Select Time", style: CustomFonts.black18w600),
                      GestureDetector(
                        onTap: () => Navigator.pop(dialogContext),
                        child: const Icon(
                          Iconsax.close_circle,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  height: 216,
                  child: CupertinoTimerPicker(
                    mode: CupertinoTimerPickerMode.hm,
                    initialTimerDuration: selectedDuration,
                    onTimerDurationChanged: (Duration newDuration) {
                      selectedDuration = newDuration;
                    },
                  ),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(
                    context.w(20),
                    context.h(8),
                    context.w(20),
                    context.h(20),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: "Done",
                      onPressed: () {
                        Navigator.pop(dialogContext);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    setState(() {
      _selectedTimes[index] = TimeOfDay(
        hour: selectedDuration.inHours % 24,
        minute: selectedDuration.inMinutes.remainder(60),
      );
    });
  }

  bool get _canConfirm {
    for (int i = 0; i < 3; i++) {
      if ((_selectedDates[i] != null && _selectedTimes[i] == null) ||
          (_selectedDates[i] == null && _selectedTimes[i] != null)) {
        return false;
      }
    }
    return true;
  }

  bool get _hasAnySelection {
    for (int i = 0; i < 3; i++) {
      if (_selectedDates[i] != null || _selectedTimes[i] != null) {
        return true;
      }
    }
    return false;
  }

  String? _formattedTime(int index) {
    final TimeOfDay? time = _selectedTimes[index];
    if (time == null) return null;
    return DateTime(0, 0, 0, time.hour, time.minute).formattedTime24;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.r(32)),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        context.w(24),
        context.h(16),
        context.w(24),
        context.h(32) + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: context.w(44),
              height: context.h(5),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(context.r(100)),
              ),
            ),
          ),
          SizedBox(height: context.h(24)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Preferred Appointment Slots",
                style: CustomFonts.black20w600,
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Iconsax.close_circle, color: Colors.grey),
              ),
            ],
          ),
          SizedBox(height: context.h(12)),
          Text(
            "You can select up to 3 preferred dates and times for your appointment (Optional).",
            style: CustomFonts.grey14w400,
          ),
          SizedBox(height: context.h(24)),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                children: List.generate(3, (index) {
                  return Container(
                    margin: EdgeInsets.only(bottom: context.h(20)),
                    padding: EdgeInsets.all(context.w(16)),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(context.r(20)),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(context.w(8)),
                              decoration: BoxDecoration(
                                color: CustomColors.purpleColor.withValues(
                                  alpha: 0.1,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                "${index + 1}",
                                style: CustomFonts.black14w600.copyWith(
                                  color: CustomColors.purpleColor,
                                ),
                              ),
                            ),
                            SizedBox(width: context.w(12)),
                            Text(
                              "Option ${index + 1}",
                              style: CustomFonts.black16w600,
                            ),
                          ],
                        ),
                        SizedBox(height: context.h(16)),
                        Row(
                          children: [
                            Expanded(
                              child: _buildPickerButton(
                                icon: Iconsax.calendar,
                                label:
                                    _selectedDates[index]?.formattedDate ??
                                    "Select Date",
                                isSelected: _selectedDates[index] != null,
                                onTap: () => _selectDate(index),
                              ),
                            ),
                            SizedBox(width: context.w(12)),
                            Expanded(
                              child: _buildPickerButton(
                                icon: Iconsax.clock,
                                label: _formattedTime(index) ?? "Select Time",
                                isSelected: _selectedTimes[index] != null,
                                onTap: () => _selectTime(index),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ),
          SizedBox(height: context.h(12)),
          CustomButton(
            text: _hasAnySelection ? "Continue" : "Skip",
            onPressed: _canConfirm
                ? () {
                    final List<PreferredSlot> slots = [];
                    for (int i = 0; i < 3; i++) {
                      if (_selectedDates[i] != null &&
                          _selectedTimes[i] != null) {
                        final selectedDate = _selectedDates[i]!;
                        final selectedTime = _selectedTimes[i]!;
                        final selectedDateTime = DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          selectedDate.day,
                          selectedTime.hour,
                          selectedTime.minute,
                        );
                        slots.add(
                          PreferredSlot(
                            date: selectedDate.secondsSinceEpoch,
                            time: selectedDateTime.secondsSinceEpoch,
                          ),
                        );
                      }
                    }
                    Navigator.pop(context);
                    widget.onConfirm(slots);
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildPickerButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(context.r(12)),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.w(12),
          vertical: context.h(12),
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: isSelected ? CustomColors.purpleColor : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(context.r(12)),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? CustomColors.purpleColor : Colors.grey,
            ),
            SizedBox(width: context.w(8)),
            Expanded(
              child: Text(
                label,
                style: isSelected
                    ? CustomFonts.black12w600
                    : CustomFonts.grey12w400,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}