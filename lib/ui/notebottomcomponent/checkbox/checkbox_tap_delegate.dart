import 'package:super_editor/super_editor.dart';

class CheckboxTapDelegate extends ContentTapDelegate {
  final MutableDocument document;
  final Editor editor;
  final VoidCallback onSave;

  CheckboxTapDelegate({
    required this.document,
    required this.editor,
    required this.onSave,
  });

  @override
  TapHandlingInstruction onTap(DocumentTapDetails details) {
    return TapHandlingInstruction.continueHandling;
  }
  void _replacePrefix(ParagraphNode node, String from, String to) {
    final currentSelection = node.text.text.length;

    editor.execute([
      // delete prefix
      DeleteContentRequest(
        documentRange: DocumentRange(
          start: DocumentPosition(
            nodeId: node.id,
            nodePosition: const TextNodePosition(offset: 0),
          ),
          end: DocumentPosition(
            nodeId: node.id,
            nodePosition: TextNodePosition(offset: from.length),
          ),
        ),
      ),

      // insert new prefix
      InsertTextRequest(
        documentPosition: DocumentPosition(
          nodeId: node.id,
          nodePosition: const TextNodePosition(offset: 0),
        ),
        textToInsert: to,
        attributions: {},
      ),

      // restore cursor
      ChangeSelectionRequest(
        DocumentSelection.collapsed(
          position: DocumentPosition(
            nodeId: node.id,
            nodePosition: TextNodePosition(offset: currentSelection),
          ),
        ),
        SelectionChangeType.placeCaret,
        SelectionReason.userInteraction,
      ),
    ]);

    onSave();
  }
}