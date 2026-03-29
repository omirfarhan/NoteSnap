import 'package:flutter/material.dart';
import 'package:notes/services/crud/notes_service.dart';

class FolderList extends StatefulWidget {
  const FolderList({super.key});

  @override
  State<FolderList> createState() => _FolderListState();
}

class _FolderListState extends State<FolderList> {

  late final NotesService _notesService;
  final Set<String> _selectedFoldernames = {};


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
                separatorBuilder: (context, index) => const SizedBox(height: 0),
                itemCount: folders.length,

                itemBuilder: (context, index) {
                  final folder=folders[index];
                  final isSelected = _selectedFoldernames.contains(folder.foldername);
                  final noteCount=_getNoteCount(folder.foldername);

                  return GestureDetector(

                    //ekhane aro kisu baki ase

                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5,vertical: 5),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF1A7EA8)
                              :const Color(0xFF4592AC),
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
      ),
    );
  }
}
