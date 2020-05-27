import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ringtone_app/Screen/MusicHome/PlayBottomScreen.dart';
import 'package:ringtone_app/Screen/Offline/Song_Title.dart';
import 'package:ringtone_app/Screen/now_playing/now_playing_screen.dart';
import 'package:ringtone_app/blocs/global.dart';
import 'package:ringtone_app/common/empty_screen.dart';
import 'package:ringtone_app/model/Ringtone.dart';
import 'package:ringtone_app/model/playerstate.dart';
import 'package:ringtone_app/Screen/Offline/Ringtone_Title.dart';
import 'package:provider/provider.dart';
import 'package:ringtone_app/Screen/now_playing/empty_album_art.dart';
import 'package:flutter/services.dart';
import 'package:ringtone_app/store/AppStore.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:rate_my_app/rate_my_app.dart';


class RingtoneScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return RingtoneScreenState();
  }
}
class RingtoneScreenState extends State<RingtoneScreen>  {
  PanelController panelController;
  bool isRingtone = true;
  @override
  Widget build(BuildContext context) {
    final Song _song = Provider.of<Song>(context);
    final GlobalBloc _globalBloc = Provider.of<GlobalBloc>(context);
    final double _screenHeight = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;


    final double _radius = 25.0;
    PanelController _panelController;

    @override
    void initState() {
      _panelController = PanelController();

      super.initState();
      setState(() {
       // store.isRingtone = true;
      });

    }

    @override
    void dispose() {
      _panelController.close();
      super.dispose();
    }
    return SafeArea(
      child: WillPopScope(
        onWillPop: () {

            Navigator.pop(context);
        },
        child: Scaffold(
            body: SlidingUpPanel(
                panel: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(_radius),
                    topRight: Radius.circular(_radius),
                  ),
                  child: NowPlayingScreen(controller: panelController),
                ),
                controller: panelController,
                minHeight: 110,
                maxHeight: MediaQuery.of(context).size.height,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(_radius),
                  topRight: Radius.circular(_radius),
                ),
                collapsed: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(_radius),
                      topRight: Radius.circular(_radius),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      stops: [0.0, 0.7,],
                      colors: [Color(0xFFFD9D9D), Color(0xFF8A8A8A),],
                    ),
                  ),
                  child: PlayBottomScreen(controller: panelController),
                ),
                body:  Stack(
                  children: <Widget>[
                    Container(
//                        decoration: BoxDecoration(
//                          // color: Colors.red,
//                            image: DecorationImage(
//                              image: AssetImage("assets/images/bg.jpg"),
//                              fit: BoxFit.cover,
//
//                            )
                      //),
                        color: Colors.white,
                        padding: const EdgeInsets.only(bottom: 16.0, top: 60.0),

                        child:  StreamBuilder<List<Song>>(
                          stream: _globalBloc.musicPlayerBloc.ringtone$,
                          builder: (BuildContext context, AsyncSnapshot<List<Song>> snapshot) {
                            if (!snapshot.hasData) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            final List<Song> _songs = snapshot.data;
                            if (_songs.length == 0) {
                              return EmptyScreen(
                                text: "You do not have any songs on your device.",
                              );
                            }
                            return ListView.builder(
                              key: PageStorageKey<String>("All Songs"),
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

                                    print("Current Ringtone: " + snapshot.data.value.title);

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
                                      child: Song_Tile(
                                        song: _songs[index],
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                        )
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
                            width: width/7,
                            alignment: Alignment.center,
                            //padding: EdgeInsets.only(left:15.0),
                            child:  GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Icon(Icons.arrow_back, color: Colors.white, size: 30,),
                            ),),
                          Container(
                              width: width*5/7,
                              alignment: Alignment.center,
                              child:  Text( "RINGTONES",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),)
                          ),
                        ],
                      ),
                    ),
                  ],)
            )
        ),
      ),
    );
  }

  void _showExitDialog() {
    final GlobalBloc _globalBloc = Provider.of<GlobalBloc>(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'BTS Ringtones',
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          content: Text(
            "If you like this app, please take a little bit of your time to review it !\nIt really helps us and it shouldn\'t take you more than one minute.",
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          actions: <Widget>[
            FlatButton(
              textColor: Color(0xFFDF5F9D),
              onPressed: () {
                SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                _globalBloc.dispose();
              },
              child: Text("EXIT"),
            ),
            FlatButton(
              textColor: Color(0xFFDF5F9D),
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("CANCEL"),
            ),
            FlatButton(
              textColor: Color(0xFFDF5F9D),
              onPressed: () async {
                RateMyApp rateMyApp = RateMyApp();
                await rateMyApp.launchStore();
              },
              child: Text("RATE"),
            ),
          ],
        );
      },
    );
  }
}
