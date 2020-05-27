import 'dart:async';

import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/services.dart';
import 'package:ringtone_app/model/Album.dart';
import 'package:ringtone_app/model/AlbumLocal.dart';
import 'package:ringtone_app/model/Ringtone.dart';
import 'package:ringtone_app/model/Users.dart';
import 'package:ringtone_app/model/playback.dart';
import 'package:ringtone_app/model/playerstate.dart';
import 'package:ringtone_app/model/SongLyric.dart';
import 'package:ringtone_app/constant/app_constant.dart';
import 'package:ringtone_app/utils/directory_modul.dart';
import 'package:ringtone_app/utils/download_modul.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;



class MusicPlayerBloc {

  FirebaseDatabase database;
  DatabaseReference databaseReference;
  Users _users;

  BehaviorSubject<List<Song>> _songs$;
  BehaviorSubject<List<Song>> _ringtone$;
  BehaviorSubject<List<Song>> _localSongs$;
  BehaviorSubject<List<SongLyric>> _songLyric$;
  BehaviorSubject<List<Album>> _albums$;
  BehaviorSubject<List<AlbumLocal>> _albumsLocal$;
  BehaviorSubject<MapEntry<PlayerState, Song>> _playerState$;
  BehaviorSubject<MapEntry<List<Song>, List<Song>>>
      _playlist$; //key is normal, value is shuffle
  BehaviorSubject<Duration> _position$;
  BehaviorSubject<List<Playback>> _playback$;
  BehaviorSubject<List<Song>> _favorites$;
  BehaviorSubject<bool> _isAudioSeeking$;
  MusicFinder _audioPlayer;
  Song _defaultSong;
  Map<String, SongLyric> hashMySong;

  BehaviorSubject<List<Song>> get songs$ => _songs$;
  BehaviorSubject<List<Song>> get ringtone$ => _ringtone$;
  BehaviorSubject<List<Song>> get localSongs$ => _localSongs$;

  BehaviorSubject<List<SongLyric>> get songLyric$ => _songLyric$;

  BehaviorSubject<List<Album>> get albums$ => _albums$;
  BehaviorSubject<List<AlbumLocal>> get albumsLocal$ => _albumsLocal$;


  BehaviorSubject<MapEntry<PlayerState, Song>> get playerState$ =>
      _playerState$;

  BehaviorSubject<Duration> get position$ => _position$;

  BehaviorSubject<List<Playback>> get playback$ => _playback$;

  BehaviorSubject<List<Song>> get favorites$ => _favorites$;

  MusicPlayerBloc() {
    _initDeafultSong();
    _initStreams();
    _initObservers();
    _initAudioPlayer();
  }

   //get data from firebase
//  Future<List<Ringtone>> getRingtoneSer() async {
//    //print("Chij Hanhj Hanh Hanh Hanh HAnh");
//    databaseReference = FirebaseDatabase.instance.reference();
//    List<Ringtone> ringtone = new List<Ringtone>();
//
//    await databaseReference
//        .child("ringtone")
//        .once()
//        .then((DataSnapshot snapshot) {
//      print("Chij Hanhj Hanh Hanh Hanh HAnh");
//      if (snapshot.value != null) {
//        print("Chij Hanhj Hanh Hanh Hanh HAnh");
//        values.forEach((key, values) {
//          ringtone.add(Ringtone.fromJson(values));
//
//        });
//      }
//      print('Data ringtone : ${ringtone.length}');
//    });
//    return ringtone;
//  }

