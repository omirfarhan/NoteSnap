import 'dart:convert';

import 'package:googleapis/drive/v3.dart' as drive;
import 'package:notes/services/crud/notes_service.dart';

class DriveService {

  final String accessToken;
  late final drive.DriveApi _driveApi;

  Future<String> _getOrCreateAppFolder() async {
    const appFolderName = 'MyNotesApp';

    final result = await _driveApi.files.list(
      q: "name='$appFolderName' "
          "and mimeType='application/vnd.google-apps.folder' "
          "and trashed=false",
      spaces: 'drive',
      $fields: 'files(id)',
    );

    if (result.files != null && result.files!.isNotEmpty) {
      return result.files!.first.id!;
    }

    final folder=drive.File();
    folder.name=appFolderName;
    folder.mimeType='application/vnd.google-apps.folder';

    final created = await _driveApi.files.create(folder);
    return created.id!;
  }


  Future<String> _getOrCreateNoteFolder({
    required String folderName,
    required String parentId,
  })async{

    final result = await _driveApi.files.list(
      q: "name='$folderName' "
          "and mimeType='application/vnd.google-apps.folder' "
          "and '$parentId' in parents "
          "and trashed=false",
      spaces: 'drive',
      $fields: 'files(id)',
    );

    if (result.files != null && result.files!.isNotEmpty) {
      return result.files!.first.id!;
    }

    final folder = drive.File();
    folder.name=folderName;
    folder.mimeType='application/vnd.google-apps.folder';
    folder.parents=[parentId];

    final created = await _driveApi.files.create(folder);
    return created.id!;

  }


  Future<void> uploadNote({
    required DatabaseNote note,
    required String folderName
  })async{

    final appFolderId=await _getOrCreateAppFolder();

    final noteFolderId=await _getOrCreateNoteFolder(
      folderName: folderName,
      parentId: appFolderId
    );

    final jsonStr=jsonEncode({
      'id':note.id,
      'folderId': note.userId,
      'title': note.title,
      'content': note.content,
      'background': note.background,
      'lastEdited': note.lastEdited,
    });

    final bytes=utf8.encode(jsonStr);
    final fileName='note_${note.id}.json';

    final existing = await _driveApi.files.list(
      q: "name='$fileName' "
          "and '$noteFolderId' in parents "
          "and trashed=false",
      spaces: 'drive',
      $fields: 'files(id)',
    );

    if (existing.files != null && existing.files!.isNotEmpty) {
      await _driveApi.files.update(
        drive.File(),
        existing.files!.first.id!,
        uploadMedia: drive.Media(
          Stream.fromIterable([bytes]),
          bytes.length,
        ));
    }

 }

}

