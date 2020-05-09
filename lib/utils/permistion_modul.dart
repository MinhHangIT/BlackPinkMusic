import 'package:permission_handler/permission_handler.dart';

class PermistionModule {
  static Future<bool> checkPermistionStogare() async {
    PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage);

    if (permission == PermissionStatus.granted) {
      return true;
    } else if (permission == PermissionStatus.disabled) {
      return false;
    } else {
      Map<PermissionGroup, PermissionStatus> permissions =
      await PermissionHandler()
          .requestPermissions([PermissionGroup.storage]);

      if (permissions[PermissionGroup.storage] == PermissionStatus.granted) {
        return true;
      } else {
        return false;
      }
    }
  }

  static Future<bool> openAppSettings() async {
    return await PermissionHandler().openAppSettings();
  }
}
