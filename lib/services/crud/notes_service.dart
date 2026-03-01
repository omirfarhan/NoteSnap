import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:notes/extensions/list.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class DatabaseAlreadyopenException implements Exception {}
class UnabletoGetDocuments implements Exception {}
class DatabaseIsNotOpen implements Exception {}
class CouldNotDeleteUser implements Exception {}
class userAlreadyExists implements Exception {}
class CouldnotFindUser implements Exception {}
class CouldNotFindFolder implements Exception {}
class CouldNotdeleteNote implements Exception {}
class CouldNotFindNote implements Exception {}
class CouldNotUpdateNote implements Exception {}
class Databaseallreadyopen implements Exception {}
class UserShouldBeSetBeforeReadingAllNotes implements Exception {}

class NotesService {
  Database? _db;
  Folder? _folder;
  List<DatabaseNote> _notes= [];
  List<Map<String, dynamic>>noteContent=[];

  late final StreamController<List<DatabaseNote>> _noteStreamController;

  static final NotesService _shared = NotesService._shareInstance();
  NotesService._shareInstance() {
    _noteStreamController=StreamController<List<DatabaseNote>>.broadcast(
        onListen: () {
          _noteStreamController.sink.add(_notes);
        },
    );
  }

  factory NotesService() => _shared;


  Stream<List<DatabaseNote>> get allNotes =>
  _noteStreamController.stream.filter((note){
    final currentfolder=_folder;
    if(currentfolder != null){
      return note.userId==currentfolder.id;
    }else{
      throw UserShouldBeSetBeforeReadingAllNotes();
    }

  });


  Future<void> _ensureDbisOpen()async{
    try{
      await open();
    }on DatabaseAlreadyopenException{
    }
  }

  Future<void> _cacheNote()async{
    final allNotes=await getallNotes();
    _notes=allNotes.toList();
    _noteStreamController.add(_notes);
  }


  Future<void> debugPrintAllNotes() async {
    await _ensureDbisOpen(); // এই লাইনটা যোগ করুন
    final db = _getDatabaseorThrow();
    final result = await db.query(noteTable);
    print(result);
  }

  Future<Folder> getOrCreateFolder({
    required String foldername,
    bool setCurrentFolder=true
  })async{
    try{
      final folder=await getFolder(foldername: foldername);
      if(setCurrentFolder){
        _folder=folder;
      }
      return folder;

    }on CouldNotFindFolder{
      final createdFolder=await createFolder(foldername: foldername);
      if(setCurrentFolder){
        _folder=createdFolder;
      }
      return createdFolder;
    }catch (e){
      rethrow;
    }
  }

  Future<DatabaseNote> updateNote({
    required DatabaseNote note,
    required String text,
    required String content
  })async{
    await _ensureDbisOpen();
    final db=_getDatabaseorThrow();
    print('Updating note ${note.id} with text: $text'); // এখানে
    await getNote(id: note.id);

    final updateCount=await db.update(noteTable, {
      titleColumn: text,
      contentColumn: content
    },
      where: 'id = ?',
      whereArgs: [note.id],
    );
    print('Update count: $updateCount'); // এখানে
    if(updateCount == 0){
      throw CouldNotUpdateNote();
    }else{
      final updateNote=await getNote(id: note.id);
      _notes.removeWhere((note)=> note.id==updateNote.id);
      _notes.add(updateNote);
      _noteStreamController.add(_notes);
      return updateNote;
    }


  }

  Future<Iterable<DatabaseNote>> getallNotes()async{
    await _ensureDbisOpen();
    final db=_getDatabaseorThrow();
    final notes= await db.query(noteTable);
    return notes.map((noteRow) => DatabaseNote.fromRow(noteRow));
  }

  Future<DatabaseNote> getNote({required int id})async{
    await _ensureDbisOpen();
    final db=_getDatabaseorThrow();
    final notes=await db.query(noteTable, limit: 1,  where: 'id = ? ', whereArgs: [id]);

    if(notes.isEmpty){
      throw CouldNotFindNote();
    }else{
      final note=DatabaseNote.fromRow(notes.first);
      _notes.removeWhere((note) => note.id ==id);
      _notes.add(note);
      _noteStreamController.add(_notes);
      return note;
    }


  }

  //kisu baki ase
  Future<int> deleteAllNotes()async{
    await _ensureDbisOpen();
    final db= _getDatabaseorThrow();
    final numberofDeletetions= await db.delete(noteTable);
    _notes=[];
    //stream controller use
    _noteStreamController.add(_notes);
    return numberofDeletetions;
  }
  //kisu baki ase
  Future<void> deleteNote({required int id})async{
    await _ensureDbisOpen();
    final db=_getDatabaseorThrow();
    final deleteCount=await db.delete(
     noteTable,
      where: ' id = ? ',
      whereArgs: [id]
    );
    if(deleteCount == 0){
      throw CouldNotdeleteNote();
    }else{
      _notes.removeWhere((note)=> note.id ==id);
      _noteStreamController.add(_notes);
    }

  }

  //image tao add korte hobe
  void addImage(String imagePath){
    noteContent.add({
      "type": "image",
      "value": imagePath
    });
  }

