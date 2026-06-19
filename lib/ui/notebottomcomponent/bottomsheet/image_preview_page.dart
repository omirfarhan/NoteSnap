import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:notes/ui/notebottomcomponent/bottomsheet/saveimageoption.dart';
import '../../methodChannelStorageService/storage_service.dart';

class ImagePreviewPage extends StatelessWidget {
  final Uint8List uint8list;
  final bool isSaveMode;
  final Color textcolor;
  //final Color backgroundColor;
  const ImagePreviewPage({
    super.key,
    required this.uint8list,
    required this.isSaveMode,
    required this.textcolor,
    //required this.backgroundColor,
  });



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Preview note',
          style: TextStyle(
          color: Theme.of(context).brightness == Brightness.dark
              ?Colors.white
              :Colors.black,
            fontWeight: FontWeight.w400,
            fontFamily: 'Regular'
        ),),
        actions: [
          if (isSaveMode)
            IconButton(
              onPressed: () async {
                final fileName = 'note_${DateTime.now().millisecondsSinceEpoch}.png';

                final path = await StorageService.saveImageFile(
                  fileName: fileName,
                  bytes: uint8list,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Saved: $path')),
                  );
                  Navigator.pop(context);
                }
              },
              icon: Icon(Icons.save_alt,
                  color: Theme.of(context).brightness == Brightness.dark
                  ?Colors.white
                  :Colors.black),
            )
          else
            IconButton(
              onPressed: () async {
                await SaveAsImage.shareImage(uint8list);
              },
              icon: Icon(Icons.ios_share,
                  color: Theme.of(context).brightness == Brightness.dark
                  ?Colors.white
                  :Colors.black),
            ),
        ],

      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Center(
          child: FittedBox(
            fit: BoxFit.contain,
            child: Image.memory(uint8list,
             // color: backgroundColor,
            ),
          ),
        ),
      ),

    );
  }
}
