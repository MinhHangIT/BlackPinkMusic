import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ringtone_app/blocs/global.dart';
import 'package:ringtone_app/model/SongLyric.dart';
import 'package:ringtone_app/utils/download_modul.dart';
import 'package:ringtone_app/utils/directory_modul.dart';

class DownloadSongScreen extends StatefulWidget {
  SongLyric mySong;
  DownloadSongScreen(this.mySong);

  _DownloadSongScreenState createState() => _DownloadSongScreenState();
}

class _DownloadSongScreenState extends State<DownloadSongScreen> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          title: Text(
            'Download Songs',
            style: TextStyle(
              color: Color(0xFF274D85),
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          leading: IconButton(
            onPressed: (){
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Color(0xFF274D85),
            ),

          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(10.0),
                child: Center(
                  child: Text(
                    widget.mySong.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    ),
                  ),
                ),
              ),
              DownloadItem(widget.mySong),
            ],
          ),
        ),
      );
  }
}

class DownloadItem extends StatefulWidget {
  SongLyric mySong;
  DownloadItem(this.mySong);

  _DownloadItemState createState() => _DownloadItemState();
}

class _DownloadItemState extends State<DownloadItem> {
  Downloads download;
  String textButton = 'DOWNLOAD';
  String textDownload = '';
  Timer timer;

  @override
  void initState() {
    super.initState();
    setState(() {
      download = widget.mySong.downloads[0];
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final GlobalBloc _globalBloc = Provider.of<GlobalBloc>(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          height: 100,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 20.0, top: 5.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      download.type,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(height: 5.0),
                    Text(
                      'Size: ' + download.size,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    )
                  ],
                ),
              ),
              Container(
                width: 100,
                height: 100,
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_drop_down_circle,
                    size: 50,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    containerForSheet<Downloads>(
                      context: context,
                      child: CupertinoActionSheet(
                        title: const Text('Choose download quality?'),
                        message: const Text('Your options are '),
                        actions: widget.mySong.downloads.map((o) {
                          return CupertinoActionSheetAction(
                            child: Text(o.type + ' - ' + o.size,style: TextStyle(color: Colors.white),),
                            onPressed: () {
                              Navigator.pop(context, o);
                            },
                          );
                        }).toList(),
                        cancelButton: CupertinoActionSheetAction(
                          child: const Text('Cancel'),
                          isDefaultAction: true,
                          onPressed: () {
                            Navigator.pop(context, null);
                          },
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ),
        Container(
          width: double.infinity,
          height: 50,
          child: textDownload == ''
              ? Container()
              : Center(child: Text('Download progress: ' + textDownload)),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Container(
            child: GestureDetector(
              onTap: () async {
                switch (textButton) {
                  case 'DOWNLOAD':
                    setState(() {
                      textButton = 'DOWNLOADING';
                      textDownload = 'Check file download';
                    });
                    String fileUri = await DownloadModule.downloadFile(
                        download.url,
                        widget.mySong.key +
                            '_' +
                            download.type.replaceAll(' ', ''),
                            (received, total) {
                          if (total != -1) {
                            setState(() {
                              String percent =
                                  (received / total * 100).toStringAsFixed(0) + "%";
                              textDownload = '$received/$total ($percent)';
                            });
                          }
                        });
                    if (fileUri == null) {
                      setState(() {
                        textButton = 'DOWNLOAD';
                        textDownload = 'Download Failt';
                      });
                      return;
                    }
                    await DirectoryModule.mediaScanFile(fileUri);
                    timer = Timer(Duration(seconds: 1), () async {
                      await _globalBloc.musicPlayerBloc
                          .fetchLocalSongs()
                          .then((_) {
                        setState(() {
                          textButton = 'DOWNLOAD';
                          textDownload = 'Download Success';
                        });
                      });
                    });
                    break;
                  case 'DOWNLOADING':
                    DownloadModule.cancelDownload();
                    timer = Timer(Duration(microseconds: 100), () async {
                      setState(() {
                        textButton = 'DOWNLOAD';
                        textDownload = 'Canceled';
                      });
                    });
                }
              },
              child: Container(
                width: 200,
                height: 60,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30.0),
                  gradient: LinearGradient(
                    colors: <Color>[
                      Color.fromRGBO(157, 201, 231, 1.0),
                      Color.fromRGBO(251, 172, 195, 1.0),
                    ],
                  ),
                ),
                child: Text(
                  textButton,
                  style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void containerForSheet<T>({BuildContext context, Widget child}) {
    showCupertinoModalPopup<Downloads>(
      context: context,
      builder: (BuildContext context) => child,
    ).then<void>((Downloads value) {
      if (value != null) {
        setState(() {
          download = value;
        });
      }
    });
  }
}
