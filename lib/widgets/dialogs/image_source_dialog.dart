import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:image_picker/image_picker.dart';

import '../../utils/color_constant.dart';
import '../../utils/custom_fonts.dart';

Future<ImageSource?> showImageSourceDialog(
  BuildContext context, {
  String title = 'Select Image Source',
  bool showGallery = true,
}) async {
  return await showModalBottomSheet<ImageSource>(
    context: context,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(context.r(24)),
      ),
    ),
    constraints: BoxConstraints(minWidth: 1.sw),
    builder: (BuildContext dialogContext) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: dialogContext.h(16)),
            Container(
              width: dialogContext.w(40),
              height: dialogContext.h(4),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: dialogContext.h(14)),
            Text(title, style: CustomFonts.black16w600),
            SizedBox(height: dialogContext.h(12)),
            const Divider(height: 1, color: CustomColors.greyColor),
            if (showGallery) ...[
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(dialogContext.w(8)),
                  decoration: BoxDecoration(
                    color: CustomColors.purpleColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.photo_library_outlined,
                    color: CustomColors.darkPurple,
                  ),
                ),
                title: Text(
                  'Choose from Gallery',
                  style: CustomFonts.black14w600,
                ),
                onTap: () =>
                    Navigator.pop(dialogContext, ImageSource.gallery),
              ),
              const Divider(height: 1, color: CustomColors.greyColor),
            ],
            ListTile(
              leading: Container(
                padding: EdgeInsets.all(dialogContext.w(8)),
                decoration: BoxDecoration(
                  color: CustomColors.purpleColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.photo_camera_outlined,
                  color: CustomColors.darkPurple,
                ),
              ),
              title: Text('Take a Photo', style: CustomFonts.black14w600),
              onTap: () => Navigator.pop(dialogContext, ImageSource.camera),
            ),
            SizedBox(height: dialogContext.h(16)),
          ],
        ),
      );
    },
  );
}
