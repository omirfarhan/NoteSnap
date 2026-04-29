import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseNotification extends StatefulWidget {

  final String title;
  final String body;
  final String image;

  const FirebaseNotification({
  super.key,
  required this.title,required,
  required this.body,
  required this.image
  });

  @override
  State<FirebaseNotification> createState() => _FirebaseNotificationState();
}

class _FirebaseNotificationState extends State<FirebaseNotification> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.title.isNotEmpty ||
          widget.body.isNotEmpty ||
          widget.image.isNotEmpty) {
        _showDialog();
      }
    });

  }

  void _showDialog() {
    showDialog(
      
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.title),
        backgroundColor: const Color(0xFF9EDDE4),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.body),
            if (widget.image.isNotEmpty)
              Image.network(widget.image),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> loadNotification()async{
    final prefs=await SharedPreferences.getInstance();
    List<String> notifications = prefs.getStringList('mydatabase') ?? [];
    return notifications.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Reminders'),
      ),
      body: Column(
        children: [
          Divider(
            color: Color(0xFFD2FEFF).withOpacity(0.2),
            thickness: 1.5,
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
                future: loadNotification(),
                builder: (context, snapshot) {

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Notes with upcoming reminders appear here'));
                  }

                  final notifications = snapshot.data!;

                  return ListView.builder(
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final item = notifications[index];

                        return Card(
                          color: const Color(0xFF9EDDE4),
                          margin: const EdgeInsets.all(10),
                          child: ListTile(
                            title: Text(item['title'] ?? ''),

                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['body'] ?? '',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,

                                ),
                                const SizedBox(height: 5,),

                              ],
                            ),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: const Color(0xFF9EDDE4),
                                  title: Text(item['title'] ?? ''),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item['body'] ?? ''),
                                      if (item['image'] != null && item['image'].toString().isNotEmpty)
                                        Image.network(item['image']),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text("OK"),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),


                        );
                      },
                  );


                },
            ),
          )


        ],
      ),

    );
  }


}
