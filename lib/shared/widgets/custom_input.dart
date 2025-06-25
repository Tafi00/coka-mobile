import 'package:flutter/material.dart';

class CustomInput extends StatelessWidget {
  final String? label;
  final String placeholder;
  final String? value;
  final Function(String) onChanged;
  final bool isRequired;
  final int maxLines;
  final TextInputType keyboardType;

  const CustomInput({
    Key? key,
    this.label,
    required this.placeholder,
    this.value,
    required this.onChanged,
    this.isRequired = false,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          RichText(
            text: TextSpan(
              text: label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1D2939),
              ),
              children: [
                if (isRequired)
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(color: Color(0xFFFF0000)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: TextEditingController(text: value),
            onChanged: onChanged,
            maxLines: maxLines,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: placeholder,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              hintStyle: const TextStyle(
                color: Color(0xFF667085),
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
} 