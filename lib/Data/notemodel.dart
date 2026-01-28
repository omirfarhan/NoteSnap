class Notemodel {
  String id;
  String title;
  String text;
  //DateTime createdAt;
  //DateTime updatedAt;
  List<String> imagesPath;

  Notemodel({
    required this.id,
    required this.title,
    required this.text,
    //required this.createdAt,
    //required this.updatedAt,
    required this.imagesPath
});


  Map<String,dynamic> toJson() =>{
    'id':id,
    'title':title,
    'text':text,
    //'createdAt':createdAt.toIso8601String(),
    //'updatedAt': updatedAt.toIso8601String(),
    'images':imagesPath
  };

}