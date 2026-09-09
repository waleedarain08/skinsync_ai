import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:iconsax/iconsax.dart';

import '../../screens/subscription_plans_screen.dart';
import '../../utils/color_constant.dart';
import '../../utils/custom_fonts.dart';
import '../custom_button.dart';

void showUpgradePlanDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext dialogContext) {
      return Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.r(24)),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.w(24),
            vertical: context.h(32),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: context.w(72),
                width: context.w(72),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: CustomColors.lightPurpleColor.withValues(alpha: 0.1),
                ),
                child: Center(
                  child: Icon(
                    Iconsax.crown,
                    size: context.sp(32),
                    color: CustomColors.purpleColor,
                  ),
                ),
              ),
              SizedBox(height: context.h(24)),
              Text(
                "Limit Reached!",
                textAlign: TextAlign.center,
                style: CustomFonts.black20w600,
              ),
              SizedBox(height: context.h(12)),
              Text(
                "You have reached your simulation limit. Please upgrade your plan to continue generating AI images and exploring more features.",
                textAlign: TextAlign.center,
                style: CustomFonts.textGrey14w400,
              ),
              SizedBox(height: context.h(28)),
              CustomButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  Navigator.pushNamed(
                    context,
                    SubscriptionPlansScreen.routeName,
                  );
                },
                text: "Upgrade Plan",
              ),
              SizedBox(height: context.h(15)),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: "Cancel",
                  isBorder: true,
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
