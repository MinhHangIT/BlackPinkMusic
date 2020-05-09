import 'dart:async';
import 'package:flutter/services.dart';

enum RingtoneFunc { ringtone, notification, alarm, download }

class RingtoneModule {
  static const platform = const MethodChannel('ringtone_module');

  static Future<bool> hasSettingsPermission() async {
    try {
      final bool result = await platform.invokeMethod('hasSettingsPermission');
      return result;
    } on PlatformException catch (e) {
      print(e);
      throw e;
    }
  }

  static Future<void> requestSettingsPermission() async {
    try {
      await platform.invokeMethod('requestSettingsPermission');
    } on PlatformException catch (e) {
      print(e);
      throw e;
    }
  }

  static Future<bool> setRingtone(String uri, String title) async {
    try {
      final bool result = await platform.invokeMethod('setRingtone', {"uri": uri, "title": title});
      if (result == null) {
        return false;
      }
      return result;
    } on PlatformException catch (e) {
      print(e);
      return false;
    }
  }

  static Future<bool> setNotification(String uri, String title) async {
    try {
      final bool result = await platform.invokeMethod('setNotification', {"uri": uri, "title": title});
      if (result == null) {
        return false;
      }
      return result;
    } on PlatformException catch (e) {
      print(e);
      return false;
    }
  }

  static Future<bool> setAlarm(String uri, String title) async {
    try {
      final bool result = await platform.invokeMethod('setAlarm', {"uri": uri, "title": title});
      if (result == null) {
        return false;
      }
      return result;
    } on PlatformException catch (e) {
      print(e);
      return false;
    }
  }
}
