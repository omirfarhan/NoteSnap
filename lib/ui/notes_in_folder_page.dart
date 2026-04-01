import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:notes/ui/widgets/note_fab.dart';
import 'package:notes/ui/widgets/note_grid.dart';

import '../services/crud/notes_service.dart';

class NotesInFolderPage extends StatefulWidget {
  final Folder folder;
  const NotesInFolderPage({super.key, required this.folder});

  @override
  State<NotesInFolderPage> createState() => _NotesInFolderPageState();
}

class _NotesInFolderPageState extends State<NotesInFolderPage> {

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
          title: Text(widget.folder.foldername), // ✅ folder name appbar এ
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
          child: Column(
            children: [

              Expanded(
                child: StreamBuilder<List<DatabaseNote>>(
                  stream: _notesService.notesForFolder(widget.folder.id),

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
                        child: Text('No notes in this folder',
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

      floatingActionButton: NoteFab(folderName: widget.folder.foldername),

    );
  }
}
