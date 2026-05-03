import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:notes/ui/notebottomcomponent/bottomsheet/saveimageoption.dart';
import '../../methodChannelStorageService/storage_service.dart';

class ImagePreviewPage extends StatelessWidget {
  final Uint8List uint8list;
  final bool isSaveMode;
  const ImagePreviewPage({
    super.key,
    required this.uint8list,
    required this.isSaveMode
  });

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
              icon: const Icon(Icons.save_alt, color: Color(0xFFD9FFFF)),
            )
          else
            IconButton(
              onPressed: () async {
                await SaveAsImage.shareImage(uint8list);
              },
              icon: const Icon(Icons.ios_share, color: Color(0xFFD9FFFF)),
            ),
        ],

      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Center(
          child: FittedBox(
            fit: BoxFit.contain,
            child: Image.memory(uint8list),
          ),
        ),
      ),

    );
  }
}
