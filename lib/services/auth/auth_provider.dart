import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';


class FirebaseAuthExecption implements Exception{}

class AuthProvider extends ChangeNotifier{

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
    await FirebaseAuth.instance.signOut();
   }

}