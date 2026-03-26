import 'package:flutter/material.dart';

class FolderList extends StatefulWidget {
  const FolderList({super.key});

  @override
  State<FolderList> createState() => _FolderListState();
}

class _FolderListState extends State<FolderList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Folder list',
        ),

        actions: [
          IconButton(
              onPressed: (){

              },
              icon: Icon(Icons.delete_outline))
        ],

      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20,vertical: 5),
        child: Container(
          height: 40,
          color: Color(0xFF4592AC),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_circle_outline_rounded, color: Color(0xFFE9FEFF),),
                SizedBox(width: 5),
                Text('Create New Folder',style: TextStyle(
                  color: Color(0xFFE8F8FD)
                ),)
              ],
            ),
          ),
        )
      ),
    );
  }
}
