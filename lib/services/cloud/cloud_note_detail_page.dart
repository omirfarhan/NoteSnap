import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notes/Data/cloud_note_model.dart';

class CloudNoteDetailPage extends StatelessWidget {
  final CloudNoteModel note;
  const CloudNoteDetailPage({super.key,required this.note});

  String _formatTime(int ms) {
    if (ms == 0) return '';
    final dt = DateTime.fromMillisecondsSinceEpoch(ms);
    return DateFormat('MMMM dd, hh:mm a').format(dt);
  }

  List<Widget> _buildContent(String content){
    if (content.isEmpty) return [];

    try{
      final list = jsonDecode(content) as List<dynamic>;
      final widgets = <Widget>[];

      for(final item in list){
        final type = item['type'] as String? ?? '';
        if (type == 'paragraph') {
          final text = item['text'] as String? ?? '';
          if (text.trim().isEmpty) continue;
          widgets.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                text,
                style: const TextStyle(
                  color: Color(0xFFD2FEFF),
                  fontFamily: 'Regular',
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
            ),
          );
        } else if (type == 'image') {
          final url = item['url'] as String? ?? '';
          if (url.isEmpty) continue;
          widgets.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 22),
              child: ClipRRect(

                borderRadius: BorderRadius.circular(8),
                child:AspectRatio(
                    aspectRatio: 16 / 9,
                  child: url.startsWith('http')
                      ? Image.network(
                    url,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.broken_image,
                      color: Colors.white54,
                    ),
                  )
                      : Image.file(
                    File(url),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.broken_image,
                      color: Colors.white54,
                    ),
                  ),
                )

              ),
            ),
          );
        } else if (type == 'checkbox') {
          final text = item['text'] as String? ?? '';
          final checked = item['checked'] as bool? ?? false;
          widgets.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    checked
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                    color: const Color(0xFF9EDDE4),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      text,
                      style: TextStyle(
                        color: checked
                            ? Colors.white54
                            : const Color(0xFFD2FEFF),
                        fontFamily: 'Regular',
                        fontSize: 16,
                        decoration: checked
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      }

      return widgets;
    }catch (e){
      return [
        Text(
          content,
          style: const TextStyle(
            color: Color(0xFFD2FEFF),
            fontSize: 16,
          ),
        ),
      ];

    }


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF137FA5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          _formatTime(note.lastEdited),
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF9EDDE4),
            fontFamily: 'Regular',
          ),
        ),
      ),

      body: Container(
        decoration: note.background != null
            ? BoxDecoration(
          image: DecorationImage(
            image: AssetImage(note.background!),
            fit: BoxFit.cover,
          ),
        )
            : null,

        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(10,0,10,5),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              if (note.title.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: Text(
                    note.title,
                    style: const TextStyle(
                      color: Color(0xFFD2FEFF),
                      fontFamily: 'Regular',
                      fontSize: 19,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

              ..._buildContent(note.content)

            ],
          ),
        ),
      ),
    );
  }
}
