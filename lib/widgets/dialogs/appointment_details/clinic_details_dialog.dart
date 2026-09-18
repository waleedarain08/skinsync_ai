import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:iconsax/iconsax.dart';
import '../../../models/responses/appointments_list_response.dart';
import '../../../models/responses/chats_response.dart';
import '../../../screens/chat_screen.dart';
import '../../../utils/custom_fonts.dart';
import '../../../utils/color_constant.dart';
import '../../../utils/string_utils.dart';
import '../../../view_models/chat_view_model.dart';
import '../../custom_button.dart';

class ClinicDetailsDialog extends StatelessWidget {
  final AppointmentClinic? clinic;

  const ClinicDetailsDialog({super.key, this.clinic});

  @override
  Widget build(BuildContext context) {
    if (clinic == null) return const SizedBox.shrink();

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.r(32))),
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
                color: CustomColors.darkPurple.withValues(alpha: 0.1),
              ),
              child: Center(
                child: Icon(
                  Iconsax.hospital,
                  size: context.sp(32),
                  color: CustomColors.darkPurple,
                ),
              ),
            ),
            SizedBox(height: context.h(24)),
            Text("Clinic Details", style: CustomFonts.black20w600),
            SizedBox(height: context.h(24)),
            
            Row(
              children: [
                if (clinic!.logo != null && clinic!.logo!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(context.r(12)),
                    child: CachedNetworkImage(
                      imageUrl: clinic!.logo!,
                      height: context.w(50),
                      width: context.w(50),
                      fit: BoxFit.cover,
                    ),
                  ),
                if (clinic!.logo != null && clinic!.logo!.isNotEmpty) SizedBox(width: context.w(16)),
                Expanded(
                  child: Text(
                    clinic!.name?.capitalize ?? "N/A",
                    style: CustomFonts.black16w700,
                  ),
                ),
              ],
            ),
            SizedBox(height: context.h(20)),
            _buildRow("Email", clinic!.email ?? "N/A", Iconsax.sms),
            _buildRow("Phone", "${clinic!.cc ?? ''} ${clinic!.phone ?? 'N/A'}".trim(), Iconsax.call),
            _buildRow("Address", clinic!.address ?? "N/A", Iconsax.location),
            _buildRow("Country", clinic!.country ?? "N/A", Iconsax.global),
            
            SizedBox(height: context.h(28)),
            Consumer(
              builder: (context, ref, _) {
                return SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    onPressed: () {
                      Navigator.pop(context);
                      if (clinic?.id != null) {
                        ref.read(chatProvider.notifier).selectChat(
                          Chat(
                            id: clinic!.id,
                            clinicName: clinic!.name,
                          ),
                        );
                        Navigator.pushNamed(context, ChatScreen.routeName);
                      }
                    },
                    text: "Chat with Clinic",
                    backgroundColor: CustomColors.blackColor,
                    textColor: Colors.white,
                  ),
                );
              },
            ),
            SizedBox(height: context.h(12)),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                onPressed: () => Navigator.pop(context),
                text: "Close",
                isBorder: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18.sp, color: Colors.grey.shade400),
          SizedBox(width: 12.w),
          Text("$label:", style: CustomFonts.grey700_12w400),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: CustomFonts.black13w600,
            ),
          ),
        ],
      ),
    );
  }
}
