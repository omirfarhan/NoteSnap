import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:notes/ui/recently_deleted_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/routes.dart';
import 'package:notes/services/auth/auth_provider.dart';



class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}



class _SettingsPageState extends State<SettingsPage> {
  bool _isLoggingOut = false;
  bool _isLogin = false;



  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: Scaffold(
            appBar: AppBar(
              title: const Text('Settings Page'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),

      body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildtitle('Cloud Service'),

                    CloudServiceContainer(context),

                    SizedBox(
                      height: 10,
                    ),

                    buildtitle('Profile'),

                    ProfileSectionContainer(context),

                    SizedBox(
                      height: 18,
                    ),

                    buildtitle('Security'),
                    SecuritySectionContainer(context),

                    SizedBox(
                      height: 18,
                    ),

                    buildtitle('About'),

                    AboutSectionContainer(context),


                  ],
                ),
              ),
            ),
          )

    ),
    );
  }

  Widget CloudServiceContainer(BuildContext context) {
    return Container(
                width: MediaQuery.sizeOf(context).width,
                color: Color(0xFF5BB5D7),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    //buildCloudService(context, 'Cloud Files'),
                    buldCloudFileMethod(),
                    Divider(thickness: 1),
                    buildRecentlyDeleteItems(),
                    //buildCloudService(context, 'Recently delete items'),

                  ],

                )
              );
  }


  //build Recently delete items
  Widget buildRecentlyDeleteItems() {
    return Material(
        color: Colors.transparent,
        child: InkWell(

          splashColor: Colors.white.withOpacity(0.25),
          borderRadius: BorderRadius.circular(1),

          onTap: (){


            print('Recently delete items121');

            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const RecentlyDeletedPage(),
              ),
            );


          },

          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Title(color: Color(0xFF5BB5D7), child: Text('Recently delete items',
                  style: TextStyle(
                      color: Color(0xFFF7FBFD),
                      fontFamily: 'ArchivoBlack',
                      fontSize: 19,
                      fontWeight: FontWeight.w100
                  ),
                )),
                Icon(Icons.arrow_forward_ios_outlined,color: Color(0xFFF7FBFD),)
              ],
            ),
          ),

        ),
      );
  }

  //Cloud Files
  Widget buldCloudFileMethod() {
    return Material(
                color: Colors.transparent,
                child: InkWell(

                  splashColor: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(1),

                  onTap: (){
                    Navigator.of(context).pushNamed(CloudFilesRoute);
                  },

                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Title(color: Color(0xFF5BB5D7), child: Text('Cloud Files',
                          style: TextStyle(
                              color: Color(0xFFF7FBFD),
                              fontFamily: 'ArchivoBlack',
                              fontSize: 19,
                              fontWeight: FontWeight.w100
                          ),
                        )),
                        Icon(Icons.arrow_forward_ios_outlined,color: Color(0xFFF7FBFD),)
                      ],
                    ),
                  ),

                ),
              );
  }

  Widget SecuritySectionContainer(BuildContext context) {
    return Container(
                  width: MediaQuery.sizeOf(context).width,
                  color: Color(0xFF5BB5D7),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildCloudService(context, 'App Locked'),
                      Divider(thickness: 1),
                      buildCloudService(context, 'Change Password'),
                    ],

                  )
              );
  }

  Widget ProfileSectionContainer(BuildContext context) {

    return Container(
                  width: MediaQuery.sizeOf(context).width,

                  color: Color(0xFF5BB5D7),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 10,
                      ),

                      buildProfileCreator(context),
                      Divider(thickness: 1),
                      buildCloudService(context, 'Backup Email'),

                    ],

                  )
              );
  }

  Widget AboutSectionContainer(BuildContext context) {
    return Container(
                  width: MediaQuery.sizeOf(context).width,

                  color: Color(0xFF5BB5D7),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildCloudService(context, 'Help Center'),
                      Divider(thickness: 1),
                      buildCloudService(context, 'Rate us'),
                      Divider(thickness: 1),
                      buildCloudService(context, 'Privacy Policy'),
                    ],

                  )
              );
  }



  //Google Authentication
  Widget buildProfileCreator(BuildContext context){
    final auth=context.watch<AuthProvider>();
    final displayName = auth.profileName ?? 'Tap to Login';
    final photoUrl = auth.photoURL;
    final hasLoggedIn = auth.isLoggedIn;
    final isauthentication=auth.isAuthenticating;
        return Material(
          color: Colors.transparent,
          child: InkWell(
            splashColor: Colors.white.withOpacity(0.25),
            borderRadius: BorderRadius.circular(1),
            onTap:!hasLoggedIn
                ? () async {
              try {
               await auth.signinwithGoogle();
               // if(context.mounted){
               //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
               // }


              } catch (e) {
                if (mounted) {
                  debugPrint('Login failed: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Login failed: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            }
                : null,
            child: Row(
              children: [
                SizedBox(
                  width: 10,
                ),
                SizedBox(
                    height: 50,
                    width: 50,
                    child: isauthentication?
                        Center(
                          child: const SizedBox(
                            width: 25,
                            height: 25,
                            child: CircularProgressIndicator(strokeWidth: 2,),
                          ),
                        )
                    : photoUrl != null
                        ? CachedNetworkImage(
                      imageUrl: photoUrl,
                      imageBuilder: (context, imageProvider) => CircleAvatar(
                        radius: 25,
                        backgroundImage: imageProvider,
                      ),
                      placeholder: (context, url) => const CircleAvatar(
                        radius: 25,
                        backgroundColor: Color(0xFF5BB5D7),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      errorWidget: (context, url, error) => const CircleAvatar(
                        radius: 25,
                        backgroundColor: Color(0xFF5BB5D7),
                        child: Icon(Icons.person),
                      ),
                    )
                        :const CircleAvatar(
                      radius: 25,
                      backgroundColor: Color(0xFF5BB5D7),
                      child: Icon(Icons.person),
                    )

                ),


                SizedBox(
                  width: 15,
                ),
                Text(displayName.length >16
                    ?'${displayName.substring(0,16)}...'
                    : displayName,
                  style: TextStyle(
                    color: Color(0xFFF7FBFD),
                    fontWeight: FontWeight.w100,
                    fontFamily: 'ArchivoBlack',
                    fontSize: 15,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const Spacer(),
                hasLoggedIn?
                TextButton(onPressed:
                    _isLoggingOut ? null
                    : ()async{
                      setState(() => _isLoggingOut = true);
                  try{
                    final success= await auth.signOut();
                    if(success != null && context.mounted){
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(success)));
                    }
                    if (context.mounted) {
                      setState(() => _isLoggingOut = false);
                    }
                  }catch (e){
                    print('error occure is : $e');
                  }
                },
                  child:_isLoggingOut?
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2,),
                      )
                 :const Text('Log Out',
                      style: TextStyle(
                          color: Color(0xFFF7FBFD),
                          fontWeight: FontWeight.w100,
                          fontFamily: 'ArchivoBlack',
                          fontSize: 15
                      )
                  ),
                ):
                const SizedBox.shrink()
              ],
            ),

          ),
        );


  }
  
  Padding buildtitle(String title){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child:  Text('${title}', style: TextStyle(
          fontSize: 14,
          color: Color(0xFF94D0E8),
          fontWeight: FontWeight.w100,
          fontFamily: 'ArchivoBlack'
      ),),


    );

  }

  //Backup Email
  Widget buildCloudService(BuildContext context, String title){
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        splashColor: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(1),
        onTap: (){
          print('Backup Email ');
        },

        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Title(color: Color(0xFF5BB5D7), child: Text('${title}',
              style: TextStyle(
                color: Color(0xFFF7FBFD),
                fontFamily: 'ArchivoBlack',
                fontSize: 19,
                fontWeight: FontWeight.w100
              ),
              )),
              Icon(Icons.arrow_forward_ios_outlined,color: Color(0xFFF7FBFD),)
            ],
          ),
        ),

      ),
    );
    
  }

  @override
  void dispose() {
    super.dispose();
  }


}


