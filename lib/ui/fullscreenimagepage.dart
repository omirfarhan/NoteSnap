import 'dart:io';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:flutter/material.dart';

class Fullscreenimagepage extends StatelessWidget {
  
  final String imagepath;
  
  const Fullscreenimagepage({super.key,required this.imagepath});
  
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      bottomNavigationBar: Container(

        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [

            IconButton(onPressed: (){
              _saveImageToGallery(context);
            }, icon: Icon(Icons.save_alt_sharp)),

            IconButton(onPressed: (){

            }, icon: Icon(Icons.info)),

          ],
        ),
      ),

      body: Center(
        child: InteractiveViewer(child: Image.file(
          File(imagepath),
          fit: BoxFit.cover,
        )),
      ),

    );
  }

  Future<void> _saveImageToGallery(BuildContext context)async{
    try{
      final result=await ImageGallerySaverPlus.saveFile(
        imagepath,
        name: "notes_${DateTime.now().millisecondsSinceEpoch}"
      );

      if(result['isSuccess']==true){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content:Text("Image saved successfully"))
        );
      }else{
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to save image")),
        );
      }


    }catch (e){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error saving image")),
      );
    }
  }

}
