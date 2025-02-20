import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/message_state.dart';
import '../widgets/message_item.dart';

class AllMessagesTab extends ConsumerStatefulWidget {
  final String organizationId;

  const AllMessagesTab({
    super.key,
    required this.organizationId,
  });

  @override
  ConsumerState<AllMessagesTab> createState() => _AllMessagesTabState();
}

class _AllMessagesTabState extends ConsumerState<AllMessagesTab> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    Future.microtask(() {
      ref
          .read(messageProvider.notifier)
          .fetchConversations(widget.organizationId);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      final state = ref.read(messageProvider);
      if (!state.isLoading && state.hasMore) {
        ref
            .read(messageProvider.notifier)
            .fetchConversations(widget.organizationId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(messageProvider);

    if (state.isLoading && state.conversations.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!state.isLoading && state.conversations.isEmpty) {
      return const Center(child: Text('Không có tin nhắn nào'));
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: state.conversations.length + (state.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == state.conversations.length) {
          return state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : const SizedBox();
        }

        final conversation = state.conversations[index];
        return MessageItem(
          sender: conversation.personName,
          content: conversation.snippet,
          time: conversation.updatedTime.toString(),
          platform: conversation.provider,
          onTap: () {
            ref
                .read(messageProvider.notifier)
                .selectConversation(conversation.id);
            // TODO: Navigate to chat detail
          },
        );
      },
    );
  }
}
