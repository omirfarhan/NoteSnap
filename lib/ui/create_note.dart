import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
// import 'package:flutter_quill/flutter_quill.dart';
// import 'package:flutter_quill/quill_delta.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:notes/services/crud/notes_service.dart';
import 'package:notes/ui/fullscreenimagepage.dart';
import 'package:notes/utilities/generic/get_arguments.dart';
//import 'package:path/path.dart';
import 'package:super_editor/super_editor.dart';

import 'note_image_component_builder.dart';

class CreateNote extends StatefulWidget {
  const CreateNote({super.key});

  @override
  State<CreateNote> createState() => _CreateNoteState();
}

class _CreateNoteState extends State<CreateNote> {
  bool _isDescriptionFocused = false;
  bool _isInitialized = false;
  bool _isLoading = true;

  DatabaseNote? _note;
  late final NotesService _notesService;
  late final TextEditingController _textEditingController;

  // SuperEditor এর জন্য
  late MutableDocument _document;
  late Editor _editor;
  late MutableDocumentComposer _composer;


  // bool _isEditing = false;
  // late final QuillController _quillController;
  late final FocusNode _descriptionFocusNode;

  OverlayEntry? _toolbarOverlay;

  Future<DatabaseNote> createNote(BuildContext context)async{

    final widgetNote=context.arguments<DatabaseNote>();

    if(widgetNote != null){
      _note=widgetNote;
      _textEditingController.text=widgetNote.title;


      if(widgetNote.content.isNotEmpty){
        try{

          _document=_documentFromJson(widgetNote.content);

          // final delta=Delta.fromJson(jsonDecode(widgetNote.content));
          // _quillController=QuillController(
          //     document: Document.fromDelta(delta),
          //     selection: const TextSelection.collapsed(offset: 0)
          // );
        }catch (e){
          //_quillController=QuillController.basic();
          _document=_emptyDocument();
        }
      }
      _rebuildEditor();
      return widgetNote;
    }

    final existingNote=_note;

    if(existingNote != null){
      print('Returning existing note: ${existingNote.id}'); // এখানে

      return existingNote;
    }
    print('Creating new note...');
    // sob note toiri hoise all folder er vitor
    const foldername = "all";

    //final mainfolder= await _notesService.getFolder(foldername: foldername);
    final mainfolder= await _notesService.getOrCreateFolder(foldername: foldername);
    print('Got folder: ${mainfolder.id} - ${mainfolder.foldername}'); // এখানে

    final newNote=await _notesService.createNote(owner: mainfolder);
    await _notesService.debugPrintAllNotes();
    print('Created note ID: ${newNote.id}');
    _note=newNote;
    return newNote;
  }

  MutableDocument _emptyDocument() {
    return MutableDocument(nodes: [
      ParagraphNode(
        id: Editor.createNodeId(),
        text: AttributedText(''),
      ),
    ]);
  }

  /// Format: [ {"type":"paragraph","text":"..."}, {"type":"image","url":"..."} ]
  MutableDocument _documentFromJson(String jsonString) {
    final list = jsonDecode(jsonString) as List<dynamic>;
    final nodes = <DocumentNode>[];

    for (final item in list) {
      final type = item['type'] as String;
      if (type == 'paragraph') {
        nodes.add(ParagraphNode(
          id: Editor.createNodeId(),
          text: AttributedText(item['text'] as String? ?? ''),
        ));
      } else if (type == 'image') {
        nodes.add(ImageNode(
          id: Editor.createNodeId(),
          imageUrl: item['url'] as String,
        ));
      }
    }

    if (nodes.isEmpty) {
      nodes.add(ParagraphNode(
        id: Editor.createNodeId(),
        text: AttributedText(''),
      ));
    }

    return MutableDocument(nodes: nodes);
  }

  String _documentToJson() {
    final list=<Map<String, dynamic>>[];
    for (int i = 0; i < _document.nodeCount; i++) {
      final node = _document.getNodeAt(i)!;
      if (node is ImageNode) {
        list.add({'type': 'image', 'url': node.imageUrl});
      } else if (node is ParagraphNode) {
        list.add({'type': 'paragraph', 'text': node.text.text});
      }
    }

    return jsonEncode(list);
  }


  void _rebuildEditor(){
    _composer=MutableDocumentComposer();
    _editor=createDefaultDocumentEditor(
      document: _document,
      composer: _composer
    );
  }

  Future<void> _saveNote()async{
    final note=_note;
    if(note == null)return;
    if (!_isInitialized) return; // initialize হওয়ার আগে save করবে না
    final title=_textEditingController.text;
    final content=_documentToJson();

    if (title.isNotEmpty || _hasAnyContent()) {
      await _notesService.updateNote(
        note: note,
        text: title,
        content: content,
      );
    }

  }

