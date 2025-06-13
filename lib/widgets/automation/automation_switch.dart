import 'package:flutter/material.dart';
import '../../constants/automation_colors.dart';
import '../../core/theme/app_colors.dart';

class AutomationSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool isActive;
  final bool isLoading;
  
  const AutomationSwitch({
    super.key,
    required this.value,
    this.onChanged,
    required this.isActive,
    this.isLoading = false,
  });
  
  @override
  State<AutomationSwitch> createState() => _AutomationSwitchState();
}

class _AutomationSwitchState extends State<AutomationSwitch>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    if (widget.value) {
      _controller.value = 1.0;
    }
  }
  
  @override
  void didUpdateWidget(AutomationSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      if (widget.value) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return SizedBox(
        width: 51,
        height: 31,
        child: Center(
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                widget.isActive ? Colors.white : AppColors.primary,
              ),
            ),
          ),
        ),
      );
    }
    
    return GestureDetector(
      onTap: widget.onChanged != null 
          ? () => widget.onChanged!(!widget.value)
          : null,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            width: 51,
            height: 31,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Color.lerp(
                Colors.grey[300],
                widget.isActive ? Colors.white : AppColors.primary,
                _controller.value,
              ),
            ),
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  left: widget.value ? 22 : 2,
                  top: 2,
                  child: Container(
                    width: 27,
                    height: 27,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.value
                          ? (widget.isActive ? AppColors.primary : Colors.white)
                          : Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
} 