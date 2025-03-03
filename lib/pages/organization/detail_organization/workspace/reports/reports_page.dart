import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:coka/providers/report_provider.dart';
import 'package:coka/shared/widgets/loading_indicator.dart';
import 'package:coka/shared/widgets/auto_avatar.dart';
import 'package:coka/shared/widgets/custom_switch.dart';
import 'package:coka/shared/widgets/elevated_btn.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:go_router/go_router.dart';

// Re-export cacheKeyProvider từ report_provider
final _cacheKeyProvider = StateProvider<int>((ref) => 0);

// Provider để kiểm soát việc load dữ liệu
final shouldLoadReportsProvider = StateProvider<bool>((ref) => false);

class ChartModel {
  final String name;
  final num value;
  final Color? color;

  ChartModel(this.name, this.value, {this.color});
}

final dateRangeProvider = StateProvider<DateTimeRange>((ref) {
  final now = DateTime.now();
  return DateTimeRange(
    start: now.subtract(const Duration(days: 30)),
    end: now.add(const Duration(days: 1)),
  );
});

final timeTypeProvider = StateProvider<String>((ref) => 'Day');
final stageCustomerChartTypeProvider =
    StateProvider<String>((ref) => 'Phân loại');
final isPercentShowProvider = StateProvider<bool>((ref) => true);

class ReportsPage extends ConsumerStatefulWidget {
  final String organizationId;
  final String workspaceId;

