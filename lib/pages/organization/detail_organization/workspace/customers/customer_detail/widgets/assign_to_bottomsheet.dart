import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AssignToBottomSheet extends ConsumerWidget {
  final Function(Map<String, dynamic>) onSelected;

  const AssignToBottomSheet({
    super.key,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Implement user list provider
    final users = [
      {
        'id': '1',
        'fullName': 'Người dùng 1',
        'avatar': null,
      },
      {
        'id': '2',
        'fullName': 'Người dùng 2',
        'avatar': null,
      },
    ];

    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.8,
      expand: false,
      builder: (context, scrollController) => Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Chọn người phụ trách',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              controller: scrollController,
              itemCount: users.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(user['fullName']?[0] ?? ''),
                  ),
                  title: Text(user['fullName'] ?? ''),
                  onTap: () {
                    Navigator.pop(context);
                    onSelected(user);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
