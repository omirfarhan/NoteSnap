import 'dart:convert';

import 'package:notes/services/auth/auth_service_deep_listener.dart';
import 'package:notes/services/auth/authservice.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class LoginController {
  final Authservice _authservice=Authservice();
  late final DeepLinkServices _deepLinkServices;


  LoginController(){
    _deepLinkServices=DeepLinkServices(
        onAuthTokenReceived: _handleToken
    );
  }

  Future<void> init()async{
    await _deepLinkServices.initDeepLinkListener();
  }

  Future<void> login()async{


    //ekhane ekta alertdialoge create hobe
    //jodi user login kore tahole done dibe ar jodi na kore tahole login faild please login ei type er alertdialoge dibe

    final response=await http.post(
      //https://us-central1-notes-moinul-flutter-project.cloudfunctions.net/auth
      //ekhane test er jonne use: http://192.168.1.25:5001/notes-moinul-flutter-project/us-central1/auth
      Uri.parse('http://192.168.1.25:5001/notes-moinul-flutter-project/us-central1/auth'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    final consentUrl=jsonDecode(response.body)['consentUrl'];
    final uri=Uri.parse(consentUrl);
    await launchUrl(
      uri,
      mode: LaunchMode.inAppBrowserView,
    );

  }


  Future<void> _handleToken(String token) async{
    try{
      final credential=await _authservice.signInwithCustomCredential(token);
      print('Logged in: ${credential.user!.uid}');
    }catch (e){
      print('Login failed: $e');
    }

  }

  void dispose(){
    _deepLinkServices.dispose();
  }



}