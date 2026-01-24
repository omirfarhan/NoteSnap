
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../Data_Layer/google_http_client.dart';





class AuthProvider extends ChangeNotifier{

  static final GoogleSignIn googleSignInn=GoogleSignIn.instance;
  static String? driveAccessToken;
  final FirebaseAuth _firebaseAuth=FirebaseAuth.instance;

  String? photoUrl;
  String? email;
  String? profilename;
  User? user;

  AuthProvider(){
    user =_firebaseAuth.currentUser;
      if(user != null){
        photoUrl = user!.photoURL;
        profilename =user!.displayName;
        email=user!.email;
      }
  }
  bool get isLoggedIn => user != null;


  static bool isinitalized= false;
  static Future<void> _initSignin() async{
    if(!isinitalized){
      await googleSignInn.initialize(serverClientId: "84036142309-o3fo97q8hdn43as73p6jaevqdph86hvr.apps.googleusercontent.com");
    }
    isinitalized = true;
  }


  //For SignIn
  static Future<UserCredential> signinwithGoogle() async{
    await _initSignin();


    final scopes = [
      'email',
      'profile',
      'https://www.googleapis.com/auth/drive.appdata',
    ];

    final GoogleSignInAccount account = await googleSignInn.authenticate();
    final idToken=await account.authentication.idToken;

    //Google API access করার জন্য লাগে example: যেমন google Drive API
    final authClient=await account.authorizationClient;


    /*
    //Scopes হলো permission সেট — ইউজারকে কোন কোন ডেটা অ্যাক্সেস করতে দেবে।
    GoogleSignInClientAuthorization? auth=await authClient.authorizationForScopes(
      scopes
    );



    final aacessToken=auth?.accessToken;


     */


    final GoogleSignInServerAuthorization? serverAuth = await authClient.authorizeServer(scopes);
    final servercode=serverAuth!.serverAuthCode;
    print('Server code: ${servercode}');




    //HTTP request in server and data send to google drive
    /*
       final clientt=GoogleHttpClient({
      'Authorization': 'Bearer $aacessToken',
    });




    final drive=ga.DriveApi(clientt);
    final fileMetadata=ga.File();
    fileMetadata.name='note.txt';
    fileMetadata.parents=["appDataFolder"];

    final content=utf8.encode('my createing note app i feel best proud');
    final media=ga.Media(
       Stream.value(content),
      content.length,
      contentType: 'text/plain'
    );

    var result=await drive.files.create(fileMetadata, uploadMedia: media);
    print("Uploaded File ID: ${result.id}");

        */
    //file show data example : Text
    /*
    final getresult=await drive.files.get('1JRed4r6cLXJ_yw-7dr2KEBFobMOSNfeW58sRcUVNefBo8_OF',
      downloadOptions: ga.DownloadOptions.fullMedia
    ) as ga.Media;

    var dataBytes = <int>[];
    await getresult.stream.forEach((chunk) {
      dataBytes.addAll(chunk);
    });

    var filetext=utf8.decode(dataBytes);

    print("Uploaded FileText show: ${filetext}");

     */


    /*
    print('Access Token is=======: ${aacessToken}');

    if(aacessToken == null){
      final auth2=await authClient.authorizeScopes(
        scopes
      );

      if(auth2?.accessToken == null){
        throw FirebaseAuthException(code: 'No access Token', message: 'fail to retrive access token');
      }
      auth=auth2;
    }

     */

    final credential= GoogleAuthProvider.credential(accessToken: null, idToken: idToken);
    return await FirebaseAuth.instance.signInWithCredential(credential);

  }

  //For signOut
    Future<void> signOut() async{

      await googleSignInn.signOut();
      await _firebaseAuth.signOut();
      user=null;
      photoUrl=null;
      profilename=null;
      email=null;

    notifyListeners();
   }

   Future<void> signinwithgoogle() async{

    final userdata=await AuthProvider.signinwithGoogle();
    // photoUrl=userdata.additionalUserInfo!.profile!['picture'] as String?;
    // email=userdata.additionalUserInfo!.profile!['email'] as String?;
    // profilename=userdata.additionalUserInfo!.profile!['name'] as String?;

    user=userdata.user;
    profilename=user!.displayName;
    email=user!.email;
    photoUrl=user!.photoURL;

    notifyListeners();
   }





}