import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/help_chat_model.dart';
import 'base_view_model.dart';
import '../screens/face_pose_capture_screen.dart';
import '../screens/consent_forms/face_consent_screen.dart';
import '../screens/journey_clinics_screen.dart';
import '../screens/treatments_screen.dart';
import '../screens/bottom_nav_screens/appointments_screen.dart';
import '../screens/bottom_nav_screens/my_profile_screen.dart';
import '../view_models/checkout_view_model.dart';
import '../view_models/treatment_journey_view_model.dart';
import 'auth_view_model.dart';
import '../view_models/treatment_view_model.dart';
import 'package:flutter/material.dart';

final helpChatViewModelProvider = NotifierProvider<HelpChatViewModel, HelpChatState>(() {
  return HelpChatViewModel();
});

class HelpChatState {
  final List<HelpChatMessage> messages;

  HelpChatState({required this.messages});

  HelpChatState copyWith({List<HelpChatMessage>? messages}) {
    return HelpChatState(
      messages: messages ?? this.messages,
    );
  }
}

class HelpChatViewModel extends BaseViewModel<HelpChatState> {
  HelpChatViewModel() : super(initialState: HelpChatState(messages: []));

  late Map<String, HelpChatQuestion> _questionsMap;

  @override
  void init() {
    super.init();
    _initializeQuestions();
  }

