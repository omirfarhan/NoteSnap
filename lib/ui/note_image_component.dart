import 'dart:io';
import 'package:flutter/material.dart';

class NoteImageComponent extends StatelessWidget {
  final String imagePath;
  final VoidCallback onTap;

  const NoteImageComponent({
    super.key,
    required this.imagePath,
    required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical:6),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap, // editor focus যাবে না → keyboard আসবে না
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.file(
              File(imagePath),
              fit: BoxFit.fill,
            ),
          ),
        ),
      ),
    );
  }
}
