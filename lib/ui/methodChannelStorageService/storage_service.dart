import 'dart:convert';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class StorageService {
  static const _channel = MethodChannel('com.yourapp/storage');

  // Permission check
  static Future<bool> requestPermission() async {
    final sdk = (await DeviceInfoPlugin().androidInfo).version.sdkInt;

    if (sdk >= 29) {
      return true;
    } else {
      // Android 9 এবং নিচে
      final status = await Permission.storage.request();
      return status.isGranted;
    }
  }


  static Future<String> saveTextFile({
    required String fileName,
    required String content,
    String subFolder = 'Note storage',
  }) async {
    final hasPermission = await requestPermission();
    if (!hasPermission) throw Exception('Storage permission denied');

    //final bytes = Uint8List.fromList(content.codeUnits);
    // ✅ codeUnits এর বদলে utf8.encode ব্যবহার করো
    final bytes = Uint8List.fromList(utf8.encode(content));

    final path = await _channel.invokeMethod<String>('saveFile', {
      'fileName': fileName,
      'content': bytes,
      'mimeType': 'text/plain',
      'subFolder': subFolder,
    });

    return path ?? '';
  }

  // PDF file save
  static Future<String> savePdfFile({
    required String fileName,
    required Uint8List bytes,
    String subFolder = 'Note storage',
  }) async {
    final hasPermission = await requestPermission();
    if (!hasPermission) throw Exception('Storage permission denied');

    final path = await _channel.invokeMethod<String>('saveFile', {
      'fileName': fileName,
      'content': bytes,
      'mimeType': 'application/pdf',
      'subFolder': subFolder,
    });


    return path ?? '';
  }

  // Image file save
  static Future<String> saveImageFile({
    required String fileName,
    required Uint8List bytes,
    String subFolder = 'Note storage',
  }) async {
    final hasPermission = await requestPermission();
    if (!hasPermission) throw Exception('Storage permission denied');

    final path = await _channel.invokeMethod<String>('saveFile', {
      'fileName': fileName,
      'content': bytes,
      'mimeType': 'image/png',
      'subFolder': subFolder,
    });

    return path ?? '';
  }

}