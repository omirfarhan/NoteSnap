
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




}