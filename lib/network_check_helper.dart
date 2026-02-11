import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

Future<bool> HasInternetConnection()async{

  final connectivityResult=await Connectivity().checkConnectivity();

  if(connectivityResult == ConnectivityResult.none){
    return false;
  }

  try{
    final result=await InternetAddress.lookup('google.com')
        .timeout(const Duration(seconds: 10));

    return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
  }catch (e){
    return false;
  }

}