import 'package:flutter/material.dart';

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


class NotesService {
  Database? _db;

  Future<DatabaseNote> createNote({required Folder owner})async{
    final db=_getDatabaseorThrow();
    final dbFolder=await getFolder(foldername: owner.foldername);

    if(dbFolder != owner){
      throw CouldNotFindFolder();
    }

    const text='';
    final noteid=await db.insert(
      noteTable,{
      folderIdColumn: owner.id,
      titleColumn: text,
     // contentColumn:
    });

  }

  Future<Folder> getFolder({required String foldername})async{
    final db=_getDatabaseorThrow();
    final result=await db.query(
        folderTable,
        limit: 1,
        where: 'foldername = ?',
        whereArgs: [foldername.toLowerCase()]
    );
    if(result.isEmpty){
      throw CouldnotFindUser();
    }else{
      return Folder.fromRow(result.first);
    }
  }

  Future<Folder> createFolder({required String foldername})async{
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

  Future<void> deleteUser({required String foldername})async{
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
const titleColumn='titlecolumn';
const contentColumn='content';
const dbname='note.db';
const folderTable='folder';
const noteTable='note';