import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:coka_mobile/providers/report_provider.dart';
import 'package:coka_mobile/shared/widgets/loading_indicator.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ChartModel {
  final String name;
  final num value;
  final Color? color;

  ChartModel(this.name, this.value, {this.color});
}

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

class _ReportsPageState extends ConsumerState<ReportsPage> {
  late DateTime fromDate;
  late DateTime toDate;
  String dateString = "30 ngày qua";
  String currentTimeType = "Day";
  String currentStageCustomerChartType = "Phân loại";
  bool isPercentShow = true;

  @override
  void initState() {
    super.initState();
    fromDate = DateTime.now().subtract(const Duration(days: 30));
    toDate = DateTime.now().add(const Duration(days: 1));
  }

  ReportParams get reportParams => ReportParams(
        organizationId: widget.organizationId,
        workspaceId: widget.workspaceId,
        startDate: DateFormat('yyyy-MM-dd').format(fromDate),
        endDate: DateFormat('yyyy-MM-dd').format(toDate),
      );

  ReportOverTimeParams get reportOverTimeParams => ReportOverTimeParams(
        organizationId: widget.organizationId,
        workspaceId: widget.workspaceId,
        startDate: DateFormat('yyyy-MM-dd').format(fromDate),
        endDate: DateFormat('yyyy-MM-dd').format(toDate),
        type: currentTimeType,
      );

