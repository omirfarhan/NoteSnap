package com.moinulislamsxs.notes;

//import androidx.annotation.NonNull;
//
//import io.flutter.embedding.android.FlutterActivity;
//import io.flutter.embedding.engine.FlutterEngine;
//import io.flutter.plugin.common.MethodChannel;
//
//import android.content.Context;
//import android.content.ContextWrapper;
//import android.content.Intent;
//import android.content.IntentFilter;
//import android.os.BatteryManager;
//import android.os.Build;


import android.content.ContentValues;
import android.os.Build;
import android.os.Environment;
import android.provider.MediaStore;

import androidx.annotation.NonNull;

import java.io.File;
import java.io.FileOutputStream;
import java.io.OutputStream;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;


public class MainActivity extends FlutterActivity {

    //private static final String CHANNEL = "samples.flutter.dev/battery";
    private static final String CHANNEL = "com.yourapp/storage";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

//        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(),
//                CHANNEL
//        ).setMethodCallHandler((call, result) -> {
//
//            if (call.method.equals("getBatteryLevel")) {
//                int batteryLevel = getBatteryLevel();
//
//                if (batteryLevel != -1) {
//                    result.success(batteryLevel);
//                } else {
//                    result.error("UNAVAILABLE", "Battery level not available.", null);
//                }
//            } else {
//                result.notImplemented();
//            }
//
//        });

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler((call, result) -> {
                    if (call.method.equals("saveFile")) {
                        String fileName = call.argument("fileName");
                        byte[] content = call.argument("content");
                        String mimeType = call.argument("mimeType");
                        String subFolder = call.argument("subFolder");

                        if (subFolder == null) subFolder = "Note storage";

                        try {
                            String path = saveToDocuments(fileName, content, mimeType, subFolder);
                            result.success(path);
                        } catch (Exception e) {
                            result.error("SAVE_ERROR", e.getMessage(), null);
                        }
                    } else {
                        result.notImplemented();
                    }
                });
    }

    private String saveToDocuments(
            String fileName,
            byte[] content,
            String mimeType,
            String subFolder
    ) throws Exception {

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            // ✅ MediaStore.Files use করো - Documents folder এ save হবে
            ContentValues contentValues = new ContentValues();
            contentValues.put(MediaStore.Files.FileColumns.DISPLAY_NAME, fileName);
            contentValues.put(MediaStore.Files.FileColumns.MIME_TYPE, mimeType);
            contentValues.put(
                    MediaStore.Files.FileColumns.RELATIVE_PATH,
                    Environment.DIRECTORY_DOCUMENTS + "/" + subFolder
            );

            android.net.Uri uri = getContentResolver().insert(
                    MediaStore.Files.getContentUri("external"),
                    contentValues
            );

            if (uri == null) throw new Exception("Failed to create file");

            OutputStream outputStream = getContentResolver().openOutputStream(uri);
            if (outputStream == null) throw new Exception("Failed to open output stream");

            outputStream.write(content);
            outputStream.close();

            return "Documents/" + subFolder + "/" + fileName;

        } else {
            // ✅ Android 9 এবং নিচে : Direct file write
            File folder = new File(
                    Environment.getExternalStoragePublicDirectory(
                            Environment.DIRECTORY_DOCUMENTS),
                    subFolder
            );

            if (!folder.exists()) {
                folder.mkdirs();
            }

            File file = new File(folder, fileName);
            FileOutputStream fos = new FileOutputStream(file);
            fos.write(content);
            fos.close();

            return file.getAbsolutePath();
        }
    }

//    private int getBatteryLevel() {
//        int batteryLevel;
//
//        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
//            BatteryManager batteryManager =
//                    (BatteryManager) getSystemService(Context.BATTERY_SERVICE);
//            batteryLevel = batteryManager.getIntProperty(
//                    BatteryManager.BATTERY_PROPERTY_CAPACITY
//            );
//        } else {
//            Intent intent = new ContextWrapper(getApplicationContext())
//                    .registerReceiver(null, new IntentFilter(Intent.ACTION_BATTERY_CHANGED));
//
//            batteryLevel = intent.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) * 100
//                    / intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1);
//        }
//
//        return batteryLevel;
//    }
}