  const ReportsPage({
    super.key,
    required this.organizationId,
    required this.workspaceId,
  });

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late final ReportParams _initialParams;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final initialDateRange = DateTimeRange(
      start: now.subtract(const Duration(days: 30)),
      end: now.add(const Duration(days: 1)),
    );
    _initialParams = ReportParams(
      organizationId: widget.organizationId,
      workspaceId: widget.workspaceId,
      startDate: DateFormat('yyyy-MM-dd').format(initialDateRange.start),
      endDate: DateFormat('yyyy-MM-dd').format(initialDateRange.end),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      // Chỉ fetch data lần đầu tiên khi widget được mount
      _isInitialized = true;
      // Delay một chút để tránh fetch ngay lập tức
      Future.microtask(() {
        ref.read(reportParamsProvider.notifier).state = _initialParams;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final dateRange = ref.watch(dateRangeProvider);
    final reportParams = ref.watch(reportParamsProvider);
    final reportData = ref.watch(reportDataProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  'Báo cáo',
                  style: const TextStyle(
                      color: Color(0xFF1F2329),
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
              ),
              const SizedBox(width: 5),
              const Icon(
                Icons.keyboard_arrow_down_sharp,
                size: 24,
              ),
            ],
          ),
        ),
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, size: 30),
            onPressed: () {
              // TODO: Implement menu
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(reportDataProvider);
        },
        child: SingleChildScrollView(
          child: reportData.when(
            data: (data) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: buildDatePickerBtn(context),
                ),
                buildDashboardCards(data['summary']),
                const SizedBox(height: 30),
                buildCustomerValueChart(data['utmSource']),
                const SizedBox(height: 30),
                buildRatingChart(data['rating']),
                const SizedBox(height: 30),
                buildStageChart(data['dataSource']),
                const SizedBox(height: 30),
                buildStatisticUser(data['user']),
                const SizedBox(height: 30),
              ],
            ),
            loading: () => const Center(child: LoadingIndicator()),
            error: (error, stack) => Center(child: Text('Lỗi: $error')),
          ),
        ),
      ),
    );
  }

  Widget buildDatePickerBtn(BuildContext context) {
    final dateRange = ref.watch(dateRangeProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE3DFFF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () async {
          final newDateRange = await showDateRangePicker(
            context: context,
            initialDateRange: dateRange,
            firstDate: DateTime(2018),
            lastDate: DateTime(2030),
          );
          if (newDateRange != null) {
            ref.read(dateRangeProvider.notifier).state = newDateRange;
            ref.read(reportParamsProvider.notifier).state = ReportParams(
              organizationId: widget.organizationId,
              workspaceId: widget.workspaceId,
              startDate: DateFormat('yyyy-MM-dd').format(newDateRange.start),
              endDate: DateFormat('yyyy-MM-dd').format(newDateRange.end),
            );
          }
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.calendar_month,
              color: Color(0xFF5C33F0),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              getDateRangeText(dateRange),
              style: const TextStyle(
                color: Color(0xFF2C160C),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  String getDateRangeText(DateTimeRange dateRange) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (dateRange.start == today &&
        dateRange.end == today.add(const Duration(days: 1))) {
      return 'Hôm nay';
    } else if (dateRange.start == yesterday && dateRange.end == today) {
      return 'Hôm qua';
    } else if (dateRange.start == now.subtract(const Duration(days: 7)) &&
        dateRange.end == now.add(const Duration(days: 1))) {
      return '7 ngày qua';
    } else if (dateRange.start == now.subtract(const Duration(days: 30)) &&
        dateRange.end == now.add(const Duration(days: 1))) {
      return '30 ngày qua';
    } else {
      return '${DateFormat('dd/MM/yyyy').format(dateRange.start)} - ${DateFormat('dd/MM/yyyy').format(dateRange.end)}';
    }
  }

  Widget buildDashboardCards(Map<String, dynamic> data) {
    try {
      final cards = {
        "customer": {
          "name": "Khách hàng",
          "icon": const Icon(Icons.person_outline, size: 22),
          "value": (data['totalContact'] as num?)?.toInt() ?? 0,
          "color": const Color(0xFFE3DFFF),
          "onPressed": () {
            context.go(
                '/organization/${widget.organizationId}/workspace/${widget.workspaceId}/customers');
          }
        },
        "demand": {
          "name": "Nhu cầu",
          "icon": const Icon(Icons.assignment_outlined, size: 22),
          "value": (data['totalDemand'] as num?)?.toInt() ?? 0,
          "color": const Color(0xFFE3DFFF),
          "onPressed": () {
            context.go(
                '/organization/${widget.organizationId}/workspace/${widget.workspaceId}/customers');
          }
        },
        "product": {
          "name": "Sản phẩm",
          "icon": const Icon(Icons.shopping_bag_outlined, size: 22),
          "value": (data['totalProduct'] as num?)?.toInt() ?? 0,
          "color": const Color(0xFFE3DFFF),
          "onPressed": () {
            context.go(
                '/organization/${widget.organizationId}/workspace/${widget.workspaceId}/customers');
          }
        },
        "member": {
          "name": "Sales",
          "icon": const Icon(Icons.people_outline, size: 22),
          "value": (data['totalMember'] as num?)?.toInt() ?? 0,
          "color": const Color(0xFFE3DFFF),
          "onPressed": () {
            context.go(
                '/organization/${widget.organizationId}/workspace/${widget.workspaceId}/teams');
          }
        },
      };

      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        childAspectRatio: 2.15,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: cards.entries.map((e) => buildCard(e.value)).toList(),
      );
    } catch (e) {
      print('Error in buildDashboardCards: $e');
      return const SizedBox.shrink();
    }
  }

  Widget buildCard(Map<String, dynamic> card) {
    return GestureDetector(
      onTap: card["onPressed"] as Function(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: card['color'] as Color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: card['icon'] as Widget,
                ),
                const SizedBox(width: 4),
                Text(
                  card['value'].toString(),
                  style: const TextStyle(
                    color: Color(0xFF5A48F1),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            Text(
              card['name'] as String,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCustomerValueChart(Map<String, dynamic> data) {
    try {
      final chartData = (data['content'] as List?) ?? [];
      final formData = <ChartModel>[];
      final importData = <ChartModel>[];
      final otherData = <ChartModel>[];

      for (var item in chartData) {
        if (item is Map<String, dynamic>) {
          final date = item['date']?.toString() ?? '';
          formData.add(ChartModel(date, (item['form'] as num?) ?? 0));
          importData.add(ChartModel(date, (item['import'] as num?) ?? 0));
          otherData.add(ChartModel(date, (item['other'] as num?) ?? 0));
        }
      }

      return Container(
        width: double.infinity,
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
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Phân loại khách hàng',
                style: TextStyle(
                  color: Color(0xFF595A5C),
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(
                    Icons.circle,
                    color: Color(0xFF9B8CF7),
                    size: 13,
                  ),
                  const SizedBox(width: 5),
                  const Text(
                    'Form',
                    style: TextStyle(
                      color: Color(0xB2000000),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Icon(
                    Icons.circle,
                    color: Color(0xFFA5F2AA),
                    size: 13,
                  ),
                  const SizedBox(width: 5),
                  const Text(
                    'Import',
                    style: TextStyle(
                      color: Color(0xB2000000),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Icon(
                    Icons.circle,
                    color: Color(0xFFF5C19E),
                    size: 13,
                  ),
                  const SizedBox(width: 5),
                  const Text(
                    'Khác',
                    style: TextStyle(
                      color: Color(0xB2000000),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3DFFF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_month_sharp,
                          color: Color(0xFF5C33F0),
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Ngày',
                          style: const TextStyle(
                            color: Color(0xFF2C160C),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            if (formData.isNotEmpty)
              SizedBox(
                height: 300,
                child: SfCartesianChart(
                  primaryXAxis: CategoryAxis(
                    labelStyle: const TextStyle(
                      fontSize: 11,
                      color: Colors.black,
                      fontStyle: FontStyle.italic,
                    ),
                    labelRotation: 312,
                  ),
                  primaryYAxis: NumericAxis(
                    numberFormat: NumberFormat.compact(),
                  ),
                  series: <CartesianSeries<ChartModel, String>>[
                    StackedColumnSeries<ChartModel, String>(
                      dataSource: formData,
                      xValueMapper: (ChartModel data, _) => data.name,
                      yValueMapper: (ChartModel data, _) => data.value,
                      name: 'Form',
                      width: 0.4,
                      color: const Color(0xFF9B8CF7),
                    ),
                    StackedColumnSeries<ChartModel, String>(
                      dataSource: importData,
                      xValueMapper: (ChartModel data, _) => data.name,
                      yValueMapper: (ChartModel data, _) => data.value,
                      name: 'Import',
                      width: 0.4,
                      color: const Color(0xFFA5F2AA),
                    ),
                    StackedColumnSeries<ChartModel, String>(
                      dataSource: otherData,
                      xValueMapper: (ChartModel data, _) => data.name,
                      yValueMapper: (ChartModel data, _) => data.value,
                      name: 'Khác',
                      width: 0.4,
                      color: const Color(0xFFF5C19E),
                    ),
                  ],
                ),
              )
            else
              const Center(
                child: Text('Không có dữ liệu'),
              ),
          ],
        ),
      );
    } catch (e) {
      print('Error in buildCustomerValueChart: $e');
      return const SizedBox.shrink();
    }
  }

  Widget buildRatingChart(Map<String, dynamic> data) {
    try {
      final List<ChartModel> chartData = [];
      final ratings = (data['content'] as List?) ?? [];

      for (var rating in ratings) {
        if (rating is Map<String, dynamic>) {
          final ratingValue = (rating['rating'] as num?)?.toInt() ?? 0;
          final count = (rating['count'] as num?)?.toInt() ?? 0;
          final name = ratingValue == 0 ? 'Chưa đánh giá' : '$ratingValue sao';
          final color = {
                5: const Color(0xff9B8CF7),
                4: const Color(0xFFB6F1FD),
                3: const Color(0xffA5F2AA),
                2: const Color(0xffF0D5FC),
                1: const Color(0xffF5C19E),
                0: const Color(0xff554FE8),
              }[ratingValue] ??
              Colors.grey;

          chartData.add(ChartModel(name, count, color: color));
        }
      }

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Đánh giá khách hàng',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (chartData.isNotEmpty)
              SizedBox(
                height: 300,
                child: SfCircularChart(
                  series: <CircularSeries<ChartModel, String>>[
                    DoughnutSeries<ChartModel, String>(
                      dataSource: chartData,
                      xValueMapper: (ChartModel data, _) => data.name,
                      yValueMapper: (ChartModel data, _) => data.value,
                      pointColorMapper: (ChartModel data, _) => data.color,
                      dataLabelSettings:
                          const DataLabelSettings(isVisible: true),
                    ),
                  ],
                ),
              )
            else
              const Center(
                child: Text('Không có dữ liệu'),
              ),
          ],
        ),
      );
    } catch (e) {
      print('Error in buildRatingChart: $e');
      return const SizedBox.shrink();
    }
  }

  Widget buildStageChart(Map<String, dynamic> data) {
    try {
      final List<dynamic> stages = data['content'] ?? [];
      final Map<String, dynamic> metadata = data['metadata'] ?? {};

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Trạng thái khách hàng',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            for (var stage in stages)
              if (stage is Map<String, dynamic>)
                _buildStageItem(stage, metadata),
          ],
        ),
      );
    } catch (e) {
      print('Error in buildStageChart: $e');
      return const SizedBox.shrink();
    }
  }

  Widget _buildStageItem(
      Map<String, dynamic> stage, Map<String, dynamic> metadata) {
    try {
      final name = stage['name']?.toString() ?? 'Unknown';
      final Map<String, dynamic> stageData = stage['data'] ?? {};

      final undefined = (stageData['undefined'] as num?) ?? 0;
      final potential = (stageData['potential'] as num?) ?? 0;
      final unpotential = (stageData['unpotential'] as num?) ?? 0;
      final transaction = (stageData['transaction'] as num?) ?? 0;

      final totalValue = undefined + potential + unpotential + transaction;
      final metadataTotal = (metadata['undefined'] as num? ?? 0) +
          (metadata['potential'] as num? ?? 0) +
          (metadata['unpotential'] as num? ?? 0) +
          (metadata['transaction'] as num? ?? 0);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: metadataTotal > 0 ? totalValue / metadataTotal : 0,
            backgroundColor: Colors.grey[200],
            color: const Color(0xFF9B8CF7),
          ),
          const SizedBox(height: 4),
          Text(
            '$totalValue / $metadataTotal',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
        ],
      );
    } catch (e) {
      print('Error in _buildStageItem: $e');
      return const SizedBox.shrink();
    }
  }

  Widget buildStatisticUser(Map<String, dynamic> data) {
    final users = data['content'] as List;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thống kê theo nhân viên',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...users.map((user) => buildUserItem(user)).toList(),
        ],
      ),
    );
  }

  Widget buildUserItem(Map<String, dynamic> user) {
    final fullName = user['fullName'] as String? ?? 'Unknown';
    final avatar = user['avatar'] as String?;
    final total = user['total'] as int? ?? 0;
    final potential = user['potential'] as int? ?? 0;
    final revenue = user['revenue'] as int? ?? 0;
    final transactions = user['transactions'] as int? ?? 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: avatar != null ? NetworkImage(avatar) : null,
            child: avatar == null
                ? Text(fullName.isNotEmpty ? fullName[0] : 'U')
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$total khách hàng - $potential tiềm năng',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${NumberFormat('#,###').format(revenue)} đ',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$transactions giao dịch',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
