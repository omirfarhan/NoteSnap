
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:notes/Data_Layer/drive_http_request_to_server.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AuthProvider extends ChangeNotifier{
   final GoogleSignIn googleSignInn=GoogleSignIn.instance;
   String? driveAccessToken;

   String _userkey="googleuserid";
   String? _googleUserId;
   String? get googleuserId => _googleUserId;

   String? _accessToken;
   String? get accessToken=> _accessToken;

  final FirebaseAuth _firebaseAuth=FirebaseAuth.instance;
  String? photoUrl;
  String? email;
  String? profilename;
  User? user;

  AuthProvider(){
    _firebaseAuth.authStateChanges().listen((User? firebaseUser) {
      user=firebaseUser;
      if(user != null){
        photoUrl=user!.photoURL;
        email=user!.email;
        profilename=user!.displayName;

      }else{
        photoUrl=null;
        email=null;
        profilename=null;
        _googleUserId=null;
      }
      notifyListeners();
    });
    
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
    final prefs=await SharedPreferences.getInstance();
    _googleUserId= prefs.getString(_userkey);
    notifyListeners();
  }

  bool get isLoggedIn => user != null;
  String? get profileName => user?.displayName;
  String? get gmail => user?.email;
  String? get photoURL=> user?.photoURL;


   bool isinitalized= false;
   Future<void> _initSignin() async{
    if(!isinitalized){
      await googleSignInn.initialize(serverClientId: "84036142309-o3fo97q8hdn43as73p6jaevqdph86hvr.apps.googleusercontent.com");
    }
    isinitalized = true;
  }



  //For SignIn
   /*
   Future<UserCredential> signinwithGoogle() async{
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

    */

   Future<void> signinwithGoogle() async {
     await _initSignin();

     final scopes = [
       'https://www.googleapis.com/auth/drive.appdata',
       'https://www.googleapis.com/auth/userinfo.email',
       'https://www.googleapis.com/auth/userinfo.profile',
     ];

     final account = await googleSignInn.authenticate();
     final idToken = await account.authentication.idToken;

     final serverAuth =
     await account.authorizationClient.authorizeServer(scopes);

     _googleUserId = account.id;
     await _saveGoogleUserid(_googleUserId!);


     final authCode = serverAuth?.serverAuthCode;
     await _sendAuthtoBackend(authCode);

     final credential =
     GoogleAuthProvider.credential(idToken: idToken);

     final userCredential =
     await _firebaseAuth.signInWithCredential(credential);

     user = userCredential.user;
     photoUrl = user?.photoURL;
     profilename = user?.displayName;
     email = user?.email;

     notifyListeners();  // 🔥 এখন ProxyProvider নিশ্চিতভাবে trigger হবে
   }


   Future<void> _saveGoogleUserid(String userID)async{
    final prefs=await SharedPreferences.getInstance();
     prefs.setString(_userkey, userID);
    print('save google user id:======== $userID');
  }

  static Future<void> _sendAuthtoBackend(final authCode)async{
    try{
      final response =await http.post(
        Uri.parse('http://192.168.1.25:5001/notes-moinul-flutter-project/us-central1/exchangeToken'),
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

    try{
     final response= await http.post(
          Uri.parse('http://192.168.1.25:5001/notes-moinul-flutter-project/us-central1/signOut'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({ 'uid':_googleUserId})
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
      _clearUserData();
     notifyListeners();
     return "You have logged out successfully!";

    }on TimeoutException{
      return "Server is taking too long. Check your internet.";
    }on SocketException{
      return "No internet connection";
    } catch (e){
      return "Something went wrong.";
    }

   }

   Future<void> _clearUserData()async{
    final prefs=await SharedPreferences.getInstance();
    await prefs.remove(_userkey);
    _googleUserId =null;
   }


   Future<void> getAccessTokenFromServer() async {
     try{
       final response =await http.post(
           Uri.parse('http://192.168.1.25:5001/notes-moinul-flutter-project/us-central1/getRefreshToken'),
           headers: {'Content-Type': 'application/json'},
           body: jsonEncode({'userId': googleuserId})
       );

       if(response.statusCode == 200){
         final data= jsonDecode(response.body);
         _accessToken=data['accessToken'];
         print('your server accessToken is: $_accessToken');
         notifyListeners();
       }else{
         print('backend Error');
       }

     }catch (e){
       print('server error: $e');
     }
   }


/*
   Future<void> signinwithgoogle() async{
    final userdata=await AuthProvider.signinwithGoogle();
    user=userdata.user;
    profilename=user!.displayName;
    email=user!.email;
    photoUrl=user!.photoURL;
    notifyListeners();
   }

    */



}