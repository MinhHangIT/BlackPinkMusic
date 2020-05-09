import 'package:flutter/material.dart';
import 'package:ringtone_app/Screen/Offline/Song_Title.dart';
import 'package:ringtone_app/Screen/Online/RingtoneScreen.dart';
import 'package:ringtone_app/Screen/Online/SongScreen.dart';
import 'package:ringtone_app/blocs/global.dart';
import 'package:provider/provider.dart';
import 'package:ringtone_app/common/empty_screen.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:ringtone_app/model/Ringtone.dart';
import 'package:ringtone_app/model/SongLyric.dart';
import 'package:ringtone_app/store/AppStore.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:flute_music_player/flute_music_player.dart';
import 'package:ringtone_app/model/playerstate.dart';
import 'package:ringtone_app/Screen/Offline/Ringtone_Title.dart';
import 'package:flutter/services.dart';


class HomeScreen extends StatefulWidget {

  bool isOpen;

  HomeScreen(this.isOpen);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return HomeScreenState();
  }
}

class HomeScreenState extends State<HomeScreen> {

  bool get wantKeepAlive => true;
  Widget OfflineHome(BuildContext context){
    final GlobalBloc _globalBloc = Provider.of<GlobalBloc>(context);

    // TODO: implement build
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    final double _radius = 25.0;
    PanelController _panelController;

    @override
    void initState() {
      _panelController = PanelController();

      //setState(() {
//        store.isRingtone = false;
//        store.isLocal = true;
       // print("check ringtone"+store.isRingtone.toString());
     // });
      super.initState();
    }


    @override
    void dispose() {
      _panelController.close();
      super.dispose();
    }
    return  Scaffold(
        body: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/bg.jpg"),
                fit: BoxFit.cover,
              )
          ),
          child: StreamBuilder<List<Song>>(
        stream: _globalBloc.musicPlayerBloc.localSongs$,
        builder: (BuildContext context, AsyncSnapshot<List<Song>> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          final List<Song> _songs = snapshot.data;

          if (_songs.length == 0) {
            return Padding(
              padding: EdgeInsets.only(bottom: width/3),
              child: EmptyScreen(
                text: "You do not have any songs on your device.",
              ),
            );
          }
          return ListView.builder(
            key: PageStorageKey<String>("Local Songs"),
            padding: const EdgeInsets.only(bottom: 150.0),
            physics: BouncingScrollPhysics(),
            itemCount: _songs.length,
            itemExtent: 110,
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
                          _globalBloc.musicPlayerBloc
                              .playMusic(_songs[index]);
                          break;
                        default:
                          break;
                      }
                    },
                    child: Song_Tile(
                      song: _songs[index],
                    ),
                  );
                },
              );
            },
          );
        },
      ),)
    );

  }

  Widget OnlineHome(BuildContext context){
    final GlobalBloc _globalBloc = Provider.of<GlobalBloc>(context);

    // TODO: implement build
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    final double _radius = 25.0;


    return Scaffold(
      body: Container(
        width: width,
        height: height/1.1,
        decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/bg.jpg"),
              fit: BoxFit.cover,
            )
        ),

        child: Padding(
          padding: EdgeInsets.only(bottom: width/3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[

              Container(
                margin: EdgeInsets.only(bottom: 20.0),
                  width: 308,
                  height: 63,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/images/songButton.png"),
                        fit: BoxFit.fill,
                      )
                  ),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
//                        store.isRingtone = false;
//                        store.isLocal = false;
                      });
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Provider<SongLyric>.value(
                              //value: _songLyric[index],
                              child: SongScreen(),
                            ),
                          ));
                    },)
              ),
              Container(
                  width: 308,
                  height: 63,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/images/ringtonButton.png"),
                        fit: BoxFit.fill,
                      )
                  ),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
//                        store.isRingtone = true;
//                        store.isLocal= false;
                      });
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Provider<Song>.value(
                              //value: _songLyric[index],
                              child: RingtoneScreen(),
                            ),
                          ));
                    },)
              )
            ],
          ),
        )
      ),
    );
  }

  @override
  Widget build(BuildContext context) {


    // TODO: implement build
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;


    return Scaffold(
      body: widget.isOpen ? OnlineHome(context) : OfflineHome(context)
    );
  }
}

