import 'dart:io';

import 'package:flutter/material.dart';

class ProfileAvatarPicker extends StatelessWidget {
  final File? image;
  final VoidCallback onTap;

  const ProfileAvatarPicker({
    Key? key,
    required this.image,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            height: 120,
            width: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[200],
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipOval(
              child:
                  image != null
                      ? Image.file(
                        image!,
                        fit: BoxFit.cover,
                        width: 120,
                        height: 120,
                      )
                      : Icon(Icons.person, size: 60, color: Colors.grey[400]),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFC87859), // Terracotta
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }
}
