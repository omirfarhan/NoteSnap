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
  List<Folder> _folders = [];
  List<Map<String, dynamic>>noteContent=[];
  late final StreamController<List<Folder>> _folderStreamController;


  late final StreamController<List<DatabaseNote>> _noteStreamController;

  static final NotesService _shared = NotesService._shareInstance();
  NotesService._shareInstance() {
    _noteStreamController=StreamController<List<DatabaseNote>>.broadcast(
        onListen: () {
          _noteStreamController.sink.add(_notes);
        },
    );

    _folderStreamController = StreamController<List<Folder>>.broadcast(
      onListen: () {
        _folderStreamController.sink.add(_folders);
      },
    );

  }

  factory NotesService() => _shared;

  Stream<List<Folder>> get allFolders => _folderStreamController.stream;

  Stream<List<DatabaseNote>> get allNotes =>
      _noteStreamController.stream.filter((note){
        final currentfolder=_folder;
        if(currentfolder != null){
          return note.userId==currentfolder.id;
        }else{
          throw UserShouldBeSetBeforeReadingAllNotes();
        }
      });


  Stream<List<DatabaseNote>> get allNotesUnfiltered async* {
    yield _notes; // ✅ সাথে সাথে current data দেবে
    yield* _noteStreamController.stream;
  }


  Stream<List<DatabaseNote>> notesForFolder(int folderId) async* {

    yield _notes.where((note) => note.userId == folderId).toList();

    // ✅ তারপর থেকে real-time update
    yield* _noteStreamController.stream.map(
          (notes) => notes.where((note) => note.userId == folderId).toList(),
    );
  }

  void refreshNotes() {
    _noteStreamController.add(_notes);
  }

  Future<void> _ensureDbisOpen()async{
    try{
      await open();
    }on DatabaseAlreadyopenException{
    }
  }

  Future<void> _cacheFolders() async {
    final db = _getDatabaseorThrow();
    final result = await db.query(folderTable);
    _folders = result.map((row) => Folder.fromRow(row)).toList();
    if (!_folderStreamController.isClosed) {
      _folderStreamController.add(_folders);
    }
   // _folderStreamController.add(_folders);
  }

  Future<void> _cacheNote()async{
    final allNotes=await getallNotes();
    _notes=allNotes.toList();

    _noteStreamController.add(_notes);
  }

  //eta hocche sodu folder er jonne
  //--> mane listview te eta dara show korbe noteCount
  int getNoteCountForFolder({required String foldername}){


    final folder = _folders.firstWhere(
          (f) => f.foldername.toLowerCase() == foldername.toLowerCase(),
      orElse: () => Folder(id: -1, foldername: ''),
    );

    if (folder.id == -1) return 0;
    return _notes.where((note) => note.userId == folder.id).length;
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
    required String content,
    String? background,
  })async{
    await _ensureDbisOpen();
    final db=_getDatabaseorThrow();
    final now = DateTime.now().millisecondsSinceEpoch; // 👈 ADD
    await getNote(id: note.id);

    final updateCount=await db.update(noteTable, {
      titleColumn: text,
      contentColumn: content,
      backgroundColumn:background,
      lastEditedColumn:now
    },
      where: 'id = ?',
      whereArgs: [note.id],
    );

    if(updateCount == 0){
      throw CouldNotUpdateNote();
    }else{
      final updateNote=await getNote(id: note.id);
      _notes.removeWhere((note)=> note.id==updateNote.id);
      _notes.insert(0, updateNote); // ← add এর বদলে insert(0)
      _notes.sort((a,b) => b.lastEdited.compareTo(a.lastEdited));
      _noteStreamController.add(_notes);
      // ←←← এই লাইন যোগ করুন
      await _cacheFolders();
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
      _notes.insert(0,note);
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
      // ←←← এই লাইন যোগ করুন
      await _cacheFolders();
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
    final now = DateTime.now().millisecondsSinceEpoch;

    if(dbFolder != owner){
      throw CouldNotFindFolder();
    }
    const text='';
    final noteid=await db.insert(
      noteTable,{
      folderIdColumn: owner.id,
      titleColumn: text,
      contentColumn:jsonEncode(noteContent),
      backgroundColumn:null,
      lastEditedColumn:now
    });

    final note=DatabaseNote(
        id: noteid,
        userId: owner.id,
        title: text,
        content: jsonEncode(noteContent),
        background: null,
       lastEdited: now
    );

    //_notes.add(note);
    _notes.insert(0, note);
    _noteStreamController.add(_notes);
    _folderStreamController.add(_folders);
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

    final folder = Folder(id: folderId, foldername: foldername);
    _folders.add(folder);          // এটা যোগ করো
    _folderStreamController.add(_folders); // এটা যোগ করো
    return folder;
  }

  Future<void> deleteFolder({required String foldername})async{
    await _ensureDbisOpen();
    final db=_getDatabaseorThrow();

    final folder = await getFolder(foldername: foldername);

    final deleteNotes= await db.delete(
      noteTable,
      whereArgs: [folder.id],
      where: '$folderIdColumn = ?',
    );
    
    _notes.removeWhere((note) => note.userId == folder.id);
    _noteStreamController.add(_notes);

    final deleteAccount= await db.delete(
        folderTable,
        where: 'foldername = ?',
        whereArgs: [foldername.toLowerCase()]
    );
    if(deleteAccount!= 1){
      throw CouldNotDeleteUser();
    }
    _folders.removeWhere(
            (f) => f.foldername.toLowerCase() == foldername.toLowerCase());
    _folderStreamController.add(_folders);
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
      //await _folderStreamController.close();
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

      // ✅ Migration — background column না থাকলে add করো
      final columns = await db.rawQuery('PRAGMA table_info(note)');
      final columnNames = columns.map((c) => c['name'] as String).toList();
      if (!columnNames.contains('background')) {
        await db.execute('ALTER TABLE note ADD COLUMN background TEXT');
      }

      // 👇 ADD THIS
      if (!columnNames.contains('last_edited')) {
        await db.execute('ALTER TABLE note ADD COLUMN last_edited INTEGER');
      }

      await _cacheNote();
      await _cacheFolders();
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
  final String? background;
  final int lastEdited; // 👈 ADD
  //is_synced_with_cloud ei option ta pore add korbo jodi lge

  DatabaseNote({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    this.background,
    required this.lastEdited,
  });

  DatabaseNote.fromRow(Map<String, Object?> map):
  id=map[idColumn] as int,
  userId=map[folderIdColumn] as int,
  title=map[titleColumn] as String,
  content=map[contentColumn] as String,
  background=map[backgroundColumn] as String?,

  lastEdited = map[lastEditedColumn] == null
            ? 0
            : map[lastEditedColumn] is int
            ? map[lastEditedColumn] as int
            : int.tryParse(map[lastEditedColumn].toString()) ?? 0;

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
	        "background" TEXT,
	        "last_edited" TEXT,
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
const backgroundColumn = 'background';
const lastEditedColumn= 'last_edited';