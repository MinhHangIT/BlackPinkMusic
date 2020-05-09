import 'package:flutter/material.dart';
import 'package:ringtone_app/Screen/MainScreen.dart';
import 'package:ringtone_app/blocs/global.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class BlackPinkApp extends StatefulWidget {
  BlackPinkApp({Key key}) : super(key: key);

  _BlackPinkAppState createState() => _BlackPinkAppState();
}

class _BlackPinkAppState extends State<BlackPinkApp> {
  final GlobalBloc _globalBloc = GlobalBloc();

  @override
  void initState() {
    super.initState();
    //_globalBloc.musicPlayerBloc.getRingtoneSer();
  }

  @override
  Widget build(BuildContext context) {
    return Provider<GlobalBloc>(
      builder: (BuildContext context) {
        _globalBloc.permissionsBloc.storagePermissionStatus$.listen(
              (data) {
            if (data == PermissionStatus.granted) {
              _globalBloc.musicPlayerBloc.fetchLocalSongs().then(
                    (_) {
                      // get data song
                    }
              );
              _globalBloc.musicPlayerBloc.fetchSongs().then(
                      (_){
                    _globalBloc.musicPlayerBloc.retrieveFavorites();
                  });
              // get data ringtone
              _globalBloc.musicPlayerBloc.fetchRingtones().then(
                      (_) {
                    _globalBloc.musicPlayerBloc.retrieveFavorites();
                  });
            }
          },
        );
        return _globalBloc;
      },
      dispose: (BuildContext context, GlobalBloc value) => value.dispose(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SafeArea(
          child: StreamBuilder<PermissionStatus>(
            stream: _globalBloc.permissionsBloc.storagePermissionStatus$,
            builder: (BuildContext context,
                AsyncSnapshot<PermissionStatus> snapshot) {
              if (!snapshot.hasData) {
                return Container(
                  height: double.infinity,
                  width: double.infinity,
                  color: Colors.white,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              final PermissionStatus _status = snapshot.data;
              if (_status == PermissionStatus.denied) {
                _globalBloc.permissionsBloc.requestStoragePermission();
                return Container(
                  height: double.infinity,
                  width: double.infinity,
                  color: Colors.white,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              } else {
                return MainScreen();
              }
            },
          ),
        ),
      ),
    );
  }
}
