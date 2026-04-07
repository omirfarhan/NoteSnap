import 'package:notes/Data/folder_model.dart';

class FolderWithFiles {
  final FolderModel folder;
  final List<FolderModel> files;
  bool isExpanded; // folder open/close

  FolderWithFiles({
    required this.folder,
    required this.files,
    this.isExpanded = false,
  });

}