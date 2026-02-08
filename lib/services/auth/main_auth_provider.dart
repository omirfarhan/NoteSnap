import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes/services/auth/authservice.dart';

class MainAuthProvider extends ChangeNotifier{
  final Authservice _authservice=Authservice();

  User? _user;
  bool _loading=false;
  String? _error;

  User? get user => _user;
  bool get isLoading=> _loading;
  String? get error => _error;

  Future<void> loginwithToken(String token)async{
    _loading =true;
    _error=null;
    notifyListeners();
    try{
      final credential=await _authservice.signInwithCustomCredential(token);
      _user=credential.user;
    }catch(e){
      _error=e.toString();
    }

    _loading=false;
    notifyListeners();

  }



}