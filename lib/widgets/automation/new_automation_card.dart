import 'package:flutter/material.dart';
import '../../constants/automation_colors.dart';
import '../../styles/automation_text_styles.dart';
import 'automation_card_base.dart';
import 'automation_badge.dart';
import 'automation_switch.dart';
import 'statistics_item.dart';

class NewAutomationCard extends StatelessWidget {
  final String type; // 'reminder' or 'eviction'
  final Map<String, dynamic> data;
  final VoidCallback? onTap;
  final VoidCallback? onToggle;
  final VoidCallback? onDelete;
  final bool isLoading;
  
  const NewAutomationCard({
    super.key,
    required this.type,
    required this.data,
    this.onTap,
    this.onToggle,
    this.onDelete,
    this.isLoading = false,
  });
  
  @override
  Widget build(BuildContext context) {
    final bool isActive = data['isActive'] ?? false;
    final String title = _getTitle();
    final String description = _getDescription();
    final List<StatisticsData> statistics = _getStatistics();
    
    return AutomationCardBase(
      isActive: isActive,
      onTap: onTap,
      onDelete: onDelete,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Badge + Switch
          Row(
            children: [
              AutomationBadge(
                type: type == 'reminder' 
                    ? AutomationBadgeType.reminder 
                    : AutomationBadgeType.recall,
                isActive: isActive,
              ),
              const SizedBox(width: 8),
              _FeatureIcons(
                hasWorkingHours: _hasWorkingHours(),
                hasRepeat: _hasRepeat(),
                isActive: isActive,
              ),
              const Spacer(),
              AutomationSwitch(
                value: isActive,
                onChanged: onToggle != null ? (_) => onToggle!() : null,
                isActive: isActive,
                isLoading: isLoading,
              ),
            ],
          ),
          
          const SizedBox(height: 4),
          
          // Content Area
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  title,
                  style: AutomationTextStyles.cardTitle(isActive),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 1),
                
                // Description
                if (description.isNotEmpty)
                  Text(
                    description,
                    style: AutomationTextStyles.cardSubtitle(isActive),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                
                const SizedBox(height: 2),
                
                // Workspace
                Text(
                  'Tại không gian làm việc: ${_getWorkspaceName()}',
                  style: AutomationTextStyles.workspaceName(isActive),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const Spacer(),
                
                // Statistics (always show at bottom)
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: StatisticsRow(
                    statistics: statistics,
                    isActive: isActive,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  String _getTitle() {
    final String baseTitle = data['title'] ?? 'Untitled';
    
    if (type == 'reminder') {
      final int minutes = data['minutes'] ?? 30;
      final String duration = _formatDuration(minutes);
      return 'Gửi thông báo sau $duration tiếp nhận khách hàng';
    } else {
      final int hours = data['hours'] ?? 24;
      final String duration = _formatDuration(hours * 60);
      return 'Thu hồi Lead sau $duration';
    }
  }
  
  String _getDescription() {
    final String description = data['description'] ?? '';
    if (description.isNotEmpty) return description;
    
    if (type == 'reminder') {
      return 'thuộc bất kỳ trạng thái nào';
    } else {
      return 'chuyển trạng thái chăm sóc';
    }
  }
  
  String _getWorkspaceName() {
    return 'Mặc định'; // Simplified for now
  }
  
  List<StatisticsData> _getStatistics() {
    // Always show statistics, even with 0 counts
    if (type == 'reminder') {
      return [
        const StatisticsData(name: 'Đã gửi', count: 45),
        const StatisticsData(name: 'Chờ xử lý', count: 12),
      ];
    } else {
      return [
        const StatisticsData(name: 'Đã thu hồi', count: 0), // Show 0 count
        const StatisticsData(name: 'Đang xử lý', count: 5),
      ];
    }
  }
  
  bool _hasWorkingHours() {
    return true; // All automations respect working hours
  }
  
  bool _hasRepeat() {
    if (type == 'reminder') {
      return true; // Reminders can repeat
    }
    return false; // Eviction rules don't repeat
  }
  
  String _formatDuration(int minutes) {
    if (minutes == 0) return '0 phút';
    
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    
    if (hours == 0) return '$mins phút';
    if (mins == 0) return '$hours giờ';
    return '$hours giờ $mins phút';
  }
}

class _FeatureIcons extends StatelessWidget {
  final bool hasWorkingHours;
  final bool hasRepeat;
  final bool isActive;
  
  const _FeatureIcons({
    required this.hasWorkingHours,
    required this.hasRepeat,
    required this.isActive,
  });
  
  @override
  Widget build(BuildContext context) {
    final iconColor = isActive 
        ? AutomationColors.textOnPrimary 
        : AutomationColors.textSecondary;
    
    return Row(
      children: [
        if (hasWorkingHours)
          Tooltip(
            message: 'Chỉ hoạt động trong giờ làm việc',
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Icon(
                Icons.access_time,
                size: 16,
                color: iconColor,
              ),
            ),
          ),
        if (hasRepeat)
          Tooltip(
            message: 'Lặp lại nhiều lần',
            child: Icon(
              Icons.loop,
              size: 16,
              color: iconColor,
            ),
          ),
      ],
    );
  }
} 