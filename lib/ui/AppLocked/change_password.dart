import 'package:flutter/material.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
            'Change Password'
        ),
      ),
      
      body: Column(
        children: [
          // TextButton(
          //   onPressed: (){
          //
          //   },
          //   child: Text(),
          // )
        ],
      ),


    );
  }
}
