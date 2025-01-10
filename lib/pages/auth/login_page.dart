import 'package:coka/core/constants/app_constants.dart';
import 'package:coka/core/theme/app_colors.dart';
import 'package:coka/core/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 24.0, left: 16, right: 16),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Image.asset(
                '${AppConstants.imagePath}/coka_login.png',
                height: 80,
              ),
              const SizedBox(height: 12),
              Text(
                'Đăng nhập',
                style: TextStyles.heading1,
              ),
              const SizedBox(height: 8),
              Text(
                'Chào mừng đến với ứng dụng COKA',
                style: TextStyles.body,
              ),
              const SizedBox(height: 28),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: TextStyles.label,
                      children: [
                        TextSpan(
                          text: 'Email ',
                        ),
                        TextSpan(
                          text: '*',
                          style: TextStyle(
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Nhập Email của bạn',
                      filled: true,
                      fillColor: AppColors.backgroundSecondary,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Đăng nhập'),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: Colors.grey.shade300,
                      thickness: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      'Hoặc đăng nhập bằng',
                      style: TextStyles.body.copyWith(
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: Colors.grey.shade300,
                      thickness: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSocialButton('google_icon.png', 'Google'),
                  const SizedBox(height: 14),
                  _buildSocialButton('facebook_icon.png', 'Facebook'),
                  const SizedBox(height: 14),
                  _buildSocialButton('apple_icon.png', 'Apple'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(String iconName, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Image.asset(
            '${AppConstants.imagePath}/$iconName',
            height: 24,
            width: 24,
          ),
          const SizedBox(width: 8),
          Text(
            'Đăng nhập bằng $label',
            style: TextStyles.body,
          ),
        ],
      ),
    );
  }
}