  void addText(String text){
    noteContent.add({
      "type": "text",
      "value": text
    });
  }
  Future<DatabaseNote> createNote({required Folder owner})async{
    noteContent=[];
    await _ensureDbisOpen();
    final db=_getDatabaseorThrow();

    final dbFolder=await getFolder(foldername: owner.foldername);
    print('Found folder: ${dbFolder.id} - ${dbFolder.foldername}');

    if(dbFolder != owner){
      throw CouldNotFindFolder();
    }

    const text='';
    final noteid=await db.insert(
      noteTable,{
      folderIdColumn: owner.id,
      titleColumn: text,
      contentColumn:jsonEncode(noteContent)
    });

    print('Inserted note with id: $noteid');
    final note=DatabaseNote(
        id: noteid,
        userId: owner.id,
        title: text,
        content: jsonEncode(noteContent)
    );

    _notes.add(note);
    _noteStreamController.add(_notes);

    return note;
  }

  Future<Folder> getFolder({required String foldername})async{
    await _ensureDbisOpen();
    final db=_getDatabaseorThrow();
    final result=await db.query(
        folderTable,
        limit: 1,
        where: 'foldername = ?',
        whereArgs: [foldername.toLowerCase()]
    );
    if (result.isEmpty) {
      throw CouldNotFindFolder(); // CouldnotFindUser থেকে change করুন
    } else {
      return Folder.fromRow(result.first);
    }
  }

  Future<Folder> createFolder({required String foldername})async{
    await _ensureDbisOpen();
    final db=_getDatabaseorThrow();
    final results=await db.query(
        folderTable,limit: 1,
        where: 'foldername = ? ',
        whereArgs: [foldername.toLowerCase()]
    );
    if(results.isNotEmpty){
      throw userAlreadyExists();
    }
    final folderId=await db.insert(folderTable,{
      nameColumn: foldername.toLowerCase()
    });
    return Folder(id: folderId, foldername: foldername);
  }

  Future<void> deleteFolder({required String foldername})async{
    await _ensureDbisOpen();
    final db=_getDatabaseorThrow();
    final deleteAccount= await db.delete(
        folderTable,where: 'foldername = ?',
        whereArgs: [foldername.toLowerCase()]
    );
    if(deleteAccount!= 1){
      throw CouldNotDeleteUser();
    }
  }
  Database _getDatabaseorThrow(){
    final db=_db;
    if(db== null){
      throw DatabaseIsNotOpen();
    }else{
      return db;
    }
    
  }
  Future<void> close()async{
    final db=_db;
    if(db == null){
      throw DatabaseIsNotOpen();
    }else{
      await db.close();
      _db=null;
    }
  }
  Future<void> open()async{

    if(_db != null){
     throw DatabaseAlreadyopenException();
    }try{
      final docsPath= await getApplicationDocumentsDirectory();
      final dbpath=join(docsPath.path, dbname);
      final db=await openDatabase(dbpath);
      _db=db;

      await db.execute(CreateFolderTable);
      await db.execute(createNoteTable);
      await _cacheNote();
    }on MissingPlatformDirectoryException{
      throw UnabletoGetDocuments();
    }
    
  }

}



class DatabaseNote{
  final int id;
  final int userId;
  final String title;
  final String content;
  //is_synced_with_cloud ei option ta pore add korbo jodi lge

  DatabaseNote({
    required this.id,
    required this.userId,
    required this.title,
    required this.content
  });

  DatabaseNote.fromRow(Map<String, Object?> map):
  id=map[idColumn] as int,
  userId=map[folderIdColumn] as int,
  title=map[titleColumn] as String,
  content=map[contentColumn] as String;

  @override
  String toString() => 'Note, ID=$id, user_id=$userId, title=$title,';

  @override
  bool operator ==(covariant DatabaseNote other) => id== other.id;

  @override
  int get hashCode => id.hashCode;
}

@immutable
class Folder{
  final int id;
  final String foldername;

  const Folder({
    required this.id,
    required this.foldername,
  });

  Folder.fromRow(Map<String, Object?> map)
  : id=map[idColumn] as int,
    foldername=map[nameColumn] as String;

  @override
  String toString() => 'Person, ID=$id, foldername=$foldername';

  @override
  bool operator == (covariant Folder other) =>id==other.id;

  @override
  int get hashCode => id.hashCode;

}

const CreateFolderTable='''CREATE TABLE IF NOT EXISTS "user" (
	          "id"	INTEGER NOT NULL,
	         "foldername"	TEXT NOT NULL UNIQUE,
	         PRIMARY KEY("id" AUTOINCREMENT
	         )
);''';

const createNoteTable='''CREATE TABLE IF NOT EXISTS "note" (
	        "id"	INTEGER NOT NULL,
	        "user_id"	INTEGER NOT NULL,
	        "title"	TEXT,
	        "content" TEXT,
	         FOREIGN KEY("user_id") REFERENCES "user"("id"),
	         PRIMARY KEY("id" AUTOINCREMENT)
);''';



const idColumn='id';
const nameColumn='foldername';
const folderIdColumn='user_id';
const titleColumn='title';
const contentColumn='content';
const dbname='note.db';
const folderTable='user';
const noteTable='note';