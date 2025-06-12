import 'package:coka/shared/widgets/avatar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import './state/message_state.dart';
import './state/chat_state.dart';
import './models/message_model.dart';
import '../../../shared/widgets/loading_indicator.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ChatDetailPage extends ConsumerStatefulWidget {
  final String organizationId;
  final String conversationId;

  const ChatDetailPage({
    super.key,
    required this.organizationId,
    required this.conversationId,
  });

  @override
  ConsumerState<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends ConsumerState<ChatDetailPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    Future(() {
      if (mounted) {
        _loadInitialMessages();
      }
    });
    _setupScrollListener();
  }

  void _loadInitialMessages() {
    ref.read(chatProvider.notifier).loadMessages(
          widget.organizationId,
          widget.conversationId,
          refresh: true,
        );
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _loadMoreMessages();
      }
    });
  }

  Future<void> _loadMoreMessages() async {
    if (_isLoadingMore) return;
    _isLoadingMore = true;

    await ref.read(chatProvider.notifier).loadMessages(
          widget.organizationId,
          widget.conversationId,
        );

    _isLoadingMore = false;
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    _messageController.clear();

    try {
      await ref.read(chatProvider.notifier).sendMessage(
            widget.organizationId,
            widget.conversationId,
            message,
          );
    } catch (e) {
      // Hiển thị thông báo lỗi nếu có lỗi xảy ra
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể gửi tin nhắn: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);

    // Tìm conversation trong các provider
    final allConversations = ref.watch(allMessageProvider).conversations;
    final zaloConversations = ref.watch(zaloMessageProvider).conversations;
    final facebookConversations =
        ref.watch(facebookMessageProvider).conversations;

    Conversation? foundConversation;

    // Tìm trong Zalo conversations
    try {
      foundConversation = zaloConversations.firstWhere(
        (conv) => conv.id == widget.conversationId,
      );
    } catch (_) {
      // Tìm trong Facebook conversations
      try {
        foundConversation = facebookConversations.firstWhere(
          (conv) => conv.id == widget.conversationId,
        );
      } catch (_) {
        // Tìm trong all conversations
        try {
          foundConversation = allConversations.firstWhere(
            (conv) => conv.id == widget.conversationId,
          );
        } catch (_) {
          // Không tìm thấy conversation
        }
      }
    }

    // Nếu không tìm thấy conversation, hiển thị thông báo lỗi
    if (foundConversation == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          title: const Text('Chi tiết tin nhắn'),
        ),
        body: const Center(
          child: Text(
            'Không tìm thấy cuộc trò chuyện',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    final conversation = foundConversation;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            AppAvatar(
              imageUrl: conversation.personAvatar,
              fallbackText: conversation.personName,
              size: 40,
              shape: AvatarShape.circle,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    conversation.personName,
                    style: const TextStyle(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    conversation.pageName,
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // TODO: Hiển thị menu với các tùy chọn khác
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: chatState.isLoading && chatState.messages.isEmpty
                ? const Center(child: LoadingIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount:
                        chatState.messages.length + (chatState.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == chatState.messages.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: LoadingIndicator(),
                          ),
                        );
                      }

                      final message = chatState.messages[index];
                      final previousMessage =
                          index < chatState.messages.length - 1
                              ? chatState.messages[index + 1]
                              : null;
                      final isFirstInTurn = previousMessage == null ||
                          previousMessage.senderName != message.senderName;
                      final showAvatar = isFirstInTurn;

                      if (index == chatState.messages.length - 1) {
                        return Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                children: [
                                  Expanded(
                                      child: Divider(
                                          color:
                                              Theme.of(context).dividerColor)),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    child: Text(
                                      'Bắt đầu cuộc trò chuyện',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(context).hintColor,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                      child: Divider(
                                          color:
                                              Theme.of(context).dividerColor)),
                                ],
                              ),
                            ),
                            _MessageBubble(
                              message: message,
                              showAvatar: showAvatar,
                              isFirstInTurn: isFirstInTurn,
                            ),
                          ],
                        );
                      }

                      return _MessageBubble(
                        message: message,
                        showAvatar: showAvatar,
                        isFirstInTurn: isFirstInTurn,
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: IconButton(
                      icon: const Icon(Icons.add),
                      iconSize: 22,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      color: Theme.of(context).primaryColor,
                      onPressed: () {
                        // TODO: Xử lý thêm file/hình ảnh
                      },
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: SizedBox(
                      height: 32,
                      child: Stack(
                        children: [
                          TextField(
                            controller: _messageController,
                            minLines: 1,
                            maxLines: 1,
                            style: const TextStyle(fontSize: 14),
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              // Thêm padding bên phải để tránh text đè lên icon
                              suffixIcon: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 28,
                                    height: 32,
                                    child: IconButton(
                                      icon: const Icon(
                                          Icons.attach_file_outlined),
                                      iconSize: 20,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      color: Theme.of(context).primaryColor,
                                      onPressed: () {
                                        // TODO: Xử lý đính kèm file
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    width: 28,
                                    height: 32,
                                    child: IconButton(
                                      icon: const Icon(Icons.image_outlined),
                                      iconSize: 20,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      color: Theme.of(context).primaryColor,
                                      onPressed: () {
                                        // TODO: Xử lý thêm hình ảnh
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              hintText: 'Nhập nội dung...',
                              hintStyle: TextStyle(
                                color: Theme.of(context).hintColor,
                                fontSize: 14,
                              ),
                              filled: true,
                              fillColor: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest
                                  .withValues(alpha: 0.3),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            textInputAction: TextInputAction.newline,
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: IconButton(
                      onPressed: chatState.isSending ? null : _sendMessage,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: chatState.isSending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              Icons.send,
                              color: Theme.of(context).primaryColor,
                              size: 20,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}

class _MessageBubble extends StatelessWidget {
  final Message message;
  final bool showAvatar;
  final bool isFirstInTurn;

  const _MessageBubble({
    required this.message,
    this.showAvatar = true,
    this.isFirstInTurn = true,
  });

  @override
  Widget build(BuildContext context) {
    const bubbleColor = Color(0xFFF1F5F9);
    const textColor = Colors.black;

    return Consumer(
      builder: (context, ref, child) {
        final chatState = ref.watch(chatProvider);
        final hasError = chatState.messageErrors.containsKey(message.id);
        final errorMessage =
            hasError ? chatState.messageErrors[message.id] : null;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 16),
          child: Row(
            mainAxisAlignment: message.isFromMe
                ? MainAxisAlignment.start
                : MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (message.isFromMe) ...[
                if (showAvatar)
                  AppAvatar(
                    imageUrl: message.senderAvatar,
                    fallbackText: message.senderName,
                    size: 44,
                    shape: AvatarShape.circle,
                  ).animate().fadeIn(duration: 300.ms)
                else
                  const SizedBox(width: 44),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Column(
                  crossAxisAlignment: message.isFromMe
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.end,
                  children: [
                    if (isFirstInTurn && message.isFromMe)
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 4),
                        child: Text(
                          message.senderName,
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                      ).animate().fadeIn(duration: 300.ms),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Flexible(
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.7,
                            ),
                            padding: message.attachments?.isNotEmpty == true &&
                                    message.content.isEmpty
                                ? const EdgeInsets.all(
                                    8) // Padding nhỏ hơn khi chỉ có hình ảnh
                                : const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: bubbleColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (message.content.isNotEmpty)
                                  Text(
                                    message.content,
                                    style: const TextStyle(
                                      color: textColor,
                                      fontSize: 14,
                                      height: 1.25,
                                    ),
                                  ),
                                if (message.attachments?.isNotEmpty ==
                                    true) ...[
                                  if (message.content.isNotEmpty)
                                    const SizedBox(height: 8),
                                  ...message.attachments!.map((attachment) {
                                    if (attachment.type.toLowerCase() ==
                                            'sticker' ||
                                        attachment.type
                                            .toLowerCase()
                                            .contains('image')) {
                                      return Container(
                                        width: attachment.type.toLowerCase() ==
                                                'sticker'
                                            ? 130
                                            : 200,
                                        height: attachment.type.toLowerCase() ==
                                                'sticker'
                                            ? 130
                                            : 200,
                                        margin:
                                            const EdgeInsets.only(bottom: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            Image.network(
                                              attachment.url,
                                              fit: BoxFit.contain,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Center(
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .broken_image_rounded,
                                                        size: 40,
                                                        color: Theme.of(context)
                                                            .hintColor,
                                                      ),
                                                      const SizedBox(height: 8),
                                                      Text(
                                                        'Hình ảnh không khả dụng',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              Theme.of(context)
                                                                  .hintColor,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                              loadingBuilder: (context, child,
                                                  loadingProgress) {
                                                if (loadingProgress == null) {
                                                  return child;
                                                }
                                                return Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                    value: loadingProgress
                                                                .expectedTotalBytes !=
                                                            null
                                                        ? loadingProgress
                                                                .cumulativeBytesLoaded /
                                                            loadingProgress
                                                                .expectedTotalBytes!
                                                        : null,
                                                  ),
                                                );
                                              },
                                            ),
                                            Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                onTap: () {
                                                  // TODO: Implement image viewer
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ).animate().fadeIn(duration: 300.ms);
                                    }
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      child: TextButton.icon(
                                        onPressed: () {},
                                        style: TextButton.styleFrom(
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .surfaceContainerHighest,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                        ),
                                        icon: const Icon(Icons.attachment),
                                        label: Text(
                                          attachment.name ?? 'File đính kèm',
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      ),
                                    ).animate().fadeIn(duration: 300.ms);
                                  }),
                                ],
                              ],
                            ),
                          ).animate().fadeIn(duration: 300.ms).slideX(
                                begin: message.isFromMe ? 0.3 : -0.3,
                                end: 0,
                                duration: 300.ms,
                                curve: Curves.easeOutCubic,
                              ),
                        ),
                        if (hasError)
                          Padding(
                            padding: const EdgeInsets.only(left: 4, bottom: 4),
                            child: GestureDetector(
                              onTap: () {
                                // Hiển thị thông báo lỗi
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Lỗi: ${errorMessage ?? 'Không thể gửi tin nhắn'}'),
                                    action: SnackBarAction(
                                      label: 'Gửi lại',
                                      onPressed: () {
                                        // Gửi lại tin nhắn
                                        final chatNotifier =
                                            ref.read(chatProvider.notifier);
                                        final conversationId =
                                            message.conversationId;
                                        final organizationId =
                                            (context.findAncestorWidgetOfExactType<
                                                        ChatDetailPage>()
                                                    as ChatDetailPage)
                                                .organizationId;

                                        chatNotifier.resendMessage(
                                          organizationId,
                                          conversationId,
                                          message.id,
                                          message.content,
                                          attachments: message.attachments
                                              ?.map((a) => {
                                                    'type': a.type,
                                                    'url': a.url,
                                                    if (a.name != null)
                                                      'name': a.name,
                                                    if (a.payload != null)
                                                      'payload': a.payload,
                                                  })
                                              .toList(),
                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              if (!message.isFromMe) ...[
                const SizedBox(width: 8),
                if (showAvatar)
                  AppAvatar(
                    imageUrl: message.senderAvatar,
                    fallbackText: message.senderName,
                    size: 44,
                    shape: AvatarShape.circle,
                  ).animate().fadeIn(duration: 300.ms)
                else
                  const SizedBox(width: 44),
              ],
            ],
          ),
        );
      },
    );
  }
}
