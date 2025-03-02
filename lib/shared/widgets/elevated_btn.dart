import 'package:flutter/material.dart';

class ElevatedBtn extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final double circular;
  final double paddingAllValue;
  final Color? backgroundColor;

  const ElevatedBtn({
    super.key,
    required this.onPressed,
    required this.child,
    this.circular = 8,
    this.paddingAllValue = 8,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? Colors.white,
        padding: EdgeInsets.all(paddingAllValue),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(circular),
        ),
        elevation: 0,
      ),
      child: child,
    );
  }
}
