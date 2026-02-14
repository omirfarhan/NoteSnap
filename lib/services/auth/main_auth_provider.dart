import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:notes/services/auth/auth_service_deep_listener.dart';
import 'package:notes/services/auth/authservice.dart';
import 'package:notes/services/shared_preference_service.dart';
import 'package:http/http.dart' as http;


class MainAuthProvider extends ChangeNotifier{
  final Authservice _authservice=Authservice();
  late final DeepLinkServices _deepLinkServices;


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

  //loading Method
  void setLoading(bool value){
    _loading = value;
    notifyListeners();
  }

  MainAuthProvider(){
    _loadCacheUser();
    _initAuthListener();
  }

  Future<void> _loadCacheUser()async{
    _cacheUserData=await _cacheService.getUserData();
    notifyListeners();
  }

  void _initAuthListener(){

    Authservice.auth.authStateChanges().listen((User? user) {

      _user=user;
      if(user != null){
        // User login থাকলে data save করা
        _cacheService.saveUserData(
            displayName: user.displayName,
            email: user.email,
            photoUrl: user.photoURL,
            uid: user.uid);
      }else{

        _cacheUserData=null;
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

  Future<String?> SignOut()async{
    final Uid=uid;
    print('user tap is signOut and uid is: ${Uid}');

    if(Uid == null){
      return 'No user to signOut';
    }


      try{

        final response=await http.post(
            Uri.parse('http://192.168.1.25:5001/notes-moinul-flutter-project/us-central1/signOut'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({ 'uid':Uid})
        ).timeout(const Duration(seconds: 30));

        //await GoogleSignIn.instance.signOut();
        await FirebaseAuth.instance.signOut();

        print("signOut completed");
        _user=null;
        await _cacheService.clearUserData();
        _cacheUserData=null;

        await Future.delayed(const Duration(seconds: 500));


        if (response.statusCode == 200) {
          return "You have logged out successfully!";
        }

      }on TimeoutException{
        return "Server is taking too long. Check your internet.";
      }on SocketException{
        return "No internet connection";
      } catch (e){
        return "Something went wrong.";
      }


    notifyListeners();
    return null;
  }


  // bool get hasLoggedIn{
  //   return _user != null || _cacheUserData != null;
  // }

  bool get hasLoggedIn => _user != null;

}