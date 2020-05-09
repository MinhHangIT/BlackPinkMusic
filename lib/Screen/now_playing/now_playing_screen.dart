//import 'package:firebase_admob/firebase_admob.dart';
import 'dart:async';

import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:ringtone_app/Screen/DownloadSong/DownloadSong.dart';
import 'package:ringtone_app/blocs/global.dart';
import 'package:ringtone_app/model/SongLyric.dart';
import 'package:ringtone_app/model/playerstate.dart';
import 'package:ringtone_app/Screen/now_playing/album_art_container.dart';
import 'package:ringtone_app/Screen/now_playing/empty_album_art.dart';
import 'package:ringtone_app/Screen/now_playing/music_board_controls.dart';
import 'package:ringtone_app/Screen/now_playing/now_playing_slider.dart';
import 'package:ringtone_app/Screen/now_playing/preferences_board.dart';
import 'package:ringtone_app/store/AppStore.dart';
import 'package:ringtone_app/utils/directory_modul.dart';
import 'package:ringtone_app/utils/download_modul.dart';
import 'package:ringtone_app/utils/permistion_modul.dart';
import 'package:ringtone_app/utils/ringtone_modul.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:rxdart/rxdart.dart';


class NowPlayingScreen extends StatefulWidget {

  final PanelController controller;

  NowPlayingScreen({this.controller});


  _NowPlayingScreenState createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen> {
  String textDownload;
  bool isDownloading = false;
  Timer timer;


//  InterstitialAd _interstitialAd;

  @override
  void dispose() {
//    _interstitialAd?.dispose();
    timer?.cancel();
    super.dispose();
  }

  void _handleSetRingtone(RingtoneFunc func, Song song, GlobalBloc _globalBloc) async {
    setState(() {
      isDownloading = true;
    });
    bool permistionStorage = await PermistionModule.checkPermistionStogare();
    if (permistionStorage) {
      bool settingPermistion = await RingtoneModule.hasSettingsPermission();
      if (!settingPermistion) {
        await RingtoneModule.requestSettingsPermission();
      } else {
        setState(() {
          textDownload = 'Downloading... 1%';
        });
        var path = await DownloadModule.downloadFileAudio(song.uri, song.title, (rec, total) {
          String abc = ((rec / total) * 100).toStringAsFixed(0) + "%";
          setState(() {
            textDownload = 'Downloading... ${abc}';
          });
        });
        setState(() {
          textDownload = null;
        });
        switch (func) {
          case RingtoneFunc.ringtone:
            {
              bool setRingtone = await RingtoneModule.setRingtone(path, song.title);
              if (setRingtone) {
                  _showDialog("Set Ringtones", "Success");
              } else {
                _showDialog("Set Ringtones", "Failt");
              }
              break;
            }
          case RingtoneFunc.notification:
            {
              bool setRingtone = await RingtoneModule.setNotification(path, song.title);
              if (setRingtone) {
                  _showDialog("Set Notification", "Success");
              } else {
                _showDialog("Set Notification", "Failt");
              }
              break;
            }
          case RingtoneFunc.alarm:
            {
              bool setRingtone = await RingtoneModule.setAlarm(path, song.title);
              if (setRingtone) {
                  _showDialog("Set Alarm", "Success");
              } else {
                _showDialog("Set Alarm", "Failt");
              }
              break;
            }
          case RingtoneFunc.download:
            {
                _showDialog("Download", "Save success on path ${path}");
                await DirectoryModule.mediaScanFile(path);
                timer = Timer(Duration(seconds: 1), () async {
                  await _globalBloc.musicPlayerBloc
                      .fetchLocalSongs()
                      .then((_) {
                    setState(() {
                      textDownload = 'Download Success';
                    });
                  });
                });
              break;
            }
        }
      }
    } else {
      _showDialog("Alert", "No permistion Storage");
    }
    setState(() {
      isDownloading = false;
    });
  }

  void _showDialog(String title, String body) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(
            title,
            style: TextStyle(
              fontFamily: "PlayfairDisplay",
            ),
          ),
          content: new Text(body,
              style: TextStyle(
                fontFamily: "PlayfairDisplay",
              )),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close",
                  style: TextStyle(
                    fontFamily: "PlayfairDisplay",
                  )),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final GlobalBloc _globalBloc = Provider.of<GlobalBloc>(context);
    final double _radius = 20.0;
    final double _screenHeight = MediaQuery.of(context).size.height;
    final double _albumArtSize = _screenHeight / 2;
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            width: double.infinity,
            height: _albumArtSize + 50,
            child: Stack(
              children: <Widget>[
                StreamBuilder<MapEntry<PlayerState, Song>>(
                  stream: _globalBloc.musicPlayerBloc.playerState$ ,
                  builder: (BuildContext context, AsyncSnapshot<MapEntry<PlayerState, Song>> snapshot) {

                    if (!snapshot.hasData || snapshot.data.value.albumArt == null) {
                      return EmptyAlbumArtContainer(
                        radius: _radius,
                        albumArtSize: _albumArtSize,
                        iconSize: _albumArtSize / 2,
                      );
                    }

                    final Song _currentSong = snapshot.data.value;
                    return AlbumArtContainer(
                      radius: _radius,
                      albumArtSize: _albumArtSize,
                      currentSong: _currentSong,
                    );
                  },

                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: MusicBoardControls(),
                ),
              ],
            ),
          ),
