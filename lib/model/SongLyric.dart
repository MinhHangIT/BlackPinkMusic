class SongLyric {
  int id;
  String key;
  int duration;
  int isFav;
  int timestamp;
  int count;
  String artist;
  String title;
  String album;
  int albumId;
  String uri;
  String albumArt;
  List<Downloads> downloads;
  Lyrics lyrics;

  SongLyric(
      {this.id,
        this.key,
        this.duration,
        this.isFav,
        this.timestamp,
        this.count,
        this.artist,
        this.title,
        this.album,
        this.albumId,
        this.uri,
        this.albumArt,
        this.downloads,
        this.lyrics});

  SongLyric.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    key = json['key'];
    duration = json['duration'];
    isFav = json['isFav'];
    timestamp = json['timestamp'];
    count = json['count'];
    artist = json['artist'];
    title = json['title'];
    album = json['album'];
    albumId = json['albumId'];
    uri = json['uri'];
    albumArt = json['albumArt'];
    if (json['downloads'] != null) {
      downloads = new List<Downloads>();
      json['downloads'].forEach((v) {
        downloads.add(new Downloads.fromJson(v));
      });
    }
    lyrics =
    json['lyrics'] != null ? new Lyrics.fromJson(json['lyrics']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['key'] = this.key;
    data['duration'] = this.duration;
    data['isFav'] = this.isFav;
    data['timestamp'] = this.timestamp;
    data['count'] = this.count;
    data['artist'] = this.artist;
    data['title'] = this.title;
    data['album'] = this.album;
    data['albumId'] = this.albumId;
    data['uri'] = this.uri;
    data['albumArt'] = this.albumArt;
    if (this.downloads != null) {
      data['downloads'] = this.downloads.map((v) => v.toJson()).toList();
    }
    if (this.lyrics != null) {
      data['lyrics'] = this.lyrics.toJson();
    }
    return data;
  }
}

class Downloads {
  String url;
  String type;
  String size;

  Downloads({this.url, this.type, this.size});

  Downloads.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    type = json['type'];
    size = json['size'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['url'] = this.url;
    data['type'] = this.type;
    data['size'] = this.size;
    return data;
  }
}

class Lyrics {
  Lyric lyric1;
  Lyric lyric3;
  Lyric lyric2;

  Lyrics({this.lyric1, this.lyric3, this.lyric2});

  Lyrics.fromJson(Map<String, dynamic> json) {
    lyric1 =
    json['lyric1'] != null ? new Lyric.fromJson(json['lyric1']) : null;
    lyric2 =
    json['lyric2'] != null ? new Lyric.fromJson(json['lyric2']) : null;
    lyric3 =
    json['lyric3'] != null ? new Lyric.fromJson(json['lyric3']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.lyric1 != null) {
      data['lyric1'] = this.lyric1.toJson();
    }
    if (this.lyric3 != null) {
      data['lyric3'] = this.lyric3.toJson();
    }
    if (this.lyric2 != null) {
      data['lyric2'] = this.lyric2.toJson();
    }
    return data;
  }
}

class Lyric {
  String name;
  List<String> sub;

  Lyric({this.name, this.sub});

  Lyric.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    sub = json['sub'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['sub'] = this.sub;
    return data;
  }
}
