import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:collection/collection.dart';
import 'package:go_router/go_router.dart';
import '../../../../../../api/repositories/customer_repository.dart';
import '../../../../../../api/api_client.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/utils/helpers.dart';
import '../../../../../../shared/widgets/avatar_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../providers/customer_provider.dart';
import '../customer_detail/customer_detail_page.dart';

class CustomersList extends ConsumerStatefulWidget {
  final String organizationId;
  final String workspaceId;
  final String? stageGroupId;
  final String? searchQuery;
  final Map<String, dynamic> queryParams;

  const CustomersList({
    super.key,
    required this.organizationId,
    required this.workspaceId,
    this.stageGroupId,
    this.searchQuery,
    required this.queryParams,
  });

  @override
  ConsumerState<CustomersList> createState() => _CustomersListState();
}

class _CustomersListState extends ConsumerState<CustomersList> {
  late final PagingController<int, Map<String, dynamic>> _pagingController;
  final int _limit = 20;
  final _mapEquality = const MapEquality<String, dynamic>();
  final _customerRepository = CustomerRepository(ApiClient());
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    _pagingController = PagingController(firstPageKey: 0);
    _pagingController.addPageRequestListener(_fetchPage);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pagingController.refresh();
    });
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(CustomersList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stageGroupId != widget.stageGroupId ||
        oldWidget.organizationId != widget.organizationId ||
        oldWidget.workspaceId != widget.workspaceId ||
        oldWidget.searchQuery != widget.searchQuery ||
        !_mapEquality.equals(oldWidget.queryParams, widget.queryParams)) {
      setState(() {
        _isFirstLoad = true;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _pagingController.refresh();
        }
      });
    }
  }

  Future<void> _fetchPage(int pageKey) async {
    if (!mounted) return;

    try {
      final Map<String, dynamic> params =
          Map<String, dynamic>.from(widget.queryParams);
      params['offset'] = pageKey;
      params['limit'] = _limit;
      params['searchText'] = widget.searchQuery;
      params['stageGroupId'] = widget.stageGroupId;

      await ref.read(customerListProvider.notifier).loadCustomers(
            widget.organizationId,
            widget.workspaceId,
            params.map((key, value) => MapEntry(key, value?.toString() ?? '')),
          );

      if (!mounted) return;

      final customers = ref.read(customerListProvider).value ?? [];
      final isLastPage = customers.length < _limit;

      setState(() {
        _isFirstLoad = false;
      });

      if (isLastPage) {
        _pagingController.appendLastPage(customers);
      } else {
        _pagingController.appendPage(customers, pageKey + _limit);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isFirstLoad = false;
        });
        _pagingController.error = e;
      }
    }
  }

  Widget _buildShimmerItem() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 100,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerItem(Map<String, dynamic> customer) {
    final assignToUser = customer['assignToUser'];
    final stage = customer['stage'];
    final createdDate = DateTime.parse(customer['createdDate']);
    final timeAgo = timeago.format(createdDate, locale: 'vi');
    final isNewStage = stage?['name'] == 'Mới';

    return InkWell(
      onTap: () {
        context.push(
          '/organization/${widget.organizationId}/workspace/${widget.workspaceId}/customers/${customer['id']}',
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AvatarWidget(
              imgData: null,
              width: 48,
              height: 48,
              borderRadius: 24,
              fallbackText: customer['fullName'],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          customer['fullName'] ?? 'Không có tên',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight:
                                isNewStage ? FontWeight.w500 : FontWeight.w400,
                            color: AppColors.text,
                          ),
                        ),
                      ),
                      Text(
                        timeAgo,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF828489),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  if (stage != null)
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Helpers.getTabBadgeColor(
                              Helpers.getStageGroupName(stage['id']) ?? '',
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          stage['name'] ?? '',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight:
                                isNewStage ? FontWeight.w500 : FontWeight.w400,
                            color: AppColors.text,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      if (assignToUser != null) ...[
                        AvatarWidget(
                          imgData: assignToUser['avatar'],
                          width: 16,
                          height: 16,
                          borderRadius: 8,
                          fallbackText: assignToUser['fullName'],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          assignToUser['fullName'] ?? '',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF828489),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _isFirstLoad = true;
        });
        _pagingController.refresh();
      },
      child: PagedListView<int, Map<String, dynamic>>(
        pagingController: _pagingController,
        builderDelegate: PagedChildBuilderDelegate<Map<String, dynamic>>(
          itemBuilder: (context, customer, index) =>
              _buildCustomerItem(customer),
          firstPageProgressIndicatorBuilder: (context) => _isFirstLoad
              ? Column(
                  children: List.generate(
                    5,
                    (index) => _buildShimmerItem(),
                  ),
                )
              : const SizedBox.shrink(),
          newPageProgressIndicatorBuilder: (context) => _buildShimmerItem(),
          firstPageErrorIndicatorBuilder: (context) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Có lỗi xảy ra khi tải danh sách khách hàng',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isFirstLoad = true;
                    });
                    _pagingController.refresh();
                  },
                  child: Text(
                    'Thử lại',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          noItemsFoundIndicatorBuilder: (context) => _isFirstLoad
              ? const SizedBox.shrink()
              : const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Không có khách hàng nào'),
                  ),
                ),
        ),
      ),
    );
  }
}
