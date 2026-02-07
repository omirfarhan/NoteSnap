import 'package:firebase_auth/firebase_auth.dart';

class Authservice {
  final FirebaseAuth _auth=FirebaseAuth.instance;
  User? get currentuser => _auth.currentUser;



  //firebase Sign hobe
  Future<UserCredential> signInwithCustomCredential(String token)async{

    final credential=_auth.signInWithCustomToken(token);
    print('custom credential is ${credential}');
    return credential;

  }

  //ekhane firebase signout hobe


}