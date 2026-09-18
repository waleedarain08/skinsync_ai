import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:iconsax/iconsax.dart';

import '../screens/chat_list_screen.dart';
import '../utils/color_constant.dart';

class ChatButton extends StatelessWidget {
  const ChatButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(ChatListScreen.routeName);
      },
      child: Container(
        padding: EdgeInsets.all(context.r(10)),
        decoration: BoxDecoration(
          gradient: CustomColors.purpleBlueGradient,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(context.r(26)),
            topRight: Radius.circular(context.r(26)),
            bottomLeft: Radius.circular(context.r(6)),
            bottomRight: Radius.circular(context.r(26)),
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
        child: Icon(
          Iconsax.message_text_1,
          color: CustomColors.blackColor,
          size: context.sp(30),
        ),
      ),
    );
  }
}
