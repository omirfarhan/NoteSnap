import 'package:flutter/material.dart';
import 'package:notes/main.dart';
import 'package:notes/services/crud/notes_service.dart';

import 'all_notes_page.dart';
import 'notes_in_folder_page.dart';


class FolderList extends StatefulWidget {
  const FolderList({super.key});

  @override
  State<FolderList> createState() => _FolderListState();
}

class _FolderListState extends State<FolderList> {

  late final NotesService _notesService;
  final Set<String> _selectedFoldernames = {};
  bool _isSelecting = false;


  @override
  void initState() {
    super.initState();
    _notesService=NotesService();
  }


  @override
  void dispose() {
    //_notesService.close();
    super.dispose();
  }

  Future<void> _deleteSelectedFolders()async{

    // All Folder যদি কোনোভাবে সিলেক্ট হয়ে থাকে তাহলে সরিয়ে দাও
    _selectedFoldernames.removeWhere((name) => name == 'all folder');

    if (_selectedFoldernames.isEmpty) {
      setState(() => _isSelecting = false);
      return;
    }

    final confirm=await showDialog<bool>(
        context: context,
        builder:(context) => AlertDialog(
          backgroundColor: const Color(0xFF0D6186),
          title: const Text(
            'Delete folders?',
            style: TextStyle(color: Color(0xFFD9FFFF)),
          ),

          content:  Text(
            '${_selectedFoldernames.length} folder(s) will be deleted.',
            style: const TextStyle(color: Color(0xFF9EDDE4)),
          ),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF9EDDE4))),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete', style: TextStyle(color: Color(0xFFD9FFFF))),
            ),
          ],
        ),
    );


    if(confirm == true){
      
      for(final name in _selectedFoldernames){
        await _notesService.deleteFolder(foldername: name);
      }

      setState(() {
        _selectedFoldernames.clear();
        _isSelecting = false;
      });
    }
  }


  Future<void> _createFolderDialog() async{

    final controller=TextEditingController();
    await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Color(0xFF0D6186),
          title: const Text(
            'Create new note folder',
            style: TextStyle(color: Color(0xFFE8F8FD),fontSize: 15),
          ),

          content: TextField(
            controller: controller,
            //autofocus: true,
            style: const TextStyle(color: Color(0xFFD9FFFF)),
            cursorColor: const Color(0xFFD9FFFF),
            decoration: const InputDecoration(
              hintText: 'Folder name',
              hintStyle: TextStyle(color: Color(0xFF9EDDE4)),

              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF4592AC)),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF9EDDE4)),
              ),
            ),
          ),

          shape: BoxBorder.all(style: BorderStyle.none),

          actions: [
            TextButton(
                onPressed: (){
                  Navigator.pop(context);
            }, child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF9EDDE4)))
            ),

            TextButton(
                onPressed: ()async{
                  final name =controller.text.trim();

                  if(name.isNotEmpty){
                    Navigator.pop(context);
                    await _notesService.getOrCreateFolder(
                        foldername: name,
                        setCurrentFolder: false
                    );
                  }

                },
                child: const Text('Create', style: TextStyle(color: Color(0xFFD9FFFF))),
            )


          ],

        ),
    );


  }

  // bool _isAllFolder(String folderName){
  //   return folderName.toLowerCase() == 'all folder';
  // }

  int _getNoteCount(String foldername) {
    return _notesService.getNoteCountForFolder(foldername: foldername);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0D6186),
        centerTitle: true,
        title: Text(
          _isSelecting
          ? '${_selectedFoldernames.length} Selected'
          : 'Folder list',
        ),

        actions: [

          if(_isSelecting)
            IconButton(
              onPressed: _selectedFoldernames.isEmpty
                  ? null
                  : _deleteSelectedFolders,
              icon: const Icon(Icons.delete_outline),
            )else
             IconButton(
              onPressed: (){
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please select your folder'))
                );
              },
              icon: Icon(Icons.delete_outline))
        ],

      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20,vertical: 5),
        child: InkWell(
          onTap: _createFolderDialog,
          borderRadius: BorderRadius.circular(8),
          
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
          ),
        )
      ),

      body: Column(
        children: [

          StreamBuilder<List<DatabaseNote>>(
              stream: _notesService.allNotesUnfiltered,
              builder: (context, snapshot) {

                final noteCount=snapshot.data?.length ?? 0;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  child: GestureDetector(
                    onTap: () {
                      if (_isSelecting) return;

                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AllNotesPage(),
                        ),
                      );
                    },


                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      decoration: BoxDecoration(
                        color: _selectedFoldernames.contains('all')
                            ? const Color(0xFF1A7EA8)
                            : const Color(0xFF4592AC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedFoldernames.contains('all')
                              ? const Color(0xFF9EDDE4)
                              : const Color(0xFF1A7EA8),
                          width: 0.5,
                        ),
                      ),
                      child: ListTile(
                        title: Text(
                          'All Folder',
                          style: TextStyle(
                            color: Color(0xFFE8F8FD),
                            fontSize: 18,
                          ),
                        ),
                        trailing:Text(
                          '$noteCount',

                          style: const TextStyle(
                            color: Color(0xFFE8F8FD),
                            fontSize: 12,
                            fontFamily: 'Regular',
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },



    ),
          Expanded(
            child: StreamBuilder<List<Folder>>(
                stream: _notesService.allFolders,
                builder: (context, snapshot) {

                  return StreamBuilder<List<DatabaseNote>>( // ← এটা add করো
                    stream: _notesService.allNotes,
                    builder: (context, noteSnapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text('No folders yet',
                              style: TextStyle(color: Color(0xFF9EDDE4))),
                        );
                      }

                      final folders = snapshot.data!
                      .where((folder)=>folder.foldername.toLowerCase() != 'all folder')
                      .toList();
                      

                      return StreamBuilder<List<DatabaseNote>>(
                        stream: _notesService.allNotesUnfiltered,
                        builder: (context, noteSnapshot) {



                          return ListView.separated(
                            separatorBuilder: (context, index) =>
                            const SizedBox(height: 0),
                            itemCount: folders.length,

                            itemBuilder: (context, index) {
                              final folder = folders[index];
                              final folderLower = folder.foldername.toLowerCase();
                              //final isAllFolder = _isAllFolder(folder.foldername);

                              final isSelected =
                                  _selectedFoldernames.contains(folderLower);


                              final noteCount=_getNoteCount(folder.foldername);

                              return GestureDetector(

                                onLongPress: () {
                                  //if (isAllFolder) return;

                                  setState(() {
                                    _isSelecting = true;
                                    _selectedFoldernames.add(
                                        folder.foldername.toLowerCase());
                                  });
                                },

                                onTap: () {

                                  if (_isSelecting) {

                                    //if (isAllFolder) return;

                                    setState(() {
                                      final name = folder.foldername.toLowerCase(); // ✅ এটা যোগ করুন
                                      if (_selectedFoldernames.contains(name)) {
                                        _selectedFoldernames.remove(name);
                                        if (_selectedFoldernames.isEmpty)
                                          _isSelecting = false;
                                      } else {
                                        _selectedFoldernames.add(name);
                                      }
                                    });
                                  }
                                  //ekhane hocche folder e click korle note page e jabe
                                  //mane sob note dekha jabe

                                  else{

                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => NotesInFolderPage(folder: folder),
                                      ),
                                    );

                                    // if (isAllFolder) {
                                    //   Navigator.of(context).push(
                                    //     MaterialPageRoute(
                                    //       builder: (context) => const AllNotesPage(),
                                    //     ),
                                    //   );
                                    // } else {
                                    //
                                    // }

                                  }



                                },


                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 5),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 150),
                                    decoration: BoxDecoration(
                                        color: isSelected
                                            ? const Color(0xFF1A7EA8)
                                            : const Color(0xFF4592AC),
                                        borderRadius: BorderRadius.circular(12),
                                        border: BoxBorder.all(
                                            color: isSelected
                                                ? const Color(0xFF9EDDE4)
                                                : const Color(0xFF1A7EA8),
                                            width: 0.5
                                        )
                                    ),

                                    child: ListTile(
                                      //ekhane kisu baki

                                      title: Text(
                                        folder.foldername,
                                        style: const TextStyle(
                                          color: Color(0xFFE8F8FD),
                                          fontSize: 18,
                                          fontFamily: 'Regular',
                                        ),
                                      ),
                                      trailing: Text(
                                        '$noteCount',
                                        style: const TextStyle(
                                          color: Color(0xFFE8F8FD),
                                          fontSize: 12,
                                          fontFamily: 'Regular',
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },


                          );
                        },

                      );
                    },
                  );
                }),
          )
        ],
      )

    );
  }
}
