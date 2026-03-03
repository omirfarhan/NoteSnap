
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class ImageEmbedBuilder extends EmbedBuilder {
  @override
  String get key => BlockEmbed.imageType;

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    final imagePath = embedContext.node.value.data;

    return Padding(
      padding: const EdgeInsets.only(top: 6,bottom: 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: AspectRatio(
          aspectRatio: 16/9,
          child: Image.file(
            File(imagePath),

            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }
}
