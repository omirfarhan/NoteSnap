import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:notes/ui/notebottomcomponent/checkbox/checkbox_component.dart';
import 'package:notes/ui/notebottomcomponent/checkbox/checkbox_node.dart';
import 'package:super_editor/super_editor.dart';

class CheckboxComponentBuilder implements ComponentBuilder {
  const CheckboxComponentBuilder({required this.onCheckChanged});

  final void Function(String nodeId, bool isChecked) onCheckChanged;

  @override
  SingleColumnLayoutComponentViewModel? createViewModel(
      Document document, DocumentNode node) {
    if (node is! ParagraphNode) return null;

    final blockType = node.metadata['blockType'];
    if (blockType is! NamedAttribution || blockType.id != 'checkbox') {
      return null;
    }

    return CheckboxComponentViewModel(
      nodeId: node.id,
      text: node.text,
      isChecked: node.metadata['checked'] as bool? ?? false,
    );
  }

  @override
  Widget? createComponent(
      SingleColumnDocumentComponentContext context,
      SingleColumnLayoutComponentViewModel viewModel) {
    if (viewModel is! CheckboxComponentViewModel) return null;

    return CheckboxComponent(
      key: context.componentKey,
      text: viewModel.text,
      isChecked: viewModel.isChecked,
      onCheckChange: (val) => onCheckChanged(viewModel.nodeId, val),
    );
  }
}


class CheckboxComponentViewModel extends SingleColumnLayoutComponentViewModel {
  final CheckboxNode node;
  final AttributedText text;
  final bool isChecked;
  //final DateTime createdAt;

  CheckboxComponentViewModel({
    required String nodeId,
    required this.text,
    required this.isChecked,
    //required this.createdAt,
  })  : node = CheckboxNode(
    id: nodeId,
    text: text,
    isChecked: isChecked,

  ),
        super(
        nodeId: nodeId,
        createdAt: DateTime.now(),
        maxWidth: double.infinity,
        padding: EdgeInsets.zero,
      );

  @override
  CheckboxComponentViewModel copy() {
    return CheckboxComponentViewModel(
      nodeId: nodeId,
      text: text,
      isChecked: isChecked,
      // createdAt: createdAt,
    );
  }
}