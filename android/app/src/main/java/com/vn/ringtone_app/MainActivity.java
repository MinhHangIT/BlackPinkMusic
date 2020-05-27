package com.vn.ringtone_app;

import android.Manifest;
import android.app.Activity;
import android.app.AlertDialog;
import android.content.ContentValues;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.media.RingtoneManager;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.provider.MediaStore;
import android.provider.Settings;
import android.util.Log;

import androidx.core.app.ActivityCompat;

import java.io.File;
import java.util.LinkedHashMap;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.*;

import static android.os.Environment.DIRECTORY_DOWNLOADS;

public class MainActivity extends FlutterActivity {

  private static final String CHANNEL = "ringtone_module";


  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);

    Boolean writeSg = isWriteStoragePermissionGranted();

    boolean settingsCanWrite = false;
    if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.M) {
      settingsCanWrite = Settings.System.canWrite(MainActivity.this);

      if(!settingsCanWrite) {
        // If do not have write settings permission then open the Can modify system settings panel.
        Intent intent = new Intent(Settings.ACTION_MANAGE_WRITE_SETTINGS);
        startActivity(intent);
      }else {
        // If has permission then show an alert dialog with message.

      }
    }


    new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(
            new MethodChannel.MethodCallHandler() {
              @Override
              public void onMethodCall(MethodCall call, MethodChannel.Result result) {
                if (call.method.equals("hasSettingsPermission")) {
                  boolean resultHasSettingsPermission = hasSettingsPermission();
                  result.success(resultHasSettingsPermission);
                } else if (call.method.equals("requestSettingsPermission")) {
                  requestSettingsPermission();
                  result.success(null);
                } else if (call.method.equals("setRingtone")) {
                  try {
                    setRingtone(call.argument("uri"), call.argument("title"));
                    result.success(true);
                  } catch (Exception e) {
                    result.success(false);
                  }
                } else if (call.method.equals("setNotification")) {
                  try {
                    setNotification(call.argument("uri"), call.argument("title"));
                    result.success(true);
                  } catch (Exception e) {
                    result.success(false);
                  }
                } else if (call.method.equals("setAlarm")) {
                  try {
                    setAlarm(call.argument("uri"), call.argument("title"));
                    result.success(true);
                  } catch (Exception e) {
                    result.success(false);
                  }
                } else if(call.method.equals("getExternalStorageDirectory")){
                    result.success(Environment.getExternalStorageDirectory().toString());
                } else if(call.method.equals("mediaScanFile")){
                  File f = new File(call.argument("uri").toString());
                  getApplicationContext().sendBroadcast(new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE, Uri.fromFile(f)));
                  result.success(true);
                } else {
                  result.notImplemented();
                }
              }
            });

