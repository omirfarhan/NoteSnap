import 'package:flutter/cupertino.dart';
import 'package:super_editor/super_editor.dart';

class CheckboxNode extends TextNode with ChangeNotifier{

  CheckboxNode({
    required String id,
    required AttributedText text,
    bool isChecked = false,
    Map<String, dynamic>? metadata,
  }) : _isChecked = isChecked,
        super(
        id: id,
        text: text,
        metadata: metadata ?? {},
      );

  bool _isChecked;
  bool get isChecked => _isChecked;
  set isChecked(bool value) {
    _isChecked = value;
    notifyListeners();
  }

  @override
  bool hasEquivalentContent(DocumentNode other) {
    return other is CheckboxNode &&
        text.text == other.text.text &&
        isChecked == other.isChecked;
  }

  @override
  DocumentNode copyAndReplaceMetadata(Map<String, dynamic> newMetadata) {
    return CheckboxNode(
      id: id,
      text: text,
      isChecked: _isChecked,
      metadata: newMetadata,
    );
  }

  @override
  DocumentNode copyWithAddedMetadata(Map<String, dynamic> newProperties) {
    return CheckboxNode(
      id: id,
      text: text,
      isChecked: _isChecked,
      metadata: {...metadata, ...newProperties},
    );
  }


}