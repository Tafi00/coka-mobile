import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:coka/core/utils/helpers.dart';

class AvatarWidget extends StatelessWidget {
  final String? imgUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? errorWidget;
  final double? borderRadius;
  final String? fallbackText;
  final BoxBorder? outline;

  const AvatarWidget({
    super.key,
    this.imgUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.errorWidget,
    this.borderRadius,
    this.fallbackText,
    this.outline,
  });

  String _getDisplayText() {
    if (fallbackText == null || fallbackText!.isEmpty) return '';

    final words = fallbackText!.trim().split(' ');
    if (words.length == 1) {
      return words[0][0].toUpperCase();
    }

    return '${words.first[0]}${words.last[0]}'.toUpperCase();
  }

  static Widget _buildShimmerAvatar(double radius, [double? borderRadius]) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: borderRadius != null ? BoxShape.rectangle : BoxShape.circle,
          borderRadius:
              borderRadius != null ? BorderRadius.circular(borderRadius) : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (imgUrl == null || imgUrl!.isEmpty) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: fallbackText != null
              ? Helpers.getColorFromText(fallbackText!)
              : Colors.grey[300],
          borderRadius: BorderRadius.circular(borderRadius ?? 0),
          border: outline,
        ),
        child: Center(
          child: Text(
            _getDisplayText(),
            style: TextStyle(
              color: Colors.white,
              fontSize: (width ?? 40) * 0.4,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius ?? 0),
        border: outline,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius ?? 0),
        child: CachedNetworkImage(
          imageUrl: Helpers.getAvatarUrl(imgUrl!),
          width: width,
          height: height,
          fit: fit,
          placeholder: (context, url) => _buildShimmerAvatar(
              width != null ? width! / 2 : 20, borderRadius),
          errorWidget: (context, url, error) =>
              errorWidget ?? const Icon(Icons.error),
        ),
      ),
    );
  }
}

class CircleAvatarWidget extends StatelessWidget {
  final String? imgData;
  final double radius;
  final String? fallbackText;
  final Color backgroundColor;

  const CircleAvatarWidget({
    super.key,
    this.imgData,
    this.radius = 20,
    this.fallbackText,
    this.backgroundColor = Colors.blue,
  });

  String _getDisplayText() {
    if (fallbackText == null || fallbackText!.isEmpty) return '';

    final words = fallbackText!.trim().split(' ');
    if (words.length == 1) {
      return words[0][0].toUpperCase();
    }

    return '${words.first[0]}${words.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    if (imgData == null || imgData!.isEmpty) {
      return Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            _getDisplayText(),
            style: TextStyle(
              color: Colors.white,
              fontSize: radius * 0.7,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    return ClipOval(
      child: SizedBox(
        width: radius * 2,
        height: radius * 2,
        child: CachedNetworkImage(
          imageUrl: Helpers.getAvatarUrl(imgData!),
          fit: BoxFit.cover,
          placeholder: (context, url) =>
              AvatarWidget._buildShimmerAvatar(radius),
          errorWidget: (context, url, error) => Container(
            width: radius * 2,
            height: radius * 2,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                _getDisplayText(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: radius * 0.7,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
