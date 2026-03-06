import 'package:flutter/material.dart';
import 'package:super_editor/super_editor.dart';

import 'note_image_component.dart';

class NoteImageComponentBuilder implements ComponentBuilder {
  final void Function(String imagePath, GlobalKey imageKey) onImageTap;
  const NoteImageComponentBuilder({required this.onImageTap});

  @override
  SingleColumnLayoutComponentViewModel? createViewModel(
      Document document, DocumentNode node) {
    if (node is! ImageNode) return null;
    return ImageComponentViewModel(
      nodeId: node.id,
      imageUrl: node.imageUrl,
      selectionColor: Colors.transparent,
    );
  }

  @override
  Widget? createComponent(
      SingleColumnDocumentComponentContext componentContext,
      SingleColumnLayoutComponentViewModel componentViewModel) {
    if (componentViewModel is! ImageComponentViewModel) return null;

    final imagePath = componentViewModel.imageUrl;

    final imageKey = GlobalKey();   // 👈 এখানে key তৈরি
    return NoteImageComponent(
      key: componentContext.componentKey,
      imagePath: imagePath,
      imageKey: imageKey,
      onTap: () => onImageTap(imagePath,imageKey),
    );
  }

}