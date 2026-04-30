
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../methodChannelStorageService/storage_service.dart';

class SaveAsImage {
  static const double targetwidth=668;

  static Future<String> saveNoteAsImage({
    required Widget widget,
    required String filename,
  })async{
    final bytes=await captureWidget(widget);

    final path = await StorageService.saveImageFile(
      fileName: filename,
      bytes: bytes,
    );

    return path;
  }



  static Future<Uint8List> captureWidget(Widget widget, {
    double width = 668, double minHeight = 1280
  }) async {
    final repaintBoundary = RenderRepaintBoundary();

    final renderView = RenderView(
      child: RenderPositionedBox(
        alignment: Alignment.topCenter,
        child: repaintBoundary,
      ),
      configuration: ViewConfiguration(

        logicalConstraints: BoxConstraints(
          maxWidth: targetwidth,
          maxHeight: double.infinity,
          minHeight: minHeight
        ),

        physicalConstraints: BoxConstraints(
          maxWidth: targetwidth,
          maxHeight: double.infinity,
          minHeight: minHeight
        ),

        devicePixelRatio: 2.0,
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

    final image = await repaintBoundary.toImage(pixelRatio: 2.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData == null) {
      throw Exception("Failed to convert image to bytes");
    }
    return byteData.buffer.asUint8List();
  }

  static Future<void> shareImage(Uint8List bytes)async{
    final tempDir=await getTemporaryDirectory();
    final file = File('${tempDir.path}/note.png');
    await file.writeAsBytes(bytes);
    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'My Note',
    );
  }

}
