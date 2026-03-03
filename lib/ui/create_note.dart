import 'dart:convert';
import 'dart:io';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:notes/services/crud/notes_service.dart';
import 'package:notes/utilities/generic/get_arguments.dart';

import 'imageembedbuilder.dart';

class CreateNote extends StatefulWidget {
  const CreateNote({super.key});

  @override
  State<CreateNote> createState() => _CreateNoteState();
}

class _CreateNoteState extends State<CreateNote> {

  late final QuillController _quillController;

  bool _isDescriptionFocused = false;
  bool _isInitialized = false; // দুইবার call হওয়া ঠেকাতে
  bool _isLoading = true;
  DatabaseNote? _note;
  late final NotesService _notesService;
  late final TextEditingController _textEditingController;
  //late final TextEditingController _textEdtdescriptioncontroller;
  late final FocusNode _descriptionFocusNode;

  Future<DatabaseNote> createNote(BuildContext context)async{
    final widgetNote=context.arguments<DatabaseNote>();
    if(widgetNote != null){
      _note=widgetNote;
      _textEditingController.text=widgetNote.title;
      // content restore করুন
      if(widgetNote.content.isNotEmpty){
        try{
          final delta=Delta.fromJson(jsonDecode(widgetNote.content));
          _quillController=QuillController(
              document: Document.fromDelta(delta),
              selection: const TextSelection.collapsed(offset: 0)
          );
        }catch (e){
          _quillController=QuillController.basic();
        }
      }



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
    final quillContent=_quillController.document.toPlainText().trim();
    if(_textEditingController.text.isEmpty &&quillContent.isEmpty && note != null){
      _notesService.deleteNote(id: note.id);
    }
  }

  void saveNoteifTextNoteEmpty()async{
    final note=_note;
    final text=_textEditingController.text;

    final content=jsonEncode(_quillController.document.toDelta().toJson());
    final quillText=_quillController.document.toPlainText().trim();


    if(note != null && (text.isNotEmpty || quillText.isNotEmpty)){
      // _notesService.noteContent=[];
      // _notesService.addText(content);
      await _notesService.updateNote(
          note: note,
          text: text,
          content: content
      );
    }
  }

  void _textControllerListener()async{
    final note=_note;
    final text=_textEditingController.text;
    if(note == null){
      return;
    }
    final quilcontroldata=jsonEncode(_quillController.document.toDelta().toJson());
    await _notesService.updateNote(
      note: note,
      text: text,
      content: quilcontroldata
    );
  }

  void _saveQuillContent()async{
    final note=_note;
    if (note == null) return;
    final content=jsonEncode(_quillController.document.toDelta().toJson());
    await _notesService.updateNote(
        note: note,
        text: _textEditingController.text,
        content: content
    );

  }


  //add image to note

  void addImageToNote(String imagePath)async{
    final note= _note;
    if (note == null) return;

    final index=_quillController.selection.baseOffset;
    _quillController.document.insert(index, BlockEmbed.image(imagePath));
    _saveQuillContent();

  }


  void _setupTextControllerlistener(){
    _textEditingController.removeListener(_textControllerListener);
    _textEditingController.addListener(_textControllerListener);
    _quillController.removeListener(_saveQuillContent);
    _quillController.addListener(_saveQuillContent);
  }


  @override
  void initState() {
    super.initState();
    _notesService = NotesService();
    _textEditingController = TextEditingController();

    _quillController=QuillController.basic();

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
    _quillController.dispose();
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
        Padding(
          padding: const EdgeInsets.fromLTRB(10,0,10,5),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Color(0xFF4692AC),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [

                      IconButton(onPressed: ()async{
                        final ImagePicker picker = ImagePicker();
                        final List<XFile> images = await picker.pickMultiImage();
                        int index = _quillController.selection.baseOffset;
                        final plainText = _quillController.document.toPlainText().trim();
                        if(plainText.isEmpty){
                          _quillController.document.insert(0, '\n');
                          index = 1;
                        }

                        for (XFile image in images) {
                          _quillController.document.insert(index, '\n');
                          _quillController.document.insert(
                              index,
                              BlockEmbed.image(image.path)
                          );
                          index+=1;

                          // 👇 cursor image এর পরে নিয়ে যাওয়া
                          // 👇 image এর পরে newline add
                          _quillController.document.insert(index, '\n');
                          index += 1;
                        }
                        // 👇 cursor নিচে নিয়ে যাওয়া
                        _quillController.updateSelection(
                          TextSelection.collapsed(offset: index),
                          ChangeSource.local,
                        );
                        _saveQuillContent();
                        },
                          icon: Icon(Icons.image_rounded,color: Colors.white,)
                      ),
                      Icon(Icons.crop_square, color: Colors.white),
                      Icon(FontAwesomeIcons.tshirt, color: Colors.white),
                    ],
                  ),
                ),
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
                            child: TextSelectionTheme(
                        data: TextSelectionThemeData(
                          cursorColor: Color(0xFFC8E1E4)
                        ),
                        child: QuillEditor.basic(

                          controller: _quillController,
                          focusNode: _descriptionFocusNode,
                          config: QuillEditorConfig(
                            embedBuilders: [
                              ImageEmbedBuilder(),
                            ],
                              placeholder: 'description',
                              customStyles: DefaultStyles(
                                  paragraph: DefaultTextBlockStyle(
                                      TextStyle(
                                        color: Color(0xFFD2FEFF),
                                        fontFamily: 'Regular',
                                        fontSize: 14,
                                      ),
                                      HorizontalSpacing.zero,
                                      VerticalSpacing.zero,
                                      VerticalSpacing.zero,
                                      null
                                  )
                              )
                          ),
                        )
    )
                        )

                        /*
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

                         */
                      ],
                    ),
                  ),

                ],
              )

    );
  }
}