  void _initializeQuestions() {
    final questions = [
      HelpChatQuestion(
        id: 'q_initial',
        text: "Hi! 👋 I'm your SkinSync AI assistant.\nWhat can I help you with today?",
        options: [
          HelpChatOption(
            id: 'opt_scan',
            label: "Scan my face",
            nextQuestionId: 'q_scan',
          ),
          HelpChatOption(
            id: 'opt_clinics',
            label: "Explore clinics",
            nextQuestionId: 'q_clinics',
          ),
          HelpChatOption(
            id: 'opt_treatments',
            label: "Explore treatments",
            nextQuestionId: 'q_treatments',
          ),
          HelpChatOption(
            id: 'opt_appointments',
            label: "My appointments",
            nextQuestionId: 'q_appointments',
          ),
          HelpChatOption(
            id: 'opt_profile',
            label: "Manage my profile",
            action: (context, ref) {
              Navigator.pushNamed(context, MyProfileScreen.routeName);
            },
          ),
          HelpChatOption(
            id: 'opt_back',
            label: "Go back",
            action: (context, ref) {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      HelpChatQuestion(
        id: 'q_scan',
        text: "Great! I can help you get started with your skin analysis. What would you like to do?",
        options: [
          HelpChatOption(
            id: 'opt_start_scan',
            label: "Start Face Scan",
            action: (context, ref) {
              FaceConsentScreen.checkAndProceed(
                context: context,
                ref: ref,
                onProceed: () {
                  ref.read(checkoutViewModel.notifier).clearState();
                  ref.read(treatmentViewModel.notifier).clearAllSelectedTreatments();
                  ref.read(treatmentViewModel.notifier).clearAiImage();
                  ref.read(treatmentJourneyProvider.notifier).clearSelectedGroup();
                  Navigator.of(context).pushNamed(FacePoseCaptureScreen.routeName);
                },
              );
            },
          ),
          HelpChatOption(
            id: 'opt_scan_back',
            label: "Go back",
            action: (context, ref) {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      HelpChatQuestion(
        id: 'q_clinics',
        text: "Sure! Let's find the right clinic for you. What would you like to do?",
        options: [
          HelpChatOption(
            id: 'opt_find_clinics',
            label: "Explore Clinics",
            action: (context, ref) {
              Navigator.pushNamed(context, JourneyClinicsScreen.routeName);
            },
          ),
          HelpChatOption(
            id: 'opt_clinics_back',
            label: "Go back",
            action: (context, ref) {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      HelpChatQuestion(
        id: 'q_treatments',
        text: "Absolutely! What would you like to explore?",
        options: [
          HelpChatOption(
            id: 'opt_find_treatments',
            label: "Explore All Treatments",
            action: (context, ref) {
              Navigator.pushNamed(context, TreatmentsScreen.routeName);
            },
          ),
          HelpChatOption(
            id: 'opt_treatments_back',
            label: "Go back",
            action: (context, ref) {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      HelpChatQuestion(
        id: 'q_appointments',
        text: "I can help you with your appointments. What would you like to do?",
        options: [
          HelpChatOption(
            id: 'opt_view_appointments',
            label: "View Appointments",
            action: (context, ref) {
              Navigator.pushNamed(context, AppointmentsScreen.routeName);
            },
          ),
          HelpChatOption(
            id: 'opt_appointments_back',
            label: "Go back",
            action: (context, ref) {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    ];

    _questionsMap = {for (var q in questions) q.id: q};
  }

  void startConversation() {
    state = state.copyWith(messages: []);
    _addAssistantQuestion('q_initial');
  }

  void restartConversation() {
    startConversation();
  }

  Future<void> _addAssistantQuestion(String questionId) async {
    final question = _questionsMap[questionId];
    if (question == null) return;

    final messageId = DateTime.now().millisecondsSinceEpoch.toString();

    final typingMessage = HelpChatMessage(
      id: messageId,
      text: "",
      isAssistant: true,
      isTyping: true,
    );

    state = state.copyWith(messages: [...state.messages, typingMessage]);

    // Simulate typing delay
    await Future.delayed(const Duration(milliseconds: 1500));

    String questionText = question.text;
    if (questionId == 'q_initial') {
      final userName = ref.read(authViewModel).authData?.user?.name;
      if (userName != null && userName.isNotEmpty) {
        questionText = "Hi $userName! 👋 I'm your SkinSync AI assistant.\nWhat can I help you with today?";
      }
    }

    final actualMessage = HelpChatMessage(
      id: messageId,
      text: questionText,
      isAssistant: true,
      options: question.options,
    );

    final newMessages = List<HelpChatMessage>.from(state.messages);
    final index = newMessages.indexWhere((m) => m.id == messageId);
    if (index != -1) {
      newMessages[index] = actualMessage;
    }

    state = state.copyWith(messages: newMessages);
  }

  void selectOption(HelpChatOption option, BuildContext context, WidgetRef ref) {
    // Remove options from the last message
    final messages = List<HelpChatMessage>.from(state.messages);
    if (messages.isNotEmpty) {
      final lastMsg = messages.last;
      messages[messages.length - 1] = lastMsg.copyWith(options: []);
    }

    // Add user message
    final userMessage = HelpChatMessage(
      id: "${DateTime.now().millisecondsSinceEpoch}_u",
      text: option.label,
      isAssistant: false,
    );
    messages.add(userMessage);
    
    state = state.copyWith(messages: messages);

    // Handle action or next question
    if (option.action != null) {
      option.action!(context, ref);
      
      // Optionally continue conversation or reset
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!context.mounted) return;
        final resetId = "${DateTime.now().millisecondsSinceEpoch}_a";
        final resetMsg = HelpChatMessage(
          id: resetId,
          text: "Can I help you with anything else?",
          isAssistant: true,
          options: _questionsMap['q_initial']?.options ?? [],
        );
        state = state.copyWith(messages: [...state.messages, resetMsg]);
      });
      
    } else if (option.nextQuestionId != null) {
      _addAssistantQuestion(option.nextQuestionId!);
    } else {
      // Fallback
      final errorId = "${DateTime.now().millisecondsSinceEpoch}_a";
      final errorMsg = HelpChatMessage(
        id: errorId,
        text: "Sorry, I couldn't open that section right now. Please try again.",
        isAssistant: true,
        options: _questionsMap['q_initial']?.options ?? [],
      );
      state = state.copyWith(messages: [...state.messages, errorMsg]);
    }
  }
}
