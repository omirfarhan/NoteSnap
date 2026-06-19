import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class Imagetopdf {

  // sharpness — 2.5–3.0 gives crisp, print-quality text without huge files.
  Future<({Uint8List bytes, double height})> renderTextToImage({
    required String text,
    required String fontFamily,
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
    required double maxWidthPoints,
    double lineHeight = 1.35,
    double pixelRatio = 2.5,
  }) async {
    final scaledFontSize = fontSize * pixelRatio;
    final scaledMaxWidth = maxWidthPoints * pixelRatio;

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontFamily: fontFamily,
          fontSize: scaledFontSize,
          fontWeight: fontWeight,
          color: color,
          height: lineHeight,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
      textWidthBasis: TextWidthBasis.parent, // keeps painter.width == maxWidth
    )..layout(maxWidth: scaledMaxWidth);

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromLTWH(0, 0, textPainter.width, textPainter.height),
    );

    textPainter.paint(canvas, Offset.zero);

    final picture = recorder.endRecording();
    final image = await picture.toImage(
      textPainter.width.ceil(),
      textPainter.height.ceil(),
    );
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    picture.dispose();

    return (
    bytes: byteData!.buffer.asUint8List(),
    height: textPainter.height / pixelRatio, // back to PDF points
    );
  }

}