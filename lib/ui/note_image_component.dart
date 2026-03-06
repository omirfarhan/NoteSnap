import 'dart:io';
import 'package:flutter/material.dart';

class NoteImageComponent extends StatefulWidget {
  final String imagePath;
  final VoidCallback onTap;
  final GlobalKey imageKey;

  const NoteImageComponent({
    super.key,
    required this.imagePath,
    required this.onTap,
    required this.imageKey,
  });

  @override
  State<NoteImageComponent> createState() => _NoteImageComponentState();
}

class _NoteImageComponentState extends State<NoteImageComponent> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical:6),
      child: GestureDetector(
        onTap: widget.onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: AspectRatio(
            aspectRatio: 16/9,
            child: Image.file(
              File(widget.imagePath),
              key: widget.imageKey,
              fit: BoxFit.fill,
            ),
          ),
        ),
      ),
    );
  }
}