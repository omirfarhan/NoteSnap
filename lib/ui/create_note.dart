import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:notes/services/crud/notes_service.dart';
import 'package:notes/ui/methodChannelStorageService/storage_service.dart';
import 'package:notes/ui/notebottomcomponent/bottomsheet/bottom_sheet_screen.dart';
import 'package:notes/ui/notebottomcomponent/bottomsheet/saveimageoption.dart';
import 'package:notes/ui/notebottomcomponent/checkbox/checkbox_node.dart';
import 'package:notes/ui/notebottomcomponent/fullscreenimagepage.dart';
import 'package:super_editor/super_editor.dart';
import 'notebottomcomponent/bottomsheet/image_preview_page.dart';
import 'notebottomcomponent/checkbox/checkbox_tap_delegate.dart';
import 'notebottomcomponent/note_image_component_builder.dart';

import 'package:syncfusion_flutter_pdf/pdf.dart';

class CreateNote extends StatefulWidget {
  final DatabaseNote? note;
  final String? folderName;

  const CreateNote({
    super.key,
    this.note,
    this.folderName,
  });

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
  String get currentTime=> _currentTime;



  DatabaseNote? _note;
  late final NotesService _notesService;
  late final TextEditingController _textEditingController;

  late MutableDocument _document;
  late Editor _editor;
  late MutableDocumentComposer _composer;

  late final FocusNode _descriptionFocusNode;
  late final FocusNode _titleFocusNode;


  Color? _bottomBarColor; //= const Color(0xFF137FA5); // default color
  //Color get bottomBarColor => _bottomBarColor;
  OverlayEntry? _toolbarOverlay;
  final GlobalKey _globalKey=GlobalKey();

