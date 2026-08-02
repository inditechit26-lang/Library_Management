import 'dart:convert';
import 'package:flutter/material.dart';

class CustomQrImageView extends StatelessWidget {
  final String url;
  final double width;
  final double height;
  final Widget fallback;
  final BoxFit fit;

  const CustomQrImageView({
    super.key,
    required this.url,
    required this.width,
    required this.height,
    required this.fallback,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    if (url.trim().isEmpty) return fallback;
    final cleanUrl = url.trim();

    if (cleanUrl.startsWith('data:')) {
      try {
        final commaIndex = cleanUrl.indexOf(',');
        final base64Content = commaIndex != -1 ? cleanUrl.substring(commaIndex + 1) : cleanUrl;
        final bytes = base64Decode(base64Content);
        return Image.memory(
          bytes,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (_, __, ___) => fallback,
        );
      } catch (_) {
        return fallback;
      }
    }

    return Image.network(
      cleanUrl,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => fallback,
    );
  }
}
