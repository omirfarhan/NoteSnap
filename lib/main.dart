import 'dart:convert';


import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:notes/constants/routes.dart';
import 'package:notes/services/auth/auth_provider.dart';
import 'package:notes/services/cloud/cloud_files.dart';
import 'package:notes/services/crud/notes_service.dart';
import 'package:notes/ui/AppLocked/app_lock_wrapper.dart';
import 'package:notes/ui/create_note.dart';
import 'package:notes/ui/folder_list.dart';
import 'package:notes/Data/notifincation_in_firebase.dart';
import 'package:notes/ui/settings_page.dart';
import 'package:notes/ui/widgets/note_fab.dart';
import 'package:notes/ui/widgets/note_grid.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_notification.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  final prefs = await SharedPreferences.getInstance();
  List<String> notifications = prefs.getStringList('mydatabase') ?? [];

  notifications.add(jsonEncode({
    'title': message.notification?.title ?? '',
    'body': message.notification?.body ?? '',
    'type': message.data['type'] ?? '',
    'image': message.data['image'] ?? '',
    'time': DateTime.now().toString(),
  }));
  await prefs.setStringList('mydatabase', notifications);
}
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await FirebaseMessaging.instance
      .setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

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
      navigatorKey: navigatorKey,
      home: const AppLockWrapper(child: MainPage()),
      routes: {
        SettingspageRoute: (context) => const SettingsPage(),
        CloudFilesRoute: (context) => const CloudFiles(),
        CreateNoteRoute: (context) => const CreateNote(),
        FolderListRoute: (context) => const FolderList(),
      },
      //0xFF239AC4
      themeMode: ThemeMode.system,
      // Light Theme
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFEEEEEE),

        colorScheme: const ColorScheme.light(
          onSurface: Color(0xFF484848), // ← light mode text color
        ),

        appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle.light,
          backgroundColor: Color(0xFFEEEEEE),
          titleTextStyle: TextStyle(
            color: Color(0xFF484848),
            fontFamily: 'ArchivoBlack',
            fontSize: 19,
            fontWeight: FontWeight.w400,
          ),

        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: Color(0xFF9EDDE4),
        ),
      ),
      // Dark Theme
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1F1F1F),
        colorScheme: const ColorScheme.dark(
          onSurface: Color(0xFFE1E1E1), // ← dark mode text color
        ),
        appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle.light,
          backgroundColor: Color(0xFF1E1E1E),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontFamily: 'ArchivoBlack',
            fontSize: 19,
            fontWeight: FontWeight.w600,
          ),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: Colors.tealAccent,
        ),
      ),

    );
  }
}



class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late Future _initFuture;
  late final NotesService _notesService;
  String _searchQuery='';
  Folder? _selectedFolder;
  Set<int> _selectedNoteIds = {};
  bool _isSelecting = false;

  NotifincationInFirebase notificationservices=NotifincationInFirebase();



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

  void _toggleSelection(int noteId){
    setState(() {
      if (_selectedNoteIds.contains(noteId)) {
        _selectedNoteIds.remove(noteId);
        if (_selectedNoteIds.isEmpty) _isSelecting = false;
      } else {
        _selectedNoteIds.add(noteId);
      }
    });
  }

  Future<void> _deleteSelectedNotes()async{
    final confirm=await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0D6186),
        title: const Text(
          'Delete notes?',
          style: TextStyle(color: Color(0xFFD9FFFF)),
        ),

        content: Text(
          '${_selectedNoteIds.length} note(s) will be deleted.',
          style: const TextStyle(color: Color(0xFF9EDDE4)),
        ),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFF9EDDE4))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete',
                style: TextStyle(color: Color(0xFFD9FFFF))),
          ),
        ],
      ),

    );

    if(confirm == true){
      for(final id in _selectedNoteIds){
        await _notesService.deleteNote(id: id);
      }

      setState(() {
        _selectedNoteIds.clear();
        _isSelecting = false;
      });
    }

  }

  // আপনার যেকোনো Screen বা initState এ:



  @override
  void initState() {
    super.initState();
    _notesService=NotesService();

    _initFuture = _notesService.getOrCreateFolder(
      foldername: 'All Folder',
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      notificationservices.init(context);
    });


  }


  @override
  void dispose() {
    super.dispose();
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Note storage',
        ),

        actions: [

          if(_isSelecting)
            IconButton(
                onPressed: _selectedNoteIds.isEmpty ? null
                    :_deleteSelectedNotes,
                icon:  const Icon(Icons.delete_outline)
            ),

          IconButton(onPressed: (){
            Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => FirebaseNotification(title: '', body: '', image: '',),
                ));
          }, icon: Icon(Icons.notifications_on_outlined)),

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
                //color: Color(0xFFC8E1E4),
                fontSize: 14,
              ),
              decoration: InputDecoration(
                prefixIcon: Icon(FontAwesomeIcons.magnifyingGlass,
                  //color: Color(0xFFB8E2E8),
                  size: 16,
                ),
                //fillColor: Color(0xFF0B7197),
                filled: true,
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                prefixIconConstraints: BoxConstraints(minHeight: 38,minWidth: 38),
                hintText: 'Search notes...',
                hintStyle: TextStyle(
                  //color: Color(0xFFC8E1E4),
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
                  future: _initFuture,
                  builder: (context, snapshot) {
                    switch(snapshot.connectionState){
                      case ConnectionState.done:
                        return  StreamBuilder<List<DatabaseNote>>(
                          stream: _notesService.allNotesUnfiltered,
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

                                  return NoteGrid(
                                    notes: notes,
                                    onNoteChanged: () => _notesService.refreshNotes(),
                                    selectedNoteIds: _selectedNoteIds,
                                    onNoteLongPress: (id) {
                                      setState(() {
                                        _isSelecting = true;
                                        _selectedNoteIds.add(id);
                                      });
                                    },

                                    onNoteTap: _isSelecting ? _toggleSelection: null,
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
                        return Center(child: const CircularProgressIndicator());
                    }
                  },
              )


            ),
          ],
        ),
      ),

      floatingActionButton: NoteFab(folderName: _selectedFolder?.foldername ?? 'all folder'),

    );
  }
}





