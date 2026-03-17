import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:googleapis/gmail/v1.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:notes/services/crud/notes_service.dart';
import 'package:notes/ui/notebottomcomponent/bottomsheet/bottom_sheet_screen.dart';
import 'package:notes/ui/notebottomcomponent/checkbox/checkbox_component_builder.dart';
import 'package:notes/ui/notebottomcomponent/checkbox/checkbox_node.dart';
import 'package:notes/ui/notebottomcomponent/fullscreenimagepage.dart';
import 'package:notes/utilities/generic/get_arguments.dart';
import 'package:super_editor/super_editor.dart';
//import 'package:palette_generator_master/palette_generator_master.dart';
import 'notebottomcomponent/checkbox/CheckboxTapDelegate.dart';
import 'notebottomcomponent/note_image_component_builder.dart';

class CreateNote extends StatefulWidget {
  const CreateNote({super.key});

  @override
  State<CreateNote> createState() => _CreateNoteState();
}



class _CreateNoteState extends State<CreateNote> {
  bool _isDescriptionFocused = false;
  bool _isInitialized = false;
  bool _isLoading = true;

  bool _isSaved = false;
  bool _ignoreNextChange = false;
  bool _isUndoRedu=false;

  final List<String> _history=[];
  int _historyIndex=-1;
  int characterCount=0;

  String? _imagepath;
  String _currentTime="";
  String? _backgroundImage;


  DatabaseNote? _note;
  late final NotesService _notesService;
  late final TextEditingController _textEditingController;

  // SuperEditor এর জন্য
  late MutableDocument _document;
  late Editor _editor;
  late MutableDocumentComposer _composer;

  late final FocusNode _descriptionFocusNode;
  late final FocusNode _titleFocusNode;
  // late final UndoHistoryController _undoHistoryController;

  Color _bottomBarColor = const Color(0xFF137FA5); // default color

  OverlayEntry? _toolbarOverlay;

  Future<DatabaseNote> createNote(BuildContext context)async{
    final widgetNote=context.arguments<DatabaseNote>();
    if(widgetNote != null){
      _note=widgetNote;
      _textEditingController.text=widgetNote.title;
      _backgroundImage=widgetNote.background;


      _bottomBarColor = BottomSheetScreen.backgrounds[_backgroundImage]
          ?? const Color(0xFF076687);

      if(widgetNote.content.isNotEmpty){
        try{
          _document=_documentFromJson(widgetNote.content);
        }catch (e){
          _document=_emptyDocument();
        }
      }
      _rebuildEditor();
      return widgetNote;
    }
    final existingNote=_note;
    if(existingNote != null){
      return existingNote;
    }
    const foldername = "all";
    final mainfolder= await _notesService.getOrCreateFolder(foldername: foldername);
    final newNote=await _notesService.createNote(owner: mainfolder);
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
      }else if (type == 'checkbox') {
        nodes.add(CheckboxNode(
          id: Editor.createNodeId(),
          text: AttributedText(item['text'] as String? ?? ''),
          isChecked: item['checked'] as bool? ?? false,
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
      }
      else if (node is ParagraphNode) {
        list.add({'type': 'paragraph', 'text': node.text.text});
      }else if (node is CheckboxNode) {
        list.add({
          'type': 'checkbox',
          'text': node.text.text,
          'checked': node.isChecked,
        });
      }
    }

    return jsonEncode(list);
  }


  void _rebuildEditor() {
    _composer = MutableDocumentComposer();

    _editor = createDefaultDocumentEditor(
      document: _document,
      composer: _composer,
    );

    // Cursor guard for checkbox
    _composer.selectionNotifier.addListener(_enforceCheckboxCursor);

    _document.addListener((DocumentChangeLog changeLog) {
      if (_isSaved && mounted) {
        setState(() => _isSaved = false);
      }

      if (_isUndoRedu) return;

      final currentJson = _documentToJson();

      if (_historyIndex < _history.length - 1) {
        _history.removeRange(_historyIndex + 1, _history.length);
      }

      _history.add(currentJson);
      _historyIndex = _history.length - 1;

      if (mounted) setState(() {});
    });
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
        background: _backgroundImage
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
    if(_textEditingController.text.trim().isEmpty && !_hasAnyContent()){
      _notesService.deleteNote(id: note.id);
    }
  }

