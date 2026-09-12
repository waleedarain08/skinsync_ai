import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../models/responses/appointments_list_response.dart';
import '../models/responses/messages_response.dart';
import '../services/websocket_service.dart';
import '../view_models/auth_view_model.dart';
import '../view_models/bottom_nav_view_model.dart';
import '../view_models/chat_view_model.dart';
import '../view_models/forms_view_model.dart';
import '../view_models/subscription_view_model.dart';
import '../view_models/treatment_view_model.dart';
import '../widgets/chat_button.dart';
import '../widgets/help_chat_button.dart';
import '../widgets/scan_face_button.dart';
import 'bottom_nav_bar.dart';
import 'bottom_nav_screens/explore_screen.dart';
import 'bottom_nav_screens/home_screen.dart';
import 'bottom_nav_screens/my_profile_screen.dart';
import 'bottom_nav_screens/treatment_explore_screen.dart';
import 'treatment_journey_screen.dart';

class BottomNavPage extends ConsumerStatefulWidget {
  const BottomNavPage({super.key});

  static const String routeName = '/BottomNavPage';

  @override
  ConsumerState<BottomNavPage> createState() => _BottomNavPageState();
}

class _BottomNavPageState extends ConsumerState<BottomNavPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _wsInstance = WebSocketService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bottomNavViewModel.notifier).changePage(0);
      ref.read(treatmentViewModel.notifier).init();
      ref.read(subscriptionProvider.notifier).fetchSubscriptionPlans();
      ref.read(formsViewModel.notifier).fetchForms();
      _wsInstance.connect(
        onEvent: (event) {
          try {
            switch (event.type) {
              case .error:
                final error = event.data['error'] as String?;
                if (error != null) {
                  EasyLoading.showError(error);
                }
                break;
              case .appointment:
                break;
              case .newAppointment:
                log('DATA: ${event.data}');
                ref
                    .read(authViewModel.notifier)
                    .addAppointment(AppointmentItem.fromJson(event.data));
                break;
              case .chat:
                final message = Message.fromJson(event.data);
                if (ref.exists(chatProvider)) {
                  ref.read(chatProvider.notifier).addMessage(message);
                }
                break;
              case .subscription:
                // TODO: Handle this case.
                throw UnimplementedError();
            }
          } catch (_) {
            log(' Ignoring parsing errors');
          }
        },
      );
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(bottomNavViewModel, (previous, next) {
      if (_tabController.index != next) {
        _tabController.animateTo(next);
      }
    });

    return Consumer(
      builder: (context, ref, child) {
        final index = ref.watch(bottomNavViewModel);
        return Scaffold(
          body: Stack(
            alignment: Alignment.center,
            children: [
              switch (index) {
                0 => const HomeScreen(),
                1 => const TreatmentExploreScreen(),
                2 => const ExploreScreen(),
                3 => const TreatmentJourneyScreen(isFromBottomNav: true),
                4 => const MyProfileScreen(),
                int() => throw UnimplementedError(),
              },
              if (index != 2)
                Positioned(
                  bottom: 110.h + MediaQuery.paddingOf(context).bottom,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const ScanFaceButton(),

                      SizedBox(width: 12.w),
                      const HelpChatButton(),
                    ],
                  ),
                ),
              Positioned(
                right: 20.w,
                bottom: 110.h + MediaQuery.paddingOf(context).bottom,
                child: const ChatButton(),
              ),
            ],
          ),
          extendBody: true,
          bottomNavigationBar: BottomNavBar(controller: _tabController),
        );
      },
    );
  }
}
