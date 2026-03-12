import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:notes/ui/notebottomcomponent/checkbox/checkbox_component.dart';
import 'package:notes/ui/notebottomcomponent/checkbox/checkbox_node.dart';
import 'package:super_editor/super_editor.dart';

class CheckboxComponentBuilder implements ComponentBuilder {
  final void Function(String nodeId, bool isChecked) onCheckChanged;

  const CheckboxComponentBuilder({required this.onCheckChanged});

  @override
  SingleColumnLayoutComponentViewModel? createViewModel(
      Document document, DocumentNode node) {
    if (node is! CheckboxNode) return null;

    return CheckboxComponentViewModel(
      nodeId: node.id,
      text: node.text,
      isChecked: node.isChecked,
      //createdAt: node.createdAt,
    );
  }

  @override
  Widget? createComponent(
      SingleColumnDocumentComponentContext componentContext,
      SingleColumnLayoutComponentViewModel componentViewModel) {

    if (componentViewModel is! CheckboxComponentViewModel) return null;

    return CheckboxComponent(
      key: componentContext.componentKey,
      node: componentViewModel.node,
      isChecked: componentViewModel.isChecked,
      onCheckChange: (value) =>
          onCheckChanged(componentViewModel.nodeId, value),
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