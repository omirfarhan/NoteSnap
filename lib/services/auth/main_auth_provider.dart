import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes/services/auth/authservice.dart';
import 'package:notes/services/shared_preference_service.dart';
import 'package:http/http.dart' as http;

import '../../network_check_helper.dart';

class MainAuthProvider extends ChangeNotifier{
  final Authservice _authservice=Authservice();
  final hasInternetConnection=HasInternetConnection();

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

  Future<bool> SignOut()async{

    final Uid=uid;
    print('user tap is signOut and uid is: ${user?.uid}');
    if(Uid == null){
      // already signed out
      return true;
    }

    final checknetwork=await hasInternetConnection;
    bool backendSuccess=false;

    if(checknetwork){
      try{
        final response=await http.post(
            Uri.parse('http://192.168.1.25:5001/notes-moinul-flutter-project/us-central1/signOut'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({ 'uid':Uid})
        )
            .timeout(const Duration(seconds: 10));

        await FirebaseAuth.instance.signOut();
        _user=null;
        // Cache clear করা
        await _cacheService.clearUserData();
        _cacheUserData=null;

        if(response.statusCode==200){
          backendSuccess=true;
          print('response status Code: 200');
        }else{
          print('Backend signOut faild: ${response.statusCode} ${response.body}');
        }

      }catch (e){
        'SignOut API error: $e';
      }
    }else{
      //alert dialoge hobe
      print('please connection your data');
    }

    notifyListeners();
    return backendSuccess;
  }


  bool get hasLoggedIn{
    return _user != null || _cacheUserData != null;
  }


}