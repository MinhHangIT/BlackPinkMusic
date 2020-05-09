import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ringtone_app/utils/directory_modul.dart';
import 'package:ringtone_app/constant/app_constant.dart';

class DownloadModule {

  static Future<String> downloadFileAudio(String uri, String name, Function onProgress) async {
    Dio dio = Dio();

    try {
      String dirPath = await createAppFolder();

      if (dirPath != null) {
        dirPath = "${dirPath}/${name}.${getExt(uri)}";
        await dio.download(uri, dirPath, onReceiveProgress: onProgress);
        return dirPath;
      } else {
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  static CancelToken token = new CancelToken();

  static Future<String> downloadFile(
      String uri, String name, Function onProgress) async {
    Dio dio = Dio();
    token = new CancelToken();

    try {
      String dirPath = await createAppFolder();

      if (dirPath != null) {
        dirPath = "${dirPath}/${name}.${getExt(uri)}";
        await dio.download(uri, dirPath,
            onReceiveProgress: onProgress, cancelToken: token);
        return dirPath;
      } else {
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }
  static Future<String> createAppFolder() async {
    try {
      String dir = await DirectoryModule.getExternalStorageDirectory();
      final myDir = new Directory('${dir}/${FOLDER_NAME}');
      bool isThere = await myDir.exists();
      if (isThere) {
        return myDir.path;
      } else {
        myDir.create(recursive: true);
        return myDir.path;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }
  static void cancelDownload() {
    token.cancel("cancelled");
  }

  static String getExt(String path) {
    var ext = path.split(".").last;
    if (ext.length > 3) ext = 'mp3';
    return ext;
  }
}
