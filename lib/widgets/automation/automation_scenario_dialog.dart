import 'package:flutter/material.dart';
import '../../constants/dialog_colors.dart';
import '../../models/automation_scenario.dart';
import '../../styles/dialog_text_styles.dart';
import 'scenario_card.dart';

class AutomationScenarioDialog extends StatefulWidget {
  final Function(String scenarioType)? onScenarioSelected;
  
  const AutomationScenarioDialog({
    super.key,
    this.onScenarioSelected,
  });
  
  @override
  State<AutomationScenarioDialog> createState() => _AutomationScenarioDialogState();
}

class _AutomationScenarioDialogState extends State<AutomationScenarioDialog>
    with TickerProviderStateMixin {
  late AnimationController _dialogController;
  late AnimationController _cardsController;
  late Animation<double> _dialogAnimation;
  late Animation<double> _overlayAnimation;
  
  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }
  
  void _setupAnimations() {
    _dialogController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _cardsController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _dialogAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _dialogController,
      curve: Curves.easeOutBack,
    ));
    
    _overlayAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _dialogController,
      curve: Curves.easeOut,
    ));
  }
  
  void _startAnimations() {
    _dialogController.forward();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _cardsController.forward();
      }
    });
  }
  
  @override
  void dispose() {
    _dialogController.dispose();
    _cardsController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _dialogController,
      builder: (context, child) {
        return Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              // Overlay
              FadeTransition(
                opacity: _overlayAnimation,
                child: GestureDetector(
                  onTap: () => _closeDialog(),
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: DialogColors.overlayBackground,
                  ),
                ),
              ),
              
              // Dialog Content
              Center(
                child: ScaleTransition(
                  scale: _dialogAnimation,
                  child: _DialogContent(
                    cardsController: _cardsController,
                    onScenarioSelected: widget.onScenarioSelected,
                    onClose: _closeDialog,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  void _closeDialog() {
    _dialogController.reverse().then((_) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }
}

class _DialogContent extends StatelessWidget {
  final AnimationController cardsController;
  final Function(String)? onScenarioSelected;
  final VoidCallback onClose;
  
  const _DialogContent({
    required this.cardsController,
    this.onScenarioSelected,
    required this.onClose,
  });
  
  @override
  Widget build(BuildContext context) {
    final scenarios = _getScenarios();
    
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      constraints: const BoxConstraints(maxWidth: 900),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: DialogColors.dialogBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: DialogColors.cardShadow,
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          _DialogHeader(onClose: onClose),
          
          // Content
          Flexible(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: _ScenarioGrid(
                scenarios: scenarios,
                cardsController: cardsController,
                onScenarioSelected: onScenarioSelected,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  List<AutomationScenario> _getScenarios() {
    return [
      AutomationScenario(
        id: 'recall',
        title: 'Thu hồi khách hàng',
        description: 'Thu hồi khách hàng sau một khoảng thời gian không có phản hồi',
        icon: Icons.assignment_return,
        color: DialogColors.iconPrimary,
      ),
      AutomationScenario(
        id: 'reminder',
        title: 'Nhắc hẹn chăm sóc',
        description: 'Nhắc nhở cập nhật trạng thái sau khi tiếp nhận khách hàng',
        icon: Icons.alarm_on,
        color: DialogColors.iconSecondary,
      ),
    ];
  }
}

class _DialogHeader extends StatelessWidget {
  final VoidCallback onClose;
  
  const _DialogHeader({required this.onClose});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Chọn kịch bản Automation',
              style: DialogTextStyles.dialogTitle,
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close, size: 20),
            style: IconButton.styleFrom(
              backgroundColor: Colors.grey.withOpacity(0.1),
              foregroundColor: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScenarioGrid extends StatelessWidget {
  final List<AutomationScenario> scenarios;
  final AnimationController cardsController;
  final Function(String)? onScenarioSelected;
  
  const _ScenarioGrid({
    required this.scenarios,
    required this.cardsController,
    this.onScenarioSelected,
  });
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);
        final aspectRatio = _getAspectRatio(constraints.maxWidth);
        
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
            childAspectRatio: aspectRatio,
          ),
          itemCount: scenarios.length,
          itemBuilder: (context, index) {
            return ScenarioCard(
              scenario: scenarios[index],
              animationController: cardsController,
              animationDelay: Duration(milliseconds: index * 100),
              onTap: () => onScenarioSelected?.call(scenarios[index].id),
            );
          },
        );
      },
    );
  }
  
  int _getCrossAxisCount(double width) {
    if (width < 600) return 1;  // Mobile
    if (width < 900) return 2;  // Tablet
    return 2; // Desktop (keep 2 for this dialog size)
  }
  
  double _getAspectRatio(double width) {
    if (width < 600) return 1.3;  // Mobile - taller cards
    return 1.1; // Tablet/Desktop
  }
} 