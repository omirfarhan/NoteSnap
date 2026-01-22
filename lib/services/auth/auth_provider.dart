import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:notes/Data_Layer/google_http_client.dart';
import 'package:googleapis/drive/v3.dart' as ga;




class AuthProvider extends ChangeNotifier{

  //static var client;
  final FirebaseAuth _firebaseAuth=FirebaseAuth.instance;

  static final folderId = "1GCNjcP3k4qU8gepp5_mPnuzQ4-tY7PFf";

  String? photoUrl;
  String? email;
  String? profilename;

  User? user;
//FirebaseAuth.instance.currentUser;
  AuthProvider(){
    user =_firebaseAuth.currentUser;

      if(user != null){
        photoUrl = user!.photoURL;
        profilename =user!.displayName;
        email=user!.email;
      }


  }

  bool get isLoggedIn => user != null;


  static final GoogleSignIn googleSignInn=GoogleSignIn.instance;
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


     final GoogleSignInAccount account = await googleSignInn.authenticate();


    if(account == null ){
      throw FirebaseAuthException(code: 'SignIN Aborted by user',
        message: 'SIGNIN incomlete'
      );
    }


    final idToken=await account.authentication.idToken;

    //Google API access করার জন্য লাগে example: যেমন google Drive API
    final authClient=await account.authorizationClient;

    //Scopes হলো permission সেট — ইউজারকে কোন কোন ডেটা অ্যাক্সেস করতে দেবে।
    GoogleSignInClientAuthorization? auth=await authClient.authorizationForScopes([
      'email',
      'profile',
      //drive er file toiri upload/show er jonne
      'https://www.googleapis.com/auth/drive.file'
    ]);
    final aacessToken=auth?.accessToken;

    //  final clientt=GoogleHttpClient({
    //   'Authorization': 'Bearer $aacessToken',
    // });


     //delete method
    // final drive=ga.DriveApi(clientt);
    // var file=ga.File();
    // file.name="note.txt";
    // file.parents=['1Cl1SDznsR5cDJoQVG0IzB6YVoM8gH9VN'];
    //
    // var media=ga.Media(
    //   Stream.value(utf8.encode("THis is my note")),
    //   null
    // );
    //
    // var result=await drive.files.create(file, uploadMedia: media);
    // print("Uploaded File ID: ${result.id}");
//======================================
     //client=clientt;



    //print('Access Token is=======: ${aacessToken}');



    // GoogleSignInServerAuthorization? serverAuth= await authClient.authorizeServer([
    //   'email',
    //   'profile',
    //   //drive er file toiri upload/show er jonne
    //   'https://www.googleapis.com/auth/drive.file'
    // ]);
    //
    // if(serverAuth?.serverAuthCode==null){
    //   throw FirebaseAuthException(
    //       code: 'no Server code',
    //     message: 'Failed to retrieve server authorization code'
    //
    //   );
    //
    // }



    if(aacessToken == null){
      final auth2=await authClient.authorizationForScopes([
        'email',
        'profile',
        //drive er file toiri upload/show er jonne
        'https://www.googleapis.com/auth/drive.file'

      ]);

      if(auth2?.accessToken == null){
        throw FirebaseAuthException(code: 'No access Token', message: 'fail to retrive access token');
      }

      auth=auth2;


    }
    //=============



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
    // photoUrl=userdata.additionalUserInfo!.profile!['picture'] as String?;
    // email=userdata.additionalUserInfo!.profile!['email'] as String?;
    // profilename=userdata.additionalUserInfo!.profile!['name'] as String?;

    user=userdata.user;
    profilename=user!.displayName;
    email=user!.email;
    photoUrl=user!.photoURL;

    notifyListeners();
   }





}