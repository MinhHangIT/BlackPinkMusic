import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';
import 'package:ringtone_app/Screen/Offline/Song_Title.dart';
import 'package:ringtone_app/blocs/global.dart';
import 'package:ringtone_app/model/Album.dart';
import 'package:ringtone_app/model/AlbumLocal.dart';
import 'package:ringtone_app/model/playerstate.dart';
import 'package:ringtone_app/Screen/Offline/Ringtone_Title.dart';
import 'package:provider/provider.dart';

class SpecificAlbumLocalScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AlbumLocal _album = Provider.of<AlbumLocal>(context);
    final GlobalBloc _globalBloc = Provider.of<GlobalBloc>(context);

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
          body: Stack(
            children: <Widget>[

              StreamBuilder<List<Song>>(
                stream: _globalBloc.musicPlayerBloc.localSongs$,
                builder: (BuildContext context, AsyncSnapshot<List<Song>> snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  final List<Song> _allSongs = snapshot.data;
                  List<Song> _albumSongs = [];
                  for (var song in _allSongs) {
                    if (song.albumId == _album.id) {
                      _albumSongs.add(song);
                    }
                  }

                  return ListView.builder(
                    key: UniqueKey(),
                    padding: const EdgeInsets.only(bottom: 16.0, top: 60.0),
                    physics: BouncingScrollPhysics(),
                    itemCount: _albumSongs.length,
                    itemExtent: 100,
                    itemBuilder: (BuildContext context, int index) {
                      return StreamBuilder<MapEntry<PlayerState, Song>>(
                        stream: _globalBloc.musicPlayerBloc.playerState$,
                        builder: (BuildContext context,
                            AsyncSnapshot<MapEntry<PlayerState, Song>> snapshot) {
                          if (!snapshot.hasData) {
                            return Container();
                          }
                          final PlayerState _state = snapshot.data.key;
                          final Song _currentSong = snapshot.data.value;
                          final bool _isSelectedSong =
                              _currentSong == _albumSongs[index];
                          return GestureDetector(
                            onTap: () {
                              _globalBloc.musicPlayerBloc.updatePlaylist(_albumSongs);
                              switch (_state) {
                                case PlayerState.playing:
                                  if (_isSelectedSong) {
                                    _globalBloc.musicPlayerBloc
                                        .pauseMusic(_currentSong);
                                  } else {
                                    _globalBloc.musicPlayerBloc.stopMusic();
                                    _globalBloc.musicPlayerBloc.playMusic(
                                      _albumSongs[index],
                                    );
                                  }
                                  break;
                                case PlayerState.paused:
                                  if (_isSelectedSong) {
                                    _globalBloc.musicPlayerBloc
                                        .playMusic(_albumSongs[index]);
                                  } else {
                                    _globalBloc.musicPlayerBloc.stopMusic();
                                    _globalBloc.musicPlayerBloc.playMusic(
                                      _albumSongs[index],
                                    );
                                  }
                                  break;
                                case PlayerState.stopped:
                                  _globalBloc.musicPlayerBloc
                                      .playMusic(_albumSongs[index]);
                                  break;
                                default:
                                  break;
                              }
                            },
                            child: Song_Tile(
                              song: _albumSongs[index],
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
              Container(
                width:width ,
                height: 70.0,
                decoration: new BoxDecoration(
                  gradient: new LinearGradient(
                      colors: [Color(0xffFD9D9D), Color(0xffc4c4c4)],
                      begin: const FractionalOffset(0.0, 0.0),
                      end: const FractionalOffset(0.8, 0.0),
                      stops: [0.0, 1.0],
                      tileMode: TileMode.clamp
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: width*2/7,
                      alignment: Alignment.center,
                      padding: EdgeInsets.only(right:20.0),
                      child:  GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(Icons.arrow_back, color: Colors.white, size: 35,),
                      ),),
                    Text( _album.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),)
                  ],
                ),
              ),
            ],
          )
      ),
    );
  }
}