  void _insertImages(List<XFile> images) async {
    final selection = _composer.selection;
    String insertAfterNodeId;

    if (selection != null) {
      final node = _document.getNodeById(selection.extent.nodeId);

      if (node is ParagraphNode) {
        final position = selection.extent.nodePosition;

        if (position is TextNodePosition) {
          final offset = position.offset;

          if (offset != 0 && offset != node.text.text.length) {
            final newParagraphId = Editor.createNodeId();

            _editor.execute([
              SplitParagraphRequest(
                nodeId: node.id,
                splitPosition: TextPosition(offset: offset),
                newNodeId: newParagraphId,
                replicateExistingMetadata: true,
              )
            ]);
          }
        }
      }

      insertAfterNodeId = selection.extent.nodeId;
    } else {
      insertAfterNodeId = _document.getNodeAt(_document.nodeCount - 1)!.id;
    }

    for (final image in images) {
      final imageId = Editor.createNodeId();

      _editor.execute([
        InsertNodeAfterNodeRequest(
          existingNodeId: insertAfterNodeId,
          newNode: ImageNode(
            id: imageId,
            imageUrl: image.path,
          ),
        )
      ]);

      final paragraphId = Editor.createNodeId();

      _editor.execute([
        InsertNodeAfterNodeRequest(
          existingNodeId: imageId,
          newNode: ParagraphNode(
            id: paragraphId,
            text: AttributedText(''),
          ),
        )
      ]);

      insertAfterNodeId = paragraphId;
    }

    _saveNote();
  }


  @override
  void initState() {
    super.initState();

    _notesService = NotesService();
    _textEditingController = TextEditingController();
    _timeinfo();
    _descriptionFocusNode = FocusNode();
    _titleFocusNode=FocusNode();
    _document=_emptyDocument();
    _rebuildEditor();

    _titleFocusNode.addListener(() {
      if (mounted) setState(() {});
    });

    _textEditingController.addListener(() {
      if (_ignoreNextChange) {
        _ignoreNextChange = false;
        return;
      }
      if (_isSaved) {
        setState(() {
          _isSaved = false;
        });

      }
      _saveNote();
    });

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


    if (mounted) {
      final initialJson = _documentToJson();
      _history.add(initialJson);
      _historyIndex = 0;

      setState(() {
        _isLoading = false;
      });

    }
  }


