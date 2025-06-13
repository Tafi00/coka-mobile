import 'package:flutter/material.dart';
import '../../constants/automation_colors.dart';

enum StatisticType { cancelled, pending, completed }

class StatisticItem extends StatelessWidget {
  final StatisticType type;
  final int count;
  final bool isActive;
  final String? customLabel;
  
  const StatisticItem({
    super.key,
    required this.type,
    required this.count,
    required this.isActive,
    this.customLabel,
  });
  
  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: _getTooltipMessage(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: isActive 
              ? AutomationColors.statsBackgroundActive 
              : AutomationColors.statsBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getIcon(),
              size: 12,
              color: isActive 
                  ? AutomationColors.textOnPrimary 
                  : AutomationColors.textPrimary,
            ),
            const SizedBox(width: 4),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isActive 
                    ? AutomationColors.textOnPrimary 
                    : AutomationColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  IconData _getIcon() {
    switch (type) {
      case StatisticType.cancelled:
        return Icons.do_not_disturb_on;
      case StatisticType.pending:
        return Icons.hourglass_empty;
      case StatisticType.completed:
        return Icons.assignment_turned_in;
    }
  }
  
  String _getTooltipMessage() {
    if (customLabel != null) return customLabel!;
    
    switch (type) {
      case StatisticType.cancelled:
        return 'Đã hủy';
      case StatisticType.pending:
        return 'Chờ xử lý';
      case StatisticType.completed:
        return 'Đã xử lý';
    }
  }
}

class StatisticsData {
  final String name;
  final int count;
  
  const StatisticsData({
    required this.name,
    required this.count,
  });
}

class StatisticsRow extends StatelessWidget {
  final List<StatisticsData> statistics;
  final bool isActive;
  
  const StatisticsRow({
    super.key,
    required this.statistics,
    required this.isActive,
  });
  
  @override
  Widget build(BuildContext context) {
    if (statistics.isEmpty) return const SizedBox.shrink();
    
    return Row(
      children: statistics.map((stat) {
        StatisticType type;
        if (stat.name.contains('hủy') || stat.name.contains('Hủy')) {
          type = StatisticType.cancelled;
        } else if (stat.name.contains('chờ') || stat.name.contains('Chờ')) {
          type = StatisticType.pending;
        } else {
          type = StatisticType.completed;
        }
        
        return Padding(
          padding: const EdgeInsets.only(right: 6),
          child: StatisticItem(
            type: type,
            count: stat.count,
            isActive: isActive,
            customLabel: stat.name,
          ),
        );
      }).toList(),
    );
  }
} 