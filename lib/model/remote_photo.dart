class RemotePhoto {
  final String id;
  final Urls urls;
  final String description;

  RemotePhoto(this.id, this.urls, this.description);

  RemotePhoto.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        description = json['description'],
        urls = json['urls'] == null
            ? null
            : Urls.fromJson(json['urls'] as Map<String, dynamic>);
}

class Urls {
  final String thumb;
  final String full;

  Urls.fromJson(Map<String, dynamic> json)
      : thumb = json['thumb'],
        full = json['full'];
}
