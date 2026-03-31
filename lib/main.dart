import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:notes/constants/routes.dart';
import 'package:notes/services/auth/auth_provider.dart';
import 'package:notes/services/cloud/cloud_files.dart';
import 'package:notes/services/crud/notes_service.dart';
import 'package:notes/ui/create_note.dart';
import 'package:notes/ui/folder_list.dart';
import 'package:notes/ui/settings_page.dart';
import 'package:notes/ui/widgets/note_fab.dart';
import 'package:notes/ui/widgets/note_grid.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(

    MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),

        ],
      child: const MyApp(),
    )
  );
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Note App',
      home: const MainPage(),
      routes: {
        SettingspageRoute: (context) => const SettingsPage(),
        CloudFilesRoute: (context) => const CloudFiles(),
        CreateNoteRoute: (context) => const CreateNote(),
        FolderListRoute: (context) => const FolderList(),
      },
      //0xFF239AC4
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFF137FA5), //Full app background color set
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF137FA5),
          titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontFamily: 'Fredoka',
              fontWeight: FontWeight.w600
          ),
          iconTheme: IconThemeData(
              color: Colors.white
          ),
        ),

      ),

    );
  }
}

//typedef NoteCallback=void Function(DatabaseNote note);

class MainPage extends StatefulWidget {
  //final NoteCallback onTap;
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late final NotesService _notesService;
  String _searchQuery='';
  Folder? _selectedFolder;


  String _getPlainTextFromContent(String content) {
    if (content.isEmpty) return '';
    try {
      final list = jsonDecode(content) as List<dynamic>;
      return list
          .where((item) => item['type'] == 'paragraph')
          .map((item) => item['text'] as String? ?? '')
          .where((text) => text.trim().isNotEmpty)
          .join('\n');
    } catch (e) {
      return content;
    }
  }


  @override
  void initState() {
    super.initState();
    _notesService=NotesService();
  }


  @override
  void dispose() {
    //_notesService.close();
    super.dispose();
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //backgroundColor: Color(0xFF137FA5),
        title: const Text('Note storage',
        ),

        actions: [

          IconButton(onPressed: ()async{

           final selected=await Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => FolderList())
            );


           if(selected!= null && selected is Folder){

             await _notesService.getOrCreateFolder(
               foldername: selected.foldername,
               setCurrentFolder: true,
             );

             setState(() {
               _selectedFolder = selected;
             });
           }



          }, icon: Icon(Icons.folder_copy_outlined)),


          IconButton(onPressed: (){
            Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SettingsPage()
                ));
          }, icon: Icon(Icons.settings)),

        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
        child: Column(
          children: [
            TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery=value.toLowerCase();
                });
              },
              autocorrect: false,
              enableSuggestions: false,
              spellCheckConfiguration: SpellCheckConfiguration.disabled(),
              cursorColor: Color(0xFFC8E1E4),
              style: TextStyle(
                color: Color(0xFFC8E1E4),
                fontSize: 14,
              ),
              decoration: InputDecoration(
                prefixIcon: Icon(FontAwesomeIcons.magnifyingGlass,
                  color: Color(0xFFB8E2E8),size: 16,
                ),
                fillColor: Color(0xFF0B7197),
                filled: true,
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                prefixIconConstraints: BoxConstraints(minHeight: 38,minWidth: 38),
                hintText: 'Search notes...',
                hintStyle: TextStyle(
                  color: Color(0xFFC8E1E4),
                  fontSize: 12,
                  fontFamily: 'Fredoka',
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide(color: Color(0xFFC6E1E5)),
                ),

                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide(color: Color(0xFFC6E1E5)),

                )

              ),

            ),

            const SizedBox(
              height: 18,
            ),
            Expanded(
              child:FutureBuilder(
                  future: _notesService.getOrCreateFolder(foldername: 'All Folder'),
                  builder: (context, snapshot) {
                    switch(snapshot.connectionState){
                      case ConnectionState.done:
                        return  StreamBuilder<List<DatabaseNote>>(
                          stream: _notesService.allNotes,
                          builder: (context, snapshot) {
                            switch(snapshot.connectionState){
                              case ConnectionState.waiting:
                              case ConnectionState.active:
                                if(snapshot.hasData){

                                  final allnote=snapshot.data!;
                                  final notes=allnote.where((note){
                                    final title=note.title.toLowerCase();
                                    final plaintext=_getPlainTextFromContent(note.content).toLowerCase();
                                    return title.contains(_searchQuery) ||
                                        plaintext.contains(_searchQuery);
                                  }).toList();

                                   return NoteGrid(notes: notes);

                                }else{
                                  return const Center(child: Text(''),);
                                }
                              default:
                                return const Center(child: CircularProgressIndicator(),);

                            }
                          },
                        );
                      default:
                        return const CircularProgressIndicator();
                    }
                  },
              )


            ),
          ],
        ),
      ),

      floatingActionButton: NoteFab(folderName: _selectedFolder?.foldername ?? 'all folder'),
      /*
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //Navigator.of(context).pushNamed(CreateNoteRoute);
          Navigator.of(context).pushNamed(
            CreateNoteRoute,
            // ✅ এখন folder নামও পাঠাচ্ছি
            arguments: _selectedFolder?.foldername ?? 'all folder',
          );
        },
        backgroundColor: Color(0xFF219BCB),
        splashColor: Colors.transparent,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50)
        ),
        elevation: 0,
        child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFFFFFFF),
          ),
          padding: const EdgeInsets.all(6),
          child: const Icon(
            Icons.add,
            size: 35,
            color: Color(0xFF219BCB),

          ),
        ),
      ),

       */
    );
  }
}





