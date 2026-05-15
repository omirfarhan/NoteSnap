import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notes/Data/cloud_note_model.dart';

class CloudNoteDetailPage extends StatefulWidget {
  final CloudNoteModel note;
  const CloudNoteDetailPage({super.key, required this.note});

  @override
  State<CloudNoteDetailPage> createState() => _CloudNoteDetailPageState();
}

class _CloudNoteDetailPageState extends State<CloudNoteDetailPage> with WidgetsBindingObserver {

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

  Color get _bgColor {
    // custom color select করা থাকলে সেটা দেখাও
    if (widget.note.background != null && widget.note.background!.isNotEmpty) {
      final parsed = int.tryParse(widget.note.background!);
      if (parsed != null) return Color(parsed);
    }
    // না থাকলে dark/light mode অনুযায়ী
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF131313)
        : const Color(0xFFF9F9F9);
  }

  Color get _textColor {
    if (widget.note.background != null && widget.note.background!.isNotEmpty) {
      final parsed = int.tryParse(widget.note.background!);
      if (parsed != null) {
        final hsl = HSLColor.fromColor(Color(parsed));
        if (hsl.lightness > 0.6) return const Color(0xFF2C2C2C);
      }
      return const Color(0xFFE1E1E1);
    }
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFE1E1E1)
        : const Color(0xFF2C2C2C);
  }

  String _formatTime(int ms) {
    if (ms == 0) return '';
    final dt = DateTime.fromMillisecondsSinceEpoch(ms);
    return DateFormat('MMMM dd, hh:mm a').format(dt);
  }

  List<Widget> _buildContent(String content) {
    if (content.isEmpty) return [];
    try {
      final list = jsonDecode(content) as List<dynamic>;
      final widgets = <Widget>[];

      for (final item in list) {
        final type = item['type'] as String? ?? '';

        if (type == 'paragraph') {
          final text = item['text'] as String? ?? '';
          if (text.trim().isEmpty) continue;
          widgets.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                text,
                style: TextStyle(
                  color: _textColor, // ← dynamic
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
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: url.startsWith('http')
                      ? Image.network(url, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                      const Icon(Icons.broken_image, color: Colors.white54))
                      : Image.file(File(url), fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                      const Icon(Icons.broken_image, color: Colors.white54)),
                ),
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
                    checked ? Icons.check_box : Icons.check_box_outline_blank,
                    color: _textColor.withOpacity(0.7), // ← dynamic
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      text,
                      style: TextStyle(
                        color: checked
                            ? _textColor.withOpacity(0.4)
                            : _textColor, // ← dynamic
                        fontFamily: 'Regular',
                        fontSize: 16,
                        decoration: checked ? TextDecoration.lineThrough : null,
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
    } catch (e) {
      return [
        Text(content, style: TextStyle(color: _textColor, fontSize: 16)),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          _formatTime(widget.note.lastEdited),
          style: TextStyle(
            fontSize: 12,
            color: _textColor.withOpacity(0.7), // ← dynamic
            fontFamily: 'Regular',
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: _bgColor,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.note.title.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 9),
                    child: Text(
                      widget.note.title,
                      style: TextStyle(
                        color: _textColor, // ← dynamic
                        fontFamily: 'Regular',
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ..._buildContent(widget.note.content),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
