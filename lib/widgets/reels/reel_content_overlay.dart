import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../../utils/assets.dart';
import '../../utils/custom_fonts.dart';
import '../../utils/string_utils.dart';

class ReelContentOverlay extends StatefulWidget {
  final String userName;
  final String userProfileImage;
  final String? caption;
  final String? musicTitle;

  const ReelContentOverlay({
    super.key,
    required this.userName,
    required this.userProfileImage,
    this.caption,
    this.musicTitle,
  });

  @override
  State<ReelContentOverlay> createState() => _ReelContentOverlayState();
}

class _ReelContentOverlayState extends State<ReelContentOverlay> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: .symmetric(horizontal: 8.w, vertical: 6.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.r),
            color: Colors.white,
          ),
          child: Text(
            'Verified Provider',
            style: CustomFonts.blue10w700.copyWith(fontSize: 14.sp),
          ),
        ),
        SizedBox(height: context.w(10)),
        Row(
          children: [
            CircleAvatar(
              radius: context.r(18),
              backgroundImage: widget.userProfileImage != ''
                  ? NetworkImage(widget.userProfileImage)
                  : const AssetImage(PngAssets.splashLogo) as ImageProvider,
            ),
            SizedBox(width: context.w(10)),
            Text(widget.userName.capitalize, style: CustomFonts.white16w600),
          ],
        ),
        SizedBox(height: context.h(12)),
        if (widget.caption != null && widget.caption!.trim().isNotEmpty)
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: _buildCaption(context),
          ),
        SizedBox(height: context.h(8)),
        if (widget.musicTitle != null)
          Row(
            children: [
              Icon(
                Icons.music_note_rounded,
                size: context.sp(14),
                color: Colors.white,
              ),
              SizedBox(width: context.w(4)),
              Expanded(
                child: Text(
                  widget.musicTitle!,
                  style: CustomFonts.white12w400,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildCaption(BuildContext context) {
    final captionText = widget.caption!.trim();

    if (_isExpanded) {
      return Text(captionText, style: CustomFonts.white14w400);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final textSpan = TextSpan(
          text: captionText,
          style: CustomFonts.white14w400,
        );
        final tp = TextPainter(
          text: textSpan,
          maxLines: 2,
          textDirection: TextDirection.ltr,
        );
        tp.layout(maxWidth: constraints.maxWidth);

        if (tp.didExceedMaxLines) {
          return RichText(
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              text: captionText,
              style: CustomFonts.white14w400,
              children: [
                TextSpan(
                  text: ' ...more',
                  style: CustomFonts.white14w600.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          );
        }

        return Text(
          captionText,
          style: CustomFonts.white14w400,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }
}
