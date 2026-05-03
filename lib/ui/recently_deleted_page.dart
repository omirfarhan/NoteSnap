import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';

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

  String _formatTime(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('MMM dd, hh:mm a').format(date);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recently Deleted'),
      ),

      body: Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
        child: Column(
          children: [
           const Text('Recently deleted notes are kept here for 30 days.'
               ' You can recover them anytime during this period—afterward, '
               'they’ll be gone for good.',
               style: TextStyle(color: Color(0xFF89D3DA))),

            SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<List<DatabaseNote>>(
                stream: _notesService.deletedNotes,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final notes = snapshot.data!;


                  return MasonryGridView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: notes.length,
                    gridDelegate:
                    const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                    ),
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 10,
                    itemBuilder: (context, index) {
                      final note = notes[index];

                      return _buildDeletedNoteCard(note);
                    },
                  );


                },
              ),
            ),

          ],
        )

      ),

    );
  }

  Widget _buildDeletedNoteCard(DatabaseNote note) {

    final plainText = _getPlainTextFromContent(note.content);
    final firstimage = _getFirstImageFromContent(note.content);

    return InkWell(
        onTap: () => _showCannotEditDialog(note), //_showCannotEditDialog(note) ✅ click করলে dialog
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF58B4D3),
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: Colors.white24,
              width: 1,
            ),
          ),

          clipBehavior: Clip.hardEdge,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
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
                              fontSize: 13,
                              color: Color(0xFFDBF5FB),
                            ),
                          ),
                          Text(
                            plainText,
                            style: const TextStyle(
                              color: Color(0xFFDBF5FB),
                              fontFamily: 'Regular',
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
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
                                  fontFamily: 'Fredoka',
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
            ],
          ),
        )
    );

  }


  // ✅ Alert dialog
  void _showCannotEditDialog(DatabaseNote note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0D6186),
        title: const Text(
          'Cannot Edit',
          style: TextStyle(color: Color(0xFFD9FFFF)),
        ),
        content: const Text(
          'Cannot edit recently deleted notes. Please move this note to another folder before continuing.',
          style: TextStyle(color: Color(0xFF9EDDE4)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF9EDDE4)),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // dialog বন্ধ করুন
              await _restoreNote(note); // ✅ restore করুন
            },
            child: const Text(
              'Move',
              style: TextStyle(color: Color(0xFFD9FFFF)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _restoreNote(DatabaseNote note) async {
    await _notesService.restoreNote(id: note.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note restored')),
      );
    }
  }

}
