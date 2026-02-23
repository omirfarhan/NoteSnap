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


class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final List<String> imageList=[
    'images/tree.jpg',
    'images/tree.jpg'
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      title: 'Note App',
      home: const MainPage(),

      routes: {
        SettingspageRoute: (context) => const SettingsPage(),
        CloudFilesRoute: (context) => const CloudFiles()
      },

      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFF239AC4), //Full app background color set
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
      body:Padding(
        padding: const EdgeInsets.fromLTRB(0, 2, 0, 20),
        child: GridView.builder(
          itemCount: 10,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,

            mainAxisSpacing: 8,
          ),
          itemBuilder: (context,int index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Container(
                color: Color(0xFF4CA0BC),
                child: Column(

                  children: [
                    Container(
                      width: double.infinity,
                      height: 100,
                      decoration:  BoxDecoration(
                          image: DecorationImage(image: NetworkImage('https://thumb.photo-ac.com/98/98328339ce5727d17948b5722e2d804b_w.jpeg'),
                            fit: BoxFit.cover,)
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    )




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





