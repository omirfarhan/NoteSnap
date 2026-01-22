
import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart' as drive;

class CloudFiles extends StatefulWidget {
  const CloudFiles({super.key});

  @override
  State<CloudFiles> createState() => _CloudFilesState();
}

class _CloudFilesState extends State<CloudFiles> {



  late final TextEditingController _textEditingController;

  @override
  void initState() {
    _textEditingController=TextEditingController();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
      return Scaffold(
        
        appBar: AppBar(
          title: const Text('Cloud Files'),
        ),


        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _textEditingController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: 'enter your mind',

                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.cyanAccent,width: 1)
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.cyanAccent,width: 1)
                    )
                  ),

                ),
              ),
              ElevatedButton(
                  onPressed: () async{



                  }, 
                  child: const Text('Save Drive')
              )

            ],
          ),
        ),
        
      );
  }






  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

}
