import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../api/repositories/message_repository.dart';
import '../../../../api/api_client.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

final messageRepositoryProvider = Provider<MessageRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return MessageRepository(apiClient);
});

final messageProvider =
    StateNotifierProvider<MessageNotifier, MessageState>((ref) {
  final repository = ref.watch(messageRepositoryProvider);
  return MessageNotifier(repository);
});

class MessageState {
  final bool isLoading;
  final List<Conversation> conversations;
  final Conversation? selectedConversation;
  final int page;
  final bool hasMore;
  final String? searchText;

  MessageState({
    this.isLoading = false,
    this.conversations = const [],
    this.selectedConversation,
    this.page = 0,
    this.hasMore = true,
    this.searchText,
  });

  MessageState copyWith({
    bool? isLoading,
    List<Conversation>? conversations,
    Conversation? selectedConversation,
    int? page,
    bool? hasMore,
    String? searchText,
  }) {
    return MessageState(
      isLoading: isLoading ?? this.isLoading,
      conversations: conversations ?? this.conversations,
      selectedConversation: selectedConversation ?? this.selectedConversation,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      searchText: searchText ?? this.searchText,
    );
  }
}

class Conversation {
  final String id;
  final String pageId;
  final String pageName;
  final String? pageAvatar;
  final String personId;
  final String personName;
  final String? personAvatar;
  final String snippet;
  final bool canReply;
  final DateTime updatedTime;
  final int gptStatus;
  final bool isRead;
  final String type;
  final String provider;
  final String status;
  final String? assignName;
  final String? assignAvatar;

  Conversation({
    required this.id,
    required this.pageId,
    required this.pageName,
    this.pageAvatar,
    required this.personId,
    required this.personName,
    this.personAvatar,
    required this.snippet,
    required this.canReply,
    required this.updatedTime,
    required this.gptStatus,
    required this.isRead,
    required this.type,
    required this.provider,
    required this.status,
    this.assignName,
    this.assignAvatar,
  });

  Conversation copyWith({
    String? assignName,
    String? assignAvatar,
  }) {
    return Conversation(
      id: id,
      pageId: pageId,
      pageName: pageName,
      pageAvatar: pageAvatar,
      personId: personId,
      personName: personName,
      personAvatar: personAvatar,
      snippet: snippet,
      canReply: canReply,
      updatedTime: updatedTime,
      gptStatus: gptStatus,
      isRead: isRead,
      type: type,
      provider: provider,
      status: status,
      assignName: assignName ?? this.assignName,
      assignAvatar: assignAvatar ?? this.assignAvatar,
    );
  }

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'],
      pageId: json['pageId'],
      pageName: json['pageName'],
      pageAvatar: json['pageAvatar'],
      personId: json['personId'],
      personName: json['personName'],
      personAvatar: json['personAvatar'],
      snippet: json['snippet'],
      canReply: json['canReply'] ?? false,
      updatedTime: DateTime.parse(json['updatedTime']),
      gptStatus: json['gptStatus'] ?? 0,
      isRead: json['isRead'] ?? false,
      type: json['type'] ?? 'MESSAGE',
      provider: json['provider'] ?? 'ZALO',
      status: json['status'] ?? '',
      assignName: json['assignName'],
      assignAvatar: json['assignAvatar'],
    );
  }
}

class MessageNotifier extends StateNotifier<MessageState> {
  final MessageRepository _repository;

  MessageNotifier(this._repository) : super(MessageState());

  Future<void> fetchConversations(String organizationId,
      {String? provider}) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true);

    try {
      final response = await _repository.getConversationList(
        organizationId,
        page: state.page,
        provider: provider,
      );

      final List<Conversation> conversations = (response['content'] as List)
          .map((item) => Conversation.fromJson(item))
          .toList();

      state = state.copyWith(
        conversations: [...state.conversations, ...conversations],
        isLoading: false,
        hasMore: conversations.length >= 20,
        page: state.page + 1,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  void selectConversation(String conversationId) {
    final conversation = state.conversations.firstWhere(
      (conv) => conv.id == conversationId,
      orElse: () => state.selectedConversation!,
    );
    state = state.copyWith(selectedConversation: conversation);
  }

  Future<void> assignConversation(
    String organizationId,
    String conversationId,
    String userId,
    String assignName,
    String? assignAvatar,
  ) async {
    try {
      await _repository.assignConversation(
        organizationId,
        conversationId,
        userId,
      );

      final updatedConversations = state.conversations.map((conv) {
        if (conv.id == conversationId) {
          return conv.copyWith(
            assignName: assignName,
            assignAvatar: assignAvatar,
          );
        }
        return conv;
      }).toList();

      state = state.copyWith(
        conversations: updatedConversations,
        selectedConversation: state.selectedConversation?.copyWith(
          assignName: assignName,
          assignAvatar: assignAvatar,
        ),
      );
    } catch (e) {
      // Handle error
    }
  }

  void updateConversation(Conversation updatedConversation) {
    final updatedConversations = state.conversations.map((conv) {
      if (conv.id == updatedConversation.id) {
        return updatedConversation;
      }
      return conv;
    }).toList();

    state = state.copyWith(
      conversations: updatedConversations,
      selectedConversation:
          state.selectedConversation?.id == updatedConversation.id
              ? updatedConversation
              : state.selectedConversation,
    );
  }

  void addConversation(Conversation newConversation) {
    state = state.copyWith(
      conversations: [newConversation, ...state.conversations],
    );
  }
}
