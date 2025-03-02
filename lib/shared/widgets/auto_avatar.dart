import 'package:flutter/material.dart';

ImageProvider getAvatarProvider(String? url) {
  if (url == null || url.isEmpty) {
    return const AssetImage('assets/images/default_avatar.png');
  }
  return NetworkImage(url);
}

Widget createCircleAvatar({
  required String name,
  required double radius,
  required double fontSize,
}) {
  return CircleAvatar(
    radius: radius,
    backgroundColor: Colors.grey[300],
    child: Text(
      name.isNotEmpty ? name[0].toUpperCase() : '?',
      style: TextStyle(
        color: Colors.black87,
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
