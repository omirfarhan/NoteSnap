import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:notes/ui/notebottomcomponent/bottomsheet/saveimageoption.dart';

class ImagePreviewPage extends StatelessWidget {
  final Uint8List uint8list;
  const ImagePreviewPage({super.key, required this.uint8list});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Preview note',
          style: TextStyle(
          color: Color(0xFFD9FFFF),
            fontWeight: FontWeight.w400,
            fontFamily: 'Regular'
        ),),
        actions: [
          IconButton(onPressed: ()async{
            await SaveAsImage.shareImage(uint8list);
          }, icon: const Icon(
            Icons.ios_share,
            color: Color(0xFFD9FFFF),
          ))
        ],

      ),
      body: InteractiveViewer(
          child: Image.memory(uint8list)
      ),


    );
  }
}
