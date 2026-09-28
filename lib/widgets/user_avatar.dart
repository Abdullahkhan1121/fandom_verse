import 'package:flutter/material.dart';

import '../screens/theme/app_theme.dart';

/// Circular avatar with a gradient ring. Falls back to the first letter
/// of the name when there is no (http) photo.
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.name,
    this.photoUrl,
    this.radius = 20,
  });

  final String name;
  final String? photoUrl;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final url = (photoUrl ?? '').trim();
    final hasPhoto = url.startsWith('http');
    final letter = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : 'F';

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.primaryGradient,
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.surfaceHigh,
        backgroundImage: hasPhoto ? NetworkImage(url) : null,
        child: hasPhoto
            ? null
            : Text(
                letter,
                style: TextStyle(
                  fontSize: radius * 0.85,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
      ),
    );
  }
}
