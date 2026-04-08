class CloudNoteModel {
  final String fileName;
  final String fileId;
  final String title;
  final String content;
  final String? background;
  final int lastEdited;


  CloudNoteModel({
    required this.fileName,
    required this.fileId,
    required this.title,
    required this.content,
    required this.background,
    required this.lastEdited,
  });

  factory CloudNoteModel.fromJson(
      Map<String, dynamic> json, {
        required String fileId,
        required String fileName,
      }) {
    return CloudNoteModel(
      fileName: fileName,
      fileId: fileId,
      title: json['title'] ?? '',
      content: json['content'] ?? '[]',
      background: json['background'],
      lastEdited: json['lastEdited'] ?? 0,
    );
  }


}