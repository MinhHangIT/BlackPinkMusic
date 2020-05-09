class Ringtone {
  int id;
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




  Ringtone(
      {this.id,
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
        this.downloads});

  Ringtone.fromJson(Map<String, dynamic> json) {
    id = json['id'];
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

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
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
