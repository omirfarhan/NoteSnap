import 'dart:io';
import 'package:flutter/material.dart';
import 'package:super_editor/super_editor.dart';

class NoteImageComponent extends StatefulWidget {
  final ImageNode node;
  final String imagePath;
  final VoidCallback onTap;
  final GlobalKey imageKey;

  const NoteImageComponent({
    super.key,
    required this.node,
    required this.imagePath,
    required this.onTap,
    required this.imageKey,
  });

  @override
  State<NoteImageComponent> createState() => _NoteImageComponentState();
}

class _NoteImageComponentState extends State<NoteImageComponent>
    with DocumentComponent<NoteImageComponent> {

  @override
  DocumentNode get node => widget.node;

  RenderBox? get _renderBox =>
      context.findRenderObject() as RenderBox?;

  Rect? getRectForPossition(DocumentPosition position){
    final box=_renderBox;
    if(box == null) return null;

    final offset=box.localToGlobal(Offset.zero);
    return offset & box.size;
  }


  @override
  Offset getOffsetPossition(DocumentPosition position){
    return Offset.zero;
  }

  @override
  DocumentPosition getDocumentAtOffset(Offset localOffset){
    return DocumentPosition(
        nodeId: widget.node.id,
        nodePosition: const UpstreamDownstreamNodePosition.upstream()
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical:6),
      child: GestureDetector(
        onTap: widget.onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: AspectRatio(
            aspectRatio: 16 / 9,   // screenshot এর মতো
            child: Image.file(
              File(widget.imagePath),
              key: widget.imageKey,
              fit: BoxFit.cover,   // image crop করে container fill করবে
              width: double.infinity,
            ),
          ),
        ),
      ),
    );
  }

  @override
  NodePosition getBeginningPosition() {
    // TODO: implement getBeginningPosition
    throw UnimplementedError();
  }

  @override
  NodePosition getBeginningPositionNearX(double x) {
    // TODO: implement getBeginningPositionNearX
    throw UnimplementedError();
  }

  @override
  NodeSelection getCollapsedSelectionAt(NodePosition nodePosition) {
    // TODO: implement getCollapsedSelectionAt
    throw UnimplementedError();
  }

  @override
  MouseCursor? getDesiredCursorAtOffset(Offset localOffset) {
    // TODO: implement getDesiredCursorAtOffset
    throw UnimplementedError();
  }

  @override
  Rect getEdgeForPosition(NodePosition nodePosition) {
    // TODO: implement getEdgeForPosition
    throw UnimplementedError();
  }

  @override
  NodePosition getEndPosition() {
    // TODO: implement getEndPosition
    throw UnimplementedError();
  }

  @override
  NodePosition getEndPositionNearX(double x) {
    // TODO: implement getEndPositionNearX
    throw UnimplementedError();
  }

  @override
  Offset getOffsetForPosition(NodePosition nodePosition) {
    // TODO: implement getOffsetForPosition
    throw UnimplementedError();
  }

  @override
  NodePosition? getPositionAtOffset(Offset localOffset) {
    // TODO: implement getPositionAtOffset
    throw UnimplementedError();
  }

  @override
  Rect getRectForPosition(NodePosition nodePosition) {
    // TODO: implement getRectForPosition
    throw UnimplementedError();
  }

  @override
  Rect getRectForSelection(NodePosition baseNodePosition, NodePosition extentNodePosition) {
    // TODO: implement getRectForSelection
    throw UnimplementedError();
  }

  @override
  NodeSelection getSelectionBetween({required NodePosition basePosition, required NodePosition extentPosition}) {
    // TODO: implement getSelectionBetween
    throw UnimplementedError();
  }

  @override
  NodeSelection? getSelectionInRange(Offset localBaseOffset, Offset localExtentOffset) {
    // TODO: implement getSelectionInRange
    throw UnimplementedError();
  }

  @override
  NodeSelection getSelectionOfEverything() {
    // TODO: implement getSelectionOfEverything
    throw UnimplementedError();
  }

  @override
  NodePosition? movePositionDown(NodePosition currentPosition) {
    // TODO: implement movePositionDown
    throw UnimplementedError();
  }

  @override
  NodePosition? movePositionLeft(NodePosition currentPosition, [MovementModifier? movementModifier]) {
    // TODO: implement movePositionLeft
    throw UnimplementedError();
  }

  @override
  NodePosition? movePositionRight(NodePosition currentPosition, [MovementModifier? movementModifier]) {
    // TODO: implement movePositionRight
    throw UnimplementedError();
  }

  @override
  NodePosition? movePositionUp(NodePosition currentPosition) {
    // TODO: implement movePositionUp
    throw UnimplementedError();
  }
}