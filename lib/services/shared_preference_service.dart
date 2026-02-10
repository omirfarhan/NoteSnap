import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
class UserCacheService{
  static const String _userKey='cached_user_data';
  static const String _isLoggedinkey='is_logged_in';

  Future<void> saveUserData({
    required String? displayName,
    required String? email,
    required String? photoUrl,
    required String? uid,
})async {
    final prefs=await SharedPreferences.getInstance();
    final userData={
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'uid' : uid,
    };
    await prefs.setString(_userKey, jsonEncode(userData));
    await prefs.setBool(_isLoggedinkey, true);
}

//get user data
Future<Map<String, dynamic>?> getUserData()async{
    final prefs=await SharedPreferences.getInstance();
    final userDataString=prefs.getString(_userKey);

    if(userDataString != null){
      return jsonDecode(userDataString) as Map<String, dynamic>;
    }
    return null;
}

//check user logged in
Future<bool> isLoggedIn()async{
    final prefs=await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedinkey) ?? false;
}

// User data clear করা (logout এর সময়)
Future<void> clearUserData()async{
    final prefs=await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.setBool(_isLoggedinkey, false);
}


}