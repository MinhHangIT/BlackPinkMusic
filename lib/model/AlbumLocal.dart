import 'package:flute_music_player/flute_music_player.dart';
class AlbumLocal {
  int _id;
  String _name;
  String _art;
  String _artist;

  int get id => _id;
  String get name => _name;
  String get art => _art;
  String get artist => _artist;

  AlbumLocal(this._id, this._name, this._art, this._artist);

  factory AlbumLocal.fromSong(Song song) {
    return AlbumLocal(song.albumId, song.album, song.albumArt, song.artist);
  }

  AlbumLocal.fromMap(Map m) {
    _id = m["_id"];
    _name= m["_name"];
    _art = m["_art"];
    _artist = m["_artist"];

  }
}
