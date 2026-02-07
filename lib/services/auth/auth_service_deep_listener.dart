import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:firebase_auth/firebase_auth.dart';


class DeepLinkServices {
  StreamSubscription? _sub;
  final appLinks=AppLinks();

  final void Function(String token) onAuthTokenReceived;
  DeepLinkServices({required this.onAuthTokenReceived});

  Future<void> initDeepLinkListener() async{
    final initaluri=await appLinks.getInitialLink();
    if(initaluri != null){
      _handleUri(initaluri);
    }

    _sub=appLinks.uriLinkStream.listen((uri){
      if(uri != null){
        _handleUri(uri);
      }
    },onError: (error){
      print('deep link error ${error}');
    });

  }

  void _handleUri(Uri? uri){
    if(uri != null && uri.host == 'auth' && uri.path == '/callback'){
      final token=uri.queryParameters['token'];
      if(token != null){
        onAuthTokenReceived(token);
      }
    }
  }


  void dispose(){
    _sub?.cancel();
  }

}
