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
    with DocumentComponent<CheckboxComponent>{

  //final _textKey = GlobalKey();

  // @override
  // GlobalKey get childDocumentComponentKey => _textKey;

  @override
  TextComposable get childTextComposable {
    // null check যোগ করুন
    final state = _textKey.currentState;
    if (state == null) {
      throw Exception('TextComponent state is null');
    }
    return state as TextComposable;
  }


  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => widget.onCheckChange(!widget.isChecked),
          child: Container(
            width: 15,
            height: 15,
            margin: const EdgeInsets.only(right: 8, top: 2),
            decoration: BoxDecoration(
              border: Border.all(color: Color(0xFFD2FEFF), width: 1.5),
              borderRadius: BorderRadius.circular(4),
              color: widget.isChecked
                  ? Color(0xFFD2FEFF).withOpacity(0.3)
                  : Colors.transparent,
            ),
            child: widget.isChecked
                ? Icon(Icons.check, size: 10, color: Color(0xFFD2FEFF))
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


  final GlobalKey<TextComponentState> _textKey = GlobalKey();

  TextComponentState get _text => _textKey.currentState!;

  @override
  NodePosition getBeginningPosition() {
    return _text.getBeginningPosition();
  }

  @override
  NodePosition getBeginningPositionNearX(double x) {
    return _text.getBeginningPositionNearX(x);
  }

  @override
  NodeSelection getCollapsedSelectionAt(NodePosition nodePosition) {
    return _text.getCollapsedSelectionAt(nodePosition);
  }

  @override
  MouseCursor? getDesiredCursorAtOffset(Offset localOffset) {
    return _text.getDesiredCursorAtOffset(localOffset);
  }

  @override
  Rect getEdgeForPosition(NodePosition nodePosition) {
    return _text.getEdgeForPosition(nodePosition);
  }

  @override
  NodePosition getEndPosition() {
    return _text.getEndPosition();
  }

  @override
  NodePosition getEndPositionNearX(double x) {
    return _text.getEndPositionNearX(x);
  }

  @override
  Offset getOffsetForPosition(NodePosition nodePosition) {
    return _text.getOffsetForPosition(nodePosition);
  }

  @override
  NodePosition? getPositionAtOffset(Offset localOffset) {
    return _text.getPositionAtOffset(localOffset);
  }

  @override
  Rect getRectForPosition(NodePosition nodePosition) {
    return _text.getRectForPosition(nodePosition);
  }

  @override
  Rect getRectForSelection(NodePosition baseNodePosition, NodePosition extentNodePosition) {
    return _text.getRectForSelection(baseNodePosition, extentNodePosition);
  }

  @override
  NodeSelection getSelectionBetween({
    required NodePosition basePosition,
    required NodePosition extentPosition,
  }) {
    return _text.getSelectionBetween(
      basePosition: basePosition,
      extentPosition: extentPosition,
    );
  }

  @override
  NodeSelection? getSelectionInRange(Offset localBaseOffset, Offset localExtentOffset) {
    return _text.getSelectionInRange(localBaseOffset, localExtentOffset);
  }

  @override
  NodeSelection getSelectionOfEverything() {
    return _text.getSelectionOfEverything();
  }

  @override
  NodePosition? movePositionDown(NodePosition currentPosition) {
    return _text.movePositionDown(currentPosition);
  }

  @override
  NodePosition? movePositionLeft(NodePosition currentPosition, [MovementModifier? movementModifier]) {
    return _text.movePositionLeft(currentPosition, movementModifier);
  }

  @override
  NodePosition? movePositionRight(NodePosition currentPosition, [MovementModifier? movementModifier]) {
    return _text.movePositionRight(currentPosition, movementModifier);
  }

  @override
  NodePosition? movePositionUp(NodePosition currentPosition) {
    return _text.movePositionUp(currentPosition);
  }


}
