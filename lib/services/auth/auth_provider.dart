
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../Data_Layer/google_http_client.dart';
import 'package:cloud_functions/cloud_functions.dart';

import 'package:http/http.dart' as http;


class AuthProvider extends ChangeNotifier{

  static final GoogleSignIn googleSignInn=GoogleSignIn.instance;
  static String? driveAccessToken;
  final FirebaseAuth _firebaseAuth=FirebaseAuth.instance;

  String? photoUrl;
  String? email;
  String? profilename;
  User? user;

  AuthProvider(){
    user =_firebaseAuth.currentUser;
      if(user != null){
        photoUrl = user!.photoURL;
        profilename =user!.displayName;
        email=user!.email;
      }
  }
  bool get isLoggedIn => user != null;


  static bool isinitalized= false;
  static Future<void> _initSignin() async{
    if(!isinitalized){
      await googleSignInn.initialize(serverClientId: "84036142309-o3fo97q8hdn43as73p6jaevqdph86hvr.apps.googleusercontent.com");
    }
    isinitalized = true;
  }


  //For SignIn
  static Future<UserCredential> signinwithGoogle() async{
    await _initSignin();

    // final scopes = [
    //   'email',
    //   'profile',
    //   'https://www.googleapis.com/auth/drive.appdata',
    // ];

    final GoogleSignInAccount account = await googleSignInn.authenticate();
    final idToken=await account.authentication.idToken;

    final response= await http.post(
      Uri.parse('https://us-central1-notes-moinul-flutter-project.cloudfunctions.net/auth'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'idToken': idToken}),
    );

    print('Status: ${response.statusCode}');
    print('Body: ${response.body}');

    final credential= GoogleAuthProvider.credential(accessToken: null, idToken: idToken);
    return await FirebaseAuth.instance.signInWithCredential(credential);

  }

  //For signOut
    Future<void> signOut() async{

      await googleSignInn.signOut();
      await _firebaseAuth.signOut();
      user=null;
      photoUrl=null;
      profilename=null;
      email=null;

    notifyListeners();
   }

   Future<void> signinwithgoogle() async{
    final userdata=await AuthProvider.signinwithGoogle();
    user=userdata.user;
    profilename=user!.displayName;
    email=user!.email;
    photoUrl=user!.photoURL;
    notifyListeners();
   }





}