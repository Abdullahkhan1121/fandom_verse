import 'dart:convert';
import 'package:flutter/material.dart';

class FandomImage extends StatelessWidget {
  const FandomImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.height,
    this.width,
  });

  final String imageUrl;
  final BoxFit fit;
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final value = imageUrl.trim();

    if (value.isEmpty) {
      return _placeholder();
    }

    // Normal image URL
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return Image.network(
        value,
        fit: fit,
        height: height,
        width: width,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }

    // Base64 image, with or without a data URI prefix
    try {
      final base64String = value.startsWith('data:image/')
          ? value.substring(value.indexOf(',') + 1)
          : value;

      final bytes = base64Decode(base64String.replaceAll(RegExp(r'\s+'), ''));

      return Image.memory(
        bytes,
        fit: fit,
        height: height,
        width: width,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    } catch (_) {
      return _placeholder();
    }
  }

  Widget _placeholder() {
    return Container(
      height: height,
      width: width,
      color: Colors.grey.shade900,
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_not_supported_outlined,
        size: 40,
        color: Colors.white54,
      ),
    );
  }
}
