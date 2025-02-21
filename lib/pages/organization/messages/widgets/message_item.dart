import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/avatar_widget.dart';
import '../state/message_state.dart';

class MessageItem extends ConsumerWidget {
  final String id;
  final String organizationId;
  final String sender;
  final String content;
  final String time;
  final String platform;
  final String? avatar;
  final String? pageAvatar;

  const MessageItem({
    super.key,
    required this.id,
    required this.organizationId,
    required this.sender,
    required this.content,
    required this.time,
    required this.platform,
    this.avatar,
    this.pageAvatar,
  });

  String _getFirstAndLastWord(String text) {
    final words = text.split(' ');
    if (words.length == 1) return words[0][0];
    return words.first[0] + words.last[0];
  }

  Widget _buildAvatar(
      String name, String? imageUrl, double width, double height) {
    return AvatarWidget(
      // imgUrl: imageUrl,
      width: width,
      height: height,
      borderRadius: 100,
      fallbackText: name,
    );
  }

  void _handleTap(BuildContext context, WidgetRef ref) {
    // Kiểm tra conversation trong state tương ứng và cập nhật selected conversation
    if (platform == 'FACEBOOK') {
      if (ref
          .read(facebookMessageProvider)
          .conversations
          .any((c) => c.id == id)) {
        ref.read(facebookMessageProvider.notifier).selectConversation(id);
      }
    } else if (platform == 'ZALO') {
      if (ref.read(zaloMessageProvider).conversations.any((c) => c.id == id)) {
        ref.read(zaloMessageProvider.notifier).selectConversation(id);
      }
    } else {
      if (ref.read(allMessageProvider).conversations.any((c) => c.id == id)) {
        ref.read(allMessageProvider.notifier).selectConversation(id);
      }
    }

    // Điều hướng đến trang chi tiết
    context.push('/organization/$organizationId/messages/detail/$id');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: Colors.white,
      elevation: 0,
      child: InkWell(
        onTap: () => _handleTap(context, ref),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAvatar(sender, avatar, 40, 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            sender,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              timeago.format(
                                DateTime.parse(time),
                                locale: 'vi',
                              ),
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(width: 8),
                            SvgPicture.asset(
                              platform == 'FACEBOOK'
                                  ? 'assets/icons/messenger.svg'
                                  : 'assets/icons/zalo.svg',
                              width: 16,
                              height: 16,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            content,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        if (pageAvatar != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: _buildAvatar('Page', pageAvatar, 15, 15),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
