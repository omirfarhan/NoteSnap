import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:notes/constants/routes.dart';
import 'package:notes/services/auth/auth_provider.dart';

import 'package:notes/services/cloud/cloud_files.dart';
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
        CloudFilesRoute: (context) => const CloudFiles()
      },
      //0xFF239AC4
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFF137FA5), //Full app background color set
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF137FA5),
          titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 18
          ),
          iconTheme: IconThemeData(
              color: Colors.white
          ),
        ),

      ),

    );
  }
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  final imageUrl='https://thumb.photo-ac.com/98/98328339ce5727d17948b5722e2d804b_w.jpeg';
  //https://thumb.photo-ac.com/98/98328339ce5727d17948b5722e2d804b_w.jpeg
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //backgroundColor: Color(0xFF137FA5),
        title: const Text('Note storage',
        style: TextStyle(
          fontFamily: 'Fredoka',
          fontWeight: FontWeight.w600
        ),),

        actions: [
          IconButton(onPressed: (){
            Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SettingsPage()
                ));
          }, icon: Icon(Icons.settings))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
        child: Column(
          children: [
            TextField(
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
              child: GridView.builder(
                itemCount: 10,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 5,
                    crossAxisSpacing: 10,
                    childAspectRatio: imageUrl.isNotEmpty
                        ? 0.9
                        :1.4
                ),
                itemBuilder: (context,int index) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
                    child: Container(
                      decoration: BoxDecoration(

                          color: Color(0xFF58B4D3),
                          borderRadius: BorderRadius.circular(5)
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if(imageUrl.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(5, 8, 5, 3),
                              child: Container(
                                width: double.infinity,
                                height: 70,
                                decoration:  BoxDecoration(
                                    image: DecorationImage(image: NetworkImage(imageUrl),
                                      fit: BoxFit.cover,)
                                ),
                              ),
                            ),


                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('The note app title is the day',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontFamily: 'Fredoka',
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                        color: Color(0xFFDBF5FB)
                                    ),
                                  ),
                                  Expanded(
                                    child: Text('The note app more is ready when the data is coming the ready to gap format the ready method pixel',
                                      style: TextStyle(
                                        color:Color(0xFFDBF5FB),
                                        fontFamily: 'Fredoka',
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12,
                                        height: 1.2,

                                      ),
                                      maxLines: 4,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text('22 Feb, 2026', style: TextStyle(
                                          color: Color(0xFFDBF5FB),
                                          fontSize: 10,
                                          fontFamily: 'Fredoka',
                                          fontWeight: FontWeight.w600
                                      ),)
                                    ],
                                  )


                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),



      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print('Floating action button');
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





