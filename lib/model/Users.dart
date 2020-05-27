class Users {
  String uid;
  String name;
  String photoUrl;
  List<String> musicLists;

  Users({this.uid, this.name, this.photoUrl, this.musicLists});

  Users.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    name = json['name'];
    photoUrl = json['photoUrl'];
    musicLists = json['musicLists'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['uid'] = this.uid;
    data['name'] = this.name;
    data['photoUrl'] = this.photoUrl;
    data['musicLists'] = this.musicLists;
    return data;
  }
}