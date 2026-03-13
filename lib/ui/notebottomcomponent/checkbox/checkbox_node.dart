import 'package:flutter/cupertino.dart';
import 'package:super_editor/super_editor.dart';

class CheckboxNode extends TextNode with ChangeNotifier {
  CheckboxNode({
    required String id,
    required AttributedText text,
    bool isChecked = false,
  })  : _isChecked = isChecked,
        super(id: id, text: text);

  bool _isChecked;

  bool get isChecked => _isChecked;

  set isChecked(bool value) {
    if (_isChecked == value) return;
    _isChecked = value;
    notifyListeners();
  }
}