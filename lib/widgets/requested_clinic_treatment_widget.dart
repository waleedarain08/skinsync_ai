import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:iconsax/iconsax.dart';

import '../models/responses/auth_response.dart';
import '../models/responses/chats_response.dart';
import '../screens/chat_screen.dart';
import '../utils/color_constant.dart';
import '../view_models/chat_view_model.dart';
import 'app_network_image.dart';

class RequestClinicTreatmentCard extends StatelessWidget {
  final RequestClinicTreatmentModel data;
  final VoidCallback? onTap;

  const RequestClinicTreatmentCard({super.key, required this.data, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final patientName = data.clinicName ?? '';
    final address = data.address ?? '';
    final patientEmail = data.clinicEmail ?? '';
    final chatId = data.chatId;

    return Container(
      width: MediaQuery.of(context).size.width * 0.78,
      margin: const EdgeInsets.only(bottom: 20, top: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: CustomColors.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.white,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  // Patient Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: SizedBox(
                      height: 52,
                      width: 52,
                      child: data.image != null && data.image!.isNotEmpty
                          ? AppNetworkImage(
                              imageUrl: data.image!,
                              width: 52,
                              height: 52,
                              fit: BoxFit.cover,
                              borderRadius: BorderRadius.circular(14),
                              errorIcon: Iconsax.user,
                            )
                          : Container(
                              color: theme.primaryColor.withValues(alpha: 0.08),
                              child: Icon(
                                Iconsax.user,
                                size: 25,
                                color: theme.primaryColor,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  // Patient Information
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Patient Name
                        Text(
                          patientName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            // Explicit dark color — this was unset before and
                            // was inheriting a near-white color, making the
                            // clinic name invisible against the card.
                            color: Colors.black87,
                          ),
                        ),

                        // Email
                        if (patientEmail.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Iconsax.sms,
                                size: 14,
                                color: Colors.grey.shade500,
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  patientEmail,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (address.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Iconsax.location,
                                size: 13,
                                color: Colors.grey.shade500,
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  address,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        // Treatment Count
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Iconsax.health,
                              size: 14,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Total Request: ${data.totalTreatmentCount ?? 0} ',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Arrow
                  if (chatId == null)
                    Icon(
                      Iconsax.arrow_right_3,
                      size: 18,
                      color: Colors.grey.shade400,
                    )
                  else
                    Consumer(
                      builder: (_, ref, _) {
                        return GestureDetector(
                          onTap: () {
                            ref
                                .read(chatProvider.notifier)
                                .selectChat(Chat(id: chatId));
                            Navigator.pushNamed(context, ChatScreen.routeName);
                          },
                          child: Container(
                            padding: EdgeInsets.all(context.r(10)),
                            decoration: BoxDecoration(
                              gradient: CustomColors.purpleBlueGradient,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  blurRadius: 12,
                                  spreadRadius: 1,
                                  offset: const Offset(0, 4),
                                ),
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  blurRadius: 16,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(
                              Iconsax.message_text_1,
                              color: CustomColors.blackColor,
                              size: context.sp(18),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
