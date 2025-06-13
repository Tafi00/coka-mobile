import 'package:flutter/material.dart';
import '../widgets/automation/automation_scenario_dialog.dart';

class DialogUtils {
  static Future<String?> showAutomationScenarioDialog(BuildContext context) {
    return showGeneralDialog<String>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Automation Scenario Dialog',
      pageBuilder: (context, animation, secondaryAnimation) {
        return AutomationScenarioDialog(
          onScenarioSelected: (scenarioType) {
            Navigator.of(context).pop(scenarioType);
          },
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return child;
      },
    );
  }
} 