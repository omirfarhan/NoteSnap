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





  String? _getFirstImageFromContent(String content) {
    if (content.isEmpty) return null;
    try {
      final list = jsonDecode(content) as List<dynamic>;
      for (final item in list) {
        if (item['type'] == 'image') {
          return item['url'] as String?;
        }
      }
    } catch (e) {
      return null;
    }
    return null;
  }


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

  String _formatTime(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('MMM dd, hh:mm a').format(date);
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

                                   return MasonryGridView.builder(

                                    itemCount: notes.length,
                                    gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                    ),
                                    mainAxisSpacing: 8,
                                    crossAxisSpacing: 20,
                                    itemBuilder: (context, index) {
                                      final note = notes[index];
                                      final firstimage = _getFirstImageFromContent(note.content);
                                      final plainText = _getPlainTextFromContent(note.content);

                                      return InkWell(
                                        onTap: () {
                                          Navigator.of(context).pushNamed(CreateNoteRoute,arguments: note);
                                         //  Navigator.of(context).pushNamed(
                                         //    CreateNoteRoute,
                                         //    arguments: {'folder': _selectedFolder?.foldername ?? 'All Folder'},
                                         //  );
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Color(0xFF58B4D3),
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                          clipBehavior: Clip.hardEdge,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min, // ← এটাই magic, content অনুযায়ী height নেয়
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              if (firstimage != null)
                                                Container(
                                                  width: double.infinity,
                                                  height: 75,
                                                  decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                      image: FileImage(File(firstimage)),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                              Padding(
                                                padding: const EdgeInsets.fromLTRB(5, 2, 5, 5),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(note.title,
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontFamily: 'Regular',
                                                        fontWeight: FontWeight.w600,
                                                        fontSize: 13,
                                                        color: Color(0xFFDBF5FB),
                                                      ),
                                                    ),

                                                      Text(plainText,
                                                        style: TextStyle(
                                                          color: Color(0xFFDBF5FB),
                                                          fontFamily: 'Regular',
                                                          fontWeight: FontWeight.w400,
                                                          fontSize: 12,
                                                          height: 1.2,
                                                        ),
                                                        maxLines: 4,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    SizedBox(
                                                      height: 5,
                                                    ),
                                                    Text(_formatTime(note.lastEdited),
                                                      style: TextStyle(
                                                        color: Color(0xFFDBF5FB),
                                                        fontSize: 10,
                                                        fontFamily: 'Fredoka',
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );

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
    );
  }
}





