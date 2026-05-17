import 'dart:convert';

import 'package:googleapis/drive/v3.dart' as drive;
import 'package:notes/services/crud/notes_service.dart';

import '../../Data_Layer/google_http_client.dart';

class DriveService {
  final String accessToken;
  late final drive.DriveApi _driveApi;

  DriveService({required this.accessToken}) {
    final client = GoogleHttpClient({
      'Authorization': 'Bearer $accessToken',
    });
    _driveApi = drive.DriveApi(client);
  }

  // 🔹 Get or Create Main App Folder (inside appDataFolder)
  Future<String> _getOrCreateAppFolder() async {
    const appFolderName = 'MyNotesApp';

    final result = await _driveApi.files.list(
      spaces: 'appDataFolder',
      q: "name='$appFolderName' and mimeType='application/vnd.google-apps.folder'",
      $fields: 'files(id)',
    );

    if (result.files != null && result.files!.isNotEmpty) {
      return result.files!.first.id!;
    }

    final folder = drive.File()
      ..name = appFolderName
      ..mimeType = 'application/vnd.google-apps.folder'
      ..parents = ['appDataFolder']; // 🔥 IMPORTANT

    final created = await _driveApi.files.create(folder);
    return created.id!;
  }

  /// 🔹 Create sub-folder inside app folder
  Future<String> _getOrCreateNoteFolder({
    required String folderName,
    required String parentId,
  }) async {
    final result = await _driveApi.files.list(
      spaces: 'appDataFolder',
      q: "name='$folderName' and mimeType='application/vnd.google-apps.folder' and '$parentId' in parents",
      $fields: 'files(id)',
    );

    if (result.files != null && result.files!.isNotEmpty) {
      return result.files!.first.id!;
    }

    final folder = drive.File()
      ..name = folderName
      ..mimeType = 'application/vnd.google-apps.folder'
      ..parents = [parentId];

    final created = await _driveApi.files.create(folder);
    return created.id!;
  }

  /// 🔹 Upload Single Note
  Future<void> uploadNote({
    required DatabaseNote note,
    required String folderName,
  }) async {
    final appFolderId = await _getOrCreateAppFolder();

    final noteFolderId = await _getOrCreateNoteFolder(
      folderName: folderName,
      parentId: appFolderId,
    );

    final jsonStr = jsonEncode({
      'id': note.id,
      'folderId': note.userId,
      'title': note.title,
      'content': note.content,
      'background': note.background,
      'lastEdited': note.lastEdited,
    });

    final bytes = utf8.encode(jsonStr);
    final fileName = 'note_${note.id}.json';

    final existing = await _driveApi.files.list(
      spaces: 'appDataFolder',
      q: "name='$fileName' and '$noteFolderId' in parents",
      $fields: 'files(id)',
    );

    if (existing.files != null && existing.files!.isNotEmpty) {
      // 🔄 Update existing
      await _driveApi.files.update(
        drive.File(),
        existing.files!.first.id!,
        uploadMedia: drive.Media(
          Stream.value(bytes),
          bytes.length,
        ),
      );
    } else {
      // 🆕 Create new
      final driveFile = drive.File()
        ..name = fileName
        ..parents = [noteFolderId];

      await _driveApi.files.create(
        driveFile,
        uploadMedia: drive.Media(
          Stream.value(bytes),
          bytes.length,
        ),
      );
    }
  }

  // 🔹 Upload Multiple Notes
  Future<void> uploadMultipleNotes({
    required List<DatabaseNote> notes,
    required String folderName,
  }) async {
    for (final note in notes) {
      await uploadNote(
        note: note,
        folderName: folderName,
      );
    }
  }
}

