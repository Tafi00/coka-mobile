import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../api/repositories/message_repository.dart';
import '../models/message_model.dart';
import './message_state.dart';

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  final repository = ref.watch(messageRepositoryProvider);
  return ChatNotifier(repository);
});

class ChatState {
  final bool isLoading;
  final List<Message> messages;
  final int page;
  final bool hasMore;
  final bool isSending;

  ChatState({
    this.isLoading = false,
    this.messages = const [],
    this.page = 0,
    this.hasMore = true,
    this.isSending = false,
  });

  ChatState copyWith({
    bool? isLoading,
    List<Message>? messages,
    int? page,
    bool? hasMore,
    bool? isSending,
  }) {
    return ChatState(
      isLoading: isLoading ?? this.isLoading,
      messages: messages ?? this.messages,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isSending: isSending ?? this.isSending,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final MessageRepository _repository;

  ChatNotifier(this._repository) : super(ChatState());

  Future<void> loadMessages(String organizationId, String conversationId,
      {bool refresh = false}) async {
    if (state.isLoading) return;

    if (refresh) {
      state = ChatState(isLoading: true);
    } else {
      state = state.copyWith(isLoading: true);
    }

    try {
      final response = await _repository.getChatList(
        organizationId,
        conversationId,
        refresh ? 0 : state.page,
      );

      final List<Message> messages = (response['content'] as List)
          .map((item) => Message.fromJson(item))
          .toList();

      if (refresh) {
        state = state.copyWith(
          messages: messages,
          isLoading: false,
          hasMore: messages.length >= 20,
          page: 1,
        );
      } else {
        state = state.copyWith(
          messages: [...state.messages, ...messages],
          isLoading: false,
          hasMore: messages.length >= 20,
          page: state.page + 1,
        );
      }
    } catch (e) {
      print('Error loading messages: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> sendMessage(
    String organizationId,
    String conversationId,
    String content, {
    List<Map<String, dynamic>>? attachments,
  }) async {
    state = state.copyWith(isSending: true);

    try {
      final body = {
        'conversationId': conversationId,
        'content': content,
        if (attachments != null) 'attachments': attachments,
      };

      await _repository.sendFacebookMessage(organizationId, body);

      // Refresh messages after sending
      await loadMessages(organizationId, conversationId, refresh: true);
    } catch (e) {
      print('Error sending message: $e');
    } finally {
      state = state.copyWith(isSending: false);
    }
  }

  void addMessage(Message message) {
    state = state.copyWith(
      messages: [message, ...state.messages],
    );
  }
}
