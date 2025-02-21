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

// Provider riêng cho từng loại tin nhắn
final zaloMessageProvider =
    StateNotifierProvider<MessageNotifier, MessageState>((ref) {
  final repository = ref.watch(messageRepositoryProvider);
  return MessageNotifier(repository, 'ZALO');
});

final facebookMessageProvider =
    StateNotifierProvider<MessageNotifier, MessageState>((ref) {
  final repository = ref.watch(messageRepositoryProvider);
  return MessageNotifier(repository, 'FACEBOOK');
});

final allMessageProvider =
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
  final String? provider;

  MessageState({
    this.isLoading = false,
    this.conversations = const [],
    this.selectedConversation,
    this.page = 0,
    this.hasMore = true,
    this.searchText,
    this.provider,
  });

  MessageState copyWith({
    bool? isLoading,
    List<Conversation>? conversations,
    Conversation? selectedConversation,
    int? page,
    bool? hasMore,
    String? searchText,
    String? provider,
  }) {
    return MessageState(
      isLoading: isLoading ?? this.isLoading,
      conversations: conversations ?? this.conversations,
      selectedConversation: selectedConversation ?? this.selectedConversation,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      searchText: searchText ?? this.searchText,
      provider: provider ?? this.provider,
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
    try {
      // Convert timestamp to DateTime
      final timestamp = json['updatedTime'] is int
          ? json['updatedTime']
          : int.tryParse(json['updatedTime']?.toString() ?? '') ??
              DateTime.now().millisecondsSinceEpoch;

      return Conversation(
        id: json['id']?.toString() ?? '',
        pageId: json['pageId']?.toString() ?? '',
        pageName: json['pageName']?.toString() ?? '',
        pageAvatar: json['pageAvatar']?.toString(),
        personId: json['personId']?.toString() ?? '',
        personName: json['personName']?.toString() ?? '',
        personAvatar: json['personAvatar']?.toString(),
        snippet: json['snippet']?.toString() ?? '',
        canReply: json['canReply'] ?? false,
        updatedTime: DateTime.fromMillisecondsSinceEpoch(timestamp),
        gptStatus: json['gptStatus'] is int ? json['gptStatus'] : 0,
        isRead: json['isRead'] ?? false,
        type: json['type']?.toString() ?? 'MESSAGE',
        provider: json['provider']?.toString() ?? 'ZALO',
        status: json['status']?.toString() ?? '',
        assignName: json['assignName']?.toString(),
        assignAvatar: json['assignAvatar']?.toString(),
      );
    } catch (e) {
      print('Error parsing conversation: $json');
      print('Error: $e');
      rethrow;
    }
  }
}

class MessageNotifier extends StateNotifier<MessageState> {
  final MessageRepository _repository;
  final String? _defaultProvider;

  MessageNotifier(this._repository, [this._defaultProvider])
      : super(MessageState(provider: _defaultProvider));

  void reset() {
    state = MessageState(provider: _defaultProvider);
  }

  Future<void> fetchConversations(String organizationId,
      {String? provider, bool forceRefresh = false}) async {
    if (state.isLoading) return;

    final currentProvider = provider ?? _defaultProvider;

    // Reset state nếu là lần fetch đầu tiên hoặc forceRefresh
    if (state.page == 0 || forceRefresh) {
      state = MessageState(
        isLoading: true,
        provider: currentProvider,
      );
    } else {
      state = state.copyWith(isLoading: true);
    }

    try {
      final response = await _repository.getConversationList(
        organizationId,
        page: forceRefresh ? 0 : state.page,
        provider: currentProvider,
      );

      final List<Conversation> conversations = (response['content'] as List)
          .map((item) => Conversation.fromJson(item))
          .toList();

      if (forceRefresh || state.page == 0) {
        state = state.copyWith(
          conversations: conversations,
          isLoading: false,
          hasMore: conversations.length >= 20,
          page: 1,
        );
      } else {
        state = state.copyWith(
          conversations: [...state.conversations, ...conversations],
          isLoading: false,
          hasMore: conversations.length >= 20,
          page: state.page + 1,
        );
      }
    } catch (e) {
      print(e);
      state = state.copyWith(isLoading: false);
    }
  }

  void clearConversations() {
    state = state.copyWith(
      conversations: [],
      page: 0,
      hasMore: true,
      selectedConversation: null,
    );
  }

  void selectConversation(String conversationId) {
    try {
      final conversation = state.conversations.firstWhere(
        (conv) => conv.id == conversationId,
      );
      state = state.copyWith(selectedConversation: conversation);
    } catch (_) {
      // Không làm gì nếu không tìm thấy conversation
    }
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
