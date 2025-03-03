import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../shared/widgets/elevated_btn.dart';
import '../../../../../../shared/widgets/custom_switch.dart';
import 'report_providers.dart';

class StageChart extends ConsumerWidget {
  final Map<String, dynamic> data;
  final List<String> chartTypes;
  final String currentChartType;
  final Function(String) onChartTypeChanged;
  final bool isLoading;

  const StageChart({
    Key? key,
    required this.data,
    required this.chartTypes,
    required this.currentChartType,
    required this.onChartTypeChanged,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPercentShow = ref.watch(reportsIsPercentShowProvider);

    try {
      final List<dynamic> stages = data['content'] ?? [];
      final Map<String, dynamic> metadata = data['metadata'] ?? {};

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.only(left: 16, top: 16, bottom: 16),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D000000),
                offset: Offset(0, 2),
                blurRadius: 8,
                spreadRadius: 0,
              )
            ]),
        child: Wrap(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      "Trạng thái khách hàng",
                      style: TextStyle(
                          color: Color(0XFF595A5C),
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    MenuAnchor(
                      menuChildren: [
                        ...chartTypes.map((e) => MenuItemButton(
                              child: Text(
                                style: const TextStyle(fontSize: 14),
                                e,
                              ),
                              onPressed: () {
                                onChartTypeChanged(e);
                              },
                            ))
                      ],
                      style: const MenuStyle(
                          backgroundColor: WidgetStatePropertyAll(Colors.white),
                          padding: WidgetStatePropertyAll(
                              EdgeInsets.symmetric(horizontal: 12))),
                      builder: (context, controller, child) => ElevatedBtn(
                          onPressed: () {
                            if (controller.isOpen) {
                              controller.close();
                            } else {
                              controller.open();
                            }
                          },
                          circular: 12,
                          paddingAllValue: 0,
                          child: FittedBox(
                            child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE3DFFF),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      currentChartType,
                                      style: const TextStyle(
                                          color: Color(0xFF2C160C),
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(
                                      width: 4,
                                    ),
                                    const Icon(
                                      Icons.keyboard_arrow_down,
                                      size: 20,
                                    ),
                                  ],
                                )),
                          )),
                    ),
                    const SizedBox(
                      width: 8,
                    )
                  ],
                ),
                const SizedBox(
                  height: 14,
                ),
                _buildSourceLegend(metadata, isPercentShow),
                const SizedBox(
                  height: 5,
                ),
                isLoading
                    ? _buildChartFetching(100.0)
                    : stages.isEmpty
                        ? const Center(
                            child: Text(
                              "Chưa có dữ liệu nào",
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xB2000000),
                                  fontWeight: FontWeight.w500),
                            ),
                          )
                        : Column(
                            children: [
                              ...stages.map((element) {
                                if (element is! Map<String, dynamic>)
                                  return const SizedBox.shrink();

                                final name =
                                    element["name"]?.toString() ?? 'Unknown';
                                final Map<String, dynamic> stageData =
                                    element["data"] ?? {};

                                num totalPercentage = 0;
                                final chartWidth =
                                    MediaQuery.of(context).size.width - 100;

                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Tooltip(
                                      message: _capitalize(name),
                                      triggerMode: TooltipTriggerMode.tap,
                                      child: SizedBox(
                                          width: 70,
                                          child: Text(
                                            _capitalize(name),
                                            style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500),
                                            overflow: TextOverflow.ellipsis,
                                          )),
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    SizedBox(
                                      width: chartWidth,
                                      child: Row(
                                        children: [
                                          ...stageData.entries.map((e) {
                                            final groupName =
                                                _getGroupNameFromKey(e.key);
                                            final bgColor =
                                                _getColorFromKey(e.key);
                                            final isLastIndex = _isLastElement(
                                                stageData, e.key);
                                            final percent = isLastIndex
                                                ? 100 - totalPercentage
                                                : _getRoundedPercentage(
                                                    stageData, e.key);

                                            totalPercentage += percent;
                                            return percent == 0
                                                ? Container()
                                                : Column(
                                                    children: [
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      SizedOverflowBox(
                                                        size: const Size(0, 16),
                                                        child: Row(
                                                          children: [
                                                            Text(
                                                                e.value
                                                                    .toString(),
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold)),
                                                            if (isPercentShow)
                                                              Text(
                                                                  "($percent%)",
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      color: Color(
                                                                          0xFF646A73),
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .normal)),
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 3,
                                                      ),
                                                      Container(
                                                        width: chartWidth *
                                                            percent /
                                                            100,
                                                        height: 8,
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        35),
                                                            color: bgColor),
                                                      ),
                                                      const SizedBox(
                                                        height: 2,
                                                      )
                                                    ],
                                                  );
                                          }).toList(),
                                        ],
                                      ),
                                    )
                                  ],
                                );
                              }).toList(),
                            ],
                          ),
                const SizedBox(
                  height: 16,
                ),
                Row(
                  children: [
                    const Spacer(),
                    SwitchRow(
                      initialValue: isPercentShow,
                      onChanged: (value) {
                        ref.read(reportsIsPercentShowProvider.notifier).state =
                            value;
                      },
                    ),
                    const SizedBox(
                      width: 4,
                    )
                  ],
                )
              ],
            ),
          ],
        ),
      );
    } catch (e) {
      print('Error in StageChart: $e');
      return const SizedBox.shrink();
    }
  }

  Widget _buildSourceLegend(Map<String, dynamic> metadata, bool isPercentShow) {
    return Builder(builder: (context) {
      final screenWidth = MediaQuery.of(context).size.width;
      return Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: SizedBox(
              width: (screenWidth - 32) / 2 + 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.circle,
                        color: Color(0xFF92F7A8),
                        size: 13,
                      ),
                      const SizedBox(
                        width: 3,
                      ),
                      const Text(
                        'Giao dịch',
                        style: TextStyle(
                            color: Color(0xB2000000),
                            fontSize: 11,
                            fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      Text(
                        "${metadata["transaction"] ?? 0}",
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w500),
                      ),
                      if (isPercentShow)
                        Text(
                            "(${_getRoundedPercentage(metadata, "transaction")}%)",
                            style: const TextStyle(
                                fontSize: 11, color: Color(0xB2000000))),
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.circle,
                        color: Color(0xFFFEBE99),
                        size: 13,
                      ),
                      const SizedBox(
                        width: 3,
                      ),
                      const Text(
                        'Không tiềm năng',
                        style: TextStyle(
                            color: Color(0xB2000000),
                            fontSize: 11,
                            fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      Text("${metadata["unpotential"] ?? 0}",
                          style: const TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w500)),
                      if (isPercentShow)
                        Text(
                            "(${_getRoundedPercentage(metadata, "unpotential")}%)",
                            style: const TextStyle(
                                fontSize: 11, color: Color(0xB2000000))),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.circle,
                      color: Color(0xFFA4F3FF),
                      size: 13,
                    ),
                    const SizedBox(
                      width: 3,
                    ),
                    const Text(
                      'Tiềm năng',
                      style: TextStyle(
                          color: Color(0xB2000000),
                          fontSize: 11,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    Text("${metadata["potential"] ?? 0}",
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w500)),
                    if (isPercentShow)
                      Text("(${_getRoundedPercentage(metadata, "potential")}%)",
                          style: const TextStyle(
                              fontSize: 11, color: Color(0xB2000000))),
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.circle,
                      color: Color(0xFF9F87FF),
                      size: 13,
                    ),
                    const SizedBox(
                      width: 3,
                    ),
                    const Text(
                      'Không xác định',
                      style: TextStyle(
                          color: Color(0xB2000000),
                          fontSize: 11,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    Text("${metadata["undefined"] ?? 0}",
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w500)),
                    if (isPercentShow)
                      Text(
                        "(${_getRoundedPercentage(metadata, "undefined")}%)",
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xB2000000)),
                      ),
                  ],
                )
              ],
            ),
          )
        ],
      );
    });
  }

  Widget _buildChartFetching(double height) {
    return SizedBox(
      height: height,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  String _getGroupNameFromKey(String key) {
    if (key == "potential") {
      return "Tiềm năng";
    }
    if (key == "transaction") {
      return "Giao dịch";
    }
    if (key == "unpotential") {
      return "Không tiềm năng";
    }
    if (key == "undefined") {
      return "Không xác định";
    }
    if (key == "other") {
      return "Khác";
    }
    return "";
  }

  Color _getColorFromKey(String key) {
    if (key == "potential") {
      return const Color(0xFFA4F3FF);
    }
    if (key == "transaction") {
      return const Color(0xFF92F7A8);
    }
    if (key == "unpotential") {
      return const Color(0xFFFEBE99);
    }
    if (key == "undefined") {
      return const Color(0xFF9F87FF);
    }
    return const Color(0xFF9F87FF);
  }

  bool _isLastElement(Map<String, dynamic> data, String key) {
    List keys = data.keys.toList();
    int index = keys.indexOf(key);
    return index == keys.length - 1;
  }

  int _getRoundedPercentage(Map<String, dynamic> data, String key) {
    if (data.containsKey(key)) {
      num total = 0;
      data.forEach((_, value) {
        total += (value as num? ?? 0);
      });
      if (total == 0) {
        return 0;
      }
      double percentage = ((data[key] as num? ?? 0) / total) * 100.0;
      return percentage.round();
    } else {
      // Trả về 0 nếu key không tồn tại trong map
      return 0;
    }
  }
}
