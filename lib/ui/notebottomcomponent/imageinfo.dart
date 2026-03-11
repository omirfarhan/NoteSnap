import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class Imageinfo extends StatefulWidget {
  final String imagepath;
  const Imageinfo({super.key,required this.imagepath});

  @override
  State<Imageinfo> createState() => _ImageinfoState();
}

class _ImageinfoState extends State<Imageinfo> {

  late File _file;
  String _fileSize = "";
  String _modifiedDate = "";


  @override
  void initState() {
    super.initState();
    _loadFileinfo();
  }

  Future<void> _loadFileinfo()async{

    _file=File(widget.imagepath);
    final bytes=await _file.length();
    final kb =bytes/1024;
    final mb = kb / 1024;

    final modified=await _file.lastModified();

    setState(() {
      _fileSize = mb >=1
          ? "${mb.toStringAsFixed(2)} MB"
          : "${kb.toStringAsFixed(2)} KB";

      final dateLine =
      DateFormat('MMMM dd, yyyy').format(modified);

      final timeLine =
      DateFormat('EEEE HH:mm').format(modified);

      _modifiedDate = "$dateLine\n$timeLine";

    });
    
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: const Text("Image Info", style: TextStyle(
          color: Colors.white, fontFamily: 'Regular'
        ),),
      ),
      
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Date info: ${_modifiedDate}", style: TextStyle(
              color: Colors.white54,fontSize: 18,fontFamily: 'Regular'
            ),),
            SizedBox(
              height: 10,
            ),
            Text("File size: ${_fileSize}", style: TextStyle(
                color: Colors.white54,fontSize: 18,fontFamily: 'Regular'
            )),
            SizedBox(
              height: 10,
            ),
            Text("Local Path: ${displayPath(widget.imagepath)}", style: TextStyle(
                color: Colors.white54,fontSize: 18,fontFamily: 'Regular'
            ))
          ],
        ),
      ),
      
    );
  }

  
  
  String displayPath(String path) {
    final fileName = File(path).uri.pathSegments.last;
    return "/storage/emulated/0/Notes/$fileName";
  }


}