//          Divider(
//            color: Colors.transparent,
//            height: _screenHeight / 30,
//          ),

          StreamBuilder<MapEntry<PlayerState, Song>>(
          stream:  _globalBloc.musicPlayerBloc.playerState$ ,
          builder: (BuildContext context, AsyncSnapshot<MapEntry<PlayerState, Song>> snapshot) {
            return Container(
             // height: 50,
              width: double.infinity,
              alignment: Alignment.bottomCenter,
              color: Colors.transparent,
              child: Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: <Widget>[
                PreferencesBoard(),
                snapshot.data.value.type == "ringtone" ?
                (
                    StreamBuilder<MapEntry<PlayerState, Song>>(
                        stream:  _globalBloc.musicPlayerBloc.playerState$ ,
                        builder: (BuildContext context, AsyncSnapshot<MapEntry<PlayerState, Song>> snapshot) {
                          return Container(
                            height: 50,
                            width: double.infinity,
                            alignment: Alignment.bottomCenter,
                            color: Colors.transparent,
                            child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: <Widget>[
                              snapshot.data.value.type == "ringtone" ?
                              GestureDetector(
                                onTap: () {
                                  if (!isDownloading && snapshot.hasData && snapshot.data.value.uri != null) {
                                    _handleSetRingtone(RingtoneFunc.ringtone, snapshot.data.value, _globalBloc);
                                  }
                                },
                                child: Container(
                                  width: 50,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20.0),
                                    gradient: LinearGradient(
                                      colors: <Color>[
                                        isDownloading ? Color(0xFFC7D2E3) : Color.fromRGBO(233, 96, 182, 1),
                                        isDownloading ? Color(0xFFC7D2E3) : Color.fromRGBO(151, 110, 246, 1),
                                      ],
                                    ),
                                  ),
                                  child: Icon(Icons.ring_volume, color: Colors.white,size: 20,),
                                ),
                              ): Icon(Icons.ring_volume, color: Color(0xFFC7D2E3),size: 20) ,
                              snapshot.data.value.type == "ringtone"  ?
                              GestureDetector(
                                onTap: () {
                                  if (!isDownloading && snapshot.hasData && snapshot.data.value.uri != null) {
                                    _handleSetRingtone(RingtoneFunc.notification, snapshot.data.value, _globalBloc);
                                  }
                                },
                                child: Container(
                                  width: 50,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20.0),
                                    gradient: LinearGradient(
                                      colors: <Color>[
                                        isDownloading ? Color(0xFFC7D2E3) : Color.fromRGBO(233, 96, 182, 1),
                                        isDownloading ? Color(0xFFC7D2E3) : Color.fromRGBO(151, 110, 246, 1),
                                      ],
                                    ),
                                  ),
                                  child: Icon(Icons.notifications, color: Colors.white,size: 20),
                                ),
                              ): Icon(Icons.notifications, color: Color(0xFFC7D2E3),size: 20),
                              snapshot.data.value.type == "ringtone" ?
                              GestureDetector(
                                onTap: () {
                                  if (!isDownloading && snapshot.hasData && snapshot.data.value.uri != null) {
                                    _handleSetRingtone(RingtoneFunc.alarm, snapshot.data.value, _globalBloc);
                                  }
                                },
                                child: Container(
                                  width: 50,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20.0),
                                    gradient: LinearGradient(
                                      colors: <Color>[
                                        isDownloading ? Color(0xFFC7D2E3) : Color.fromRGBO(233, 96, 182, 1),
                                        isDownloading ? Color(0xFFC7D2E3) : Color.fromRGBO(151, 110, 246, 1),
                                      ],
                                    ),
                                  ),
                                  child: Icon(Icons.alarm, color: Colors.white,size: 20),
                                ),
                              ) :Icon(Icons.alarm, color: Color(0xFFC7D2E3),size: 20) ,
                              snapshot.data.value.type == "songOnline" || snapshot.data.value.type == "ringtone" ?
                              GestureDetector(
                                onTap: () {
                                  if (!isDownloading && snapshot.hasData && snapshot.data.value.uri != null) {
                                    _handleSetRingtone(RingtoneFunc.download, snapshot.data.value, _globalBloc);
                                  }
                                },
                                child: Container(
                                  width: 50,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20.0),
                                    gradient: LinearGradient(
                                      colors: <Color>[
                                        isDownloading ? Color(0xFFC7D2E3) : Color.fromRGBO(233, 96, 182, 1),
                                        isDownloading ? Color(0xFFC7D2E3) : Color.fromRGBO(151, 110, 246, 1),
                                      ],
                                    ),
                                  ),
                                  child: Icon(Icons.file_download, color: Colors.white,size: 20),
                                ),
                              ):Icon(Icons.file_download, color: Color(0xFFC7D2E3),size: 20),
                            ]),
                          );
                        })
                ):
                Container(),

               ]
              )
            );
          }
          ),

          Divider(
            color: Colors.transparent,
            height: _screenHeight / 40,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Flexible(
                  flex: 12,
                  child: Container(
                    child: StreamBuilder<MapEntry<PlayerState, Song>>(
                      stream: _globalBloc.musicPlayerBloc.playerState$,
                      builder: (BuildContext context, AsyncSnapshot<MapEntry<PlayerState, Song>> snapshot) {
                        if (!snapshot.hasData) {
                          return Container();
                        }
                        if (snapshot.data.key == PlayerState.stopped) {
                          return Container();
                        }
                        final Song _currentSong = snapshot.data.value;

                        final String _artists = _currentSong.artist.split(";").reduce((String a, String b) {
                          return a + " & " + b;
                        });
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              textDownload != null ? textDownload : _currentSong.album.toUpperCase() + " • " + _artists.toUpperCase(),
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFFADB9CD),
                                letterSpacing: 1,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Divider(
                              height: 5,
                              color: Colors.transparent,
                            ),
                            Text(
                              _currentSong.title,
                              style: TextStyle(
                                fontSize: 22,
                                color: Color(0xFF4D6B9C),
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
//                Flexible(
//                  flex: 2,
//                  child: GestureDetector(
//                    onTap: () => widget.controller.close(),
//                    child: HideIcon(
//                      color: Color(0xFF90A4D4),
//                    ),
//                  ),
//                )
              ],
            ),
          ),
          Divider(
            color: Colors.transparent,
            height: _screenHeight / 50,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: StreamBuilder<MapEntry<PlayerState, Song>>(
                        stream:  _globalBloc.musicPlayerBloc.playerState$ ,
                        builder: (BuildContext context, AsyncSnapshot<MapEntry<PlayerState, Song>> snapshot) {
                          if (!snapshot.hasData) {
                            return Text(
                              "0:00",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFADB9CD),
                                letterSpacing: 1,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            );
                          }
                          final Song _currentSong = snapshot.data.value;
                          final PlayerState _state = snapshot.data.key;
                          if (_state == PlayerState.stopped) {
                            return Text(
                              "0:00",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFADB9CD),
                                letterSpacing: 1,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            );
                          }
                          return Text(
                            getDuration(_currentSong),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFADB9CD),
                              letterSpacing: 1,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          );
                        }),
                  ),
                ),
                NowPlayingSlider(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String getDuration(Song _song) {
    final double _temp = _song.duration / 1000;
    final int _minutes = (_temp / 60).floor();
    final int _seconds = (((_temp / 60) - _minutes) * 60).round();
    if (_seconds.toString().length != 1) {
      return _minutes.toString() + ":" + _seconds.toString();
    } else {
      return _minutes.toString() + ":0" + _seconds.toString();
    }
  }
}
