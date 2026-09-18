import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../models/responses/simulation_history_response.dart';
import '../utils/assets.dart';
import '../utils/color_constant.dart';
import '../utils/custom_fonts.dart';
import 'app_network_image.dart';

class SimulationTreatmentAreaChip extends StatelessWidget {
  final String? icon;
  final String label;
  final bool isTreatment;
  final String? imageUrl;
  final List<SimulationMaterial>? materials;
  final VoidCallback? onTap;

  const SimulationTreatmentAreaChip({
    super.key,
    this.icon,
    required this.label,
    this.isTreatment = false,
    this.imageUrl,
    this.materials,
    this.onTap,
  });

  Widget _buildIcon(BuildContext context) {
    final size = context.w(32);

    final hasIcon = icon != null && icon!.isNotEmpty && icon != "";

    if (!hasIcon) {
      return Image.asset(
        PngAssets.splashLogo,
        width: size,
        height: size,
        fit: BoxFit.contain,
      );
    }

    final isNetwork =
        icon!.startsWith('http://') || icon!.startsWith('https://');

    if (isNetwork) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(context.r(8)),
        child: AppNetworkImage(
          imageUrl: icon!,
          width: size,
          height: size,
          fit: BoxFit.contain,
          borderRadius: BorderRadius.circular(context.r(8)),
          errorIcon: Icons.broken_image,
        ),
      );
    }

    return Image.asset(
      icon!,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => Image.asset(
        PngAssets.splashLogo,
        width: size,
        height: size,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget? _buildTrailing(BuildContext context) {
    if (isTreatment) {
      return Icon(
        Icons.info_outline_rounded,
        size: context.sp(18),
        color: CustomColors.darkPurple,
      );
    }

    return null;
  }

  Widget _buildMaterials(BuildContext context) {
    final selectedMaterials = (materials ?? [])
        .where((material) => (material.selectedQuantity ?? 0) > 0)
        .toList();

    if (selectedMaterials.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.only(top: context.h(2)),
      child: Wrap(
        spacing: context.w(4),
        runSpacing: context.h(3),
        children: selectedMaterials.map((material) {
          return Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.w(7),
              vertical: context.h(3),
            ),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(context.r(6)),
            ),
            child: Text(
              '${material.name ?? "Material"} × ${material.selectedQuantity ?? 0}',
              style: CustomFonts.black12w500.copyWith(
                color: Colors.white,
                fontSize: context.sp(11),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final trailing = _buildTrailing(context);
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    final selectedMaterials = (materials ?? [])
        .where((material) => (material.selectedQuantity ?? 0) > 0)
        .toList();

    final hasMaterials = selectedMaterials.isNotEmpty;

    return InkWell(
      onTap: isTreatment ? onTap : null,
      borderRadius: BorderRadius.circular(context.r(20)),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.w(20),
          vertical: context.h(12),
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(context.r(24)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(context.r(10)),
          child: Stack(
            children: [
              // Background image
              if (hasImage)
                Positioned.fill(
                  child: AppNetworkImage(
                    imageUrl: imageUrl!,
                    fit: BoxFit.cover,
                    placeholderColor: Colors.transparent,
                  ),
                ),

              // Overlay
              Positioned.fill(
                child: Container(
                  color: hasImage
                      ? Colors.white.withValues(alpha: 0.8)
                      : CustomColors.greyColor.withValues(alpha: 0.3),
                ),
              ),

              // Content
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.w(12),
                  vertical: context.h(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildIcon(context),

                    SizedBox(width: context.w(12)),

                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              label,
                              style: CustomFonts.black16w500,
                              overflow: TextOverflow.ellipsis,
                            ),

                            if (trailing != null) ...[
                              SizedBox(width: context.w(6)),
                              trailing,
                            ],
                          ],
                        ),

                        if (!isTreatment && hasMaterials)
                          _buildMaterials(context),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
