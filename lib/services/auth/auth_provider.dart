
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AuthProvider extends ChangeNotifier{
  static final GoogleSignIn googleSignInn=GoogleSignIn.instance;
  static String? driveAccessToken;
  static String? googleuserid;

  final FirebaseAuth _firebaseAuth=FirebaseAuth.instance;
  String? photoUrl;
  String? email;
  String? profilename;
  User? user;

  AuthProvider(){
    init();
  }

  Future<void> init() async {
    await saveGoogleuserID();
    user = _firebaseAuth.currentUser;

    if (user != null) {
      photoUrl = user!.photoURL;
      profilename = user!.displayName;
      email = user!.email;
    }

    notifyListeners();
  }



  Future<void> saveGoogleuserID()async{
    SharedPreferences prefs=await SharedPreferences.getInstance();
    googleuserid=prefs.getString("googleuserid");
    notifyListeners();
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

    final googleuid=await account.id;
    googleuserid=googleuid;
    _saveGoogleUserid(googleuserid!);
    final authCode= serverAuth?.serverAuthCode;
    await _sendAuthtoBackend(authCode);
    final credential= GoogleAuthProvider.credential(accessToken: null, idToken: idToken);
    return await FirebaseAuth.instance.signInWithCredential(credential);

  }

  static Future<void> _saveGoogleUserid(String userID)async{
    SharedPreferences prefs=await SharedPreferences.getInstance();
    prefs.setString("googleuserid", userID);
    print('save google user id:======== $userID');
  }

  static Future<void> _sendAuthtoBackend(final authCode)async{
    try{
      final response =await http.post(
        Uri.parse('http://10.214.51.221:5001/notes-moinul-flutter-project/us-central1/exchangeToken'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'code': authCode}),
      );
      if(response.statusCode == 200){
        final data=json.decode(response.body);
        print('Success! Tokens saved for user: ${data['email']}');
      }else{
        print('backend Error');
      }
    }catch (e){
      print('No Send data to backend $e');
    }

  }



  //For signOut
  Future<String?> signOut() async{
    notifyListeners();
    try{
     final response= await http.post(
          Uri.parse('http://10.214.51.221:5001/notes-moinul-flutter-project/us-central1/signOut'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({ 'uid':googleuserid})
      ).timeout(const Duration(seconds: 5));

     if(response.statusCode != 200){
       return "server error";
     }

      await googleSignInn.signOut();
      await _firebaseAuth.signOut();
      user=null;
      photoUrl=null;
      profilename=null;
      email=null;

      return "You have logged out successfully!";
    }on TimeoutException{
      return "Server is taking too long. Check your internet.";
    }on SocketException{
      return "No internet connection";
    } catch (e){
      return "Something went wrong.";
    }



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