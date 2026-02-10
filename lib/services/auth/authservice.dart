import 'package:firebase_auth/firebase_auth.dart';

class Authservice {
  static final FirebaseAuth _auth=FirebaseAuth.instance;
  User? get currentuser => _auth.currentUser;



  //firebase Sign hobe
  Future<UserCredential> signInwithCustomCredential(String token)async{
    final credential=await _auth.signInWithCustomToken(token);
    //login hower por ekhan theke data ta add korbo


    print('custom credential is ${credential}');
    return credential;
  }

  //ekhane firebase signout hobe


}