//    Intent intent = new Intent(Settings.ACTION_MANAGE_WRITE_SETTINGS);
//    startActivity(intent);
  }

  public  boolean isWriteStoragePermissionGranted() {
    if (Build.VERSION.SDK_INT >= 23) {
      if (checkSelfPermission(android.Manifest.permission.WRITE_EXTERNAL_STORAGE)
              == PackageManager.PERMISSION_GRANTED) {
        return true;
      } else {

        ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.WRITE_EXTERNAL_STORAGE,}, 2);
        return false;
      }
    }
    else { //permission is automatically granted on sdk<23 upon installation
      return true;
    }
  }

  private boolean hasSettingsPermission() {
    boolean hasPermission = true;

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
      hasPermission = Settings.System.canWrite(getApplicationContext());
    }

    return hasPermission;
  }

  private void requestSettingsPermission() {
    Activity application = MainActivity.this;
    boolean checkPermistion = hasSettingsPermission();
    if (!checkPermistion) {
      Log.d("AAAAAA", "package:" + application.getPackageName());
      Intent intent = new Intent(Settings.ACTION_MANAGE_WRITE_SETTINGS)
              .setData(Uri.parse("package:" + application.getPackageName()))
              .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
      application.startActivityForResult(intent, 0);
    }
  }

  private void setRingtone(String uri, String title) {

    LinkedHashMap<String, Uri> listRingtone = RingtoneUtils.getRingTone(getApplicationContext());

    if (listRingtone.get(title) != null) {
      try {
        RingtoneManager.setActualDefaultRingtoneUri(getApplicationContext(), RingtoneManager.TYPE_RINGTONE, listRingtone.get(title));
      } catch (Throwable th) {
      }
    } else {
      File file = new File(uri);
      ContentValues contentValues = new ContentValues();
      contentValues.put(MediaStore.MediaColumns.DATA, file.getAbsolutePath());
      contentValues.put(MediaStore.MediaColumns.TITLE, title);
      contentValues.put(MediaStore.MediaColumns.MIME_TYPE, "audio/mp3");
      contentValues.put(MediaStore.MediaColumns.SIZE, Long.valueOf(file.length()));
      contentValues.put(MediaStore.Audio.Media.ARTIST, "NONE");
      contentValues.put(MediaStore.Audio.Media.IS_RINGTONE, true);
      contentValues.put(MediaStore.Audio.Media.IS_NOTIFICATION, false);
      contentValues.put(MediaStore.Audio.Media.IS_ALARM, false);
      contentValues.put(MediaStore.Audio.Media.IS_ALARM, false);
      try {
        Uri uri1 = MediaStore.Audio.Media.getContentUriForPath(file.getAbsolutePath());
        Uri uri2 = getApplicationContext().getContentResolver().insert(uri1, contentValues);

        RingtoneManager.setActualDefaultRingtoneUri(getApplicationContext(), RingtoneManager.TYPE_RINGTONE, uri2);

      } catch (Throwable th) {
      }
    }
  }

  private void setNotification(String uri, String title) {

    File f = new File(uri);
    getApplicationContext().sendBroadcast(new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE, Uri.fromFile(f)));

    LinkedHashMap<String, Uri> listRingtone = RingtoneUtils.getNotificationTones(getApplicationContext());

    if (listRingtone.get(title) != null) {
      try {
        RingtoneManager.setActualDefaultRingtoneUri(getApplicationContext(), RingtoneManager.TYPE_NOTIFICATION, listRingtone.get(title));
      } catch (Throwable th) {
      }
    } else {
      File file = new File(uri);
      ContentValues contentValues = new ContentValues();
      contentValues.put(MediaStore.MediaColumns.DATA, file.getAbsolutePath());
      contentValues.put(MediaStore.MediaColumns.TITLE, title);
      contentValues.put(MediaStore.MediaColumns.MIME_TYPE, "audio/*");
      contentValues.put(MediaStore.MediaColumns.SIZE, Long.valueOf(file.length()));
      contentValues.put(MediaStore.Audio.Media.ARTIST, "NONE");
      contentValues.put(MediaStore.Audio.Media.IS_RINGTONE, false);
      contentValues.put(MediaStore.Audio.Media.IS_NOTIFICATION, true);
      contentValues.put(MediaStore.Audio.Media.IS_ALARM, false);
      contentValues.put(MediaStore.Audio.Media.IS_ALARM, false);
      try {
        Uri uri1 = MediaStore.Audio.Media.getContentUriForPath(file.getAbsolutePath());
        Uri uri2 = getApplicationContext().getContentResolver().insert(uri1, contentValues);

        RingtoneManager.setActualDefaultRingtoneUri(getApplicationContext(), RingtoneManager.TYPE_NOTIFICATION, uri2);

      } catch (Throwable th) {
      }
    }
  }

  private void setAlarm(String uri, String title) {

    File f = new File(uri);
    getApplicationContext().sendBroadcast(new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE, Uri.fromFile(f)));

    LinkedHashMap<String, Uri> listRingtone = RingtoneUtils.getAlarmTones(getApplicationContext());

    if (listRingtone.get(title) != null) {
      try {
        RingtoneManager.setActualDefaultRingtoneUri(getApplicationContext(), RingtoneManager.TYPE_ALARM, listRingtone.get(title));
      } catch (Throwable th) {
      }
    } else {
      File file = new File(uri);
      ContentValues contentValues = new ContentValues();
      contentValues.put(MediaStore.MediaColumns.DATA, file.getAbsolutePath());
      contentValues.put(MediaStore.MediaColumns.TITLE, title);
      contentValues.put(MediaStore.MediaColumns.MIME_TYPE, "audio/mp3");
      contentValues.put(MediaStore.MediaColumns.SIZE, Long.valueOf(file.length()));
      contentValues.put(MediaStore.Audio.Media.ARTIST, "NONE");
      contentValues.put(MediaStore.Audio.Media.IS_RINGTONE, false);
      contentValues.put(MediaStore.Audio.Media.IS_NOTIFICATION, false);
      contentValues.put(MediaStore.Audio.Media.IS_ALARM, true);
      contentValues.put(MediaStore.Audio.Media.IS_ALARM, false);
      try {
        Uri uri1 = MediaStore.Audio.Media.getContentUriForPath(file.getAbsolutePath());
        sendBroadcast (
                new Intent(Intent.ACTION_MEDIA_MOUNTED,
                        Uri.fromFile(file))
        );
        getContentResolver().delete(
                uri1,
                MediaStore.MediaColumns.DATA + "=\""
                        + file.getAbsolutePath() + "\"", null);
        Uri uri2 = getApplicationContext().getContentResolver().insert(uri1, contentValues);

        RingtoneManager.setActualDefaultRingtoneUri(getApplicationContext(), RingtoneManager.TYPE_ALARM, uri2);

      } catch (Throwable th) {
      }
    }
  }
}
