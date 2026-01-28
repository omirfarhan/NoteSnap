
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:notes/Data/notemodel.dart';
import 'package:notes/Data_Layer/drive_http_request_to_server.dart';
import 'package:notes/Data_Layer/google_http_client.dart';
import 'package:provider/provider.dart';
import '../../Data_Layer/google_http_client.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../auth/auth_provider.dart';

class CloudFiles extends StatefulWidget {
  const CloudFiles({super.key});

  @override
  State<CloudFiles> createState() => _CloudFilesState();
}

class _CloudFilesState extends State<CloudFiles> {

  final accessToken=AuthProvider.driveAccessToken;

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 60, 0),
            child: Column(
              children: [
                const Text('Storage'),
                const SizedBox(height:4),

                  LinearPercentIndicator(
                    lineHeight: 10,
                    percent: 0.4,
                      linearStrokeCap: LinearStrokeCap.round,
                    backgroundColor: Color(0xFFA9CBD7),
                    progressColor: Color(0xFFE2465C),
                  ),

              ],
            ),
          ),

        ),


        body: SafeArea(
          child: Column(
            children: [

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
                          title: 'First Note1',
                          text: 'Hello Google Drive1',
                          //createdAt: DateTime.now(),
                          //updatedAt: DateTime.now(),
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
    super.dispose();
  }

}
