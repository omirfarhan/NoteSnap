import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../create_note.dart';

class NoteFab extends StatelessWidget {
  final String folderName;
  const NoteFab({
    super.key,
    required this.folderName,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CreateNote(folderName: folderName),
          ),
        );
      },
      backgroundColor: const Color(0xFFE06600), //const Color(0xFFF88627)
      splashColor: Colors.transparent,
      highlightElevation: 0,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50),
      ),
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          //color: Color(0xFFFFFFFF),
        ),
        padding: const EdgeInsets.all(6),
        child: const Icon(
          Icons.add,
          size: 35,
         // color: Color(0xFF219BCB),
        ),
      ),
    );
  }
}
