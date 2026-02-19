
import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:notes/Data/notemodel.dart';
import 'package:notes/Data/user_model.dart';
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
  final authprovider=AuthProvider();

  late AuthProvider authProviderr;
  bool isLoading = true;

  String? accessTokem;
   double? _percentvalue;
   double? _percent;
  double? get percentvalue => _percentvalue;
  double? get percent => _percent;



  List<UserModel> users=[];
  List<UserModel> filedata=[];



  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadAccessToken());
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
                    percent: percentvalue ?? 0,
                    center: Text(
                      "${(percent ?? 0).toStringAsFixed(1)} %",
                      style: new TextStyle(fontSize: 6),
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

                    if(accessTokem !=null){
                      print('accessToken is : $accessTokem');
                      final client=GoogleHttpClient({
                        'Authorization': 'Bearer $accessTokem',
                      });

                      final notes = [
                        Notemodel(
                          id: '1',
                          title: 'Second folder2',
                          text: 'Hello Google Drive1',
                          //createdAt: DateTime.now(),
                          //updatedAt: DateTime.now(),
                          imagesPath: ['null'],
                        ),
                      ];



                      final createSubFolder=await uploadDriveFile.createFolder('new folder 123', client);
                      final uploadToServer=await uploadDriveFile.uploadNotesToFolder(client, createSubFolder,notes);

                      print('upload to server Report: ${createSubFolder}');


                    }else{
                      //await AuthProvider.signinwithGoogle();
                    }


                  },
                  child: const Text('Save Drive')
              ),
              ElevatedButton(
                  onPressed: () async{

                    // Login complete হওয়ার পর user check করুন
                    final googleUserId=await authprovider.googleuserId;

                    print('google userId: === ${googleUserId}');
                    
                    if(googleUserId != null && googleUserId.isNotEmpty){

                     try{
                       final response = await http.post(
                           Uri.parse('http://192.168.1.25:5001/notes-moinul-flutter-project/us-central1/getRefreshToken'),
                           headers: {'Content-Type': 'application/json'},
                           body: jsonEncode({'userId': googleUserId})
                       );

                       if(response.statusCode == 200){
                         final data=json.decode(response.body);
                         final accesstoken=data['accessToken'];
                         accessTokem=accesstoken;
                         await loadDriveFile();

                         print('your server accessToken is: $accessTokem');
                       }else{
                         print('backend Error');
                       }

                     }catch (error){
                       print('server error: $error');
                     }

                    }else{
                      print('please connect your account');
                    }




                    // final response=await http.post(
                    //
                    //   //https://us-central1-notes-moinul-flutter-project.cloudfunctions.net/auth
                    //   //ekhane test er jonne use: http://192.168.1.25:5001/notes-moinul-flutter-project/us-central1/auth
                    //   Uri.parse('http://192.168.1.25:5001/notes-moinul-flutter-project/us-central1/auth'),
                    //   headers: {
                    //     'Content-Type': 'application/json',
                    //   },
                    // );
                    //
                    // final consentUrl=jsonDecode(response.body)['consentUrl'];
                    // final uri=Uri.parse(consentUrl);
                    //  await launchUrl(
                    //   uri,
                    //   mode: LaunchMode.inAppBrowserView,
                    // );

                    // final response2=await http.post(
                    //   Uri.parse('https://us-central1-notes-moinul-flutter-project.cloudfunctions.net/oauthCallback'),
                    //   headers: {'Content-Type': 'application/json'},
                    // );
                    // print('Status: ${response2.statusCode}');
                    // print('Body: ${response2.body}');


                  },
                  child: const Text('Server Response')
              ),

              ElevatedButton(onPressed: ()async{
                //await getdriveStorage();
                print('accessTOKEN value: ${authProviderr.accessToken}');
                //print('percent value: ${percent}');
              }, child: const Text('Storage Check')),
              Expanded(
                child: ListView.builder(

                  itemCount: users.length,
                    itemBuilder: (context, index) {
                    final folder=users[index];
                    return ListTile(
                      leading: const Icon(Icons.folder),
                      title: Text(users[index].name ?? 'Unknown' ),
                      onTap: ()async{
                        await _loadDrivefiless(folder.id!);
                        print('folder id: ${folder.id}');
                      },
                    );
                    },
                ),
              ),
              if(filedata.isNotEmpty) ...[
                const Divider(),
                Expanded(
                    child: ListView.builder(
                        itemCount: filedata.length,
                      itemBuilder: (context, index) {
                        final file = filedata[index];
                        return ListTile(
                          leading: const Icon(Icons.insert_drive_file),
                          title: Text(file.name?? 'Unnamed'),
                        );

                      },
                    ),

                )

              ]


            ],
          ),
        ),
        
      );
  }

  Future<void> _loadDrivefiless(String folderid)async{
    if(accessTokem == null){
      print('please set accessToken');
    }

    final client=GoogleHttpClient({
      'Authorization': 'Bearer $accessTokem',
    });

    final filess=await uploadDriveFile.listFilesInFolder(client, folderid);

    setState(() {
      filedata=filess;
    });

  }

  Future<void> loadDriveFile()async{
    if(accessTokem == null){
      print('please set accessToken');
    }

    final client=GoogleHttpClient({
      'Authorization': 'Bearer $accessTokem',
    });

    final files=await uploadDriveFile.getappDataFile(client);
    setState(() {
      users =files;
    });
  }


  // drive storage check
  Future<void> getdriveStorage()async {
    if (authProviderr.accessToken != null) {
      final client = GoogleHttpClient({
        'Authorization': 'Bearer ${authProviderr.accessToken}',
      });

      final driveapi = drive.DriveApi(client);
      final about = await driveapi.about.get(
        $fields: 'storageQuota',
      );

      final quota = about.storageQuota;
      final totalstorage = int.tryParse(quota?.limit ?? '0') ?? 0;
      final usedStorage = int.tryParse(quota?.usage ?? '0') ?? 0;

      double totalGBstorage = totalstorage / (1024 * 1024 * 1024);
      double usedGBStorage = usedStorage / (1024 * 1024 * 1024);
      //double percentage = (usedGBStorage/totalGBstorage) * 100;
      double percentvalues=(usedGBStorage/totalGBstorage);
      if(percentvalues>1.0){
        percentvalues=1.0;
      }
      double percent = percentvalues * 100;
      setState(() {
        _percentvalue=percentvalues;
        _percent=percent;
      });

      //print('total percentage : ${percentage.toStringAsFixed(2)} %');
      print('total storage: $totalGBstorage');
      print('used storage: ${usedGBStorage.toStringAsFixed(2)} GB');
    }
  }


  Future<void> _loadAccessToken() async {
    authProviderr = Provider.of<AuthProvider>(context, listen: false);

    setState(() {
      isLoading = true;
    });

    try {
      await authProviderr.getAccessTokenFromServer(); // এই method provider এ রাখবে
      await getdriveStorage();
    } catch (e) {
      print("Error loading token: $e");
    }

    setState(() {
      isLoading = false;
    });
  }


  @override
  void dispose() {
    super.dispose();
  }

}
