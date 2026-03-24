
import 'dart:io';
import 'dart:typed_data' as td;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class SaveAsImage {
  static const double targetwidth=668;

  static Future<String> saveNoteAsImage({
    required Widget widget,
    required String filename,
  })async{
    final bytes=await _captureWidget(widget);

    final dir = Directory('/storage/emulated/0/Documents/MyNotes');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  /*
  static Future<Uint8List> _captureWidget(Widget widget) async{
    final repaintBoundary = RenderRepaintBoundary();

    final renderView = RenderView(
      child: RenderPositionedBox(
        alignment: Alignment.center,
        child: repaintBoundary,
      ),
      configuration: ViewConfiguration(
        logicalConstraints: BoxConstraints.tight(Size(1080, 1920)),
        physicalConstraints: BoxConstraints.tight(Size(1080 * 3.0, 1920 * 3.0)),
        devicePixelRatio: 3.0,
      ),
      view: WidgetsBinding.instance.platformDispatcher.views.first,
    );

    final pipelineOwner = PipelineOwner();
    final buildOwner = BuildOwner(focusManager: FocusManager());

    final rootElement = RenderObjectToWidgetAdapter<RenderBox>(
      container: repaintBoundary,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: widget,
      ),
    ).attachToRenderTree(buildOwner);

    buildOwner.buildScope(rootElement);
    buildOwner.finalizeTree();

    pipelineOwner.flushLayout();
    pipelineOwner.flushCompositingBits();
    pipelineOwner.flushPaint();

    final image = await repaintBoundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();

  }

   */


  // 🔥 CORE RENDER LOGIC (private)
  static Future<Uint8List> _captureWidget(Widget widget) async {
    final repaintBoundary = RenderRepaintBoundary();

    final renderView = RenderView(
      child: RenderPositionedBox(
        alignment: Alignment.topCenter,
        child: repaintBoundary,
      ),
      configuration: ViewConfiguration(
        logicalConstraints: const BoxConstraints(maxWidth: targetwidth),
        physicalConstraints: const BoxConstraints(maxWidth: targetwidth),
        devicePixelRatio: 1.0,
      ),
      view: WidgetsBinding.instance.platformDispatcher.views.first,
    );

    final pipelineOwner = PipelineOwner();
    final buildOwner = BuildOwner(focusManager: FocusManager());

    pipelineOwner.rootNode = renderView;
    renderView.prepareInitialFrame();

    final rootElement = RenderObjectToWidgetAdapter<RenderBox>(
      container: repaintBoundary,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: widget,
      ),
    ).attachToRenderTree(buildOwner);

    buildOwner.buildScope(rootElement);
    buildOwner.finalizeTree();

    pipelineOwner.flushLayout();
    pipelineOwner.flushCompositingBits();
    pipelineOwner.flushPaint();

    final image = await repaintBoundary.toImage(pixelRatio: 1.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    // 🔥 IMPORTANT FIX
    if (byteData == null) {
      throw Exception("Failed to convert image to bytes");
    }

    return byteData.buffer.asUint8List();
  }

}