  Color _resolvedColor(BuildContext context) {
    if (_bottomBarColor != null) return _bottomBarColor!;
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF131313)
        : const Color(0xFFF9F9F9);
  }

  Color get _textColor{
    if (_bottomBarColor != null) return Color(0xFFE1E1E1);
    return Theme.of(context).colorScheme.onSurface;
  }

  Color get _dividercolor => Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFFE1E1E1)
      : const Color(0xFF343434);

  Future<DatabaseNote> createNote(BuildContext context) async {
    // note edit করতে
    if (widget.note != null) {
      _note = widget.note;
      _textEditingController.text = widget.note!.title;

      _bottomBarColor = (widget.note!.background != null && widget.note!.background!.isNotEmpty)
          ? Color(int.parse(widget.note!.background!))
          : null;
      if (widget.note!.content.isNotEmpty) {
        try {
          _document = _documentFromJson(widget.note!.content);
        } catch (e) {
          _document = _emptyDocument();
        }
      }
      _rebuildEditor();
      return widget.note!;
    }

    final existingNote = _note;
    if (existingNote != null) return existingNote;


    final foldername = widget.folderName ?? 'all folder';
    final mainfolder = await _notesService.getOrCreateFolder(foldername: foldername);
    final newNote = await _notesService.createNote(owner: mainfolder);
    _note = newNote;
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
    if (!_isInitialized) return;
    final title=_textEditingController.text;
    final content=_documentToJson();

    if (title.isNotEmpty || _hasAnyContent()) {

      await _notesService.updateNote(
        note: note,
        text: title,
        content: content,
        // background: _bottomBarColor.value.toString()
        background: _bottomBarColor?.value.toString() ?? ''
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

    final note = _note;
    if (note == null) return;
    if (_textEditingController.text.trim().isEmpty && !_hasAnyContent()) {
      _notesService.permanentlyDeleteNote(id: note.id); // ✅ soft delete না
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
      setState(() {});
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
      //backgroundColor: _bottomBarColor,
      backgroundColor: _resolvedColor(context),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
           spacing: 5,
          children: [
            Text(_currentTime,
              style: TextStyle(fontSize: 13,
                  color: _textColor, //Color(0xFF9EDDE4)
                  fontFamily: 'Regular'
              ),
            ),


            Text(
             "${_getCharacterCount()} character",
              style: TextStyle(fontSize: 12,
                  color: _textColor,
                  fontFamily: 'Regular'
              ),
            )


          ],
        ),


        actions: [

          if(!_isSaved) ...[
         if (_descriptionFocusNode.hasFocus)
            IconButton(
              onPressed: _historyIndex > 0 ? _undo : null,
              icon: Icon(Icons.undo,),
              iconSize: 30,
              padding: EdgeInsets.zero,
            ),
            if (_descriptionFocusNode.hasFocus)
            IconButton(
              onPressed: _historyIndex < _history.length - 1 ? _redo : null,
              icon: Icon(Icons.redo,),
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
            }, icon: Icon(Icons.check_circle_outline_rounded,color: _textColor,))
          ] else
            Padding(
                padding:const EdgeInsetsGeometry.symmetric(horizontal: 12),
              child: Row(
                children: [
                 SizedBox(width: 1),
                 InkWell(onTap: () {
                   _exportbottomsheet();
                 },
                   customBorder: const CircleBorder(),
                   child: Container(
                     height: 28,
                     width: 28,
                     alignment: Alignment.center,
                     decoration: BoxDecoration(
                       //color: Colors.white,
                       shape: BoxShape.circle,
                       border: BoxBorder.all(
                         color: _textColor,
                         width: 2
                       )
                     ),
                     child: Text(
                       "save",
                       style: TextStyle(
                         color: _textColor,
                         fontSize: 8.5,
                         fontWeight: FontWeight.bold
                       ),
                     ),
                   ),
                 )

                ],
              ),
            )
        ],
      ),
        bottomNavigationBar: _isDescriptionFocused
        ? Padding(
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
                    color: HSLColor.fromColor(_resolvedColor(context))
                        .withLightness((HSLColor.fromColor(_resolvedColor(context))
                        .lightness - 0.15).clamp(0.0, 1.0))
                        .toColor(),

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
                          icon: Icon(Icons.image_rounded,color: _textColor,)
                      ),

                      IconButton(onPressed:(){
                        _insertCheckbox();
                      },
                          icon: Icon(Icons.crop_square,color: _textColor,)
                      ),

                      IconButton(
                          onPressed: (){
                            _openbottomSheet();
                          }, icon: Icon(FontAwesomeIcons.tshirt),
                          color: _textColor
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
              : RepaintBoundary(
                key: _globalKey,
                child: Container(

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
                        cursorColor: _dividercolor,
                        decoration: InputDecoration(
                            hintText: 'Title',
                            hintStyle: TextStyle(
                                color:_textColor.withOpacity(0.5),
                                fontFamily: 'ArchivoBlack',
                                fontSize: 18,

                            ),

                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          isDense: true,

                        ),
                        style: TextStyle(
                          color: _textColor,
                          fontFamily: 'Regular',
                          fontSize: 18
                        ),
                      ),
                      Divider(
                        color: _dividercolor.withOpacity(0.2),
                        thickness: 1.5,
                      ),

                      Expanded(
                        child: SuperEditor(
                          editor: _editor,
                          document: _document,
                          composer: _composer,

                          focusNode: _descriptionFocusNode,
                          inputSource: TextInputSource.ime,

                          documentOverlayBuilders: [
                            SuperEditorIosToolbarFocalPointDocumentLayerBuilder(),
                            SuperEditorIosHandlesDocumentLayerBuilder(),
                            SuperEditorAndroidToolbarFocalPointDocumentLayerBuilder(),
                            SuperEditorAndroidHandlesDocumentLayerBuilder(
                              caretColor: _dividercolor, // ✅ Android cursor color
                              caretWidth: 2,
                            ),
                            DefaultCaretOverlayBuilder(
                              caretStyle: CaretStyle(
                                color: _dividercolor, // ✅ Desktop cursor color
                                width: 2,
                              ),
                            ),
                          ],
                          imeConfiguration: const SuperEditorImeConfiguration(
                            enableAutocorrect: false,
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
                            ...defaultComponentBuilders,
                          ],
                          stylesheet: defaultStylesheet.copyWith(
                            addRulesAfter: [
                              StyleRule(
                                BlockSelector.all,
                                    (Document doc, DocumentNode node) => {
                                  Styles.textStyle: TextStyle(
                                      color: _textColor,
                                      fontFamily: 'Regular',
                                      fontSize: 16,
                                      decoration: TextDecoration.none
                                  ),

                                  Styles.padding: const CascadingPadding.symmetric(
                                      vertical: 0,
                                      horizontal: 0
                                  ),
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
          onThemeSelected: _applyTheme, // _applyTheme
          currentColor: _bottomBarColor,
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

  void _applyTheme(Color color)async{
    setState(() {
      _bottomBarColor = color;
    });
    _saveNote();
  }

  void _exportbottomsheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // 🔥 must
      barrierColor: Colors.black54,        // background dim

      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(12), // 👈 চারপাশে gap
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(

              decoration: BoxDecoration(
                color: Color(0xFF2398C4),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,

                children: [

                  ListTile(
                    title: Center(
                      child: const Text("Save as text",
                        style:TextStyle(
                          color: Color(0xFFD9FFFF),
                            fontWeight: FontWeight.bold
                        ),),
                    ),

                    onTap: () async{
                      Navigator.pop(context);
                      await _saveAsText();
                    },
                  ),
                  Divider(),
                  ListTile(
                    title: Center(
                      child: const Text("Save as PDF", style:TextStyle(
                          color: Color(0xFFD9FFFF),
                          fontWeight: FontWeight.bold
                      ),),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _saveAsPDF();
                    },
                  ),
                  Divider(),

                  ListTile(
                    title: Center(
                      child: const Text("Save as image", style:TextStyle(
                          color: Color(0xFFD9FFFF),
                        fontWeight: FontWeight.bold
                      ),),
                    ),
                    onTap: () async{
                      Navigator.pop(context);
                      await _saveAsImage();
                    },
                  ),

                  Divider(),

                  ListTile(
                    title: Center(
                      child: const Text("Share", style:TextStyle(
                          color: Color(0xFFD9FFFF),
                          fontWeight: FontWeight.bold
                      ),),
                    ),
                      onTap: () async {
                        final rootContext = this.context;
                        Navigator.pop(context);
                        final bytes = await SaveAsImage.captureWidget(_buildExportNote());
                        if (!mounted) return;
                        Navigator.push(
                          rootContext,
                          MaterialPageRoute(
                            builder: (_) => ImagePreviewPage(
                                uint8list: bytes,
                               isSaveMode: false,
                            ),
                          ),
                        );
                      }
                  ),

                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveAsText()async{

    try{
      final buffer=StringBuffer();
      final currentTime = DateFormat('MMMM dd, hh:mm a').format(DateTime.now());
      buffer.writeln(currentTime);
      final title=_textEditingController.text.trim();

      if(title.isNotEmpty){
        buffer.writeln(title);
        buffer.writeln();
      }

      for(int i=0; i <_document.nodeCount; i++){
        final node = _document.getNodeAt(i)!;
        if(node is ParagraphNode){
          buffer.writeln(node.text.text);
        }else if(node is ImageNode){
          buffer.writeln('[Image]');
        }
      }

      final content=buffer.toString().trim();
      if(content.isEmpty) return;

      final fileName = title.isNotEmpty
          ? '${title.replaceAll(RegExp(r'[^\w\s]'), '_')}.txt'
          : 'note_${DateTime.now().millisecondsSinceEpoch}.txt';

      final path=await StorageService.saveTextFile(
          fileName: fileName,
          content: content
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved: $path')),
        );
      }

    }catch (e){

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }


  }


  Future<void> _saveAsPDF() async {
    final title = _textEditingController.text.trim();

    final regularFontData =
    await rootBundle.load('assets/fonts/NotoSerifBengali-Regular.ttf');
    final boldFontData =
    await rootBundle.load('assets/fonts/NotoSerifBengali-Bold.ttf');

    final regularFont = PdfTrueTypeFont(regularFontData.buffer.asUint8List(), 20);
    final boldFont = PdfTrueTypeFont(boldFontData.buffer.asUint8List(), 30);



    // 🔹 Content images (local file থেকে)
    final imageDataMap = <String, Uint8List>{};
    for (int i = 0; i < _document.nodeCount; i++) {
      final node = _document.getNodeAt(i);
      if (node is ImageNode) {
        try {
          imageDataMap[node.imageUrl] = await File(node.imageUrl).readAsBytes();
        } catch (_) {}
      }
    }

    final pdfDoc = PdfDocument();
    pdfDoc.pageSettings.size = PdfPageSize.a4;
    pdfDoc.pageSettings.margins.all = 20;

    PdfPage page = pdfDoc.pages.add();
    final pageWidth = page.getClientSize().width;
    final pageHeight = page.getClientSize().height;
    final contentWidth = pageWidth - 40;
    double yOffset = 0;


    final textBrush = PdfSolidBrush(PdfColor(0xD2, 0xFF, 0xFF));

    void drawBackground(PdfPage p) {
      p.graphics.drawRectangle(
        brush: PdfSolidBrush(PdfColor(
          _bottomBarColor!.red,
          _bottomBarColor!.green,
          _bottomBarColor!.blue,
        )),
        bounds: Rect.fromLTWH(0, 0, p.size.width, p.size.height),
      );

    }

    drawBackground(page);

    void checkNewPage(double neededHeight) {
      if (yOffset + neededHeight > pageHeight - 40) {
        page = pdfDoc.pages.add();
        drawBackground(page);
        yOffset = 0;
      }
    }

    // 🔹 Title
    if (title.isNotEmpty) {
      final size = boldFont.measureString(title, layoutArea: Size(contentWidth, 0));
      checkNewPage(size.height);
      page.graphics.drawString(
        title,
        boldFont,
        brush: textBrush,
        bounds: Rect.fromLTWH(20, yOffset, contentWidth, pageHeight),
        format: PdfStringFormat(
          wordWrap: PdfWordWrapType.word,
          lineSpacing: 4,
        ),
      );
      yOffset += size.height + 16;
    }

    // 🔹 Content loop
    for (int i = 0; i < _document.nodeCount; i++) {
      final node = _document.getNodeAt(i);

      if (node is ParagraphNode && node.text.text.isNotEmpty) {
        final text = node.text.text;
        final size = regularFont.measureString(text, layoutArea: Size(contentWidth, 0));
        checkNewPage(size.height);
        page.graphics.drawString(
          text,
          regularFont,
          brush: textBrush,
          bounds: Rect.fromLTWH(20, yOffset, contentWidth, pageHeight),
          format: PdfStringFormat(
            wordWrap: PdfWordWrapType.word,
            lineSpacing: 2,
          ),
        );
        yOffset += size.height + 12;
      }

      if (node is ImageNode) {
        final imgBytes = imageDataMap[node.imageUrl];
        if (imgBytes != null) {
          try {
            final image = PdfBitmap(imgBytes);
            final imgHeight = (contentWidth / image.width) * image.height;
            checkNewPage(imgHeight);
            page.graphics.drawImage(
              image,
              Rect.fromLTWH(20, yOffset, contentWidth, imgHeight),
            );
            yOffset += imgHeight + 16;
          } catch (_) {}
        }
      }
    }

    final bytes = await pdfDoc.save();
    pdfDoc.dispose();

    final fileName = title.isNotEmpty
        ? '${title.replaceAll(RegExp(r'[^\w\s]'), '_')}.pdf'
        : 'note_${DateTime.now().millisecondsSinceEpoch}.pdf';

    final path = await StorageService.savePdfFile(
      fileName: fileName,
      bytes: Uint8List.fromList(bytes),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved: $path')),
      );
    }
  }





  Future<void> _saveAsImage()async{
    final screenHeight = MediaQuery.of(context).size.height;
    final bytes = await SaveAsImage.captureWidget(
      _buildExportNote(),
      width: 668,
      minHeight: screenHeight, // ✅ full page minimum
    );

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ImagePreviewPage(
          uint8list: bytes,
          isSaveMode: true, // ✅ save button দেখাবে
        ),
      ),
    );


  }

  Widget _buildExportNote() {

    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;

    return Container(
      width: screenWidth,
      constraints: BoxConstraints(
        minHeight: screenHeight,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),

        decoration: BoxDecoration(
          color: _bottomBarColor,
        ),
      child: Padding(
        padding: const EdgeInsets.only(top: 14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _textEditingController.text,
              style: const TextStyle(
                fontSize: 18,
                color: Color(0xFFD2FEFF),
                  fontFamily: 'Regular',

              ),
            ),

            Divider(
              color: Color(0xFFD2FEFF).withOpacity(0.2),
              thickness: 1.5,
            ),
            ..._buildExportContent(),
          ],
        ),
      ),
    );
  }


  List<Widget> _buildExportContent() {
    final widgets = <Widget>[];
    for (int i = 0; i < _document.nodeCount; i++) {
      final node = _document.getNodeAt(i)!;

      if (node is ParagraphNode) {
        widgets.add(
          Text(
            node.text.text,
            style: const TextStyle(color: Color(0xFFD2FEFF), fontSize: 16),
          ),
        );
      }

      if (node is ImageNode) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8,top: 8),
            child:AspectRatio(
              aspectRatio: 16/9,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                    File(node.imageUrl),
                    fit: BoxFit.cover,
              ),
            )

          ),
         )
        );
      }
    }

    return widgets;
  }

}

