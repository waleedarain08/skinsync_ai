import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../utils/assets.dart';
import '../utils/color_constant.dart';
import '../utils/custom_fonts.dart';
import '../widgets/custom_button.dart';
import '../widgets/treatment_request_stepper.dart';
import 'bottom_nav_page.dart';

final selectedFilterProvider = StateProvider<int?>((ref) => 0);

class ProgressDetailScreen extends ConsumerWidget {
  const ProgressDetailScreen({super.key});
  static const String routeName = '/progress_detail_screen';

  final List<FilterModel> filter = const [
    FilterModel(assetIcon: PngAssets.syringe, name: "Sessions"),
    FilterModel(assetIcon: PngAssets.beforeAfter, name: "Skin Comparision"),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      extendBody: true,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              alignment: Alignment.topLeft,
              height: context.h(293),
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(DummyAssets.treatmentimage),
                  fit: BoxFit.cover,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.w(30),
                  vertical: context.h(55),
                ),
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: EdgeInsets.all(context.w(8)),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.withValues(alpha: 0.7),
                    ),
                    child: Icon(
                      CupertinoIcons.arrow_left,
                      size: context.sp(20),
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: context.h(15)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: context.w(30)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Derma Fillers - Cheeks",
                    style: CustomFonts.black30w600,
                  ),
                  SizedBox(height: context.h(2)),
                  Text("Glow Skin Clinic", style: CustomFonts.black18w400),

                  SizedBox(height: context.h(14)),

                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.w(18),
                      vertical: context.h(11),
                    ),
                    decoration: BoxDecoration(
                      color: CustomColors.lightBlueColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(context.r(10)),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: context.r(59), // radius * 2
                          height: context.r(59), // radius * 2
                          child: CircularPercentIndicator(
                            radius: context.r(29.5),
                            lineWidth: context.w(6.7),
                            animation: true,
                            percent: 0.72,
                            center: Text("72%", style: CustomFonts.black16w600),
                            circularStrokeCap: CircularStrokeCap.round,
                            progressColor: const Color(0xffEEA1F0),
                            backgroundColor: Colors.white,
                          ),
                        ),
                        SizedBox(width: context.w(16)),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Progress Complete!",
                              style: CustomFonts.black22w600,
                            ),
                            SizedBox(height: context.w(9)),
                            Text(
                              "Almost there! Keep going!",
                              style: CustomFonts.black16w400,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: context.h(14)),
                  Text(
                    "Enhance your natural beauty by adding volume, smoothing wrinkles, and contouring areas like cheeks, lips, and under-eyes for a youthful, refreshed look.",
                    style: CustomFonts.black16w400,
                  ),
                  SizedBox(height: context.h(29)),
                  Divider(color: Colors.grey.shade300, height: 0),
                  SizedBox(height: context.h(22)),
                  Row(
                    children: List.generate(filter.length, (index) {
                      final selectedIndex = ref.watch(selectedFilterProvider);
                      final isSelected = selectedIndex == index;
                      return Padding(
                        padding: EdgeInsets.only(right: context.w(10)),
                        child: GestureDetector(
                          onTap: () {
                            ref.read(selectedFilterProvider.notifier).state =
                                index;
                          },
                          child: Chip(
                            side: const BorderSide(color: Colors.transparent),
                            backgroundColor: isSelected
                                ? Colors.black
                                : Colors.grey.shade100,
                            label: Row(
                              children: [
                                Image.asset(
                                  filter[index].assetIcon,
                                  height: context.h(16),
                                  width: context.w(16),
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black,
                                ),
                                SizedBox(width: context.w(7)),
                                Text(
                                  filter[index].name,
                                  style: isSelected
                                      ? CustomFonts.white18w500
                                      : CustomFonts.black18w500,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: context.h(20)),
                  Text(
                    "Your Treatment Journey",
                    style: CustomFonts.black22w600,
                  ),
                  SizedBox(height: context.h(20)),

                  TreatmentRequestStepper(steps: _getTreatmentSteps()),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: EdgeInsets.only(
          bottom: MediaQuery.paddingOf(context).bottom + context.h(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // 👈 add this
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: context.h(20),
                left: context.w(30),
                right: context.w(30),
              ),
              child: SizedBox(
                width: double.infinity,
                child: CustomButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      BottomNavPage.routeName,
                      (_) => false,
                    );
                  },
                  text: "Post a Review",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

List<TreatmentStep> _getTreatmentSteps() {
  return [
    TreatmentStep(
      title: "Botox Treatment",
      description:
          "Mild swelling or redness is normal. Follow aftercare tips for best results.",
      date: "02 Feb 2025",
      imageAsset: DummyAssets.treatmentimage,
      isCompleted: true,
    ),
    TreatmentStep(
      title: "Botox Treatment",
      description:
          "Mild swelling or redness is normal. Follow aftercare tips for best results.",
      date: "02 Feb 2025",
      imageAsset: DummyAssets.treatmentimage,
      isCompleted: true,
    ),
    TreatmentStep(
      title: "Botox Treatment",
      description:
          "Mild swelling or redness is normal. Follow aftercare tips for best results.",
      date: "02 Feb 2025",
      imageAsset: DummyAssets.treatmentimage,
      isCompleted: true,
    ),
    TreatmentStep(
      title: "Botox Treatment",
      description:
          "Mild swelling or redness is normal. Follow aftercare tips for best results.",
      date: "02 Feb 2025",
      imageAsset: DummyAssets.treatmentimage,
      isCompleted: true,
    ),
  ];
}

class FilterModel {
  final String assetIcon;
  final String name;

  const FilterModel({required this.assetIcon, required this.name});
}
