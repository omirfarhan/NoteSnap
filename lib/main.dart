import 'package:flutter/material.dart';
import 'package:notes/constants/routes.dart';
import 'package:notes/services/auth/auth_provider.dart';
import 'package:notes/ui/settings_page.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(

    MultiProvider(
        providers: [
          
          ChangeNotifierProvider(create: (_) => AuthProvider())

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
        SettingspageRoute: (context) => const SettingsPage()
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
      ),

      body: SafeArea(
        child: Center(
          child: ElevatedButton(onPressed: () {
            Navigator.of(context).pushNamed(SettingspageRoute);
        
          }, child: const Text('Settings')),
        ),
      ),



    );
  }
}


