
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:notes/Data/folder_with_file.dart';
import 'package:notes/Data/notemodel.dart';
import 'package:notes/Data/folder_model.dart';
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
  bool isLoading = false;
  bool isSelected = false;

  List<FolderWithFiles> _allData = [];

  String? accessTokem;
   double? _percentvalue;
   double? _percent;
  double? get percentvalue => _percentvalue;
  double? get percent => _percent;



  List<FolderModel> folders=[];
  List<FolderModel> filedata=[];




  @override
  void initState() {
    super.initState();
   Future.microtask(() => _loadAccessToken());
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((results) {
      final isConnected = results.any((r) => r != ConnectivityResult.none);

      if (!isConnected) {
        _wasDisconnected = true;
      } else if (isConnected && _wasDisconnected) {
        _wasDisconnected = false;
        _loadAccessToken();
      }
    });
  }

  GoogleHttpClient get _client => GoogleHttpClient({
    'Authorization': 'Bearer ${authProviderr.accessToken}',
  });


  @override
  Widget build(BuildContext context) {


      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
           title: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center, // 🔥 center align
              children: [
                const Text('Storage'),
                const SizedBox(height: 4),
                LinearPercentIndicator(
                  lineHeight: 8,
                  percent: percentvalue ?? 0,
                  center: Text(
                    "${(percent ?? 0).toStringAsFixed(1)} %",
                    style: TextStyle(fontSize: 6),
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

          actions: [
            IconButton(
              onPressed: (){

              },
              icon: Icon(Icons.delete_outline)
            )
          ],

        ),


        body: SafeArea(
          child: Column(
            children: [
              /*
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



                      final createSubFolder=await uploadDriveFile.createFolder('n', client);
                      final uploadToServer=await uploadDriveFile.uploadNotesToFolder(client, createSubFolder,notes);

                      print('upload to server Report: ${createSubFolder}');


                    }else{
                      //await AuthProvider.signinwithGoogle();
                      print('upload to server Report false $accessTokem');
                    }


                  },
                  child: const Text('Save Drive')
              ),

               */

              if(isLoading)
                const Expanded(
                    child:Center(
                       child: SizedBox(
                          width: 25,
                          height: 25,
                          child: CircularProgressIndicator(strokeWidth: 2,),
                        ),
                    ),

                )
              else ...[
                Expanded(
                  child: _allData.isEmpty ?  //folders.isEmpty
                      const Center(
                        child: Text(
                          'No note is created',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white54
                          ),
                        ),
                      )
        :ListView.builder(
                    itemCount: _allData.length,   //folders.length
                    itemBuilder: (context, index) {
                      final folder=_allData[index];
                      //final isSelected = _selectedFoldernames.contains(folder.folder.name);

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF1A7EA8)
                                : const Color(0xFF4592AC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF9EDDE4)
                                  : const Color(0xFF1A7EA8),
                              width: 0.5,
                            ),
                          ),
                          child: ListTile(
                            leading: const Icon(Icons.folder, color: Color(0xFFE8F8FD)),
                            title: Text(
                              folder.folder.name ?? 'Unknown',
                              style: const TextStyle(
                                color: Color(0xFFE8F8FD),
                                fontSize: 18,
                              ),
                            ),
                            // trailing: Text(
                            //   '${folder.noteCount ?? 0}', // যদি থাকে
                            //   style: const TextStyle(
                            //     color: Color(0xFFE8F8FD),
                            //     fontSize: 12,
                            //     fontFamily: 'Regular',
                            //   ),
                            // ),
                          ),
                        ),



                      );
                      // return ListTile(
                      //   leading: const Icon(Icons.folder),
                      //   title: Text(folder.folder.name ?? 'Unknown' ),
                      //   onTap: ()async{
                      //     // await _loadDrivefiless(folder.id!);
                      //     // print('folder id: ${folder.id}');
                      //   },
                      // );
                    }
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

                  ),
                ],
              ],

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
      folders =files;
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

      double percentvalues=(usedGBStorage/totalGBstorage);
      if(percentvalues>1.0){
        percentvalues=1.0;
      }
      double percent = percentvalues * 100;
      setState(() {
        _percentvalue=percentvalues;
        _percent=percent;
      });

    }
  }


  Future<void> _loadAccessToken() async {

    authProviderr = Provider.of<AuthProvider>(context, listen: false);


    setState(() {
      isLoading = true;
      accessTokem=authProviderr.accessToken;
    });



    try {
      final success= await authProviderr.getAccessTokenFromServer(); // এই method provider এ রাখবে
      if(success!= null){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(success)));
      }

      final data = await uploadDriveFile.getAllFoldersWithFiles(_client);

      await getdriveStorage();
      await loadDriveFile();

      if (mounted) {
        setState(() => _allData = data);
      }

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
