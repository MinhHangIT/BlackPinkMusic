import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ringtone_app/blocs/global.dart';
import 'package:flute_music_player/flute_music_player.dart';
import 'package:ringtone_app/common/empty_screen.dart';
import 'package:ringtone_app/model/playerstate.dart';
import 'package:ringtone_app/Screen/Offline/Ringtone_Title.dart';


class FavoriteScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return FavoriteScreenState();
  }
}

class FavoriteScreenState extends State<FavoriteScreen> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    GlobalBloc _globalBloc = Provider.of<GlobalBloc>(context);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/bg.jpg"),
              fit: BoxFit.cover,
            )
        ),
        child: StreamBuilder<List<Song>>(
          stream: _globalBloc.musicPlayerBloc.favorites$,
          builder: (BuildContext context, AsyncSnapshot<List<Song>> snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            final List<Song> _songs = snapshot.data;
            if (_songs.length == 0) {
              return EmptyScreen(
                text: "You do not have any songs as your favorites.",
              );
            }
            return ListView.builder(
              key: PageStorageKey<String>("Favorites"),
              padding: const EdgeInsets.only(bottom: 150.0),
              physics: BouncingScrollPhysics(),
              itemCount: _songs.length,
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
                    final bool _isSelectedSong = _currentSong == _songs[index];
                    return GestureDetector(
                      onTap: () {
                        _globalBloc.musicPlayerBloc.updatePlaylist(_songs);
                        switch (_state) {
                          case PlayerState.playing:
                            if (_isSelectedSong) {
                              _globalBloc.musicPlayerBloc
                                  .pauseMusic(_currentSong);
                            } else {
                              _globalBloc.musicPlayerBloc.stopMusic();
                              _globalBloc.musicPlayerBloc.playMusic(
                                _songs[index],
                              );
                            }
                            break;
                          case PlayerState.paused:
                            if (_isSelectedSong) {
                              _globalBloc.musicPlayerBloc
                                  .playMusic(_songs[index]);
                            } else {
                              _globalBloc.musicPlayerBloc.stopMusic();
                              _globalBloc.musicPlayerBloc.playMusic(
                                _songs[index],
                              );
                            }
                            break;
                          case PlayerState.stopped:
                            _globalBloc.musicPlayerBloc.playMusic(_songs[index]);
                            break;
                          default:
                            break;
                        }
                      },
                      child: Ringtone_Tile(
                        song: _songs[index],
                      ),
                    );
                  },
                );
              },
            );
          },
        ),

      ),
    );
  }
}