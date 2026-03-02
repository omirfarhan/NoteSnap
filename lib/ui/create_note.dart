import 'dart:convert';

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
  bool _isDescriptionFocused = false;
  bool _isInitialized = false; // দুইবার call হওয়া ঠেকাতে
  bool _isLoading = true;
  DatabaseNote? _note;
  late final NotesService _notesService;
  late final TextEditingController _textEditingController;
  late final TextEditingController _textEdtdescriptioncontroller;

  late final FocusNode _descriptionFocusNode;

  Future<DatabaseNote> createNote(BuildContext context)async{
    final widgetNote=context.arguments<DatabaseNote>();
    if(widgetNote != null){
      _note=widgetNote;
      _textEditingController.text=widgetNote.title;
      _textEdtdescriptioncontroller.text=widgetNote.content;
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
    if(_textEditingController.text.isEmpty &&_textEdtdescriptioncontroller.text.isEmpty && note != null){
      _notesService.deleteNote(id: note.id);
    }
  }

  void saveNoteifTextNoteEmpty()async{
    final note=_note;
    final text=_textEditingController.text;
    final content=_textEdtdescriptioncontroller.text;


    if(note != null && (text.isNotEmpty || content.isNotEmpty)){
      _notesService.noteContent=[];
      _notesService.addText(content);
      await _notesService.updateNote(note: note, text: text, content: content);
    }
  }

  void _textControllerListener()async{
    final note=_note;
    final text=_textEditingController.text;
    if(note == null){
      return;
    }
    await _notesService.updateNote(
      note: note,
      text: text,
      content: jsonEncode(_notesService.noteContent)
    );
  }

  void _descriptionControllerListener()async{
    final note=_note;
    final text=_textEdtdescriptioncontroller.text;

    if(note == null) return;
    _notesService.noteContent=[];
    _notesService.addText(text);
    await _notesService.updateNote(
        note: note,
        text: _textEditingController.text,
        content: jsonEncode(_notesService.noteContent)
    );
  }


  void _setupTextControllerlistener(){
    _textEditingController.removeListener(_textControllerListener);
    _textEditingController.addListener(_textControllerListener);
    _textEdtdescriptioncontroller.removeListener(_descriptionControllerListener);
    _textEdtdescriptioncontroller.addListener(_descriptionControllerListener);

  }


  @override
  void initState() {
    super.initState();
    _notesService = NotesService();
    _textEditingController = TextEditingController();
    _textEdtdescriptioncontroller=TextEditingController();

    _descriptionFocusNode = FocusNode();
    _descriptionFocusNode.addListener(() {
      if (mounted) {
        setState(() {
          _isDescriptionFocused = _descriptionFocusNode.hasFocus;
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true; // একবারই চলবে
      _initNote();
    }
  }

  Future<void> _initNote() async {
    await createNote(context);
    _setupTextControllerlistener();

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      // TextField ready হওয়ার পর focus দাও
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _descriptionFocusNode.requestFocus();
      });
    }
  }


  @override
  void dispose() {
    saveNoteifTextNoteEmpty();
    _deleteNoteifTextIsEmpty();
    _textEditingController.dispose();
    _textEdtdescriptioncontroller.dispose();
    _descriptionFocusNode.dispose(); // এটা add করো
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Color(0xFF137FA5),
        resizeToAvoidBottomInset: true,
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
          icon: Icon(Icons.chevron_left),
            padding: EdgeInsets.zero,
              iconSize: 30
          ),
          IconButton(onPressed: (){
            _notesService.debugPrintAllNotes();
          }, icon: Icon(Icons.chevron_right),iconSize: 30,),
          SizedBox(width: 20), // gap control এখানে

          IconButton(onPressed: (){
             _notesService.debugPrintAllNotes();
          }, icon: Icon(Icons.check_circle_outline_rounded)),

        ],
      ),
        bottomNavigationBar: _isDescriptionFocused
            ?
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          color: Color(0xFF4692AC),
          child: SafeArea(
            top: false,
            child: Container(
              height: 50,

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [

                  IconButton(onPressed: (){print('icon');}, icon: Icon(Icons.image)),
                  Icon(Icons.mic_none, color: Colors.white),
                  Icon(Icons.keyboard_alt_outlined, color: Colors.white),
                ],
              ),
            ),
          ),
        ): null,

      body:_isLoading
          ? const Center(child: CircularProgressIndicator())
              : Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      children: [
                        TextField(
                          cursorColor: Color(0xFFC8E1E4),
                          autocorrect: false,
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
                        Expanded(
                          child: TextField(
                            focusNode: _descriptionFocusNode,
                            cursorColor: Color(0xFFC8E1E4),
                            autocorrect: false,
                            // enableSuggestions: false,
                            controller: _textEdtdescriptioncontroller,
                            keyboardType: TextInputType.multiline,
                            expands: true,
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
                        ),
                      ],
                    ),
                  ),
                  // Padding(
                  //   padding: EdgeInsets.only(
                  //     bottom: MediaQuery.of(context).viewInsets.bottom,
                  //   ),
                  //   child: Container(
                  //     color: Colors.black,
                  //     child: Row(
                  //       children: [
                  //         IconButton(
                  //           icon: Icon(Icons.image, color: Colors.white),
                  //           onPressed: () {},
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // )
                  // AnimatedPositioned(
                  //   duration: const Duration(milliseconds: 200),
                  //   left: 0,
                  //   right: 0,
                  //   bottom: keyboardOpen
                  //       ? MediaQuery.of(context).viewInsets.bottom
                  //       : -60,
                  //   height: 60,
                  //   child: Container(
                  //     color: Colors.black,
                  //     child: Row(
                  //       children: [
                  //         IconButton(
                  //           icon: const Icon(Icons.image, color: Colors.white),
                  //           onPressed: () {},
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),




                ],
              )

    );
  }
}

//default: return const CircularProgressIndicator();