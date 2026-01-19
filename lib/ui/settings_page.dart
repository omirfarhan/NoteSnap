import 'package:flutter/material.dart';
import 'package:notes/services/auth/auth_provider.dart';
import 'package:provider/provider.dart';


class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {



  @override
  Widget build(BuildContext context) {



    return Scaffold(

      appBar: AppBar(
        title: const Text('Settings Page',
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
                    buildCloudService(context, 'Cloud Files'),
                    Divider(thickness: 1),
                    buildCloudService(context, 'Recently delete items'),
                  ],

                )
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

    final auth = context.watch<AuthProvider>();

    return Container(
                  width: MediaQuery.sizeOf(context).width,

                  color: Color(0xFF5BB5D7),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 10,
                      ),

                      buildProfileCreator(context, auth.profilename??'profile name'),
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

  Widget buildProfileCreator(BuildContext context ,String profilename){

    final auth=context.watch<AuthProvider>();
    print('logging option ${auth.isLoggedIn}');

    return Material(


      color: Colors.transparent,
      child: InkWell(

        splashColor: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(1),



        onTap: () async{
          //email navigator page e jabe

          try{

            await context.read<AuthProvider>().signinwithgoogle();
            print(auth.email);
            print(auth.profilename);
            print(auth.photoUrl);

            profilename=auth.profilename!;

          }catch(e){
            print('Google sign in faild $e');
          }




        },


        child: Row(
          children: [
            SizedBox(
              width: 10,
            ),

            SizedBox(
              height: 50,
              width: 50,
              child: ClipRRect(
               // borderRadius: BorderRadius.circular(50),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: auth.photoUrl != null ?
                    NetworkImage(auth.photoUrl!)
                        : null,
                    child: auth.photoUrl == null ?
                    const Icon(Icons.person)
                    :null ,
                  )
              )
            ),


            SizedBox(
              width: 15,
            ),
            Text('${profilename}',
            style: TextStyle(
              color: Color(0xFFF7FBFD),
                fontWeight: FontWeight.w100,
              fontFamily: 'ArchivoBlack',
              fontSize: 15
            )
            ),

            const Spacer(),

            TextButton(onPressed: ()async{
             await auth.signOut();
             ScaffoldMessenger.of(context).showSnackBar(
                 SnackBar(content: Text('You have logged out successfully!'),
                 backgroundColor: Color(0xFF6365EF),
                 )
             );
            },
              child: Text('Log Out',
                  style: TextStyle(
                      color: Color(0xFFF7FBFD),
                      fontWeight: FontWeight.w100,
                      fontFamily: 'ArchivoBlack',
                      fontSize: 15
                  )
              ),
            ),
            SizedBox(
              width: 10,
            )

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

  Widget buildCloudService(BuildContext context, String title){
    
    return Material(
      color: Colors.transparent,
      child: InkWell(

        splashColor: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(1),

        onTap: (){
          print('tap');
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

}


