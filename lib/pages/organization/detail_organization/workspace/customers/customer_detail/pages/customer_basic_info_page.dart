import 'package:flutter/material.dart';
import '../../../../../../../core/theme/app_colors.dart';
import '../../../../../../../core/theme/text_styles.dart';
import '../../../../../../../shared/widgets/avatar_widget.dart';

class CustomerBasicInfoPage extends StatelessWidget {
  final Map<String, dynamic> customerDetail;

  const CustomerBasicInfoPage({
    super.key,
    required this.customerDetail,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Thông tin cơ bản',
          style: TextStyle(
            color: AppColors.text,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                children: [
                  AvatarWidget(
                    fallbackText: customerDetail['fullName'] ?? '',
                    imgUrl: customerDetail['avatar'],
                    width: 80,
                    height: 80,
                    borderRadius: 40,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    customerDetail['fullName'] ?? '',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                  if (customerDetail['gender'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        customerDetail['gender'] == 1
                            ? 'Nam'
                            : customerDetail['gender'] == 0
                                ? 'Nữ'
                                : 'Khác',
                        style: TextStyles.subtitle3,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: customerDetail['email'] ?? 'Chưa cập nhật',
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(
                    icon: Icons.phone_outlined,
                    label: 'Số điện thoại',
                    value: customerDetail['phone'] ?? 'Chưa cập nhật',
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(
                    icon: Icons.location_on_outlined,
                    label: 'Địa chỉ',
                    value: customerDetail['address'] ?? 'Chưa cập nhật',
                  ),
                  if (customerDetail['birthday'] != null) ...[
                    const Divider(height: 24),
                    _buildInfoRow(
                      icon: Icons.cake_outlined,
                      label: 'Ngày sinh',
                      value: customerDetail['birthday'],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
