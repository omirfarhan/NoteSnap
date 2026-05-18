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

  bool _isDeleteMode = false;
  Set<int> _selectedIndices = {};
  List<Map<String, dynamic>> _notifications = [];  // ← state এ রাখো
  bool _isLoading = true;

  Color get _textColor => Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFFE1E1E1)
      : const Color(0xFF343434);

  @override
  void initState() {
    super.initState();
    _loadNotifications();
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

  Future<void> _loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> notifications = prefs.getStringList('mydatabase') ?? [];
    setState(() {
      _notifications = notifications
          .map((e) => jsonDecode(e) as Map<String, dynamic>)
          .toList();
      _isLoading = false;
    });
  }

  Future<void> _deleteSelected() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> notifications = prefs.getStringList('mydatabase') ?? [];

    final sortedIndices = _selectedIndices.toList()..sort((a, b) => b.compareTo(a));
    for (final index in sortedIndices) {
      notifications.removeAt(index);
    }

    await prefs.setStringList('mydatabase', notifications);

    setState(() {
      _isDeleteMode = false;
      _selectedIndices.clear();
      
      _notifications = notifications
          .map((e) => jsonDecode(e) as Map<String, dynamic>)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Reminders'),
        actions: [
          if(_isDeleteMode) ...[
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: Colors.white,
              onPressed: _selectedIndices.isEmpty ? null : _deleteSelected,
            ),
            // Cancel button
            TextButton(
                onPressed: () {
                  setState(() {
                    _isDeleteMode = false;
                    _selectedIndices.clear();
                  });
                }, 
                child: const Text('Clear',
                  style: TextStyle(
                  color: Colors.white,  //Color(0xFF9EDDE4)
                    fontWeight: FontWeight.bold
                ),)
            )
            
          ]else
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                setState(() {
                  _isDeleteMode = true;
                });
              },
            ),

        ],
      ),
      body: Column(
        children: [
          Divider(
            color: Color(0xFFD2FEFF).withOpacity(0.2),
            thickness: 1.5,
          ),

          Expanded(
            child:  _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _notifications.isEmpty
                    ? Center(
                    child: Text('Notes with upcoming reminders appear here',
                        style: TextStyle(color: _textColor)),
                      )
                     : ListView.builder(
                 itemCount: _notifications.length,
                 itemBuilder: (context, index) {
                        final item = _notifications[index];
                        final isSelected = _selectedIndices.contains(index);

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
                            trailing: _isDeleteMode
                                ? GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (isSelected) {
                                      _selectedIndices.remove(index);
                                    } else {
                                      _selectedIndices.add(index);
                                    }
                                  });
                                },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected
                                      ? Colors.red
                                      : Colors.white.withOpacity(0.6),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.red
                                        : Colors.grey,
                                    width: 2,
                                  ),
                                ),
                                child: isSelected
                                    ? const Icon(
                                  Icons.check,
                                  size: 16,
                                  color: Colors.white,
                                )
                                    : null,
                              ),
                            )
                                : null,
                            onTap: _isDeleteMode
                              ? () {
                            // Tap anywhere on card to toggle in delete mode
                            setState(() {
                          if (isSelected) {
                            _selectedIndices.remove(index);
                          } else {
                            _selectedIndices.add(index);
                          }
                        });
                        }
                        : () {
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




            ),


          )
        ],
      ),

    );
  }


}
