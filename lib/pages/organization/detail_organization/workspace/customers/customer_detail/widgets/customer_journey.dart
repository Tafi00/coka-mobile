import 'package:coka/api/repositories/customer_repository.dart';
import 'package:coka/api/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../../../../core/theme/app_colors.dart';
import '../../../../../../../providers/customer_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import './stage_select.dart';
import './journey_item.dart';

class CustomerJourney extends ConsumerStatefulWidget {
  const CustomerJourney({super.key});

  @override
  ConsumerState<CustomerJourney> createState() => _CustomerJourneyState();
}

class _CustomerJourneyState extends ConsumerState<CustomerJourney>
    with SingleTickerProviderStateMixin {
  final TextEditingController chatController = TextEditingController();
  String selectedStageId = "";
  final _focusNode = FocusNode();
  bool _isInputFocused = false;
  late AnimationController _iconAnimationController;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
    _iconAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    Future(() {
      if (!mounted) return;
      final params = GoRouterState.of(context).pathParameters;
      final organizationId = params['organizationId']!;
      final workspaceId = params['workspaceId']!;
      final customerId = params['customerId']!;

      ref
          .read(customerJourneyProvider(customerId).notifier)
          .loadJourneyList(organizationId, workspaceId);
    });
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _iconAnimationController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus && selectedStageId.isEmpty) {
      setState(() {
        selectedStageId = "new"; // Mặc định là trạng thái mới
        _isInputFocused = true;
      });
      _iconAnimationController.forward();
    } else {
      setState(() {
        _isInputFocused = _focusNode.hasFocus;
      });
      if (!_focusNode.hasFocus) {
        _iconAnimationController.reverse();
      }
    }
  }

  void _showCallMethodBottomSheet() {
    final params = GoRouterState.of(context).pathParameters;
    final customerId = params['customerId']!;
    final customerState = ref.watch(customerDetailProvider(customerId));

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Wrap(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    "Phương thức gọi",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final customerData = customerState.value;
                        if (customerData != null) {
                          final phone = customerData['phone'] as String?;
                          if (phone != null) {
                            final phoneNumber = phone.startsWith("84")
                                ? phone.replaceFirst("84", "0")
                                : phone;
                            final url = Uri.parse("tel:$phoneNumber");
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url);
                            }
                          }
                        }
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 55,
                            height: 55,
                            decoration: BoxDecoration(
                              color: const Color(0xFF43B41F),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Center(
                              child: Icon(Icons.call,
                                  color: Colors.white, size: 30),
                            ),
                          ),
                          const SizedBox(height: 3),
                          const Text("Mặc định"),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    GestureDetector(
                      onTap: () {
                        // TODO: Implement call center call
                        Navigator.pop(context);
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 55,
                            height: 55,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1EEFF),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(
                              child: SvgPicture.asset("assets/icons/logo.svg"),
                            ),
                          ),
                          const SizedBox(height: 3),
                          const Text("Tổng đài"),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final params = GoRouterState.of(context).pathParameters;
    final customerId = params['customerId']!;
    final journeyState = ref.watch(customerJourneyProvider(customerId));
    final viewInsets = MediaQuery.of(context).viewInsets;
    final isKeyboardVisible = viewInsets.bottom > 0;

    return Container(
      color: const Color(0xFFF8F8F8),
      height: MediaQuery.of(context).size.height,
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: RefreshIndicator(
              onRefresh: () async {
                final params = GoRouterState.of(context).pathParameters;
                final organizationId = params['organizationId']!;
                final workspaceId = params['workspaceId']!;
                await ref
                    .read(customerJourneyProvider(customerId).notifier)
                    .loadJourneyList(organizationId, workspaceId);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Container(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height -
                        (_isInputFocused
                            ? viewInsets.bottom + 180
                            : 80), // 180 là chiều cao ước tính của stage select + input
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        journeyState.when(
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (error, stack) => Center(
                            child: Text(
                              'Có lỗi xảy ra: $error',
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                          data: (journeyList) => journeyList.isEmpty
                              ? const Center(
                                  child: Text('Chưa có hành trình nào'),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: journeyList.length,
                                  itemBuilder: (context, index) {
                                    return JourneyItem(
                                      dataItem: journeyList[index],
                                      isLast: index == journeyList.length - 1,
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: viewInsets.bottom,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isInputFocused)
                  GestureDetector(
                    onTap: () {
                      // Ngăn chặn sự kiện tap truyền xuống GestureDetector bên dưới
                    },
                    child: StageSelect(
                      defaultStage: selectedStageId,
                      selectedStage: (stage) {
                        setState(() {
                          selectedStageId = stage;
                        });
                      },
                    ),
                  ),
                Divider(height: 1, color: Colors.black.withOpacity(0.1)),
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.only(top: 6, bottom: 10),
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          focusNode: _focusNode,
                          cursorColor: Colors.black,
                          controller: chatController,
                          maxLines: 5,
                          minLines: 1,
                          keyboardType: TextInputType.multiline,
                          textCapitalization: TextCapitalization.sentences,
                          onTap: () {
                            setState(() {
                              _isInputFocused = true;
                              if (selectedStageId.isEmpty) {
                                selectedStageId = "new";
                              }
                            });
                          },
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: const Color(0x66F3EEEE),
                            hintText: "Nhập nội dung ghi chú",
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          if (!_isInputFocused) {
                            _showCallMethodBottomSheet();
                          } else {
                            if (chatController.text.trim().isEmpty) return;
                            if (selectedStageId.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Vui lòng chọn trạng thái'),
                                ),
                              );
                              return;
                            }

                            final params =
                                GoRouterState.of(context).pathParameters;
                            final organizationId = params['organizationId']!;
                            final workspaceId = params['workspaceId']!;
                            final customerId = params['customerId']!;

                            try {
                              await ref
                                  .read(customerJourneyProvider(customerId)
                                      .notifier)
                                  .updateJourney(
                                    organizationId,
                                    workspaceId,
                                    selectedStageId,
                                    chatController.text.trim(),
                                  );
                              chatController.clear();
                              setState(() {
                                _isInputFocused = false;
                              });
                              _iconAnimationController.reverse();
                              FocusScope.of(context).unfocus();
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Có lỗi xảy ra khi gửi ghi chú'),
                                  ),
                                );
                              }
                            }
                          }
                        },
                        icon: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, animation) {
                            return ScaleTransition(
                              scale: animation,
                              child: FadeTransition(
                                opacity: animation,
                                child: child,
                              ),
                            );
                          },
                          child: !_isInputFocused
                              ? const Icon(
                                  Icons.phone_outlined,
                                  key: ValueKey('phone'),
                                  color: Color(0xFF5C33F0),
                                  size: 24,
                                )
                              : SvgPicture.asset(
                                  "assets/icons/send_1_icon.svg",
                                  key: const ValueKey('send'),
                                  color: const Color(0xFF5C33F0),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
