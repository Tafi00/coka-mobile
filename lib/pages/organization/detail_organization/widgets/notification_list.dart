import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../api/repositories/notification_repository.dart';
import '../../../../api/api_client.dart';

class NotificationList extends StatefulWidget {
  final String organizationId;

  const NotificationList({
    super.key,
    required this.organizationId,
  });

  @override
  State<NotificationList> createState() => _NotificationListState();
}

class _NotificationListState extends State<NotificationList> {
  late final NotificationRepository _notificationRepository;
  late final PagingController<int, Map<String, dynamic>> _pagingController;
  List<dynamic>? _notifications;
  bool _isLoading = true;
  final int _limit = 20;

  @override
  void initState() {
    super.initState();
    _notificationRepository = NotificationRepository(ApiClient());
    _pagingController = PagingController(firstPageKey: 0);
    _pagingController.addPageRequestListener(_fetchPage);
    _fetchNotifications();
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(NotificationList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.organizationId != widget.organizationId) {
      setState(() {
        _isLoading = true;
        _notifications = null;
      });
      _pagingController.refresh();
      _fetchNotifications();
    }
  }

  Future<void> _fetchPage(int pageKey) async {
    if (widget.organizationId == 'default') return;

    try {
      final response = await _notificationRepository.getNotifications(
        organizationId: widget.organizationId,
        limit: _limit,
        offset: pageKey,
      );

      final items = response['content'] as List;
      final isLastPage = items.length < _limit;

      if (isLastPage) {
        _pagingController.appendLastPage(items.cast<Map<String, dynamic>>());
      } else {
        _pagingController.appendPage(
          items.cast<Map<String, dynamic>>(),
          pageKey + items.length,
        );
      }
    } catch (e) {
      _pagingController.error = e;
    }
  }

  Future<void> _fetchNotifications() async {
    if (widget.organizationId == 'default') {
      return;
    }
    try {
      final response = await _notificationRepository.getNotifications(
        organizationId: widget.organizationId,
        limit: _limit,
        offset: 0,
      );
      if (mounted) {
        setState(() {
          _notifications = response['content'];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Có lỗi xảy ra khi tải danh sách thông báo')),
        );
      }
    }
  }

  void _showAllNotifications() {
    _pagingController.refresh();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Text(
                'Cập nhật mới nhất',
                style: TextStyles.title,
              ),
            ),
            Expanded(
              child: PagedListView<int, Map<String, dynamic>>(
                pagingController: _pagingController,
                scrollController: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                builderDelegate:
                    PagedChildBuilderDelegate<Map<String, dynamic>>(
                  itemBuilder: (context, notification, index) =>
                      _buildNotificationItem(notification),
                  firstPageErrorIndicatorBuilder: (context) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Có lỗi xảy ra khi tải thông báo',
                          style: TextStyle(
                            color: AppColors.text,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => _pagingController.refresh(),
                          child: const Text(
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
                  noItemsFoundIndicatorBuilder: (context) => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Chưa có thông báo nào'),
                    ),
                  ),
                  firstPageProgressIndicatorBuilder: (context) => Column(
                    children: List.generate(
                      3,
                      (index) => _buildShimmerNotificationItem(),
                    ),
                  ),
                  newPageProgressIndicatorBuilder: (context) =>
                      _buildShimmerNotificationItem(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerNotificationItem() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                width: double.infinity,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 60,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<TextSpan> _parseHtmlText(String htmlText) {
    final List<TextSpan> spans = [];
    final RegExp exp = RegExp(r'<b>(.*?)</b>|([^<>]+)');

    final Iterable<Match> matches = exp.allMatches(htmlText);
    for (final Match match in matches) {
      if (match.group(1) != null) {
        // Bold text
        spans.add(TextSpan(
          text: match.group(1),
          style: const TextStyle(fontWeight: FontWeight.w500),
        ));
      } else if (match.group(2) != null) {
        // Normal text
        spans.add(TextSpan(
          text: match.group(2),
          style: const TextStyle(fontWeight: FontWeight.w400),
        ));
      }
    }
    return spans;
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    final createdDate = DateTime.parse(notification['createdDate']);
    final timeAgo = timeago.format(createdDate, locale: 'vi');

    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: InkWell(
        onTap: () {
          // TODO: Handle notification tap
        },
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/icons/logo_without_text.svg',
              width: 28,
              height: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: RichText(
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.text,
                  ),
                  children: _parseHtmlText(notification['contentHtml'] ?? ''),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              timeAgo,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding:
                const EdgeInsets.only(left: 16, right: 16, bottom: 0, top: 8),
            itemCount: 3,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12, top: 8),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        width: 60,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const Divider(
            height: 1,
            color: Color(0xFFE4E7EC),
            thickness: 0.3,
          ),
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Container(
                width: 80,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_notifications == null || _notifications!.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Chưa có thông báo nào'),
        ),
      );
    }

    final displayNotifications = _notifications!.take(5).toList();
    final hasMore = _notifications!.length > 5;

    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding:
                const EdgeInsets.only(left: 16, right: 16, bottom: 0, top: 8),
            itemCount: displayNotifications.length,
            itemBuilder: (context, index) =>
                _buildNotificationItem(displayNotifications[index]),
          ),
          if (hasMore)
            Column(
              children: [
                const Divider(
                  height: 1,
                  color: Color(0xFFE4E7EC),
                  thickness: 0.3,
                ),
                InkWell(
                  onTap: _showAllNotifications,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Xem tất cả',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 4, 16, 0),
          child: Text(
            'Cập nhật mới nhất',
            style: TextStyle(
              color: AppColors.text,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        _isLoading ? _buildShimmerLoading() : _buildContent(),
      ],
    );
  }
}