  @override
  Widget build(BuildContext context) {
    final summaryData = ref.watch(reportSummaryProvider(reportParams));
    final statisticsByUtmSource =
        ref.watch(reportStatisticsByUtmSourceProvider(reportParams));
    final statisticsByDataSource =
        ref.watch(reportStatisticsByDataSourceProvider(reportParams));
    final statisticsByTag =
        ref.watch(reportStatisticsByTagProvider(reportParams));
    final chartByOverTime =
        ref.watch(reportChartByOverTimeProvider(reportOverTimeParams));
    final chartByRating = ref.watch(reportChartByRatingProvider(reportParams));
    final statisticsByUser =
        ref.watch(reportStatisticsByUserProvider(reportParams));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Báo cáo'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.refresh(reportSummaryProvider(reportParams));
          ref.refresh(reportStatisticsByUtmSourceProvider(reportParams));
          ref.refresh(reportStatisticsByDataSourceProvider(reportParams));
          ref.refresh(reportStatisticsByTagProvider(reportParams));
          ref.refresh(reportChartByOverTimeProvider(reportOverTimeParams));
          ref.refresh(reportChartByRatingProvider(reportParams));
          ref.refresh(reportStatisticsByUserProvider(reportParams));
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: buildDatePickerBtn(context),
              ),
              summaryData.when(
                data: (data) => buildDashboardCards(data),
                loading: () => const LoadingIndicator(),
                error: (error, stack) => Text('Lỗi: $error'),
              ),
              const SizedBox(height: 30),
              chartByOverTime.when(
                data: (data) => buildCustomerValueChart(data),
                loading: () => const LoadingIndicator(),
                error: (error, stack) => Text('Lỗi: $error'),
              ),
              const SizedBox(height: 30),
              chartByRating.when(
                data: (data) => buildRatingChart(data),
                loading: () => const LoadingIndicator(),
                error: (error, stack) => Text('Lỗi: $error'),
              ),
              const SizedBox(height: 30),
              statisticsByDataSource.when(
                data: (data) => buildStageChart(data),
                loading: () => const LoadingIndicator(),
                error: (error, stack) => Text('Lỗi: $error'),
              ),
              const SizedBox(height: 30),
              statisticsByUser.when(
                data: (data) => buildStatisticUser(data),
                loading: () => const LoadingIndicator(),
                error: (error, stack) => Text('Lỗi: $error'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDatePickerBtn(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE3DFFF),
        borderRadius: BorderRadius.circular(12),
      ),
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
            dateString,
            style: const TextStyle(
              color: Color(0xFF2C160C),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Icon(Icons.arrow_drop_down),
        ],
      ),
    );
  }

  Widget buildDashboardCards(Map<String, dynamic> data) {
    final cards = [
      {
        'title': 'Khách hàng',
        'value': data['totalContact'] ?? 0,
        'icon': Icons.person_outline,
        'color': Colors.blue,
      },
      {
        'title': 'Nhu cầu',
        'value': data['totalDemand'] ?? 0,
        'icon': Icons.assignment_outlined,
        'color': Colors.green,
      },
      {
        'title': 'Sản phẩm',
        'value': data['totalProduct'] ?? 0,
        'icon': Icons.shopping_bag_outlined,
        'color': Colors.orange,
      },
      {
        'title': 'Sales',
        'value': data['totalMember'] ?? 0,
        'icon': Icons.people_outline,
        'color': Colors.purple,
      },
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: cards.map((card) => buildCard(card)).toList(),
    );
  }

  Widget buildCard(Map<String, dynamic> card) {
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
          Icon(
            card['icon'] as IconData,
            color: card['color'] as Color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            card['value'].toString(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            card['title'] as String,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCustomerValueChart(Map<String, dynamic> data) {
    final chartData = data['content'] as List;
    final formData = <ChartModel>[];
    final importData = <ChartModel>[];
    final otherData = <ChartModel>[];

    for (var item in chartData) {
      final date = item['date'] as String;
      formData.add(ChartModel(date, item['form'] ?? 0));
      importData.add(ChartModel(date, item['import'] ?? 0));
      otherData.add(ChartModel(date, item['other'] ?? 0));
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
            'Phân loại khách hàng',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: SfCartesianChart(
              primaryXAxis: CategoryAxis(),
              series: <CartesianSeries<ChartModel, String>>[
                StackedColumnSeries<ChartModel, String>(
                  dataSource: formData,
                  xValueMapper: (ChartModel data, _) => data.name,
                  yValueMapper: (ChartModel data, _) => data.value,
                  name: 'Form',
                  color: const Color(0xFF9B8CF7),
                ),
                StackedColumnSeries<ChartModel, String>(
                  dataSource: importData,
                  xValueMapper: (ChartModel data, _) => data.name,
                  yValueMapper: (ChartModel data, _) => data.value,
                  name: 'Import',
                  color: const Color(0xFFA5F2AA),
                ),
                StackedColumnSeries<ChartModel, String>(
                  dataSource: otherData,
                  xValueMapper: (ChartModel data, _) => data.name,
                  yValueMapper: (ChartModel data, _) => data.value,
                  name: 'Khác',
                  color: const Color(0xFFF5C19E),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRatingChart(Map<String, dynamic> data) {
    final List<ChartModel> chartData = [];
    final ratings = data['content'] as List;

    for (var rating in ratings) {
      final ratingValue = rating['rating'] as int;
      final count = rating['count'] as int;
      final name = ratingValue == 0 ? 'Chưa đánh giá' : '$ratingValue sao';
      final color = {
        5: const Color(0xff9B8CF7),
        4: const Color(0xFFB6F1FD),
        3: const Color(0xffA5F2AA),
        2: const Color(0xffF0D5FC),
        1: const Color(0xffF5C19E),
        0: const Color(0xff554FE8),
      }[ratingValue];

      chartData.add(ChartModel(name, count, color: color));
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
          SizedBox(
            height: 300,
            child: SfCircularChart(
              series: <CircularSeries<ChartModel, String>>[
                DoughnutSeries<ChartModel, String>(
                  dataSource: chartData,
                  xValueMapper: (ChartModel data, _) => data.name,
                  yValueMapper: (ChartModel data, _) => data.value,
                  pointColorMapper: (ChartModel data, _) => data.color,
                  dataLabelSettings: const DataLabelSettings(isVisible: true),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStageChart(Map<String, dynamic> data) {
    final stages = data['content'] as List;
    final total = data['metadata'] as Map<String, dynamic>;

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
          ...stages.map((stage) => buildStageItem(stage, total)).toList(),
        ],
      ),
    );
  }

  Widget buildStageItem(
      Map<String, dynamic> stage, Map<String, dynamic> total) {
    final name = stage['name'] as String;
    final data = stage['data'] as Map<String, dynamic>;
    final totalValue = total[name] as int;

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
          value: totalValue > 0 ? data['value'] / totalValue : 0,
          backgroundColor: Colors.grey[200],
          color: const Color(0xFF9B8CF7),
        ),
        const SizedBox(height: 4),
        Text(
          '${data['value']} / $totalValue',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage:
                user['avatar'] != null ? NetworkImage(user['avatar']) : null,
            child: user['avatar'] == null ? Text(user['fullName'][0]) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['fullName'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${user['total']} khách hàng - ${user['potential']} tiềm năng',
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
                '${NumberFormat('#,###').format(user['revenue'])} đ',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${user['transactions']} giao dịch',
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
