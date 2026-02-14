import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:notes/services/auth/auth_service_deep_listener.dart';

import 'package:http/http.dart' as http;
import 'package:notes/services/auth/main_auth_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginController {

  late final DeepLinkServices _deepLinkServices;

  final MainAuthProvider mainauthProvider;
  String? lastProcessToken;
  Set<String?> _invalidadeToken={};

  LoginController(this.mainauthProvider){
    _deepLinkServices=DeepLinkServices(
        onAuthTokenReceived: _handleToken
    );
  }

  Future<void> init()async{
    await _deepLinkServices.initDeepLinkListener();
  }

  Future<String?> login()async{

    mainauthProvider.setLoading(true);
    lastProcessToken =null;
    //ekhane ekta alertdialoge create hobe
    //jodi user login kore tahole done dibe ar jodi na kore tahole login faild please login ei type er alertdialoge dibe

    try{

      final response=await http.post(
        //https://us-central1-notes-moinul-flutter-project.cloudfunctions.net/auth
        //ekhane test er jonne use: http://192.168.1.25:5001/notes-moinul-flutter-project/us-central1/auth
        Uri.parse('http://192.168.1.25:5001/notes-moinul-flutter-project/us-central1/auth'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        return "Server error. Please try again.";
      }

      final consentUrl=jsonDecode(response.body)['consentUrl'];
      final uri=Uri.parse(consentUrl);

      final launched= await launchUrl(
        uri,
        mode: LaunchMode.inAppBrowserView,
      );
      
      await Future.delayed(const Duration(seconds: 2));

      if(!launched){
        return 'Could not open browser.';
      }

      if(!mainauthProvider.hasLoggedIn){
        mainauthProvider.setLoading(false);
      }

      return null;
    }on TimeoutException{
     return "Server is taking too long. Check your internet.";
    }on SocketException{
      return "No internet connection";
    } catch (e){
       return "Something went wrong.";
    }
    
    

  }


  Future<void> _handleToken(String token) async{

    if(lastProcessToken == token){
      print('Ignor duplicate token');
      return;
    }


    lastProcessToken = token;
    print('🔑 Processing new token$lastProcessToken');
    await mainauthProvider.loginwithToken(token);
    mainauthProvider.setLoading(false);

  }

  void invalidateCurrentToken(){

    if(lastProcessToken != null){
      _invalidadeToken.add(lastProcessToken);
      print('🗑️ Invalidated token: $lastProcessToken');
      lastProcessToken=null;
    }

  }


  void dispose(){
    _deepLinkServices.dispose();
    lastProcessToken=null;
    _invalidadeToken.clear();
  }



}