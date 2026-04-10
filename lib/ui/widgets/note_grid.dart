import 'dart:convert';
import 'dart:io';


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';

import '../../constants/routes.dart';
import '../../services/crud/notes_service.dart';
import '../create_note.dart';

class NoteGrid extends StatelessWidget {
  final List<DatabaseNote> notes;
  final VoidCallback? onNoteChanged;
  final Set<int> selectedNoteIds;
  final Function(int)? onNoteLongPress;
  final Function(int)? onNoteTap;

  const NoteGrid({
    super.key,
    required this.notes,
    this.onNoteChanged,
    this.selectedNoteIds=const {},
    this.onNoteLongPress,
    this.onNoteTap
  });


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
      itemCount: notes.length,
      gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      mainAxisSpacing: 8,
      crossAxisSpacing: 20,
      itemBuilder: (context, index) {
        final note = notes[index];
        final firstimage = _getFirstImageFromContent(note.content);
        final plainText = _getPlainTextFromContent(note.content);

        final isSelected=selectedNoteIds.contains(note.id);

        return InkWell(
          onLongPress: () {
            onNoteLongPress?.call(note.id);
          } ,

          onTap: () async {

            if(selectedNoteIds.isNotEmpty){
              onNoteTap?.call(note.id);
            }else{
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => CreateNote(note: note),
                ),
              ).then((_)=> onNoteChanged?.call());
            }
          },
          child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF1A7EA8)   // ✅ selected color
                    : const Color(0xFF58B4D3),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: isSelected ? Colors.white : Colors.transparent, // ✅ সবসময় border আছে, শুধু color change হয়
                  width: 1.5,
                ),
          ),
          clipBehavior: Clip.hardEdge,

          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF58B4D3),
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
                            style: const TextStyle(
                              fontFamily: 'Regular',
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: Color(0xFFDBF5FB),
                            ),
                          ),
                          Text(
                            plainText,
                            style: const TextStyle(
                              color: Color(0xFFDBF5FB),
                              fontFamily: 'Regular',
                              fontWeight: FontWeight.w400,
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
                                style: const TextStyle(
                                  color: Color(0xFFDBF5FB),
                                  fontSize: 10,
                                  fontFamily: 'Regular',
                                  fontWeight: FontWeight.w600,
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

              if (isSelected)  // ✅ checkmark দেখাবে
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
          )
        );
      }
    );
  }
}