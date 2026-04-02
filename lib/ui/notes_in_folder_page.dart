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

  Set<int> _selectedNoteIds = {};
  bool _isSelecting = false;

  @override
  void initState() {
    super.initState();
    _notesService = NotesService();
  }

  void _toggleSelection(int noteId){
    setState(() {
      if (_selectedNoteIds.contains(noteId)) {
        _selectedNoteIds.remove(noteId);
        if (_selectedNoteIds.isEmpty) _isSelecting = false;
      } else {
        _selectedNoteIds.add(noteId);
      }
    });
  }

  Future<void> _deleteSelectedNotes()async{
    final confirm=await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF0D6186),
          title: const Text(
            'Delete notes?',
            style: TextStyle(color: Color(0xFFD9FFFF)),
          ),

          content: Text(
            '${_selectedNoteIds.length} note(s) will be deleted.',
            style: const TextStyle(color: Color(0xFF9EDDE4)),
          ),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel',
                  style: TextStyle(color: Color(0xFF9EDDE4))),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete',
                  style: TextStyle(color: Color(0xFFD9FFFF))),
            ),
          ],
        ),

    );

    if(confirm == true){
      for(final id in _selectedNoteIds){
        await _notesService.deleteNote(id: id);
      }

      setState(() {
        _selectedNoteIds.clear();
        _isSelecting = false;
      });
    }

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
          title: Text(
             _isSelecting
             ? '${_selectedNoteIds.length} Selected'
             :widget.folder.foldername
          ), //widget.folder.foldername ✅ folder name appbar এ

          actions: [
            if(_isSelecting)
              IconButton(
                  onPressed: _selectedNoteIds.isEmpty ? null
                  :_deleteSelectedNotes,
                  icon:  const Icon(Icons.delete_outline)
              )
          ],

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
                        onNoteChanged: () => _notesService.refreshNotes(),
                      selectedNoteIds: _selectedNoteIds,
                      onNoteLongPress: (id) {
                        setState(() {
                          _isSelecting = true;
                          _selectedNoteIds.add(id);
                        });
                      },

                      onNoteTap: _isSelecting ? _toggleSelection: null,
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