  Future<void> fetchSongData() async {
    final response = await http.get('https://firebasestorage.googleapis.com/v0/b/blackpinkmusicdata-17f35.appspot.com/o/song.json?alt=media&token=6b86cfd7-0112-47d9-9db1-0a8bf170fb5c');

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      final jsonResponse = json.decode(response.body);
      hashMySong = new Map<String, SongLyric>();
      List<Song> songs = new List<Song>();
      jsonResponse.forEach((o) {
//      print(o.toString());
        SongLyric mySong = SongLyric.fromJson(o);
        Song song = Song.fromMap(o);
        song.type = "songOnline";

        int check = songs.where((ele)=> ele.title == song.title).toList().length;
        if (check == 0)
        {
          songs.add(song);
        }
        songs.sort((a,b)=>a.title.compareTo(b.title));

        hashMySong[mySong.key] = mySong;
      });
      _songs$.add(songs);

    } else {
      print("Failed to load data");
      // If the server did not return a 200 OK response,
      // then throw an exception.
//      throw Exception('Failed to load');
    }
  }

  Future<void> fetchRingToneData() async {
    final response = await http.get('https://firebasestorage.googleapis.com/v0/b/blackpinkmusicdata-17f35.appspot.com/o/ringtone.json?alt=media&token=f22dbfde-545e-4c96-8d4e-c00c0fa908ce');

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      final jsonResponse = json.decode(response.body);
      List<Song> mySongs = new List<Song>();
      jsonResponse.forEach((o) {
        Song song = Song.fromMap(o);
        song.type = "ringtone";
        mySongs.add(song);
        mySongs.sort((a,b)=>a.title.compareTo(b.title));
      });

      _ringtone$.add(mySongs);

    } else {
      print("Failed to load data");
      // If the server did not return a 200 OK response,
      // then throw an exception.
//      throw Exception('Failed to load');
    }
  }

  Future<void> fetchSongs() async {
    String jsonString = await rootBundle.loadString('lib/data/song.json');
    List<Song> mySongs = new List<Song>();
    final jsonResponse = json.decode(jsonString);
    hashMySong = new Map<String, SongLyric>();
    List<Song> songs = new List<Song>();
    jsonResponse.forEach((o) {
//      print(o.toString());
      SongLyric mySong = SongLyric.fromJson(o);
      Song song = Song.fromMap(o);
      song.type = "songOnline";

      int check = songs.where((ele)=> ele.title == song.title).toList().length;
      if (check == 0)
      {
        songs.add(song);
      }
      songs.sort((a,b)=>a.title.compareTo(b.title));

      hashMySong[mySong.key] = mySong;
    });
    _songs$.add(songs);
  }

  Future<void> fetchRingtones() async {
    String jsonString = await rootBundle.loadString('lib/data/ringtone.json');
//    print(jsonString);
    final jsonResponse = json.decode(jsonString);
    List<Song> mySongs = new List<Song>();
    jsonResponse.forEach((o) {
      Song song = Song.fromMap(o);
      song.type = "ringtone";
      mySongs.add(song);
      mySongs.sort((a,b)=>a.title.compareTo(b.title));
    });

    _ringtone$.add(mySongs);
  }

  Future<void> fetchLocalSongs() async {
    String folder = await DownloadModule.createAppFolder();
    await MusicFinder.allSongs(folder).then(
      (data) {
        print("--------------------------------------");
        print("RingTone: " + data.toString());
      List<Song> songs = new List<Song>();
        data.forEach((song) {
          print("SongType: " + song.toString());
          if (song.uri.contains(FOLDER_NAME)) {
            Song songoff = song;
            songoff.type = "songOff";
            songs.add(songoff);
          }
        });
        songs.sort((a,b)=>a.title.compareTo(b.title));
        _localSongs$.add(songs);

      }

  );}

  Future<void> removeFromLocal(Song song) async {
    await DirectoryModule.deleteFile(song.uri).then((_) async {
      Timer(Duration(seconds: 1), () async {
        await fetchLocalSongs();
      });
    });
  }

  void nextAndRemoveFromPlaylist(Song song) async {
    final bool _isShuffle = _playback$.value.contains(Playback.shuffle);
    final List<Song> _playlist =
    _isShuffle ? _playlist$.value.value : _playlist$.value.key;
    int _index = _playlist.indexOf(song);
    _playlist.removeAt(_index);
    _favorites$.add(_playlist);
    stopMusic();
    if (_playlist.length > 0) {
      if (_index == _playlist.length) {
        _index = 0;
      }
      playMusic(_playlist[_index]);
    } else {
      _initDeafultSong();
      _playerState$.add(MapEntry(
        PlayerState.stopped,
        _defaultSong,
      ));
    }
  }

  void playMusic(Song song) {
    //print("Song uri: " + song.uri +  " , Name: " + song.title);
    _audioPlayer.play(song.uri);
   //_audioPlayer.pause();

    updatePlayerState(PlayerState.playing, song);
  }

  void pauseMusic(Song song) {
    _audioPlayer.pause();
    updatePlayerState(PlayerState.paused, song);
  }

  void stopMusic() {
    _audioPlayer.stop();
  }

  void updatePlayerState(PlayerState state, Song song) {
    _playerState$.add(MapEntry(state, song));
  }

  void updatePosition(Duration duration) {
    _position$.add(duration);
  }

  void updatePlaylist(List<Song> normalPlaylist) {
    List<Song> _shufflePlaylist = []..addAll(normalPlaylist);
    _shufflePlaylist.shuffle();
    _playlist$.add(MapEntry(normalPlaylist, _shufflePlaylist));
  }

  void _updateAlbums(List<Song> songs) {
    Map<int, Album> _albumsMap = {};
    for (Song song in songs) {
      if (_albumsMap[song.albumId] == null) {
        _albumsMap[song.albumId] = Album.fromSong(song);
      }
    }
    final List<Album> _albums = _albumsMap.values.toList();
    _albums$.add(_albums);
  }

  void _updateAlbumsLocal(List<Song> songs) {
    Map<int, AlbumLocal> _albumsMap = {};
    for (Song song in songs) {
      if (_albumsMap[song.albumId] == null) {
        _albumsMap[song.albumId] = AlbumLocal.fromSong(song);
      }
    }
    final List<AlbumLocal> _albums = _albumsMap.values.toList();
    _albumsLocal$.add(_albums);
  }

  void playNextSong() {
    if (_playerState$.value.key == PlayerState.stopped) {
      return;
    }
    final Song _currentSong = _playerState$.value.value;
    final bool _isShuffle = _playback$.value.contains(Playback.shuffle);
    final List<Song> _playlist =
        _isShuffle ? _playlist$.value.value : _playlist$.value.key;
    int _index = _playlist.indexOf(_currentSong);
    if (_index == _playlist.length - 1) {
      _index = 0;
    } else {
      _index++;
    }
    stopMusic();
    playMusic(_playlist[_index]);
  }

  void playPreviousSong() {
    if (_playerState$.value.key == PlayerState.stopped) {
      return;
    }
    final Song _currentSong = _playerState$.value.value;
    final bool _isShuffle = _playback$.value.contains(Playback.shuffle);
    final List<Song> _playlist =
        _isShuffle ? _playlist$.value.value : _playlist$.value.key;
    int _index = _playlist.indexOf(_currentSong);
    if (_index == 0) {
      _index = _playlist.length - 1;
    } else {
      _index--;
    }
    stopMusic();
    playMusic(_playlist[_index]);
  }

  void _playSameSong() {
    final Song _currentSong = _playerState$.value.value;
    stopMusic();
    playMusic(_currentSong);
  }

  void _onSongComplete() {
    final List<Playback> _playback = _playback$.value;
    if (_playback.contains(Playback.repeatSong)) {
      _playSameSong();
      return;
    }
    playNextSong();
  }

  void audioSeek(double seconds) {
    _audioPlayer.seek(seconds);
  }

  void addToFavorites(Song song) async {
    List<Song> _favorites = _favorites$.value;
    _favorites.add(song);
    _favorites$.add(_favorites);
    await saveFavorites();
  }

  void removeFromFavorites(Song song) async {
    List<Song> _favorites = _favorites$.value;
    _favorites.remove(song);
    _favorites$.add(_favorites);
    await saveFavorites();
  }

  void invertSeekingState() {
    final _value = _isAudioSeeking$.value;
    _isAudioSeeking$.add(!_value);
  }

  void updatePlayback(Playback playback) {
    List<Playback> _value = playback$.value;
    if (playback == Playback.shuffle) {
      final List<Song> _normalPlaylist = _playlist$.value.key;
      updatePlaylist(_normalPlaylist);
    }
    _value.add(playback);
    _playback$.add(_value);
  }

  void removePlayback(Playback playback) {
    List<Playback> _value = playback$.value;
    _value.remove(playback);
    _playback$.add(_value);
  }

  Future<void> saveFavorites() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();

    final List<Song> _favorites = _favorites$.value;
    List<String> _encodedStrings = [];
    for (Song song in _favorites) {
      _encodedStrings.add(_encodeSongToJson(song));
    }