  @override
  void dispose() {
    _composer.selectionNotifier.removeListener(_enforceCheckboxCursor);
    _saveNote();
    _deleteNoteifTextIsEmpty();
    _textEditingController.dispose();
    _descriptionFocusNode.dispose();
    _titleFocusNode.dispose();
    _hideToolbar();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      extendBodyBehindAppBar: true, // ✅ এটা যোগ করুন
      backgroundColor: _bottomBarColor,
        resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
               spacing: 5,
              children: [
                Text(_currentTime,
                  style: TextStyle(fontSize: 10,
                      color: Color(0xFF9EDDE4),
                      fontFamily: 'Regular'
                  ),
                ),


                Text(
                 "${_getCharacterCount()} character",
                  style: TextStyle(fontSize: 10,
                      color: Color(0xFF9EDDE4),
                      fontFamily: 'Regular'
                  ),
                )


              ],
            )

        ),


        actions: [

          if(!_isSaved) ...[
         if (_descriptionFocusNode.hasFocus)
            IconButton(
              onPressed: _historyIndex > 0 ? _undo : null,
              icon: Icon(Icons.undo),
              iconSize: 30,
              padding: EdgeInsets.zero,
            ),
            if (_descriptionFocusNode.hasFocus)
            IconButton(
              onPressed: _historyIndex < _history.length - 1 ? _redo : null,
              icon: Icon(Icons.redo),
              iconSize: 30,
            ),
            SizedBox(width: 20), // gap control এখানে
            IconButton(onPressed: ()async{
              _ignoreNextChange = true; // এই লাইনটা যোগ করুন
              await _saveNote();
              if(mounted){
                setState(() {
                  _isSaved=true;
                });
                _descriptionFocusNode.unfocus();
                _titleFocusNode.unfocus();

              }
            }, icon: Icon(Icons.check_circle_outline_rounded))
          ] else
            Padding(
                padding:const EdgeInsetsGeometry.symmetric(horizontal: 12),
              child: Row(
                children: [

                 SizedBox(width: 4),
                 Text(
                  "save"
                 )
                ],
              ),
            )


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
                    color: _backgroundImage!=null
                    ? _bottomBarColor
                    :const Color(0xff67bfdc),

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
                        },
                          icon: Icon(Icons.image_rounded,color: Colors.white,)
                      ),

                      IconButton(onPressed:(){
                        _insertCheckbox();
                        //
                        // final selection = _composer.selection;
                        // String insertAfterNodeId = selection != null
                        //     ? selection.extent.nodeId
                        //     : _document.getNodeAt(_document.nodeCount - 1)!.id;
                        //
                        // _editor.execute([
                        //   InsertNodeAfterNodeRequest(
                        //     existingNodeId: insertAfterNodeId,
                        //     newNode: CheckboxNode(
                        //       id: Editor.createNodeId(),
                        //       text: AttributedText(''),
                        //     ),
                        //   )
                        // ]);
                      },
                          icon: Icon(Icons.crop_square,color: Colors.white,)
                      ),

                      IconButton(
                          onPressed: (){
                            _openbottomSheet();
                          }, icon: Icon(FontAwesomeIcons.tshirt),
                          color: Colors.white
                      )

                    ],
                  ),
                ),
              ),
            ),
          ),
        ): null,

      body:_isLoading
          ? const Center(child: CircularProgressIndicator())
              : Container(
        decoration: _backgroundImage != null
            ? BoxDecoration(
          image: DecorationImage(
            image: AssetImage(_backgroundImage!),
            fit: BoxFit.cover,
          ),
        )
            : null,
        child: Listener(
          onPointerDown: (event) {
            _hideToolbar();
          },
          child: Stack(

            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    SizedBox(height: MediaQuery.of(context).padding.top + kToolbarHeight),
                    TextField(

                      autocorrect: false,
                      controller: _textEditingController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      focusNode: _titleFocusNode,
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

                        focusNode: _descriptionFocusNode,
                        inputSource: TextInputSource.ime,

                        imeConfiguration: const SuperEditorImeConfiguration(
                          enableAutocorrect: false,      // ← এটাই underline বন্ধ করবে

                        ),

                        selectionStyle: const SelectionStyles(
                          selectionColor: Color(0x44C8E1E4),

                        ),
                        contentTapDelegateFactories: [
                              (_) => CheckboxTapDelegate(
                              document: _document,
                              editor: _editor,
                              onSave: _saveNote

                          )
                        ],

                        componentBuilders: [

                          NoteImageComponentBuilder(
                            onImageTap: (imagePath, imageKey) {
                              _descriptionFocusNode.unfocus();
                              setState(() {
                                _imagepath=imagePath;
                              });
                              _toggleToolbar(context, imageKey);
                            },
                          ),
                          // CheckboxComponentBuilder(
                          //   onCheckChanged: (nodeId, isChecked) {
                          //     final node = _document.getNodeById(nodeId);
                          //     if (node is CheckboxNode) {
                          //       node.isChecked = isChecked;
                          //       setState(() {});
                          //       _saveNote();
                          //     }
                          //   },
                          // ),
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

                      ),

                    ),

                  ],
                ),
              ),

            ],
          ),
        )

      ),
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

    const toolbarHeight = 38.0;
    const toolbarWidth = 150.0;

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
              color: Color(0xFF58B4D3),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [

                IconButton(onPressed: (){
                  _hideToolbar();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Fullscreenimagepage(imagepath: _imagepath!),
                      ));
                }, icon: Icon(Icons.image)),

                 IconButton(onPressed: (){
                   _hideToolbar();
                   _deleteImage(_imagepath!);
                   setState(() {
                     _imagepath;
                   });
                 }, icon: Icon(Icons.delete))
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_toolbarOverlay!);
  }
  void _hideToolbar() {
    if (_toolbarOverlay != null) {
      _toolbarOverlay!.remove();
      _toolbarOverlay = null;
    }
  }
  void _timeinfo()async{
    DateTime now=DateTime.now();
    setState(() {
      _currentTime=DateFormat('MMMM dd, hh:mm a').format(now);
    });
  }
  void _deleteImage(String imagePath){
    for(int i =0; i<_document.nodeCount; i++){
      final node=_document.getNodeAt(i);

      if(node is ImageNode && node.imageUrl == imagePath){
        _editor.execute([
          DeleteNodeRequest(nodeId: node.id)

        ]);
        break;
      }
    }
    _saveNote();
  }

  void _undo() {
    if (_historyIndex <= 0) return;
    _historyIndex--;
    _isUndoRedu = true;
    _document = _documentFromJson(_history[_historyIndex]);
    _rebuildEditor();
    setState(() {});
    _isUndoRedu = false;
    // TextField ready হওয়ার পর focus দাও
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _descriptionFocusNode.requestFocus(); // শুধু প্রথমবার
    });
    _saveNote();
  }

  void _redo() {
    if (_historyIndex >= _history.length - 1) return;
    _historyIndex++;
    _isUndoRedu = true;
    _document = _documentFromJson(_history[_historyIndex]);
    _rebuildEditor();
    setState(() {});
    _isUndoRedu = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _descriptionFocusNode.requestFocus();
    });
    _saveNote();
  }

  // bool _isDocumentEmpty() {
  //   if (_document.nodeCount == 0) return true;
  //
  //   for (int i = 0; i < _document.nodeCount; i++) {
  //     final node = _document.getNodeAt(i);
  //
  //     if (node is ParagraphNode && node.text.text.trim().isNotEmpty) {
  //       return false;
  //     }
  //     if (node is ImageNode) {
  //       return false;
  //     }
  //   }
  //
  //   return true;
  // }

  void _insertCheckbox() {
    final selection = _composer.selection;

    if (selection == null) return;

    final position = selection.extent;

    final node = _document.getNodeById(position.nodeId);

    if (node is! ParagraphNode) return;

    final nodePosition = position.nodePosition;

    if (nodePosition is! TextNodePosition) return;

    _editor.execute([
      InsertTextRequest(
        documentPosition: DocumentPosition(
          nodeId: node.id,
          nodePosition: TextNodePosition(offset: nodePosition.offset),
        ),
        textToInsert: '☐ ',
        attributions: {},
      ),
    ]);

    _saveNote();
  }

  int _getCharacterCount() {
    int count = _textEditingController.text.length;
    for (int i = 0; i < _document.nodeCount; i++) {
      final node = _document.getNodeAt(i)!;
      if (node is ParagraphNode) {
        count += node.text.text.length;
      }
    }
    return count;
  }

  void _enforceCheckboxCursor() {
    final selection = _composer.selection;
    if (selection == null) return;

    final position = selection.extent;
    final node = _document.getNodeById(position.nodeId);

    if (node is! ParagraphNode) return;

    final text = node.text.text;

    if (!text.startsWith('☐ ')) return;

    final nodePosition = position.nodePosition;

    if (nodePosition is! TextNodePosition) return;

    if (nodePosition.offset < 2) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        _editor.execute([
          ChangeSelectionRequest(
            DocumentSelection.collapsed(
              position: DocumentPosition(
                nodeId: node.id,
                nodePosition: const TextNodePosition(offset: 2),
              ),
            ),
            SelectionChangeType.placeCaret,
            SelectionReason.userInteraction,
          )
        ]);
      });
    }
  }

  void _openbottomSheet() {
    final hadFocus = _descriptionFocusNode.hasFocus;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white54,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (context) {
        return BottomSheetScreen(
          onThemeSelected: _applyTheme,
          currentBackground: _backgroundImage,
        );
      },
    ).then((_) {
      if (hadFocus && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _descriptionFocusNode.requestFocus();
        });
      }
    });
  }

  void _applyTheme(String? imagePath)async{
    setState(() {
      _backgroundImage=imagePath;
      _bottomBarColor = BottomSheetScreen.backgrounds[imagePath]
          ?? const Color(0xFF076687);
    });

    _saveNote();
  }

}
