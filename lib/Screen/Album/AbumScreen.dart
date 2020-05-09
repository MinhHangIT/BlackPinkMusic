import 'package:flutter/material.dart';
import 'package:ringtone_app/Screen/Album/AlbumLocalTile.dart';
import 'package:ringtone_app/Screen/Album/SpecificAlbumLocal.dart';
import 'package:ringtone_app/blocs/global.dart';
import 'package:ringtone_app/common/empty_screen.dart';
import 'package:ringtone_app/model/Album.dart';
//import 'package:ringtone_app/model/Album.dart';
import 'package:ringtone_app/Screen/Album/AlbumTitle.dart';
import 'package:ringtone_app/Screen/Album/SpecificAlbumScreen.dart';
import 'package:provider/provider.dart';
import 'package:ringtone_app/model/AlbumLocal.dart';

class AlbumsScreen extends StatefulWidget {

  bool isOpen;

  AlbumsScreen(this.isOpen);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return AlbumsScreenState();
  }
}

class AlbumsScreenState extends State<AlbumsScreen> {


  Widget OnlineAlbum(BuildContext context){
    final GlobalBloc _globalBloc = Provider.of<GlobalBloc>(context);

    // TODO: implement build
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    final double _radius = 25.0;


    return Scaffold(
      body:  Container(

          decoration: BoxDecoration(
              color: Colors.red,
              image: DecorationImage(
                image: AssetImage("assets/images/bg.jpg"),
                fit: BoxFit.cover,

              )
          ),
          child:  StreamBuilder<List<Album>>(
            stream: _globalBloc.musicPlayerBloc.albums$,
            builder: (BuildContext context, AsyncSnapshot<List<Album>> snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }

              final List<Album> _albums = snapshot.data;
              if (_albums.length == 0) {
                return EmptyScreen(
                  text: "You do not have any albums on your device.",
                );
              }

              return GridView.builder(
                key: PageStorageKey<String>("Albums Screen"),
                padding: EdgeInsets.only(
                    left: 16.0, right: 16.0, top: 16.0, bottom: 150),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8.0,
                  crossAxisSpacing: 8.0,
                ),
                physics: BouncingScrollPhysics(),
                itemCount: _albums.length,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Provider<Album>.value(
                              value: _albums[index],
                              child: SpecificAlbumScreen(),
                            ),
                          ));
                    },
                    child: AlbumTile(
                      album: _albums[index],
                    ),
                  );
                },
              );
            },
          )),
    );
  }


  Widget OfflineAlbum(BuildContext context){
    final GlobalBloc _globalBloc = Provider.of<GlobalBloc>(context);

    // TODO: implement build
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    final double _radius = 25.0;


    return Scaffold(
      body:  Container(

          decoration: BoxDecoration(
              color: Colors.red,
              image: DecorationImage(
                image: AssetImage("assets/images/bg.jpg"),
                fit: BoxFit.cover,

              )
          ),
          child:  StreamBuilder<List<AlbumLocal>>(
            stream: _globalBloc.musicPlayerBloc.albumsLocal$,
            builder: (BuildContext context, AsyncSnapshot<List<AlbumLocal>> snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }

              final List<AlbumLocal> _albums = snapshot.data;
              if (_albums.length == 0) {
                return EmptyScreen(
                  text: "You do not have any albums on your device.",
                );
              }

              return GridView.builder(
                key: PageStorageKey<String>("Albums Screen"),
                padding: EdgeInsets.only(
                    left: 16.0, right: 16.0, top: 16.0, bottom: 150),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8.0,
                  crossAxisSpacing: 8.0,
                ),
                physics: BouncingScrollPhysics(),
                itemCount: _albums.length,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Provider<AlbumLocal>.value(
                              value: _albums[index],
                              child: SpecificAlbumLocalScreen(),
                            ),
                          ));
                    },
                    child: AlbumLocalTile(
                      album: _albums[index],
                    ),
                  );
                },
              );
            },
          )),
    );
  }


  @override
  Widget build(BuildContext context) {
    GlobalBloc _globalBloc = Provider.of<GlobalBloc>(context);
    return Scaffold(
        body: widget.isOpen ? OnlineAlbum(context) : OfflineAlbum(context)
    );
  }
}
