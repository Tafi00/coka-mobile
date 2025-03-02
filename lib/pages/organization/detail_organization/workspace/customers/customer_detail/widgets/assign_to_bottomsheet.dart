import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../../core/theme/app_colors.dart';
import '../../../../../../../shared/widgets/avatar_widget.dart';
import '../../../../../../../api/repositories/team_repository.dart';
import '../../../../../../../api/api_client.dart';

class AssignToBottomSheet extends ConsumerStatefulWidget {
  final String organizationId;
  final String workspaceId;
  final Function(Map<String, dynamic>) onSelected;

  const AssignToBottomSheet({
    super.key,
    required this.organizationId,
    required this.workspaceId,
    required this.onSelected,
  });

  @override
  ConsumerState<AssignToBottomSheet> createState() =>
      _AssignToBottomSheetState();
}

class _AssignToBottomSheetState extends ConsumerState<AssignToBottomSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _memberSearchController = TextEditingController();
  final TextEditingController _teamSearchController = TextEditingController();
  final TeamRepository _teamRepository = TeamRepository(ApiClient());

  List<Map<String, dynamic>> _members = [];
  List<Map<String, dynamic>> _teams = [];
  bool _isLoadingMembers = true;
  bool _isLoadingTeams = true;
  String _memberSearchText = '';
  String _teamSearchText = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _memberSearchController.dispose();
    _teamSearchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadMembers(),
      _loadTeams(),
    ]);
  }

  Future<void> _loadMembers() async {
    try {
      final response = await _teamRepository.getTeamMemberList(
        widget.organizationId,
        widget.workspaceId,
        searchText: _memberSearchText.isNotEmpty ? _memberSearchText : null,
      );

      if (mounted) {
        setState(() {
          _members = (response['content'] as List).map((member) {
            final profile = member['profile'];
            return {
              'id': profile['id'],
              'fullName': profile['fullName'],
              'avatar': profile['avatar'],
              'isTeam': false,
              'teamId': member['teamId'],
            };
          }).toList();
          _isLoadingMembers = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingMembers = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Có lỗi xảy ra khi tải danh sách thành viên')),
        );
      }
    }
  }

  Future<void> _loadTeams() async {
    try {
      final response = await _teamRepository.getTeamList(
        widget.organizationId,
        widget.workspaceId,
      );

      if (mounted) {
        final allTeams = (response['content'] as List).map((team) {
          return {
            'id': team['id'],
            'fullName': team['name'],
            'isTeam': true,
          };
        }).toList();

        setState(() {
          if (_teamSearchText.isEmpty) {
            _teams = allTeams;
          } else {
            _teams = allTeams
                .where((team) => team['fullName']
                    .toLowerCase()
                    .contains(_teamSearchText.toLowerCase()))
                .toList();
          }
          _isLoadingTeams = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingTeams = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Có lỗi xảy ra khi tải danh sách đội')),
        );
      }
    }
  }

  Widget _buildSearchBar({
    required TextEditingController controller,
    required Function(String) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      height: 44,
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          isDense: true,
          constraints: const BoxConstraints(maxHeight: 40),
          hintText: 'Tìm kiếm',
          hintStyle: const TextStyle(fontSize: 14),
          prefixIconConstraints: const BoxConstraints(maxHeight: 40),
          prefixIcon: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Icon(Icons.search, size: 20),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }

  void _handleItemSelected(Map<String, dynamic> item) {
    final Map<String, dynamic> assignData = item['isTeam']
        ? {'teamId': item['id']}
        : {
            'assignTo': item['id'],
            'teamId': item['teamId'],
          };

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Chuyển phụ trách?'),
        content:
            Text('Bạn có chắc muốn phân phối data đến ${item['fullName']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext); // Đóng dialog trước
              await Future.delayed(const Duration(
                  milliseconds: 100)); // Đợi dialog đóng hoàn toàn
              if (!context.mounted) return;
              Navigator.pop(context); // Đóng bottom sheet sau
              widget.onSelected(
                  assignData); // Gọi callback với dữ liệu đã được format
            },
            child: const Text('Đồng ý'),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(Map<String, dynamic> item) {
    return ListTile(
      leading: AvatarWidget(
        width: 40,
        height: 40,
        imgUrl: item['avatar'],
        fallbackText: item['fullName'],
        borderRadius: 100,
      ),
      title: Text(
        item['fullName'] ?? '',
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xFF101828),
        ),
      ),
      onTap: () => _handleItemSelected(item),
    );
  }

  Widget _buildMembersList() {
    return Column(
      children: [
        _buildSearchBar(
          controller: _memberSearchController,
          onChanged: (value) {
            setState(() {
              _memberSearchText = value;
            });
            _loadMembers();
          },
        ),
        Expanded(
          child: _isLoadingMembers
              ? const Center(child: CircularProgressIndicator())
              : _members.isEmpty
                  ? const Center(
                      child: Text('Không tìm thấy thành viên nào'),
                    )
                  : ListView.builder(
                      itemCount: _members.length,
                      itemBuilder: (context, index) =>
                          _buildListItem(_members[index]),
                    ),
        ),
      ],
    );
  }

  Widget _buildTeamsList() {
    return Column(
      children: [
        _buildSearchBar(
          controller: _teamSearchController,
          onChanged: (value) {
            setState(() {
              _teamSearchText = value;
            });
            _loadTeams();
          },
        ),
        Expanded(
          child: _isLoadingTeams
              ? const Center(child: CircularProgressIndicator())
              : _teams.isEmpty
                  ? const Center(
                      child: Text('Không tìm thấy đội nào'),
                    )
                  : ListView.builder(
                      itemCount: _teams.length,
                      itemBuilder: (context, index) =>
                          _buildListItem(_teams[index]),
                    ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.8,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Chọn người phụ trách',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF101828),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: const Color(0xFF667085),
              indicatorColor: AppColors.primary,
              tabs: const [
                Tab(text: 'Thành viên'),
                Tab(text: 'Đội sale'),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildMembersList(),
                  _buildTeamsList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
