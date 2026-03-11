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


  @override
  Rect getRectForPosition(NodePosition nodePosition) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return Rect.zero;
    return Offset.zero & box.size;
  }

  @override
  Rect getEdgeForPosition(NodePosition nodePosition) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return Rect.zero;
    return Offset.zero & box.size;
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
    return const UpstreamDownstreamNodePosition.upstream();
  }

  @override
  NodePosition getBeginningPositionNearX(double x) {
    return const UpstreamDownstreamNodePosition.upstream();
  }

//eta ektu change hoise
  @override
  NodeSelection getCollapsedSelectionAt(NodePosition nodePosition) {
    return const UpstreamDownstreamNodeSelection.collapsedUpstream();
  }


  @override
  NodePosition getEndPosition() {
    return const UpstreamDownstreamNodePosition.downstream();
  }

  @override
  NodePosition getEndPositionNearX(double x) {
    return const UpstreamDownstreamNodePosition.downstream();
  }




  @override
  Offset getOffsetForPosition(NodePosition nodePosition) {
    return Offset.zero;
  }


  @override
  NodePosition? getPositionAtOffset(Offset localOffset) {
    return const UpstreamDownstreamNodePosition.upstream();
  }


  @override
  Rect getRectForSelection(NodePosition baseNodePosition, NodePosition extentNodePosition) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return Rect.zero;
    return Offset.zero & box.size;
  }

  @override
  NodeSelection getSelectionBetween({
    required NodePosition basePosition,
    required NodePosition extentPosition,
  }) {
    return UpstreamDownstreamNodeSelection(
      base: UpstreamDownstreamNodePosition.upstream(),
      extent: UpstreamDownstreamNodePosition.downstream(),
    );
  }

  @override
  NodeSelection? getSelectionInRange(Offset localBaseOffset, Offset localExtentOffset) {
    return UpstreamDownstreamNodeSelection(
      base: UpstreamDownstreamNodePosition.upstream(),
      extent: UpstreamDownstreamNodePosition.downstream(),
    );
  }

  @override
  NodeSelection getSelectionOfEverything() {
    return UpstreamDownstreamNodeSelection(
      base: UpstreamDownstreamNodePosition.upstream(),
      extent: UpstreamDownstreamNodePosition.downstream(),
    );
  }

  @override
  MouseCursor? getDesiredCursorAtOffset(Offset localOffset) => MouseCursor.defer;

  @override
  NodePosition? movePositionDown(NodePosition currentPosition) => null;

  @override
  NodePosition? movePositionLeft(NodePosition currentPosition, [MovementModifier? movementModifier]) => null;


  @override
  NodePosition? movePositionRight(NodePosition currentPosition, [MovementModifier? movementModifier]) => null;

  @override
  NodePosition? movePositionUp(NodePosition currentPosition) => null;
}