import 'package:flutter/material.dart';

class MessageItem extends StatelessWidget {
  final String sender;
  final String content;
  final String time;
  final String platform;
  final VoidCallback? onTap;

  const MessageItem({
    super.key,
    required this.sender,
    required this.content,
    required this.time,
    required this.platform,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(sender[0].toUpperCase()),
        ),
        title: Text(sender),
        subtitle: Text(
          content,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              time,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Text(
              platform,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).primaryColor,
                  ),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
