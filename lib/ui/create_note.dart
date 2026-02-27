import 'package:flutter/material.dart';
import 'package:notes/services/crud/notes_service.dart';
import 'package:notes/utilities/generic/get_arguments.dart';

class CreateNote extends StatefulWidget {
  const CreateNote({super.key});

  @override
  State<CreateNote> createState() => _CreateNoteState();
}

class _CreateNoteState extends State<CreateNote> {

  DatabaseNote? _note;
  late final NotesService _notesService;
  late final TextEditingController _textEditingController;



  Future<DatabaseNote> createNote(BuildContext context)async{
    final widgetNote=context.arguments<DatabaseNote>();
    if(widgetNote != null){
      _note=widgetNote;
      _textEditingController.text=widgetNote.title;

      return widgetNote;
    }

    final existingNote=_note;

    if(existingNote != null){
      print('Returning existing note: ${existingNote.id}'); // এখানে

      return existingNote;
    }
    print('Creating new note...');
    // sob note toiri hoise all folder er vitor
    String foldername = "all";

    //final mainfolder= await _notesService.getFolder(foldername: foldername);
    final mainfolder= await _notesService.getOrCreateFolder(foldername: foldername);
    print('Got folder: ${mainfolder.id} - ${mainfolder.foldername}'); // এখানে

    final newNote=await _notesService.createNote(owner: mainfolder);
    await _notesService.debugPrintAllNotes();
    print('Created note ID: ${newNote.id}');
    _note=newNote;
    return newNote;
  }

  void _deleteNoteifTextIsEmpty(){
    final note= _note;
    if(_textEditingController.text.isEmpty && note != null){
      _notesService.deleteNote(id: note.id);
    }
  }

  void saveNoteifTextNoteEmpty()async{
    final note=_note;
    final text=_textEditingController.text;

    if(note != null && text.isNotEmpty){
      await _notesService.updateNote(note: note, text: text);
    }
  }

  void _textControllerListener()async{
    final note=_note;
    final text=_textEditingController.text;
    if(note == null){
      return;
    }
    await _notesService.updateNote(note: note, text: text);
  }

  void _setupTextControllerlistener(){
    _textEditingController.removeListener(_textControllerListener);
    _textEditingController.addListener(_textControllerListener);
  }


  @override
  void initState() {
    super.initState();
    _notesService = NotesService();
    _textEditingController = TextEditingController();

    //age
    // _notesService=NotesService();
    // _textEditingController=TextEditingController();
    // super.initState();
  }


  @override
  void dispose() {
    saveNoteifTextNoteEmpty();
    _deleteNoteifTextIsEmpty();
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Note'),
        actions: [
          IconButton(onPressed: (){
             _notesService.debugPrintAllNotes();
          }, icon: Icon(Icons.folder_copy_outlined)),

        ],
      ),

      body: FutureBuilder(
          future:createNote(context) ,
          builder: (context, snapshot) {
            switch(snapshot.connectionState){
              case ConnectionState.done:
                _setupTextControllerlistener();

                return TextField(
                  controller: _textEditingController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: 'start type your note'
                  ),
                );
                default: return const CircularProgressIndicator();
            }

          },
      ),

    );
  }
}

