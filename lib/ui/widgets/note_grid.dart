import 'dart:convert';
import 'dart:io';


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';

import '../../services/crud/notes_service.dart';
import '../create_note.dart';

class NoteGrid extends StatefulWidget {
  final List<DatabaseNote> notes;
  final VoidCallback? onNoteChanged;
  final Set<int> selectedNoteIds;
  final Function(int)? onNoteLongPress;
  final Function(int)? onNoteTap;

  const NoteGrid({
    super.key,
    required this.notes,
    this.onNoteChanged,
    this.selectedNoteIds = const {},
    this.onNoteLongPress,
    this.onNoteTap,
  });

  @override
  State<NoteGrid> createState() => _NoteGridState();
}

class _NoteGridState extends State<NoteGrid> with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangePlatformBrightness() {
    setState(() {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Color _getNoteColor(DatabaseNote note) {
    if (note.background != null && note.background!.isNotEmpty) {
      try {
        return Color(int.parse(note.background!));
      } catch (_) {}
    }
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF131313)
        : const Color(0xFFF9F9F9);
  }

  Color _textColor(DatabaseNote note) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (note.background != null && note.background!.isNotEmpty) {
      try {
        final baseColor = Color(int.parse(note.background!));
        final hsl = HSLColor.fromColor(baseColor);
        if (hsl.lightness > 0.6) return const Color(0xFF2C2C2C);
      } catch (_) {}
      return const Color(0xFFE1E1E1);
    }
    return isDark ? const Color(0xFFE1E1E1) : const Color(0xFF2C2C2C);
  }

  String? _getFirstImageFromContent(String content) {
    if (content.isEmpty) return null;
    try {
      final list = jsonDecode(content) as List<dynamic>;
      for (final item in list) {
        if (item['type'] == 'image') return item['url'] as String?;
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  String _getPlainTextFromContent(String content) {
    if (content.isEmpty) return '';
    try {
      final list = jsonDecode(content) as List<dynamic>;
      return list
          .where((item) => item['type'] == 'paragraph')
          .map((item) => item['text'] as String? ?? '')
          .where((text) => text.trim().isNotEmpty)
          .join('\n');
    } catch (e) {
      return content;
    }
  }

  String _formatTime(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('MMM dd, hh:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return MasonryGridView.builder(
      itemCount: widget.notes.length,
      gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      mainAxisSpacing: 8,
      crossAxisSpacing: 20,
      itemBuilder: (context, index) {
        final note = widget.notes[index];
        final noteColor = _getNoteColor(note);
        final textColor = _textColor(note);
        final firstimage = _getFirstImageFromContent(note.content);
        final plainText = _getPlainTextFromContent(note.content);
        final isSelected = widget.selectedNoteIds.contains(note.id);

        return InkWell(
          onLongPress: () => widget.onNoteLongPress?.call(note.id),
          onTap: () async {
            if (widget.selectedNoteIds.isNotEmpty) {
              widget.onNoteTap?.call(note.id);
            } else {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => CreateNote(note: note),
                ),
              ).then((_) => widget.onNoteChanged?.call());
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF1A7EA8) : noteColor,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 1.5,
              ),
            ),
            clipBehavior: Clip.hardEdge,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: noteColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (firstimage != null)
                        Container(
                          width: double.infinity,
                          height: 75,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: FileImage(File(firstimage)),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(5, 2, 5, 5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              note.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Regular',
                                fontSize: 15,
                                color: textColor,
                              ),
                            ),
                            Text(
                              plainText,
                              style: TextStyle(
                                color: textColor,
                                fontFamily: 'Regular',
                                fontSize: 13.5,
                                height: 1.2,
                              ),
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  _formatTime(note.lastEdited),
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 10,
                                    fontFamily: 'Regular',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  const Positioned(
                    top: 4,
                    right: 4,
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}