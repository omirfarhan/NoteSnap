import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:notes/ui/widgets/note_fab.dart';
import 'package:notes/ui/widgets/note_grid.dart';

import '../constants/routes.dart';
import '../services/crud/notes_service.dart';

class AllNotesPage extends StatefulWidget {
  const AllNotesPage({super.key});

  @override
  State<AllNotesPage> createState() => _AllNotesPageState();
}

class _AllNotesPageState extends State<AllNotesPage> {

  late final NotesService _notesService;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _notesService = NotesService();
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



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Notes'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
        child: Column(
          children: [
            TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              autocorrect: false,
              enableSuggestions: false,
              spellCheckConfiguration: SpellCheckConfiguration.disabled(),
              cursorColor: const Color(0xFFC8E1E4),
              style: const TextStyle(color: Color(0xFFC8E1E4), fontSize: 14),
              decoration: InputDecoration(
                prefixIcon: const Icon(FontAwesomeIcons.magnifyingGlass,
                    color: Color(0xFFB8E2E8), size: 16),
                fillColor: const Color(0xFF0B7197),
                filled: true,
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                prefixIconConstraints:
                const BoxConstraints(minHeight: 38, minWidth: 38),
                hintText: 'Search notes...',
                hintStyle: const TextStyle(
                  color: Color(0xFFC8E1E4),
                  fontSize: 12,
                  fontFamily: 'Fredoka',
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: const BorderSide(color: Color(0xFFC6E1E5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: const BorderSide(color: Color(0xFFC6E1E5)),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: StreamBuilder<List<DatabaseNote>>(
                stream: _notesService.allNotesUnfiltered, // ✅ সব note
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final notes = snapshot.data!.where((note) {
                    final title = note.title.toLowerCase();
                    final plaintext =
                    _getPlainTextFromContent(note.content).toLowerCase();
                    return title.contains(_searchQuery) ||
                        plaintext.contains(_searchQuery);
                  }).toList();

                  if (notes.isEmpty) {
                    return const Center(
                      child: Text('No notes yet',
                          style: TextStyle(color: Color(0xFF9EDDE4))),
                    );
                  }

                  return NoteGrid(
                      notes: notes,
                      onNoteChanged: () => _notesService.refreshNotes()
                  );
                },
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: const NoteFab(folderName: 'all folder'),
    );
  }


}
