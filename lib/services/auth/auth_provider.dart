import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';




class AuthProvider extends ChangeNotifier{

  final FirebaseAuth _firebaseAuth=FirebaseAuth.instance;

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

    final idToken=account.authentication.idToken;

    //Google API access করার জন্য লাগে example: যেমন google Drive API
    final authClient=account.authorizationClient;

    //Scopes হলো permission সেট — ইউজারকে কোন কোন ডেটা অ্যাক্সেস করতে দেবে।
    GoogleSignInClientAuthorization? auth=await authClient.authorizationForScopes([
      'email',
      'profile',
      //drive er file toiri upload/show er jonne
      //''https://www.googleapis.com/auth/drive.file''
    ]);

    final aacessToken=auth?.accessToken;

    if(aacessToken == null){
      final auth2=await authClient.authorizationForScopes([
        'email',
        'profile',
        //drive er file toiri upload/show er jonne
        //''https://www.googleapis.com/auth/drive.file''

      ]);

      if(auth2?.accessToken == null){
        throw FirebaseAuthException(code: 'No access Token', message: 'fail to retrive access token');
      }

      auth=auth2;

    }

    final credential= GoogleAuthProvider.credential(accessToken: aacessToken, idToken: idToken);


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