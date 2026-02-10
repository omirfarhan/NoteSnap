import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes/services/auth/authservice.dart';
import 'package:notes/services/shared_preference_service.dart';

class MainAuthProvider extends ChangeNotifier{
  final Authservice _authservice=Authservice();

  User? _user;
  bool _loading=false;
  String? _error;

  User? get user => _user;
  bool get isLoading=> _loading;
  String? get error => _error;
  //shared-preference data added system
  Map<String, dynamic> ? _cacheUserData;
  final UserCacheService _cacheService=UserCacheService();

  String? get displayName =>_user?.displayName ??_cacheUserData?['displayName'];
  String? get email => _user?.email ?? _cacheUserData?['email'];
  String? get photoUrl => _user?.photoURL ?? _cacheUserData?['photoUrl'];
  String? get uid => _user?.uid ?? _cacheUserData?['uid'];


  MainAuthProvider(){
    _loadCacheUser();
    _initAuthListener();
  }

  Future<void> _loadCacheUser()async{
    _cacheUserData=await _cacheService.getUserData();
    notifyListeners();
  }

  void _initAuthListener(){
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if(user != null){
        // User login থাকলে data save করা
        _cacheService.saveUserData(
            displayName: user.displayName,
            email: user.email,
            photoUrl: user.photoURL,
            uid: user.uid);
      }
      notifyListeners();
    });
  }

  // Future<void> signIn(User user)async{
  //   _user=user;
  //
  //
  //
  // }



  Future<void> loginwithToken(String token)async{
    _loading =true;
    _error=null;
    notifyListeners();
    try{
      final credential=await _authservice.signInwithCustomCredential(token);
      _user=credential.user;

      if(_user != null){
       await _cacheService.saveUserData(
           displayName: _user?.displayName,
           email: _user?.email,
           photoUrl: _user?.photoURL,
           uid: _user?.uid
       );
      }
    }catch(e){
      _error=e.toString();
    }
    _loading=false;
    notifyListeners();
  }

  bool get hasLoggedIn{
    return _user != null || _cacheUserData != null;
  }


}