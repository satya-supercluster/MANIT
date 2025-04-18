import 'dart:convert';
import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final String? base64Image;

  const ProfileAvatar({super.key, this.base64Image});

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (base64Image != null && base64Image != 'N/A' && base64Image!.trim().isNotEmpty) {
      // strip off data URI prefix if present:
      final comma = base64Image!.indexOf(',');
      final rawString = (comma != -1) ? base64Image!.substring(comma + 1) : base64Image!;
      try {
        final bytes = base64Decode(rawString);
        child = Image.memory(
          bytes,
          fit: BoxFit.fill,
          width: 100,
          height: 100,
        );
      } catch (e) {
        // decode failed → fallback
        child = const Icon(
          Icons.person,
          size: 80,
          color: Colors.white70,
        );
      }
    } else {
      // no image string → fallback
      child = const Icon(
        Icons.person,
        size: 80,
        color: Colors.white70,
      );
    }

    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(60),
        child: child,
      ),
    );
  }
}