  bool _hasAnyContent() {
    for (int i = 0; i < _document.nodeCount; i++) {
      final node = _document.getNodeAt(i)!;
      if (node is ImageNode) return true;
      if (node is ParagraphNode && node.text.text.trim().isNotEmpty) {
        return true;
      }
    }
    return false;
  }


  void _deleteNoteifTextIsEmpty(){
    final note= _note;
    if (note == null) return;
    //final quillContent=_quillController.document.toPlainText().trim();
    if(_textEditingController.text.trim().isEmpty && !_hasAnyContent()){
      _notesService.deleteNote(id: note.id);
    }
  }

  // void saveNoteifTextNoteEmpty()async{
  //   final note=_note;
  //   final text=_textEditingController.text;
  //
  //   final content=jsonEncode(_quillController.document.toDelta().toJson());
  //   final quillText=_quillController.document.toPlainText().trim();
  //
  //
  //   if(note != null && (text.isNotEmpty || quillText.isNotEmpty)){
  //     // _notesService.noteContent=[];
  //     // _notesService.addText(content);
  //     await _notesService.updateNote(
  //         note: note,
  //         text: text,
  //         content: content
  //     );
  //   }
  // }

  // void _textControllerListener()async{
  //   final note=_note;
  //   final text=_textEditingController.text;
  //   if(note == null){
  //     return;
  //   }
  //   final quilcontroldata=jsonEncode(_quillController.document.toDelta().toJson());
  //   await _notesService.updateNote(
  //     note: note,
  //     text: text,
  //     content: quilcontroldata
  //   );
  // }

  // void _saveQuillContent()async{
  //   final note=_note;
  //   if (note == null) return;
  //   final content=jsonEncode(_quillController.document.toDelta().toJson());
  //   await _notesService.updateNote(
  //       note: note,
  //       text: _textEditingController.text,
  //       content: content
  //   );
  //
  // }


  //add image to note

  // void addImageToNote(String imagePath)async{
  //   final note= _note;
  //   if (note == null) return;
  //
  //   final index=_quillController.selection.baseOffset;
  //   _quillController.document.insert(index, BlockEmbed.image(imagePath));
  //   _saveQuillContent();
  //
  // }

  void _insertImages(List<XFile> images) async {
    // Cursor এর current position বের করো
    final selection = _composer.selection;

    String insertAfterNodeId;

    if (selection != null) {
      // Cursor যে node এ আছে, সেটার id নাও
      insertAfterNodeId = selection.extent.nodeId;
    } else {
      // Selection না থাকলে last node এ
      insertAfterNodeId = _document.getNodeAt(_document.nodeCount - 1)!.id;
    }

    for (final image in images) {
      // Image insert করো cursor position এর পরে
      _editor.execute([
        InsertNodeAfterNodeRequest(
          existingNodeId: insertAfterNodeId,
          newNode: ImageNode(
            id: Editor.createNodeId(),
            imageUrl: image.path,
          ),
        )
      ]);

      // Image node এর id বের করো (এইমাত্র insert হওয়া)
      // Image এর পরের node টাই এখন image
      final imageNodeId = _document.getNodeAfter(
        _document.getNodeById(insertAfterNodeId)!,
      )!.id;

      // Image এর পরে empty paragraph দাও
      _editor.execute([
        InsertNodeAfterNodeRequest(
          existingNodeId: imageNodeId,
          newNode: ParagraphNode(
            id: Editor.createNodeId(),
            text: AttributedText(''),
          ),
        )
      ]);

      // পরের image টা এই paragraph এর পরে যাবে
      insertAfterNodeId = _document.getNodeAfter(
        _document.getNodeById(imageNodeId)!,
      )!.id;
    }

    _saveNote();
  }


  // void _setupTextControllerlistener(){
  //   _textEditingController.removeListener(_textControllerListener);
  //   _textEditingController.addListener(_textControllerListener);
  //   // _quillController.removeListener(_saveQuillContent);
  //   // _quillController.addListener(_saveQuillContent);
  // }


