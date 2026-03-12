import 'package:flutter/material.dart';
import 'package:notes/ui/notebottomcomponent/checkbox/checkbox_node.dart';
import 'package:super_editor/super_editor.dart';

class CheckboxComponent extends StatefulWidget {
  final CheckboxNode node;
  final bool isChecked;
  final ValueChanged<bool> onCheckChange;
  const CheckboxComponent({
    super.key,
    required this.node,
    required this.isChecked,
    required this.onCheckChange
  });

  @override
  State<CheckboxComponent> createState() => _CheckboxComponentState();
}

class _CheckboxComponentState extends State<CheckboxComponent>
    with DocumentComponent, ProxyDocumentComponent<CheckboxComponent>,
        ProxyTextComposable{

  final _textKey = GlobalKey();

  @override
  GlobalKey get childDocumentComponentKey => _textKey;

  @override
  TextComposable get childTextComposable =>
      _textKey.currentState as TextComposable;


  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => widget.onCheckChange(!widget.isChecked),
          child: Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.only(right: 8, top: 2),
            decoration: BoxDecoration(
              border: Border.all(color: Color(0xFFD2FEFF), width: 1.5),
              borderRadius: BorderRadius.circular(4),
              color: widget.isChecked
                  ? Color(0xFFD2FEFF).withOpacity(0.3)
                  : Colors.transparent,
            ),
            child: widget.isChecked
                ? Icon(Icons.check, size: 14, color: Color(0xFFD2FEFF))
                : null,
          ),
        ),
        Expanded(
          child: TextComponent(
            key: _textKey,
            text: widget.node.text,
            textStyleBuilder: (_) => TextStyle(
              color: widget.isChecked
                  ? Color(0xFFD2FEFF).withOpacity(0.5)
                  : Color(0xFFD2FEFF),
              fontFamily: 'Regular',
              fontSize: 16,
              decoration: widget.isChecked
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
            ),
          ),
        ),
      ],
    );
  }


}
