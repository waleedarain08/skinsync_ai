import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../screens/help_chat_screen.dart';
import '../utils/assets.dart';
import '../utils/color_constant.dart';

class HelpChatButton extends StatelessWidget {
  const HelpChatButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(HelpChatScreen.routeName);
      },
      child: Container(
        padding: EdgeInsets.all(context.r(10)),
        decoration: BoxDecoration(
          gradient: CustomColors.purpleBlueGradient,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(context.r(26)),
            topRight: Radius.circular(context.r(26)),
            bottomLeft: Radius.circular(context.r(26)),
            bottomRight: Radius.circular(context.r(6)),
          ),
          boxShadow: [
            // Outer glow
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 16,
              spreadRadius: 3,
            ),
            // Soft white diffuse glow
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.15),
              blurRadius: 20,
              spreadRadius: 6,
            ),
          ],
        ),
        child: Image.asset(
          PngAssets.splashLogo,
          width: context.sp(32),
          height: context.sp(32),
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
