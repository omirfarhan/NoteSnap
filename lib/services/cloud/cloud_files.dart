
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
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

  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool _wasDisconnected = false;
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
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((results) {
      final isConnected = results.any((r) => r != ConnectivityResult.none);

      if (!isConnected) {
        // Net গেছে - track করো
        _wasDisconnected = true;
      } else if (isConnected && _wasDisconnected) {
        // Net ফিরে এসেছে - reload করো
        _wasDisconnected = false;
        _loadAccessToken(); // ✅ Auto reload
      }
    });
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
    if(authProviderr.accessToken == null){
      print('please set accessToken');
    }

    final client=GoogleHttpClient({
      'Authorization': 'Bearer ${authProviderr.accessToken}',
    });

    final filess=await uploadDriveFile.listFilesInFolder(client, folderid);

    setState(() {
      filedata=filess;
    });

  }

  Future<void> loadDriveFile()async{
    if(authProviderr.accessToken == null){
      print('please set accessToken');
    }

    final client=GoogleHttpClient({
      'Authorization': 'Bearer ${authProviderr.accessToken}',
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
      final success= await authProviderr.getAccessTokenFromServer(); // এই method provider এ রাখবে
      if(success!= null){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(success)));
      }
      await getdriveStorage();
      await loadDriveFile();

    }catch (e) {
      print("Error loading token: $e");
    }

    setState(() {
      isLoading = false;
    });
  }


  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

}
