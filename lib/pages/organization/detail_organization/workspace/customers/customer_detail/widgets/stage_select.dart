import 'package:flutter/material.dart';
import '../../../../../../../core/constants/app_constants.dart';

class StageSelect extends StatefulWidget {
  final String defaultStage;
  final Function(String) selectedStage;

  const StageSelect({
    super.key,
    required this.defaultStage,
    required this.selectedStage,
  });

  @override
  State<StageSelect> createState() => _StageSelectState();
}

class _StageSelectState extends State<StageSelect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: _animation,
      axisAlignment: -1,
      child: FadeTransition(
        opacity: _animation,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.white,
                isScrollControlled: true,
                builder: (context) =>
                    StageSelectBottomSheet(selectedStage: widget.selectedStage),
              );
            },
            child: Container(
              width: double.infinity,
              color: Colors.white,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    "assets/images/select_stage_icon.png",
                    height: 25,
                    width: 25,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    widget.defaultStage == ""
                        ? "Chọn trạng thái"
                        : _getStageLabel(widget.defaultStage),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_drop_down,
                    size: 20,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getStageLabel(String stageId) {
    for (var category in AppConstants.stageObject.values) {
      for (var stage in category['data'] as List) {
        if (stage['id'] == stageId) {
          return stage['name'] as String;
        }
      }
    }
    return "Chọn trạng thái";
  }
}

class StageSelectBottomSheet extends StatefulWidget {
  final Function(String) selectedStage;

  const StageSelectBottomSheet({super.key, required this.selectedStage});

  @override
  State<StageSelectBottomSheet> createState() => _StageSelectBottomSheetState();
}

class _StageSelectBottomSheetState extends State<StageSelectBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Column(
          children: [
            const SizedBox(height: 15),
            const Text(
              "Trạng thái",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 15),
            ...AppConstants.stageObject.entries.map((e) {
              final value = e.value;
              return ExpansionTile(
                title: Text(
                  value["name"].toString(),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                children: [
                  ...(value["data"] as List).map((data) {
                    return ListTile(
                      title: Text(data["name"]),
                      onTap: () {
                        widget.selectedStage(data["id"]);
                        Navigator.pop(context);
                      },
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 32),
                    );
                  })
                ],
              );
            }),
            const SizedBox(height: 25),
          ],
        ),
      ],
    );
  }
}