  @override
  void initState() {
    super.initState();
    _notesService = NotesService();
    _textEditingController = TextEditingController();
    //_quillController=QuillController.basic();
    _descriptionFocusNode = FocusNode();
    _document=_emptyDocument();
    _rebuildEditor();

    _textEditingController.addListener(_saveNote);

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
    //_setupTextControllerlistener();

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      // TextField ready হওয়ার পর focus দাও
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _descriptionFocusNode.requestFocus(); // শুধু প্রথমবার
      });
    }
  }


  @override
  void dispose() {
    _saveNote();
    //saveNoteifTextNoteEmpty();
    _deleteNoteifTextIsEmpty();
    _textEditingController.removeListener(_saveNote);
    _textEditingController.dispose();
    //_quillController.dispose();
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
                        final picker=ImagePicker();
                        final images=await picker.pickMultiImage();
                        if(images.isNotEmpty){
                          _insertImages(images);
                        }
                        // final ImagePicker picker = ImagePicker();
                        // final List<XFile> images = await picker.pickMultiImage();
                        // int index = _quillController.selection.baseOffset;
                        // final plainText = _quillController.document.toPlainText().trim();
                        // if(plainText.isEmpty){
                        //   _quillController.document.insert(0, '\n');
                        //   index = 1;
                        // }
                        //
                        // for (XFile image in images) {
                        //   _quillController.document.insert(index, '\n');
                        //   _quillController.document.insert(
                        //       index,
                        //       BlockEmbed.image(image.path)
                        //   );
                        //   index+=1;
                        //
                        //   _quillController.document.insert(index, '\n');
                        //   index += 1;
                        // }
                        // // 👇 cursor নিচে নিয়ে যাওয়া
                        // _quillController.updateSelection(
                        //   TextSelection.collapsed(offset: index),
                        //   ChangeSource.local,
                        // );
                        // _saveQuillContent();
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
                          //cursorColor: Color(0xFFC8E1E4),
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

                              child: SuperEditor(
                                editor: _editor,
                                document: _document,
                                composer: _composer,
                                //controller: _quillController,
                                focusNode: _descriptionFocusNode,
                                inputSource: TextInputSource.ime,

                                imeConfiguration: const SuperEditorImeConfiguration(
                                  enableAutocorrect: false,      // ← এটাই underline বন্ধ করবে
                                  //enableSuggestions: false
                                ),

                                selectionStyle: const SelectionStyles(
                                  selectionColor: Color(0x44C8E1E4),


                                ),



                                componentBuilders: [
                                  // Image — cursor আসবে না, keyboard আসবে না
                                  NoteImageComponentBuilder(
                                    onImageTap: (imagePath, imageKey) {
                                      _descriptionFocusNode.unfocus();
                                      _toggleToolbar(context, imageKey);
                                    },
                                  ),

                                  /*
                                      await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => Fullscreenimagepage(imagepath: imagepath),
                                          ));

                                       */

                                  ...defaultComponentBuilders,
                                ],
                                stylesheet: defaultStylesheet.copyWith(
                                  addRulesAfter: [
                                    StyleRule(
                                      BlockSelector.all,
                                          (Document doc, DocumentNode node) => {
                                        Styles.textStyle: const TextStyle(
                                          color: Color(0xFFD2FEFF),
                                          fontFamily: 'Regular',
                                          fontSize: 16,
                                          decoration: TextDecoration.none
                                        ),

                                        Styles.padding: const CascadingPadding.symmetric(
                                          vertical: 0,
                                          horizontal: 0
                                        )

                                      },
                                    ),

                                  ],
                                ),


                                // config: QuillEditorConfig(
                                //
                                //   embedBuilders: [
                                //     ImageEmbedBuilder(),
                                //   ],
                                //     placeholder: 'description',
                                //     customStyles: DefaultStyles(
                                //         paragraph: DefaultTextBlockStyle(
                                //             TextStyle(
                                //               color: Color(0xFFD2FEFF),
                                //               fontFamily: 'Regular',
                                //               fontSize: 14,
                                //             ),
                                //             HorizontalSpacing.zero,
                                //             VerticalSpacing.zero,
                                //             VerticalSpacing.zero,
                                //             null
                                //         )
                                //     )
                                // ),
                              ),
                            ),


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

  void _toggleToolbar(BuildContext context, GlobalKey key) {
    if (_toolbarOverlay != null) {
      _toolbarOverlay!.remove();
      _toolbarOverlay = null;
      return;
    }

    final renderBox = key.currentContext!.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final imageSize = renderBox.size;

    // Screen এবং AppBar এর height বের করো
    final screenHeight = MediaQuery.of(context).size.height;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final appBarHeight = kToolbarHeight + statusBarHeight;

    const toolbarHeight = 50.0;
    const toolbarWidth = 220.0;

    // প্রথমে image এর উপরে দেখাও
    double topPosition = position.dy - toolbarHeight - 8;

    // যদি AppBar এর নিচে না হয়, তাহলে image এর নিচে দেখাও
    if (topPosition < appBarHeight) {
      topPosition = position.dy + imageSize.height + 8;
    }

    // Screen এর নিচে চলে গেলে clamp করো
    if (topPosition + toolbarHeight > screenHeight) {
      topPosition = screenHeight - toolbarHeight - 8;
    }

    // Horizontal position clamp
    final screenWidth = MediaQuery.of(context).size.width;
    double leftPosition = position.dx;
    if (leftPosition + toolbarWidth > screenWidth) {
      leftPosition = screenWidth - toolbarWidth - 8;
    }

    _toolbarOverlay = OverlayEntry(
      builder: (context) => Positioned(
        top: topPosition,
        left: leftPosition,
        child: Material(
          color: Colors.transparent,
          child: Container(
            height: toolbarHeight,
            width: toolbarWidth,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                Icon(Icons.comment),
                Icon(Icons.edit),
                Icon(Icons.image),
                Icon(Icons.delete),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_toolbarOverlay!);
  }

}
