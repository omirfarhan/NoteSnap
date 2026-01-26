import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:notes/Data_Layer/google_http_client.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'dart:convert';

class DriveHttpRequestToServer {
  // Future<void> uploadFileGoogleDrive(GoogleHttpClient client, File file)async{
  //
  //   final driveapi=drive.DriveApi(client);
  //
  //   final mainfolder=drive.File();
  //
  //
  // }
  //



  Future<drive.File> createFolder(String folderName, GoogleHttpClient client) async {
    final drivetoserverupload = drive.DriveApi(client);

    final existingFolder=await drivetoserverupload.files.list(
      spaces: "appDataFolder",
      q: "name = '$folderName' and mimeType = 'application/vnd.google-apps.folder'",
      $fields: "files(id, name, mimeType)",
    );

    if(existingFolder.files != null && existingFolder.files!.isNotEmpty){
      final folder= existingFolder.files!.first;
      print('Alredy existing folder${folder.name}');
      return folder;
    }

    final folder = drive.File();
    folder.name = folderName;
    folder.parents = ["appDataFolder"];
    folder.mimeType = "application/vnd.google-apps.folder";

    final result = await drivetoserverupload.files.create(folder);

    //eta diye koto gula file create hoise egula dekha jay
    /*
    final fileList = await drivetoserverupload.files.list(
      spaces: "appDataFolder", // শুধু appDataFolder এর ভেতর খুঁজবে
       $fields: "files(id, name, mimeType)",
    );

    print("📂 appDataFolder contents:");
    for (drive.File filess in fileList.files ?? []) {


      print('📁 File/Folder name: ${filess.name}');
      print('📁 File/Folder id: ${filess.id}');
    }

     */

    print('✅ Created folder id: ${result.name}');
    return result;
  }

// Future<drive.FileList> showCreatedFolder(GoogleHttpClient client, String folderId,
  //     ) async {
  //   final driveApi = drive.DriveApi(client);
  //
  //
  //
  //   for(drive.File filess in fileList.files ??[]){
  //     print('📁 Folder name: ${filess.name}');
  //     print('📁 Folder id: ${filess.id}');
  //   }
  //
  //   return fileList;
  // }





}