import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../models/responses/chats_response.dart';
import '../utils/color_constant.dart';
import '../utils/custom_fonts.dart';
import '../utils/date_time_utils.dart';
import '../utils/string_utils.dart';
import '../view_models/chat_view_model.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_search_field.dart';
import 'chat_screen.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  static const String routeName = '/chat-list-screen';

  final bool showBackButton;

  const ChatListScreen({super.key, this.showBackButton = true});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatProvider.notifier).loadChats();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.whiteColor,
      appBar: CustomAppBar(
        showBackButton: widget.showBackButton,
        showTitle: true,
        title: "Messages",
      ),
      body: Column(
        children: [
          SizedBox(height: context.h(10)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.w(24)),
            child: CustomSearchField(
              controller: _searchController,
              hintText: "Search clinics or messages...",
              onChanged: (query) {
                _timer?.cancel();
                _timer = Timer(const Duration(milliseconds: 300), () {
                  ref.read(chatProvider.notifier).loadChats(query: query);
                });
              },
            ),
          ),
          SizedBox(height: context.h(16)),
          Expanded(
            child: Consumer(
              builder: (_, ref, _) {
                final chats = ref.watch(
                  chatProvider.select((s) => s.chatsData?.items),
                );
                if (chats?.isEmpty ?? true) {
                  return _buildEmptyState(context);
                }
                return ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.w(24),
                    vertical: context.h(8),
                  ),
                  physics: const BouncingScrollPhysics(),
                  itemCount: chats!.length,
                  itemBuilder: (context, index) {
                    final item = chats[index];
                    return _buildChatCard(context, item);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: context.w(40)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.mark_chat_read_outlined,
              size: context.sp(64),
              color: Colors.grey.shade300,
            ),
            SizedBox(height: context.h(16)),
            Text("No Conversations Found", style: CustomFonts.grey800_20w600),
            SizedBox(height: context.h(6)),
            Text(
              "Try searching for a different keyword or check back later.",
              textAlign: TextAlign.center,
              style: CustomFonts.textGrey14w400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatCard(BuildContext context, Chat item) {
    return Container(
      margin: EdgeInsets.only(bottom: context.h(12)),
      decoration: BoxDecoration(
        color: CustomColors.whiteColor,
        borderRadius: BorderRadius.circular(context.r(20)),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
        boxShadow: CustomColors.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(context.r(20)),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              ref.read(chatProvider.notifier).selectChat(item);
              Navigator.of(
                context,
              ).pushNamed(ChatScreen.routeName, arguments: true);
            },
            child: Padding(
              padding: EdgeInsets.all(context.w(16)),
              child: Row(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: context.w(48),
                        height: context.w(48),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: CustomColors.purpleColor.withValues(
                            alpha: 0.1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            item.clinicName?.firstOrNull ?? 'C',
                            style: TextStyle(
                              fontSize: context.sp(18),
                              fontWeight: FontWeight.bold,
                              color: CustomColors.purpleColor,
                              fontFamily: 'Degular',
                            ),
                          ),
                        ),
                      ),
                      if (item.isOnline)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: context.w(14),
                            height: context.w(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: CustomColors.whiteColor,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(width: context.w(14)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                item.clinicName ?? 'N/A',
                                style: CustomFonts.black16w600,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: context.w(8)),
                            Text(
                              item.time?.formattedDateTime ?? 'N/A',
                              style: item.unreadCount > 0
                                  ? CustomFonts.black12w600.copyWith(
                                      color: CustomColors.purpleColor,
                                    )
                                  : CustomFonts.grey12w400,
                            ),
                          ],
                        ),
                        SizedBox(height: context.h(4)),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.lastMessage ?? '',
                                style: item.unreadCount > 0
                                    ? CustomFonts.black14w600
                                    : CustomFonts.grey14w400,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (item.unreadCount > 0) ...[
                              SizedBox(width: context.w(8)),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: context.w(8),
                                  vertical: context.h(2),
                                ),
                                decoration: BoxDecoration(
                                  color: CustomColors.purpleColor,
                                  borderRadius: BorderRadius.circular(
                                    context.r(10),
                                  ),
                                ),
                                child: Text(
                                  '${item.unreadCount}',
                                  style: CustomFonts.white10w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: context.w(6)),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.grey.shade400,
                    size: context.sp(22),
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
