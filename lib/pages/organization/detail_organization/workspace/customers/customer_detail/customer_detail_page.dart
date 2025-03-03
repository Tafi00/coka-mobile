import 'package:coka/core/theme/app_colors.dart';
import 'package:coka/core/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:go_router/go_router.dart';
import '../../../../../../providers/customer_provider.dart';
import '../../../../../../shared/widgets/avatar_widget.dart';
import 'widgets/customer_journey.dart';
import 'widgets/assign_to_bottomsheet.dart';

class CustomerDetailPage extends ConsumerStatefulWidget {
  final String organizationId;
  final String workspaceId;
  final String customerId;

  const CustomerDetailPage({
    super.key,
    required this.organizationId,
    required this.workspaceId,
    required this.customerId,
  });

  @override
  ConsumerState<CustomerDetailPage> createState() => _CustomerDetailPageState();
}

class _CustomerDetailPageState extends ConsumerState<CustomerDetailPage> {
  @override
  void initState() {
    super.initState();
    Future(() {
      if (!mounted) return;
      ref
          .read(customerDetailProvider(widget.customerId).notifier)
          .loadCustomerDetail(widget.organizationId, widget.workspaceId);
    });
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 120,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 80,
                        height: 14,
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
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: 200,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final customerDetailAsync =
        ref.watch(customerDetailProvider(widget.customerId));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: customerDetailAsync.when(
          loading: () => Row(
            children: [
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 120,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 80,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          error: (error, stack) => Text(
            'Lỗi: ${error.toString()}',
            style: const TextStyle(color: Colors.black),
          ),
          data: (customerDetail) {
            if (customerDetail == null) {
              return const SizedBox();
            }

            return GestureDetector(
              onTap: () {
                context.push(
                  '/organization/${widget.organizationId}/workspace/${widget.workspaceId}/customers/${widget.customerId}/basic-info',
                  extra: customerDetail,
                );
              },
              child: Row(
                children: [
                  AvatarWidget(
                    fallbackText: customerDetail['fullName'] ?? '',
                    imgUrl: customerDetail['avatar'],
                    width: 40,
                    height: 40,
                    borderRadius: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          customerDetail['fullName'] ?? '',
                          style: const TextStyle(
                            color: AppColors.text,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (customerDetail['gender'] != null)
                          Text(
                            customerDetail['gender'] == 1
                                ? 'Nam'
                                : customerDetail['gender'] == 0
                                    ? 'Nữ'
                                    : 'Khác',
                            style: TextStyles.subtitle3,
                            maxLines: 1,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          customerDetailAsync.when(
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
            data: (customerDetail) {
              if (customerDetail == null) return const SizedBox();

              return MenuAnchor(
                alignmentOffset: const Offset(-160, 0),
                menuChildren: [
                  MenuItemButton(
                    leadingIcon: const Icon(Icons.person_add_outlined),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(12)),
                        ),
                        builder: (context) => AssignToBottomSheet(
                          organizationId: widget.organizationId,
                          workspaceId: widget.workspaceId,
                          onSelected: (selectedUser) async {
                            try {
                              await ref
                                  .read(
                                      customerDetailProvider(widget.customerId)
                                          .notifier)
                                  .assignToCustomer(
                                    widget.organizationId,
                                    widget.workspaceId,
                                    selectedUser,
                                  );

                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Đã chuyển phụ trách thành công')),
                              );
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Lỗi: ${e.toString()}')),
                              );
                            }
                          },
                        ),
                      );
                    },
                    child: const Text(
                      'Chuyển phụ trách',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  MenuItemButton(
                    leadingIcon: const Icon(Icons.edit_outlined),
                    onPressed: () {
                      context.push(
                        '/organization/${widget.organizationId}/workspace/${widget.workspaceId}/customers/${widget.customerId}/edit',
                        extra: customerDetail,
                      );
                    },
                    child: const Text(
                      'Chỉnh sửa thông tin',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  MenuItemButton(
                    leadingIcon:
                        const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Xóa khách hàng?'),
                          content: const Text(
                              'Bạn có chắc muốn xóa khách hàng này? Hành động này không thể hoàn tác.'),
                          actions: [
                            TextButton(
                              onPressed: () => context.pop(),
                              child: const Text('Hủy'),
                            ),
                            TextButton(
                              onPressed: () async {
                                try {
                                  await ref
                                      .read(customerDetailProvider(
                                              widget.customerId)
                                          .notifier)
                                      .deleteCustomer(
                                        widget.organizationId,
                                        widget.workspaceId,
                                      );
                                  if (!context.mounted) return;

                                  // Update customer list state
                                  await ref
                                      .read(customerListProvider.notifier)
                                      .loadCustomers(
                                    widget.organizationId,
                                    widget.workspaceId,
                                    {'limit': '20', 'offset': '0'},
                                  );

                                  context.pop();
                                  context.pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Đã xóa khách hàng thành công')),
                                  );
                                } catch (e) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text('Lỗi: ${e.toString()}')),
                                  );
                                }
                              },
                              child: const Text('Xóa',
                                  style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text(
                      'Xóa khách hàng',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
                builder: (context, controller, child) {
                  return IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {
                      if (controller.isOpen) {
                        controller.close();
                      } else {
                        controller.open();
                      }
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
      body: customerDetailAsync.when(
        loading: _buildShimmerLoading,
        error: (error, stack) => Center(
          child: Text('Lỗi: ${error.toString()}'),
        ),
        data: (customerDetail) {
          if (customerDetail == null) {
            return const Center(child: Text('Không có dữ liệu'));
          }

          return const CustomerJourney();
        },
      ),
    );
  }
}
