import 'package:flutter/material.dart';
import 'package:notes/ui/widgets/note_grid.dart';

import '../services/crud/notes_service.dart';

class RecentlyDeletedPage extends StatefulWidget {
  const RecentlyDeletedPage({super.key});

  @override
  State<RecentlyDeletedPage> createState() => _RecentlyDeletedPageState();
}

class _RecentlyDeletedPageState extends State<RecentlyDeletedPage> {

  late final NotesService _notesService;

  @override
  void initState() {
    super.initState();
    _notesService = NotesService();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recently Deleted'),
      ),

      body: StreamBuilder<List<DatabaseNote>>(
          stream: _notesService.deletedNotes,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final notes = snapshot.data!;

            if (notes.isEmpty) {
              return const Center(
                child: Text('No deleted notes',
                    style: TextStyle(color: Color(0xFF9EDDE4))),
              );
            }

            return NoteGrid(
                notes: notes
            );


          },
      ),

    );
  }
}
