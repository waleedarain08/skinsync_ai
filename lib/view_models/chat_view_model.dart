import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../exceptions/app_exception.dart';
import '../models/chat_treatment_request_model.dart';
import '../models/responses/chats_response.dart';
import '../models/responses/messages_response.dart';
import '../repositories/chat_repository.dart';
import '../services/api_base_helper.dart';
import '../services/chat_service.dart';
import '../services/websocket_service.dart';
import '../utils/enums.dart';
import 'auth_view_model.dart';
import 'base_view_model.dart';

final chatProvider = NotifierProvider(() {
  return ChatViewModel(repo: ChatService(apiService: ApiBaseHelper()));
});

class ChatViewModel extends BaseViewModel<ChatState> {
  final ChatRepository _repo;

  ChatViewModel({required this._repo}) : super(initialState: const ChatState());

  Future<void> loadChats({String? query}) async {
    return await runSafely(() async {
      state = const ChatState();
      EasyLoading.show(status: 'Loading chats...');
      final data = await _repo.getChats(search: query);
      state = state.copyWith(chatsData: data, loading: false);
      EasyLoading.dismiss();
    });
  }

  Future<void> loadMessages() async {
    return await runSafely(() async {
      final chatId = state.selectedChat?.id;
      if (chatId == null) {
        throw const AppException('No chat selected');
      }
      EasyLoading.show(status: 'Loading messages...');
      final data = await _repo.getMessages(chatId: chatId);
      state = state.copyWith(messagesData: data, loading: false);
      EasyLoading.dismiss();
    });
  }

  Future<void> sendChatMessage({
    required MessageType type,
    required String content,
    String? mediaUrl,
    String? documentUrl,
    ChatTreatmentRequestModel? treatmentRequest,
  }) async {
    return await runSafely(() async {
      final chatId = state.selectedChat?.id;
      if (chatId == null) {
        throw const AppException('No chat selected');
      }

      await WebSocketService().sendMessage(
        chatId: chatId,
        type: type,
        content: content,
        mediaUrl: mediaUrl,
        documentUrl: documentUrl,
        treatmentRequest: treatmentRequest,
      );
    });
  }

  Future<void> addMessage(Message message) async {
    final existingMessages = List<Message>.from(
      state.messagesData?.messages ?? <Message>[],
    );
    final alreadyExists = existingMessages.any((m) => m.id == message.id);
    if (alreadyExists) {
      return;
    }
    if (state.selectedChat?.id != message.chatId) {
      return;
    }
    final user = ref.read(authViewModel).authData?.user;
    if (user == null) {
      throw const AppException('Unauthorized');
    }

    final updatedMessages = [
      message.copyWith(userId: user.id),
      ...existingMessages,
    ];
    final currentData = state.messagesData ?? MessagesData(messages: const []);
    state = state.copyWith(
      messagesData: currentData.copyWith(messages: updatedMessages),
    );
  }

  void selectChat(Chat? chat) {
    state = state.copyWith(selectedChat: chat);
  }

  void clearSelectedChatAndMessages() {
    state = state.copyWithNull(selectedChat: true, messagesData: true);
  }
}

class ChatState {
  final bool loading;
  final ChatsData? chatsData;
  final Chat? selectedChat;
  final MessagesData? messagesData;

  const ChatState({
    this.loading = false,
    this.chatsData,
    this.selectedChat,
    this.messagesData,
  });

  ChatState copyWith({
    bool? loading,
    ChatsData? chatsData,
    Chat? selectedChat,
    MessagesData? messagesData,
  }) {
    return ChatState(
      loading: loading ?? this.loading,
      chatsData: chatsData ?? this.chatsData,
      selectedChat: selectedChat ?? this.selectedChat,
      messagesData: messagesData ?? this.messagesData,
    );
  }

  ChatState copyWithNull({
    bool chatsData = false,
    bool selectedChat = false,
    bool messagesData = false,
  }) {
    return ChatState(
      loading: this.loading,
      chatsData: chatsData ? null : this.chatsData,
      selectedChat: selectedChat ? null : this.selectedChat,
      messagesData: messagesData ? null : this.messagesData,
    );
  }
}
