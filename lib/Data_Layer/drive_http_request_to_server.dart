
import 'package:notes/Data/notemodel.dart';
import 'package:notes/Data/user_model.dart';
import 'package:notes/Data_Layer/google_http_client.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'dart:convert';

import 'package:notes/services/auth/auth_provider.dart';

class DriveHttpRequestToServer {

  final AccessToken=AuthProvider.driveAccessToken;

  static double? percentage=0.0;


  Future<drive.File> createFolder(String folderName, GoogleHttpClient client) async {
    final drivetoserverupload = drive.DriveApi(client);

    final existingFolder=await drivetoserverupload.files.list(
      spaces: "appDataFolder",
      q: "name = '$folderName' and mimeType = 'application/vnd.google-apps.folder'",
      $fields: "files(id, name, mimeType)",
    );

    if(existingFolder.files != null && existingFolder.files!.isNotEmpty){
      final folder= existingFolder.files!.first;
      print('Alredy existing folder: ${folder.name}');
      return folder;
    }

    final folder = drive.File();
    folder.name = folderName;
    folder.parents = ["appDataFolder"];
    folder.mimeType = "application/vnd.google-apps.folder";

    final result = await drivetoserverupload.files.create(folder);

    //eta diye koto gula file create hoise egula dekha jay

    final fileList = await drivetoserverupload.files.list(
      spaces: "appDataFolder", // শুধু appDataFolder এর ভেতর খুঁজবে
       $fields: "files(id, name, mimeType)",
    );

    print("📂 appDataFolder contents:");
    for (drive.File filess in fileList.files ?? []) {
      print('📁 File/Folder name: ${filess.name}');
      print('📁 File/Folder id: ${filess.id}');
      final filename=filess.name;
      final id=filess.id;
      UserModel(
        name: filename,
        id: id,
      );
    }



    print('✅ Created folder id: ${result.name}');
    return result;
  }

  Future<List<UserModel>> getappDataFile(GoogleHttpClient client)async{
    final driveapi=drive.DriveApi(client);

    final folderList= await driveapi.files.list(
      spaces: "appDataFolder",
      q: "mimeType = 'application/vnd.google-apps.folder' and trashed = false",
      $fields: "files(id, name, mimeType)",
    );

    return (folderList.files ?? [])
        .where((f) => f.name != null && f.id != null)
        .map((f) => UserModel(name: f.name, id: f.id)).toList();

  }

  Future<List<UserModel>> listFilesInFolder(GoogleHttpClient client, String folderid)async{
    final driveapi=drive.DriveApi(client);
    final filelist=await driveapi.files.list(
      spaces: "appDataFolder",
      q: "'$folderid' in parents and trashed = false",
      $fields: "files(id, name, mimeType)",
    );
    return (filelist.files ?? [])
        .where((f) => f.name != null && f.id != null)
        .map((f) => UserModel(name: f.name, id: f.id)).toList();
  }




  Future<void> uploadNotesToFolder(GoogleHttpClient client, drive.File folder,
      List<Notemodel> notes)async{

    final driveApi = drive.DriveApi(client);

    for(var note in notes){
      final filename = "${note.title}.json";
      final jsondata=jsonEncode(note.toJson());

      final existingfile=await findNoteFile(folder.id!, filename, driveApi);

      if(existingfile != null){
        final oldData=await readFileContent(driveApi, existingfile.id!);

        if(oldData != jsondata){
          await driveApi.files.update(
              drive.File(),
              existingfile.id!,
              uploadMedia: drive.Media(
                  Stream.value(utf8.encode(jsondata)),
                  utf8.encode(jsondata).length
              )
          );
          print('upload at new content');
        }else{
          print('Skipped at: ${filename}');
          continue;
        }

      }else{
        //if file does not exists then create new file
        final noteFile=drive.File();
        noteFile.name=filename;
        noteFile.parents=[folder.id!];

        await driveApi.files.create(
            noteFile,
          uploadMedia: drive.Media(
              Stream.value(utf8.encode(jsondata)),
              utf8.encode(jsondata).length
          )
        );

        print('new file create at: ${filename}');

      }

    }

  }

  Future<drive.File?> findNoteFile(String folderId, String filename, drive.DriveApi api)async{

    final filelist=await api.files.list(
      spaces: 'appDataFolder',
      q: "'$folderId' in parents and name='$filename'",
      $fields: "files(id, name)",
    );

    if(filelist.files != null && filelist.files!.isNotEmpty){
      return filelist.files!.first;
    }

    return null;
  }


  Future<String> readFileContent(drive.DriveApi api, String fileId)async{

    final media=await api.files.get(fileId,
      downloadOptions: drive.DownloadOptions.fullMedia
    ) as drive.Media;

    final bytes=await media.stream.fold<List<int>>(
      [],(previous, element) => previous..addAll(element)
    );
    return utf8.decode(bytes);
  }


  //Drive Storage check
Future<void> getDriveStorage()async{

    if(AccessToken!= null){
      final client=GoogleHttpClient({
        'Authorization': 'Bearer $AccessToken',
      });

      final api=drive.DriveApi(client);
      final about=await api.about.get(
        $fields: 'storageQuota',
      );

      final quota=about.storageQuota!;
      final totalStorage=int.parse(quota.limit!);
      final usedStorage=int.parse(quota.usage!);
      //final freeStorage=totalStorage - usedStorage;

      double totalstorageGB=totalStorage/(1024*1024*1024);
      double usesStorageGB=usedStorage/(1024*1024*1024);

      percentage=usesStorageGB/totalstorageGB;


      // print("Total Storage: ${bytesToGB.toStringAsFixed(2)} GB");
      // print("Uses Storage: ${usedStorage}");
      // print("Free Storage: ${freeStorage}");


    }



}




}