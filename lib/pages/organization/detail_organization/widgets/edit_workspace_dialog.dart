import 'package:flutter/material.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../api/repositories/workspace_repository.dart';
import '../../../../api/api_client.dart';
import 'package:dio/dio.dart';

class EditWorkspaceDialog extends StatefulWidget {
  final String organizationId;
  final Map<String, dynamic> workspace;
  final VoidCallback? onWorkspaceUpdated;

  const EditWorkspaceDialog({
    super.key,
    required this.organizationId,
    required this.workspace,
    this.onWorkspaceUpdated,
  });

  @override
  State<EditWorkspaceDialog> createState() => _EditWorkspaceDialogState();
}

class _EditWorkspaceDialogState extends State<EditWorkspaceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  late final WorkspaceRepository _workspaceRepository;
  
  bool _isLoading = false;
  String _selectedScope = '0'; // 0: Riêng tư, 1: Công khai

  @override
  void initState() {
    super.initState();
    _workspaceRepository = WorkspaceRepository(ApiClient());
    
    // Khởi tạo dữ liệu từ workspace hiện tại
    _nameController.text = widget.workspace['name'] ?? '';
    _selectedScope = widget.workspace['scope']?.toString() ?? '0';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _updateWorkspace() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final res = await _workspaceRepository.updateWorkspace(
        organizationId: widget.organizationId,
        workspaceId: widget.workspace['id'],
        name: _nameController.text.trim(),
        scope: _selectedScope,
      );

      if (res['code'] == 0) {
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cập nhật workspace thành công!'),
              backgroundColor: Colors.green,
            ),
          );
          widget.onWorkspaceUpdated?.call();
        }
      } else {
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(res['message'] ?? 'Có lỗi xảy ra'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      String errMsg = 'Có lỗi xảy ra';
      if (e is DioException) {
        final data = e.response?.data;
        if (data is Map && data['message'] != null) {
          errMsg = data['message'];
        } else {
          errMsg = e.message ?? errMsg;
        }
      }

      if (mounted) {
        final rootCtx = Navigator.of(context, rootNavigator: true).context;
        Navigator.of(context).pop();
        ScaffoldMessenger.of(rootCtx).showSnackBar(
          SnackBar(
            content: Text(errMsg),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Chỉnh sửa workspace',
                        style: TextStyles.title,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Tên workspace
                const Text(
                  'Tên workspace',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Nhập tên workspace',
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                    filled: true,
                    fillColor: AppColors.backgroundTertiary,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.red, width: 1),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.red, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập tên workspace';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Chế độ workspace
                const Text(
                  'Chế độ workspace',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Radio buttons
                Column(
                  children: [
                    RadioListTile<String>(
                      value: '0',
                      groupValue: _selectedScope,
                      onChanged: (value) {
                        setState(() {
                          _selectedScope = value!;
                        });
                      },
                      title: const Text(
                        'Riêng tư',
                        style: TextStyle(fontSize: 14),
                      ),
                      subtitle: const Text(
                        'Chỉ thành viên được mời mới có thể truy cập',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                    RadioListTile<String>(
                      value: '1',
                      groupValue: _selectedScope,
                      onChanged: (value) {
                        setState(() {
                          _selectedScope = value!;
                        });
                      },
                      title: const Text(
                        'Công khai',
                        style: TextStyle(fontSize: 14),
                      ),
                      subtitle: const Text(
                        'Tất cả thành viên trong tổ chức có thể truy cập',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                        child: const Text(
                          'Hủy',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _updateWorkspace,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Cập nhật',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 