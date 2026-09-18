import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../models/help_chat_model.dart';
import '../utils/assets.dart';
import '../utils/color_constant.dart';
import '../utils/custom_fonts.dart';
import '../view_models/help_chat_view_model.dart';
import '../widgets/custom_app_bar.dart';

class HelpChatScreen extends ConsumerStatefulWidget {
  static const String routeName = 'HelpChatScreen';
  
  const HelpChatScreen({super.key});

  @override
  ConsumerState<HelpChatScreen> createState() => _HelpChatScreenState();
}

class _HelpChatScreenState extends ConsumerState<HelpChatScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(helpChatViewModelProvider.notifier).startConversation();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(helpChatViewModelProvider);

    // Auto scroll when messages change
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: CustomAppBar(
        title: "AI Assistant",
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: CustomColors.blackColor),
            onPressed: () {
              ref.read(helpChatViewModelProvider.notifier).restartConversation();
            },
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(
                horizontal: context.w(16),
                vertical: context.h(8),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: context.w(16),
                vertical: context.h(12),
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    CustomColors.purpleColor.withValues(alpha: 0.12),
                    CustomColors.lightBlueColor.withValues(alpha: 0.12),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(context.r(16)),
                border: Border.all(
                  color: CustomColors.purpleColor.withValues(alpha: 0.2),
                ),
              ),
              child: Center(
                child: Text(
                  "Meet Stella, Your SkinSync AI Assistant",
                  style: CustomFonts.black14w600,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.symmetric(horizontal: context.w(16), vertical: context.h(20)),
                itemCount: state.messages.length,
                itemBuilder: (context, index) {
                  final message = state.messages[index];
                  return _buildMessageBubble(message);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(HelpChatMessage message) {
    if (message.isAssistant) {
      return Padding(
        padding: EdgeInsets.only(bottom: context.h(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  margin: EdgeInsets.only(right: context.w(8)),
                  child: CircleAvatar(
                    radius: context.r(16),
                    backgroundColor: CustomColors.purpleColor.withValues(alpha: 0.1),
                    child: Padding(
                      padding: EdgeInsets.all(context.r(4)),
                      child: Image.asset(
                        PngAssets.splashLogo,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                Flexible(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: context.w(16), vertical: context.h(12)),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(context.r(16)),
                        topRight: Radius.circular(context.r(16)),
                        bottomRight: Radius.circular(context.r(16)),
                        bottomLeft: Radius.zero,
                      ),
                      boxShadow: CustomColors.cardShadow,
                    ),
                    child: message.isTyping
                        ? _buildTypingIndicator()
                        : Text(
                            message.text,
                            style: CustomFonts.black14w400,
                          ),
                  ),
                ),
              ],
            ),
            if (message.options.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: context.h(12), left: context.w(40)),
                child: Wrap(
                  spacing: context.w(8),
                  runSpacing: context.h(8),
                  children: message.options.map((option) => _buildOptionChip(option)).toList(),
                ),
              ),
          ],
        ),
      );
    } else {
      return Padding(
        padding: EdgeInsets.only(bottom: context.h(20)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Flexible(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: context.w(16), vertical: context.h(12)),
                decoration: BoxDecoration(
                  color: CustomColors.purpleColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(context.r(16)),
                    topRight: Radius.circular(context.r(16)),
                    bottomLeft: Radius.circular(context.r(16)),
                    bottomRight: Radius.zero,
                  ),
                ),
                child: Text(
                  message.text,
                  style: CustomFonts.white14w500,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildTypingIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "AI is typing",
          style: CustomFonts.textGrey13w400,
        ),
        SizedBox(width: context.w(4)),
        SizedBox(
          width: context.w(24),
          child: const LinearProgressIndicator(
            backgroundColor: Colors.transparent,
            color: CustomColors.purpleColor,
            minHeight: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildOptionChip(HelpChatOption option) {
    return GestureDetector(
      onTap: () {
        ref.read(helpChatViewModelProvider.notifier).selectOption(option, context, ref);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: context.w(16), vertical: context.h(10)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(context.r(20)),
          border: Border.all(color: CustomColors.lightBlueColor.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: CustomColors.lightBlueColor.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          option.label,
          style: CustomFonts.purple14w600,
        ),
      ),
    );
  }
}
