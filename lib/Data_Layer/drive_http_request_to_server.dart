
import 'package:notes/Data/notemodel.dart';
import 'package:notes/Data_Layer/google_http_client.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'dart:convert';

class DriveHttpRequestToServer {

  Future<drive.File> createFolder(String folderName, GoogleHttpClient client) async {
    final drivetoserverupload = drive.DriveApi(client);

    final existingFolder=await drivetoserverupload.files.list(
      spaces: "appDataFolder",
      q: "name = '$folderName' and mimeType = 'application/vnd.google-apps.folder'",
      $fields: "files(id, name, mimeType)",
    );

    if(existingFolder.files != null && existingFolder.files!.isNotEmpty){
      final folder= existingFolder.files!.first;
     // print('Alredy existing folder: ${folder.name}');
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

    //print('✅ Created folder id: ${result.name}');
    return result;
  }

  Future<void> uploadNotesToFolder(GoogleHttpClient client, drive.File folder,
      List<Notemodel> notes)async{

    final drivetoserverupload = drive.DriveApi(client);

    for(var note in notes){
      String jsonData=jsonEncode(note);

      var noteFile=drive.File();
      noteFile.name="${note.title}.json";
      noteFile.parents=[folder.id!];

      var media=drive.Media(
        Stream.value(utf8.encode(jsonData)),
        utf8.encode(jsonData).length
      );

      await drivetoserverupload.files.create(
        noteFile,
        uploadMedia: media,
      );

    }

    final fileList = await drivetoserverupload.files.list(
      // spaces: "appDataFolder", // শুধু appDataFolder এর ভেতর খুঁজবে
      // $fields: "files(id, name, mimeType)",

      //file name see
        spaces: "appDataFolder",
        q: "'${folder.id}' in parents",
        $fields: "files(id, name, mimeType)"

        // spaces: "appDataFolder",
        // q: "mimeType = 'application/vnd.google-apps.folder' or mimeType != 'application/vnd.google-apps.folder'",
        // $fields: "files(id, name, mimeType, parents)"

    );

    // for (var f in fileList.files!) {
    //   print("${f.name} (${f.mimeType}) parent=${f.parents}");
    // }

    //file name see
    for(var note in fileList.files!){
      print('📁 Note File Name: ${note.name}');
    }

    // for (drive.File filess in fileList.files ?? []) {
    //   print('📁 File/Folder name: ${filess.name}');
    //   print('📁 File/Folder id: ${filess.id}');
    // }

    print('working at uploadNotesToFolder');
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




}