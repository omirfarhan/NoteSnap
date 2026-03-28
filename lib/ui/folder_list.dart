import 'package:flutter/material.dart';
import 'package:notes/services/crud/notes_service.dart';

class FolderList extends StatefulWidget {
  const FolderList({super.key});

  @override
  State<FolderList> createState() => _FolderListState();
}

class _FolderListState extends State<FolderList> {

  late final NotesService _notesService;


  @override
  void initState() {
    super.initState();
    _notesService=NotesService();
  }


  @override
  void dispose() {
    _notesService.close();
    super.dispose();
  }

  int _getNoteCount(String foldername) {
    return _notesService.getNoteCountForFolder(foldername: foldername);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0D6186),
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

      body: StreamBuilder(
          stream: _notesService.allFolders,
          builder: (context, snapshot) {
            if(snapshot.connectionState == ConnectionState.waiting){
              return const Center(child: CircularProgressIndicator());
            }

            if(!snapshot.hasData || snapshot.data!.isEmpty){
              return const Center(
                child: Text('No folders yet',
                    style: TextStyle(color: Color(0xFF9EDDE4))),
              );
            }

            final folders=snapshot.data!;

            return ListView.separated(
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemCount: folders.length,

                itemBuilder: (context, index) {
                  final folder=folders[index];
                  //final isSelected = _selectedFoldernames.contains(folder.foldername);
                  final noteCount=_getNoteCount(folder.foldername);

                  return GestureDetector(

                    //ekhane aro kisu baki ase

                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),

                      //ekhane aro kisu baki

                      child: ListTile(
                        //ekhane kisu baki

                        title: Text(
                          folder.foldername,

                        ),

                      ),
                    ),
                  );
                },


            );
          },
      ),
    );
  }
}
