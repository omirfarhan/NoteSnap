import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
  late final TextEditingController _textEdtdescriptioncontroller;


  Future<DatabaseNote> createNote(BuildContext context)async{
    final widgetNote=context.arguments<DatabaseNote>();
    if(widgetNote != null){
      _note=widgetNote;
      _textEditingController.text=widgetNote.title;
      //ekhane _textEdtdescriptioncontroller er kaj ase
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
    _textEdtdescriptioncontroller.removeListener(_textControllerListener);
    _textEditingController.addListener(_textControllerListener);
    _textEditingController.addListener(_textControllerListener);
  }


  @override
  void initState() {
    super.initState();
    _notesService = NotesService();
    _textEditingController = TextEditingController();
    _textEdtdescriptioncontroller=TextEditingController();
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
    _textEdtdescriptioncontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF137FA5),
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
            child: const Text('January 19, 10:23 PM',
            style: TextStyle(fontSize: 10,
                color: Color(0xFF9EDDE4),
              fontFamily: 'Regular'

            ),),
        ),

        actions: [

          IconButton(onPressed: (){
            _notesService.debugPrintAllNotes();
          },
          icon: Icon(FontAwesomeIcons.chevronLeft),
            padding: EdgeInsets.zero,
          ),
          IconButton(onPressed: (){
            _notesService.debugPrintAllNotes();
          }, icon: Icon(FontAwesomeIcons.chevronRight)),
          SizedBox(width: 20), // gap control এখানে

          IconButton(onPressed: (){
             _notesService.debugPrintAllNotes();
          }, icon: Icon(FontAwesomeIcons.checkCircle)),

        ],
      ),

      body: FutureBuilder(
          future:createNote(context) ,
          builder: (context, snapshot) {
            switch(snapshot.connectionState){
              case ConnectionState.done:
                _setupTextControllerlistener();

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    children: [
                         TextField(
                          cursorColor: Color(0xFFC8E1E4),
                          autocorrect: false,
                         // enableSuggestions: false,
                          controller: _textEditingController,
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          decoration: InputDecoration(
                            hintText: 'Title',
                            hintStyle: TextStyle(
                              color: Color(0xFFD2FEFF),
                              fontFamily: 'Regular'
                            ),
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none
                          ),
                          style: TextStyle(
                              color: Color(0xFFD2FEFF),
                              fontFamily: 'Regular',
                          ),
                        ),
                      TextField(
                        cursorColor: Color(0xFFC8E1E4),
                        autocorrect: false,
                        // enableSuggestions: false,
                        controller: _textEdtdescriptioncontroller,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        decoration: InputDecoration(
                            hintText: 'description',
                            hintStyle: TextStyle(
                                color: Color(0xFFD2FEFF),
                                fontFamily: 'Regular'
                            ),
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none
                        ),
                        style: TextStyle(
                          color: Color(0xFFD2FEFF),
                          fontFamily: 'Regular',
                        ),
                      ),
                    ],
                  ),
                );
                default: return const CircularProgressIndicator();
            }

          },
      ),

    );
  }
}

