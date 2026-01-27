
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:notes/Data/notemodel.dart';
import 'package:notes/Data_Layer/drive_http_request_to_server.dart';
import 'package:notes/Data_Layer/google_http_client.dart';
import 'package:provider/provider.dart';
import '../../Data_Layer/google_http_client.dart';

import '../auth/auth_provider.dart';

class CloudFiles extends StatefulWidget {
  const CloudFiles({super.key});

  @override
  State<CloudFiles> createState() => _CloudFilesState();
}

class _CloudFilesState extends State<CloudFiles> {


  late final TextEditingController _textEditingController;

  final accessToken=AuthProvider.driveAccessToken;





  @override
  void initState() {
    _textEditingController=TextEditingController();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
      return Scaffold(
        
        appBar: AppBar(
          title: const Text('Cloud Files'),
        ),


        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _textEditingController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: 'enter your mind',

                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.cyanAccent,width: 1)
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.cyanAccent,width: 1)
                    )
                  ),

                ),
              ),
              ElevatedButton(
                  onPressed: () async{

                    final uploadDriveFile=DriveHttpRequestToServer();

                    if(accessToken !=null){

                      final client=GoogleHttpClient({
                        'Authorization': 'Bearer $accessToken',
                      });

                      final notes = [
                        Notemodel(
                          id: '1',
                          title: 'First Note',
                          text: 'Hello Google Drive',
                          createdAt: DateTime.now(),
                          updatedAt: DateTime.now(),
                          imagesPath: ['null'],
                        ),
                      ];



                      final createSubFolder=await uploadDriveFile.createFolder('1234', client);
                      final uploadToServer=await uploadDriveFile.uploadNotesToFolder(client, createSubFolder,notes);

                      print('upload to server Report: ${createSubFolder}');


                    }else{
                      await AuthProvider.signinwithGoogle();
                    }


                  },
                  child: const Text('Save Drive')
              ),




            ],
          ),
        ),
        
      );
  }




  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

}