//    String uid = _prefs.getString("user_id");
//    if(uid != null){
//      databaseReference = FirebaseDatabase.instance.reference();
//
////      await databaseReference.child("users").child(uid).once().then((DataSnapshot snapshot){
////        if(snapshot.value != null){
////
////        }
////      });
//
////      print("USER_ID: " + uid);
////
////      await databaseReference.child("users").child(uid).child("music_favorites").set(_favorites$.value);
//
//    }

    _prefs.setStringList("favorites", _encodedStrings);
  }

  void retrieveFavorites() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
//    String uid = _prefs.getString("user_id");
//    databaseReference = FirebaseDatabase.instance.reference();
//    List<String> _savedStrings;
//    await databaseReference.child("users").child(uid).once().then((DataSnapshot snapshot){
//      if(snapshot.value != null && snapshot.value["music_favorites"] != null){
//        _savedStrings = List.from(snapshot.value['music_favorites']);
//      } else {
//        _savedStrings = new List<String>();
//      }
//    });
    final List<Song> _fetchedSongs = _songs$.value;
    List<String> _savedStrings = _prefs.getStringList("favorites") ?? [];

    List<Song> _favorites = [];
    for (String data in _savedStrings) {
      final Song song = _decodeSongFromJson(data);
      for (var fetchedSong in _fetchedSongs) {
        if (song.id == fetchedSong.id) {
          _favorites.add(fetchedSong);
        }
      }
    }
    _favorites$.add(_favorites);
  }

  String _encodeSongToJson(Song song) {
    final _songMap = songToMap(song);
    final data = json.encode(_songMap);
    return data;
  }

  Song _decodeSongFromJson(String ecodedSong) {
    final _songMap = json.decode(ecodedSong);
    final Song _song = Song.fromMap(_songMap);
    return _song;
  }

  Map<String, dynamic> songToMap(Song song) {
    Map<String, dynamic> _map = {};
    _map["album"] = song.album;
    _map["id"] = song.id;
    _map["artist"] = song.artist;
    _map["title"] = song.title;
    _map["albumId"] = song.albumId;
    _map["duration"] = song.duration;
    _map["uri"] = song.uri;
    _map["albumArt"] = song.albumArt;
    return _map;
  }

  void _initDeafultSong() {
    _defaultSong = Song(null, " ", " ", " ", null, null, null, null, "");
  }

  void _initObservers() {
    _songs$.listen(
      (List<Song> songs) {
        _updateAlbums(songs);
      },
    );
    _ringtone$.listen(
          (List<Song> songs) {
        _updateAlbums(songs);
      },
    ); // push albums from songs

    _localSongs$.listen(
          (List<Song> songs) {
        _updateAlbumsLocal(songs);
      },
    );
  }

  void _initStreams() {
    _isAudioSeeking$ = BehaviorSubject<bool>.seeded(false);
    _songs$ = BehaviorSubject<List<Song>>();
    _ringtone$ = BehaviorSubject<List<Song>>();
    _albums$ = BehaviorSubject<List<Album>>();
    _localSongs$ = BehaviorSubject<List<Song>>();
    _albumsLocal$ = BehaviorSubject<List<AlbumLocal>>();
    _position$ = BehaviorSubject<Duration>();
    _playlist$ = BehaviorSubject<MapEntry<List<Song>, List<Song>>>();
    _playback$ = BehaviorSubject<List<Playback>>.seeded([]);
    _favorites$ = BehaviorSubject<List<Song>>.seeded([]);
    _playerState$ = BehaviorSubject<MapEntry<PlayerState, Song>>.seeded(
      MapEntry(
        PlayerState.stopped,
        _defaultSong,
      ),
    );
  }

  void _initAudioPlayer() {
    _audioPlayer = MusicFinder();
    _audioPlayer.setPositionHandler(
      (Duration duration) {
        final bool _isAudioSeeking = _isAudioSeeking$.value;
        if (!_isAudioSeeking) {
          updatePosition(duration);
        }
      },
    );
    _audioPlayer.setCompletionHandler(
      () {
        _onSongComplete();
      },
    );
  }

  void dispose() {
    stopMusic();
    _isAudioSeeking$.close();
    _songs$.close();
    _ringtone$.close();
    _albums$.close();
    _albumsLocal$.close();
    _localSongs$.close();
    _playerState$.close();
    _playlist$.close();
    _position$.close();
    _playback$.close();
    _favorites$.close();
  }
}

String getKeyFromUri(String uri) {
  return uri.split('/').last.split('_')[0];
}
