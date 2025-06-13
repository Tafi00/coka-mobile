import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:coka/core/constants/app_constants.dart';
import 'package:coka/core/theme/app_colors.dart';
import '../../../../widgets/automation/new_automation_card.dart';
import '../../../../widgets/automation/automation_card_skeleton.dart';
import '../../../../utils/dialog_utils.dart';

class AutomationPage extends StatefulWidget {
  final String organizationId;
  
  const AutomationPage({
    super.key,
    required this.organizationId,
  });
  
  @override
  State<AutomationPage> createState() => _AutomationPageState();
}

class _AutomationPageState extends State<AutomationPage> {
  bool _isLoading = false;
  final List<Map<String, dynamic>> _automationConfigs = [];

  @override
  void initState() {
    super.initState();
    _loadAutomationConfigs();
  }

  Future<void> _loadAutomationConfigs() async {
    setState(() {
      _isLoading = true;
    });

    // TODO: Implement actual API call to load automation configs
    await Future.delayed(const Duration(seconds: 1)); // Simulate API call
    
    // Mock data for demonstration
    _automationConfigs.addAll([
      {
        'id': '1',
        'type': 'reminder',
        'title': 'Nhắc hẹn sau 30 phút',
        'description': 'Nhắc nhở cập nhật trạng thái sau khi tiếp nhận khách hàng',
        'isActive': true,
        'createdAt': DateTime.now().subtract(const Duration(days: 2)),
      },
      {
        'id': '2',
        'type': 'eviction',
        'title': 'Thu hồi sau 24 giờ',
        'description': 'Tự động thu hồi khách hàng sau 24 giờ không có phản hồi',
        'isActive': false,
        'createdAt': DateTime.now().subtract(const Duration(days: 5)),
      },
    ]);

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Automation',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            onPressed: _showAddAutomationDialog,
            icon: const Icon(Icons.add),
            tooltip: 'Thêm automation mới',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadAutomationConfigs,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _automationConfigs.isEmpty) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);
          
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: _getChildAspectRatio(constraints.maxWidth),
            ),
            itemCount: 6, // Show 6 skeleton cards
            itemBuilder: (context, index) => const AutomationCardSkeleton(),
          );
        },
      );
    }

    if (_automationConfigs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              '${AppConstants.imagePath}/campaign_icon_3.png',
              width: 80,
              height: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa có automation nào',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tạo automation để tự động hóa quy trình làm việc',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showAddAutomationDialog,
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Tạo automation đầu tiên'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);
        
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: _getChildAspectRatio(constraints.maxWidth),
          ),
          itemCount: _automationConfigs.length,
          itemBuilder: (context, index) {
            final config = _automationConfigs[index];
            return NewAutomationCard(
              type: config['type'] ?? 'reminder',
              data: config,
              onTap: () => _navigateToDetail(config),
              onToggle: () => _toggleConfig(config['id'], !(config['isActive'] ?? false)),
              onDelete: () => _deleteConfig(config),
            );
          },
        );
      },
    );
  }



  void _showAddAutomationDialog() async {
    final selectedScenario = await DialogUtils.showAutomationScenarioDialog(context);
    
    if (selectedScenario != null) {
      switch (selectedScenario) {
        case 'recall':
          _showCreateRecallDialog();
          break;
        case 'reminder':
          _showCreateReminderDialog();
          break;
      }
    }
  }

  void _showCreateRecallDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    int selectedHours = 24;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Tạo quy tắc thu hồi'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Tên quy tắc',
                    hintText: 'Ví dụ: Thu hồi sau 24 giờ',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Mô tả',
                    hintText: 'Mô tả chi tiết về quy tắc thu hồi',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                const Text('Thời gian thu hồi:', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  value: selectedHours,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(value: 1, child: Text('1 giờ')),
                    DropdownMenuItem(value: 6, child: Text('6 giờ')),
                    DropdownMenuItem(value: 12, child: Text('12 giờ')),
                    DropdownMenuItem(value: 24, child: Text('24 giờ')),
                    DropdownMenuItem(value: 48, child: Text('48 giờ')),
                    DropdownMenuItem(value: 72, child: Text('72 giờ')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedHours = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  _createRecallRule(
                    titleController.text,
                    descriptionController.text,
                    selectedHours,
                  );
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Tạo'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateReminderDialog() {
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    int selectedMinutes = 30;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Tạo nhắc hẹn chăm sóc'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Tên nhắc hẹn',
                    hintText: 'Ví dụ: Nhắc hẹn sau 30 phút',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: messageController,
                  decoration: const InputDecoration(
                    labelText: 'Tin nhắn nhắc nhở',
                    hintText: 'Nội dung thông báo nhắc nhở',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                const Text('Thời gian nhắc nhở:', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  value: selectedMinutes,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(value: 15, child: Text('15 phút')),
                    DropdownMenuItem(value: 30, child: Text('30 phút')),
                    DropdownMenuItem(value: 60, child: Text('1 giờ')),
                    DropdownMenuItem(value: 120, child: Text('2 giờ')),
                    DropdownMenuItem(value: 240, child: Text('4 giờ')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedMinutes = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  _createReminderConfig(
                    titleController.text,
                    messageController.text,
                    selectedMinutes,
                  );
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Tạo'),
            ),
          ],
        ),
      ),
    );
  }

  void _createRecallRule(String title, String description, int hours) {
    // TODO: Implement actual API call to create recall rule
    final newConfig = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'type': 'eviction',
      'title': title,
      'description': description.isNotEmpty ? description : 'Tự động thu hồi khách hàng sau $hours giờ không có phản hồi',
      'isActive': true,
      'createdAt': DateTime.now(),
      'hours': hours,
    };

    setState(() {
      _automationConfigs.add(newConfig);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã tạo quy tắc thu hồi thành công')),
    );
  }

  void _createReminderConfig(String title, String message, int minutes) {
    // TODO: Implement actual API call to create reminder config
    final newConfig = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'type': 'reminder',
      'title': title,
      'description': message.isNotEmpty ? message : 'Nhắc nhở cập nhật trạng thái sau $minutes phút',
      'isActive': true,
      'createdAt': DateTime.now(),
      'minutes': minutes,
    };

    setState(() {
      _automationConfigs.add(newConfig);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã tạo nhắc hẹn chăm sóc thành công')),
    );
  }

  void _navigateToDetail(Map<String, dynamic> config) {
    // TODO: Navigate to detail page
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Chi tiết automation: ${config['title']}')),
    );
  }

  void _toggleConfig(String configId, bool isActive) {
    setState(() {
      final index = _automationConfigs.indexWhere((config) => config['id'] == configId);
      if (index != -1) {
        _automationConfigs[index]['isActive'] = isActive;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isActive ? 'Đã bật automation' : 'Đã tắt automation'),
      ),
    );
  }



  void _deleteConfig(Map<String, dynamic> config) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa automation "${config['title']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _automationConfigs.removeWhere((c) => c['id'] == config['id']);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã xóa automation thành công')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  int _getCrossAxisCount(double width) {
    if (width < 600) return 1;  // Mobile
    if (width < 1200) return 2; // Tablet
    return 3; // Desktop
  }
  
  double _getChildAspectRatio(double width) {
    if (width < 600) return 2.8;  // Mobile - extremely compact
    return 3.2; // Tablet/Desktop - extremely compact
  }
} 