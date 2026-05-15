
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:googleapis/drive/v3.dart' as drive;
import 'package:notes/Data/folder_model.dart';
import 'package:notes/Data_Layer/drive_http_request_to_server.dart';
import 'package:notes/Data_Layer/google_http_client.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../auth/auth_provider.dart';
import 'cloud_folder_file_page.dart';


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


  bool _isSelecting = false;

  Set<String> _selectedFolderIds = {};




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

  void _toggleFolderSelect(String id) {
    setState(() {
      if (_selectedFolderIds.contains(id)) {
        _selectedFolderIds.remove(id);
        if (_selectedFolderIds.isEmpty) _isSelecting = false;
      } else {
        _selectedFolderIds.add(id);
      }
    });
  }

  // ── Delete selected folders (ভেতরের notes সহ) ────────────
  Future<void> _deleteSelectedFolders() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0D6186),
        title: const Text(
          'Delete folders?',
          style: TextStyle(color: Color(0xFFD9FFFF)),
        ),
        content: Text(
          '${_selectedFolderIds.length} folder(s) and all notes inside will be permanently deleted.',
          style: const TextStyle(color: Color(0xFF9EDDE4)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFF9EDDE4))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    setState(() => isLoading = true);

    try {
      for (final folderId in _selectedFolderIds) {

        final files = await uploadDriveFile.listFilesInFolder(
          _client,
          folderId,
        );
        for (final file in files) {
          if (file.id != null) {
            await uploadDriveFile.deleteFile(_client, file.id!);
          }
        }

        await uploadDriveFile.deleteFile(_client, folderId);
      }

      // UI থেকে সরাও
      setState(() {
        folders.removeWhere((f) => _selectedFolderIds.contains(f.id));
        _selectedFolderIds.clear();
        _isSelecting = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Deleted ✓'),
            backgroundColor: Color(0xFF0D6186),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {


      return Scaffold(
        backgroundColor: Color(0xFF0D6186),
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle.light,
          backgroundColor: Color(0xFF0D6186),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back,color: Color(0xFFD9FFFF)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
           title: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center, // 🔥 center align
              children: [
                const Text('Storage',style: TextStyle(
                    color: Color(0xFFD9FFFF)
                )),
                const SizedBox(height: 4),
                LinearPercentIndicator(
                  lineHeight: 14,
                  percent: percentvalue ?? 0,
                  center: Text(
                    "${(percent ?? 0).toStringAsFixed(1)} %",
                    style: TextStyle(fontSize: 10),
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
              onPressed: _isSelecting && _selectedFolderIds.isNotEmpty
                ? _deleteSelectedFolders
                : null,
              icon: Icon(Icons.delete_outline)
            )
          ],

        ),


        body: SafeArea(
          child: Column(
            children: [

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
                  child: folders.isEmpty ?
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
                    itemCount: folders.length,   //folders.length
                    itemBuilder: (context, index) {
                      final folder=folders[index];

                      final isSelected = _selectedFolderIds.contains(folder.id);

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                        child: InkWell(

                          onLongPress: () {
                            setState(() {
                              _isSelecting = true;
                              _selectedFolderIds.add(folder.id!);
                            });

                          },

                          onTap:() {

                            if(_isSelecting){
                              _toggleFolderSelect(folder.id!);
                            }else{
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CloudFolderFilePage(
                                    folderName: folder.name ?? 'Unknown',
                                    folderId: folder.id!,
                                    authProvider: authProviderr,
                                  ),
                                ),
                              );
                            }
                          },
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
                                folder.name ?? 'Unknown',
                                style: const TextStyle(
                                  color: Color(0xFFE8F8FD),
                                  fontSize: 18,
                                ),
                              ),

                            ),
                          ),
                        ),
                      );
                    }
                  ),
                ),
              ],
            ],
          ),
        ),
      );
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
      final success= await authProviderr.getAccessTokenFromServer();
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
