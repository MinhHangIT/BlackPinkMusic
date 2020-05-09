
import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';

class DirectoryModule {
  static const platform = const MethodChannel('ringtone_module');

  static Future<bool> intentApp(String package) async {
    try {
      final bool result =
      await platform.invokeMethod('intentApp', {"package": package});
      return result;
    } on PlatformException catch (e) {
      print(e);
      throw e;
    }
  }

  static Future<bool> mediaScanFile(String uri) async {
    try {
      final bool result =
      await platform.invokeMethod('mediaScanFile', {"uri": uri});
      return result;
    } on PlatformException catch (e) {
      print(e);
      throw e;
    }
  }

  static Future<bool> deleteFile(String uri) async {
    try {
      File f = new File.fromUri(Uri.file(uri));
      await f.delete();
      await mediaScanFile(uri);
      return true;
    } on PlatformException catch (e) {
      print(e);
      throw e;
    }
  }

  static Future<String> getExternalStorageDirectory() async {
    try {
      final String result =
      await platform.invokeMethod('getExternalStorageDirectory');
      return result;
    } on PlatformException catch (e) {
      print(e);
      return '/storage/emulated/0';
    }
  }

  static Future<String> getExternalStoragePublicDirectoryAlarms() async {
    try {
      final String result = await platform
          .invokeMethod('getExternalStoragePublicDirectoryAlarms');
      return result;
    } on PlatformException catch (e) {
      print(e);
      throw e;
    }
  }

  static Future<String> getExternalStoragePublicDirectoryDownload() async {
    try {
      final String result = await platform
          .invokeMethod('getExternalStoragePublicDirectoryDownload');
      return result;
    } on PlatformException catch (e) {
      print(e);
      throw e;
    }
  }

  static Future<String> getExternalStoragePublicDirectoryDCIM() async {
    try {
      final String result =
      await platform.invokeMethod('getExternalStoragePublicDirectoryDCIM');
      return result;
    } on PlatformException catch (e) {
      print(e);
      throw e;
    }
  }

  static Future<String> getExternalStoragePublicDirectoryMovies() async {
    try {
      final String result = await platform
          .invokeMethod('getExternalStoragePublicDirectoryMovies');
      return result;
    } on PlatformException catch (e) {
      print(e);
      throw e;
    }
  }

  static Future<String> getExternalStoragePublicDirectoryMusic() async {
    try {
      final String result =
      await platform.invokeMethod('getExternalStoragePublicDirectoryMusic');
      return result;
    } on PlatformException catch (e) {
      print(e);
      throw e;
    }
  }

  static Future<String> getExternalStoragePublicDirectoryNotifications() async {
    try {
      final String result = await platform
          .invokeMethod('getExternalStoragePublicDirectoryNotifications');
      return result;
    } on PlatformException catch (e) {
      print(e);
      throw e;
    }
  }

  static Future<String> getExternalStoragePublicDirectoryPictures() async {
    try {
      final String result = await platform
          .invokeMethod('getExternalStoragePublicDirectoryPictures');
      return result;
    } on PlatformException catch (e) {
      print(e);
      throw e;
    }
  }

  static Future<String> getExternalStoragePublicDirectoryPodcasts() async {
    try {
      final String result = await platform
          .invokeMethod('getExternalStoragePublicDirectoryPodcasts');
      return result;
    } on PlatformException catch (e) {
      print(e);
      throw e;
    }
  }

  static Future<String> getExternalStoragePublicDirectoryRingtones() async {
    try {
      final String result = await platform
          .invokeMethod('getExternalStoragePublicDirectoryRingtones');
      return result;
    } on PlatformException catch (e) {
      print(e);
      throw e;
    }
  }
}
