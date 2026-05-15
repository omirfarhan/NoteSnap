import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
import 'package:notes/Data_Layer/google_http_client.dart';

import '../../Data/cloud_note_model.dart';
import '../../Data_Layer/drive_http_request_to_server.dart';
import '../auth/auth_provider.dart';
import '../crud/notes_service.dart';
import 'cloud_note_detail_page.dart';

class CloudFolderFilePage extends StatefulWidget {

  final String folderName;
  final String folderId;
  final AuthProvider authProvider;


  const CloudFolderFilePage({
    super.key,
    required this.folderName,
    required this.folderId,
    required this.authProvider,
  });

  @override
  State<CloudFolderFilePage> createState() => _CloudFolderFilePageState();
}

class _CloudFolderFilePageState extends State<CloudFolderFilePage> {

  final _driveService = DriveHttpRequestToServer();
  List<CloudNoteModel> _notes = [];
  bool _isLoading = true;

  Set<String> _selectedFileIds = {};
  bool _isSelecting = false;

  Color _getNoteColor(CloudNoteModel note) {
    if (note.background != null && note.background!.isNotEmpty) {
      try {
        return Color(int.parse(note.background!));
      } catch (_) {}
    }
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF131313)
        : const Color(0xFFF9F9F9);
  }

  Color _getTextColor(CloudNoteModel note) {
    if (note.background != null && note.background!.isNotEmpty) {
      try {
        final baseColor = Color(int.parse(note.background!));
        final hsl = HSLColor.fromColor(baseColor);
        if (hsl.lightness > 0.6) return const Color(0xFF2C2C2C);
      } catch (_) {}
      return const Color(0xFFE1E1E1);
    }
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFE1E1E1)
        : const Color(0xFF2C2C2C);
  }


  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  GoogleHttpClient get _client=> GoogleHttpClient({
    'Authorization': 'Bearer ${widget.authProvider.accessToken}',
  });

  Future<void> _loadNotes()async{
    try{
      final notes=await _driveService.getNotesContentInFolder(
        _client,
        widget.folderId,
      );

      if (mounted) setState(() => _notes = notes);

    }catch (e){
      print('Error: $e');
    }finally{
      if (mounted) setState(() => _isLoading = false);
    }

  }

  String _getPlainText(String content) {
    if (content.isEmpty) return '';
    try {
      final list = jsonDecode(content) as List<dynamic>;
      return list
          .where((item) => item['type'] == 'paragraph')
          .map((item) => item['text'] as String? ?? '')
          .where((text) => text.trim().isNotEmpty)
          .join('\n');
    } catch (_) {
      return content;
    }
  }


  String? _getFirstImage(String content) {
    if (content.isEmpty) return null;
    try {
      final list = jsonDecode(content) as List<dynamic>;
      final imageBlock = list.firstWhere(
            (item) => item['type'] == 'image',
        orElse: () => null,
      );
      return imageBlock?['url'] as String?;
    } catch (_) {
      return null;
    }
  }

  String _formatTime(int ms) {
    if (ms == 0) return '';
    final dt = DateTime.fromMillisecondsSinceEpoch(ms);
    return DateFormat('MMM dd, hh:mm a').format(dt);
  }

  Future<void> _deleteSelectedNotes()async{
    final confirm=await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0D6186),
        title: const Text('Delete?',
            style: TextStyle(color: Color(0xFFD9FFFF))),
        content: Text(
          '${_selectedFileIds.length} note(s) will be deleted from cloud.',
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
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    setState(() => _isLoading = true);

    try{
      // Drive থেকে delete করো
      for (final fileId in _selectedFileIds) {
        await _driveService.deleteFile(_client, fileId);
      }

      // UI থেকে সরাও
      setState(() {
        _notes.removeWhere((note) => _selectedFileIds.contains(note.fileId));
        _selectedFileIds.clear();
        _isSelecting = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Deleted from cloud ✓'),
            backgroundColor: Color(0xFF0D6186),
          ),
        );
      }

    }catch (e){
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: $e')),
        );
      }
    }finally {
      if (mounted) setState(() => _isLoading = false);
    }

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0D6186),
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        backgroundColor: Color(0xFF0D6186),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back,color: Color(0xFFD9FFFF)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        title: Text(
          _isSelecting
            ? '${_selectedFileIds.length} Selected'
            : widget.folderName,style: TextStyle(color: Color(0xFFD9FFFF)),
        ),
        actions: [
          IconButton(
              onPressed: _isSelecting && _selectedFileIds.isNotEmpty
                  ? _deleteSelectedNotes //
                  : null,
            icon: Icon(Icons.delete_outline),
          )
        ],
      ),

      body: _isLoading
      ?const Center(
        child: SizedBox(
          width: 25,
          height: 25,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),

      ): _notes.isEmpty
      ?const Center(
        child: Text(
          'No notes in this folder',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white54,
          ),
        ),
      ):Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 8,
        ),
        child: MasonryGridView.builder(
          itemCount: _notes.length,
          gridDelegate:
          const SliverSimpleGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
          ),
          mainAxisSpacing: 8,
          crossAxisSpacing: 20,
          itemBuilder: (context, index) {
            final note = _notes[index];
            final noteColor = _getNoteColor(note);
            final textColor = _getTextColor(note);
            final plainText = _getPlainText(note.content);
            final firstImage = _getFirstImage(note.content);

            return InkWell(
              onLongPress: () {
                setState(() {
                  _isSelecting = true;
                  _selectedFileIds.add(note.fileId);
                });
              },
              onTap: () {
                if (_isSelecting) {

                  setState(() {
                    if (_selectedFileIds.contains(note.fileId)) {
                      _selectedFileIds.remove(note.fileId);
                      if (_selectedFileIds.isEmpty) _isSelecting = false;
                    } else {
                      _selectedFileIds.add(note.fileId);
                    }
                  });
                } else {

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CloudNoteDetailPage(note: note),
                    ),
                  );
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(

                  color: _selectedFileIds.contains(note.fileId)
                      ? const Color(0xFF1A7EA8)
                      : noteColor,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: _selectedFileIds.contains(note.fileId)
                        ? Colors.white
                        : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                clipBehavior: Clip.hardEdge,
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: noteColor, //const Color(0xFF58B4D3)
                        borderRadius: BorderRadius.circular(5),
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          // ── Image ──────────────────────
                          if (firstImage != null)
                            Container(
                              width: double.infinity,
                              height: 75,
                              decoration: BoxDecoration(
                                image: DecorationImage(

                                  image: firstImage.startsWith('http')
                                      ? NetworkImage(firstImage)
                                      : FileImage(File(firstImage))
                                  as ImageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),

                          // ── Text ───────────────────────
                          Padding(
                            padding:
                            const EdgeInsets.fromLTRB(5, 2, 5, 5),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  note.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style:  TextStyle(
                                    fontFamily: 'Regular',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: textColor,
                                  ),
                                ),
                                Text(
                                  plainText,
                                  style: TextStyle(
                                    color: textColor,
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
                                  mainAxisAlignment:
                                  MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      _formatTime(note.lastEdited),
                                      style: TextStyle(
                                        color: textColor,
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
                )


              ),
            );
          },
        ),
      ),

    );
  }
}
