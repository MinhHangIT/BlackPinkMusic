import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';
import 'package:ringtone_app/blocs/global.dart';
import 'package:ringtone_app/common/music_icons.dart';
import 'package:ringtone_app/model/playerstate.dart';
import 'package:provider/provider.dart';

class Ringtone_Tile extends StatelessWidget {
  final Song _song;
  String _artists;
  String _duration;
  Ringtone_Tile({Key key, @required Song song})
      : _song = song,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final GlobalBloc _globalBloc = Provider.of<GlobalBloc>(context);
    parseArtists();
    parseDuration();
    return StreamBuilder<MapEntry<PlayerState, Song>>(
        stream: _globalBloc.musicPlayerBloc.playerState$,
        builder: (BuildContext context, AsyncSnapshot<MapEntry<PlayerState, Song>> snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }

          final PlayerState _state = snapshot.data.key;
          final Song _currentSong = snapshot.data.value;
          final bool _isSelectedSong = _song == _currentSong;
          return AnimatedContainer(
            duration: Duration(milliseconds: 250),
            //height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: _isSelectedSong
                  ? LinearGradient(
                colors: [
                  Color(0xFFFD9D9D).withOpacity(0.7),
                  Colors.white,
                ],
              )
                  : null,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Divider(
                    color: Colors.transparent,
                    height: 5,
                  ),
                  Row(
                    children: <Widget>[
                      Flexible(
                        flex: 2,
                        child: Container(
                         // color: Colors.deepOrange,
                          width: double.infinity,
                          alignment: Alignment.centerLeft,
                          child: AnimatedCrossFade(
                            duration: Duration(
                              milliseconds: 150,
                            ),
                            firstChild: PauseIcon(
                              color: Colors.black,
                            ),
                            secondChild: PlayIcon(
                              color: Colors.black,
                            ),
                            crossFadeState: _isSelectedSong && _state == PlayerState.playing ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 8,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Container(
                           // color: Colors.red,
                            width: double.infinity,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  _song.title,
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Divider(
                                  height: 10,
                                  color: Colors.transparent,
                                ),
                                Text(
                                  _artists.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                    letterSpacing: 1,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 2,
                        child: Container(
                          //color: Colors.blue,
                          width: double.infinity,
                          alignment: Alignment.centerRight,
                          child: Text(
                            _duration,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                  _isSelectedSong
                      ? Container(
                    height: 30,
                    child: Row(
                        children: <Widget>[
                          Flexible(
                            flex: 3,
                            child: Container(
                              //color: Colors.yellow,
                              width: double.infinity,
                            ),
                          ),
                          Flexible(
                            flex: 18,
                            child: StreamBuilder<Duration>(
                              stream: _globalBloc.musicPlayerBloc.position$,
                              builder: (BuildContext context, AsyncSnapshot<Duration> snapshot) {
                                if (!snapshot.hasData) {
                                  return Slider(
                                    value: 0,
                                    onChanged: (double value) => null,
                                    activeColor: Colors.transparent,
                                    inactiveColor: Colors.transparent,
                                  );
                                }
                                final Duration _currentDuration = snapshot.data;
                                final int _millseconds = _currentDuration.inMilliseconds;
                                final int _songDurationInMilliseconds = _currentSong.duration;
                                return Slider(
                                  min: 0,
                                  max: _songDurationInMilliseconds.toDouble(),
                                  value: _songDurationInMilliseconds > _millseconds ? _millseconds.toDouble() : _songDurationInMilliseconds.toDouble(),
                                  onChangeStart: (double value) => _globalBloc.musicPlayerBloc.invertSeekingState(),
                                  onChanged: (double value) {
                                    final Duration _duration = Duration(
                                      milliseconds: value.toInt(),
                                    );
                                    _globalBloc.musicPlayerBloc.updatePosition(_duration);
                                  },
                                  onChangeEnd: (double value) {
                                    _globalBloc.musicPlayerBloc.invertSeekingState();
                                    _globalBloc.musicPlayerBloc.audioSeek(value / 1000);
                                  },
                                  activeColor: Colors.blue,
                                  inactiveColor: Color(0xFFCEE3EE),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                  )
                      : Container(//color: Colors.blueAccent,
                     ),

                ],
              ),
            ),
          );
        });
  }

  void parseDuration() {
    final double _temp = _song.duration / 1000;
    final int _minutes = (_temp / 60).floor();
    final int _seconds = (((_temp / 60) - _minutes) * 60).round();
    if (_seconds.toString().length != 1) {
      _duration = _minutes.toString() + ":" + _seconds.toString();
    } else {
      _duration = _minutes.toString() + ":0" + _seconds.toString();
    }
  }

  void parseArtists() {
    _artists = _song.artist.split(";").reduce((String a, String b) {
      return a + " & " + b;
    });
  }
}
