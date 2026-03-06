
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_quill/flutter_quill.dart';

import 'fullscreenimagepage.dart';

class ImageEmbedBuilder extends EmbedBuilder {
  @override

  String get key => BlockEmbed.imageType;
  final VoidCallback? onImageTap;
  ImageEmbedBuilder({this.onImageTap});

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    final imagePath = embedContext.node.value.data;


    return Padding(
      padding: const EdgeInsets.only(top: 6,bottom: 4),

      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTapDown: (TapDownDetails details) async {

          FocusManager.instance.primaryFocus?.unfocus();
          final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

          final result = await showMenu(
            context: context,
            position: RelativeRect.fromRect(
              details.globalPosition & const Size(40, 40),
              Offset.zero & overlay.size,
            ),
            items: [
              PopupMenuItem(
                value: 'view',
                child: Row(
                  children: [
                    Icon(Icons.fullscreen),
                    SizedBox(width: 8),
                    Text('Full Screen'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          );

          if (result == 'view') {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Fullscreenimagepage(imagepath: imagePath),
              ),
            );
          } else if (result == 'delete') {
            //onImageTap?.call(); // delete callback
          }
        },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: AspectRatio(
          aspectRatio: 16/9,
          child: Image.file(
            File(imagePath),
            fit: BoxFit.fill,
          ),
        ),
      ),
      )
    );
  }
}
