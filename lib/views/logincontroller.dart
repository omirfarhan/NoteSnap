import 'package:notes/services/auth/auth_service_deep_listener.dart';
import 'package:notes/services/auth/authservice.dart';

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


  Future<void> _handleToken(String token) async{
    try{
      final credential=await _authservice.signInwithCustomCredential(token);
      print('Logged in: ${credential.user!.uid}');
    }catch (e){
      print('Login failed: $e');
    }

  }



}