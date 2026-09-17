import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import '../utils/string_utils.dart';
import '../utils/color_constant.dart';
import '../utils/custom_fonts.dart';

class TreatmentStep {
  final String title;
  final String description;
  final String date;
  final String imageAsset;
  final bool isCompleted;

  TreatmentStep({
    required this.title,
    required this.description,
    required this.date,
    required this.imageAsset,
    this.isCompleted = true,
  });
}

// Stepper Widget
class TreatmentRequestStepper extends StatelessWidget {
  final List<TreatmentStep> steps;

  const TreatmentRequestStepper({super.key, required this.steps});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: steps.length,
          itemBuilder: (context, index) {
            final isLast = index == steps.length - 1;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stepper indicator column
                Column(
                  children: [
                    Container(
                      width: context.w(27),
                      height: context.h(27),
                      decoration: BoxDecoration(
                        color: steps[index].isCompleted
                            ? CustomColors.purpleColor
                            : Colors.grey.shade300,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check,
                        size: context.w(14),
                        color: Colors.white,
                      ),
                    ),
                    if (!isLast)
                      Container(
                        height: context.h(148),
                        width: context.w(1),
                        color: Colors.grey.shade400,
                      ),
                  ],
                ),
                SizedBox(width: context.w(16)),
                // Content
                Expanded(
                  child: Column(
                    children: [
                      TreatmentCard(step: steps[index]),
                      if (!isLast) SizedBox(height: context.h(18)),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

// Treatment Card Widget
class TreatmentCard extends StatelessWidget {
  final TreatmentStep step;

  const TreatmentCard({super.key, required this.step});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CustomColors.lightBlueBackground,
        borderRadius: BorderRadius.circular(context.r(12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: context.w(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: context.h(14)),
                  Text(step.title.capitalize, style: CustomFonts.black18w600),
                  SizedBox(height: context.h(11)),
                  Text(step.description, style: CustomFonts.black16w400),
                  SizedBox(height: context.h(34)),
                  Text(step.date, style: CustomFonts.black16w500),
                  SizedBox(height: context.h(14)),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(context.w(6)),
            child: Container(
              height: context.h(144),
              width: context.w(122),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(context.r(12)),
                image: DecorationImage(
                  fit: BoxFit.fill,
                  image: AssetImage(step.imageAsset),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
