
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../Data_Layer/google_http_client.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;



class AuthProvider extends ChangeNotifier{


  static final GoogleSignIn googleSignInn=GoogleSignIn.instance;
  static String? driveAccessToken;
  static String? idToken;


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
  String? get profileName => user?.displayName;
  String? get gmail => user?.email;
  String? get photoURL=> user?.photoURL;

  static bool isinitalized= false;
  static Future<void> _initSignin() async{
    if(!isinitalized){
      await googleSignInn.initialize(serverClientId: "84036142309-o3fo97q8hdn43as73p6jaevqdph86hvr.apps.googleusercontent.com");
    }
    isinitalized = true;
  }


  //For SignIn
  static Future<UserCredential> signinwithGoogle() async{
    final String backendUrl = 'http://192.168.1.25:5001/notes-moinul-flutter-project/us-central1/exchangeToken';
    await _initSignin();
    final scopes= [
      'https://www.googleapis.com/auth/drive.appdata',
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/userinfo.profile',
    ];

    final GoogleSignInAccount account = await googleSignInn.authenticate();
    final idToken=await account.authentication.idToken;
    final GoogleSignInServerAuthorization? serverAuth=
    await account.authorizationClient.authorizeServer(scopes);

    final authCode= serverAuth?.serverAuthCode;
    print('authCode:======== $authCode');

    final response = await http.post(
      Uri.parse('$backendUrl/exchangeToken'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'code': authCode}),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('✅ Success! Tokens saved for user: ${data['email']}');
      return data;
    } else {
      print('❌ Backend error: ${response.body}');
    }

    //AuthProvider.idToken=idToken;

    final credential= GoogleAuthProvider.credential(accessToken: null, idToken: idToken);
    return await FirebaseAuth.instance.signInWithCredential(credential);

  }

  Future<void> connectingGoogleDrive() async{

    final response=await http.post(
      Uri.parse('https://us-central1-notes-moinul-flutter-project.cloudfunctions.net/auth'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'idToken': idToken}),
    );

    print('Status: ${response.statusCode}');
    print('Body: ${response.body}');


    final consentUrl=jsonDecode(response.body)['consentUrl'];
    final uri=Uri.parse(consentUrl);

    // final url=Uri.parse('https://www.google.com');

    // if(await canLaunchUrl(url)){
    //   await launchUrl(
    //       url,
    //     mode: LaunchMode.externalApplication
    //   );
    // }


     //Uri ursl = Uri.parse('https://www.google.com');
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch ${uri}');
    }



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