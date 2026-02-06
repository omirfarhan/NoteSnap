
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:notes/Data/notemodel.dart';
import 'package:notes/Data_Layer/drive_http_request_to_server.dart';
import 'package:notes/Data_Layer/google_http_client.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Data_Layer/google_http_client.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:http/http.dart' as http;
import '../auth/auth_provider.dart';

class CloudFiles extends StatefulWidget {
  const CloudFiles({super.key});

  @override
  State<CloudFiles> createState() => _CloudFilesState();
}

class _CloudFilesState extends State<CloudFiles> {

  final uploadDriveFile=DriveHttpRequestToServer();

  final accessToken=AuthProvider.driveAccessToken;


  double? percentage=DriveHttpRequestToServer.percentage;


  @override
  void initState() {
    super.initState();

  }


  @override
  Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 70, 0),
            child: Column(
              children: [
                const Text('Storage'),
                const SizedBox(height:4),

                  LinearPercentIndicator(
                    lineHeight: 10,
                    percent: percentage ?? 0.0,
                    center: Text(
                      "50.0%",
                      style: new TextStyle(fontSize: 7),
                    ),
                    backgroundColor: Color(0xFFA9CBD7),
                    progressColor: Color(0xFFFF2040),
                    barRadius: Radius.circular(25),
                    animation: true,
                    animationDuration: 2500,


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
              ElevatedButton(
                  onPressed: () async{

                    //final userId = FirebaseAuth.instance.currentUser!.uid;
                    //user id ekhan theke jabe etai best practice

                    //final userId="test123";



                    final response=await http.post(

                      //https://us-central1-notes-moinul-flutter-project.cloudfunctions.net/auth
                      //ekhane test er jonne use: http://192.168.1.25:5001/notes-moinul-flutter-project/us-central1/auth
                      Uri.parse('http://192.168.1.25:5001/notes-moinul-flutter-project/us-central1/auth'),
                      headers: {
                        'Content-Type': 'application/json',
                      },
                    );

                    final consentUrl=jsonDecode(response.body)['consentUrl'];
                    final uri=Uri.parse(consentUrl);
                     await launchUrl(
                      uri,
                      mode: LaunchMode.externalApplication,
                    );

                    // final response2=await http.post(
                    //   Uri.parse('https://us-central1-notes-moinul-flutter-project.cloudfunctions.net/oauthCallback'),
                    //   headers: {'Content-Type': 'application/json'},
                    // );
                    // print('Status: ${response2.statusCode}');
                    // print('Body: ${response2.body}');


                  },
                  child: const Text('Server Response')
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
