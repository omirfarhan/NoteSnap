import 'package:flutter/material.dart';
import 'package:notes/ui/notebottomcomponent/checkbox/checkbox_node.dart';
import 'package:super_editor/super_editor.dart';

class CheckboxComponent extends StatefulWidget {
  final AttributedText text;
  final bool isChecked;
  final ValueChanged<bool> onCheckChange;

  const CheckboxComponent({
    super.key,
    required this.text,
    required this.isChecked,
    required this.onCheckChange,
  });

  @override
  State<CheckboxComponent> createState() => _CheckboxComponentState();
}

class _CheckboxComponentState extends State<CheckboxComponent>
    with DocumentComponent<CheckboxComponent> {

  @override
  NodePosition getBeginningPosition() => const TextNodePosition(offset: 0);

  @override
  NodePosition getEndPosition() => TextNodePosition(offset: widget.text.text.length);

  @override
  NodePosition getBeginningPositionNearX(double x) => const TextNodePosition(offset: 0);

  @override
  NodePosition getEndPositionNearX(double x) => TextNodePosition(offset: widget.text.text.length);

  @override
  NodePosition? getPositionAtOffset(Offset localOffset) => const TextNodePosition(offset: 0);

  @override
  NodePosition? movePositionLeft(NodePosition currentPosition, [MovementModifier? movementModifier]) => null;

  @override
  NodePosition? movePositionRight(NodePosition currentPosition, [MovementModifier? movementModifier]) => null;

  @override
  NodePosition? movePositionUp(NodePosition currentPosition) => null;

  @override
  NodePosition? movePositionDown(NodePosition currentPosition) => null;

  @override
  NodeSelection getCollapsedSelectionAt(NodePosition nodePosition) =>
      TextNodeSelection.collapsed(offset: (nodePosition as TextNodePosition).offset);

  @override
  NodeSelection getSelectionBetween({
    required NodePosition basePosition,
    required NodePosition extentPosition,
  }) => TextNodeSelection(
    baseOffset: (basePosition as TextNodePosition).offset,
    extentOffset: (extentPosition as TextNodePosition).offset,
  );

  @override
  NodeSelection? getSelectionInRange(Offset localBaseOffset, Offset localExtentOffset) =>
      const TextNodeSelection.collapsed(offset: 0);

  @override
  NodeSelection getSelectionOfEverything() => TextNodeSelection(
    baseOffset: 0,
    extentOffset: widget.text.text.length,
  );

  @override
  MouseCursor? getDesiredCursorAtOffset(Offset localOffset) => SystemMouseCursors.text;

  @override
  Rect getRectForPosition(NodePosition nodePosition) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return Rect.zero;
    return Rect.fromLTWH(0, 0, 1, box.size.height);
  }

  @override
  Rect getRectForSelection(NodePosition baseNodePosition, NodePosition extentNodePosition) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return Rect.zero;
    return Rect.fromLTWH(0, 0, 1, box.size.height);
  }

  @override
  Rect getEdgeForPosition(NodePosition nodePosition) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return Rect.zero;
    return Rect.fromLTWH(0, 0, 1, box.size.height);
  }

  @override
  Offset getOffsetForPosition(NodePosition nodePosition) => Offset.zero;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onCheckChange(!widget.isChecked),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 15,
              height: 15,
              margin: const EdgeInsets.only(right: 8, top: 2),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFD2FEFF), width: 1.5),
                borderRadius: BorderRadius.circular(4),
                color: widget.isChecked
                    ? const Color(0xFFD2FEFF).withOpacity(0.3)
                    : Colors.transparent,
              ),
              child: widget.isChecked
                  ? const Icon(Icons.check, size: 10, color: Color(0xFFD2FEFF))
                  : null,
            ),
            Expanded(
              child: Text(
                widget.text.text,
                style: TextStyle(
                  color: widget.isChecked
                      ? const Color(0xFFD2FEFF).withOpacity(0.5)
                      : const Color(0xFFD2FEFF),
                  fontFamily: 'Regular',
                  fontSize: 16,
                  decoration: widget.isChecked
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  decorationColor: const Color(0xFFD2FEFF),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}