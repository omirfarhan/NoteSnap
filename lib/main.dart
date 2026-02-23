import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
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
        title: const Text('Home Page',
        style: TextStyle(
          fontFamily: 'Regular',


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
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
        child: GridView.builder(

                itemCount: 10,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 5,
                  crossAxisSpacing: 10,
                  childAspectRatio: imageUrl != null && imageUrl.isNotEmpty
                    ? 0.9
                    :1.4
                ),
                itemBuilder: (context,int index) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
                    child: Container(
                      decoration: BoxDecoration(

                          color: Color(0xFF50A5C2),
                        borderRadius: BorderRadius.circular(5)
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if(imageUrl != null && imageUrl.isNotEmpty)
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
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Color(0xFFDBF5FB)
                                      ),
                                    ),
                                     Expanded(
                                       child: Text('The note app more is ready when the data is coming the ready to gap format',
                                         style: TextStyle(
                                           color:Color(0xFFDBF5FB).withOpacity(0.9),
                                           fontSize: 12
                                         ),

                                       ),
                                     ),
                                    Row(
                                      children: [
                                        Text('22 Feb, 2026', style: TextStyle(
                                          color: Color(0xFFDBF5FB),
                                          fontSize: 12, fontWeight: FontWeight.w800
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





