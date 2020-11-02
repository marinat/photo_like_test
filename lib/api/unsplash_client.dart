import 'package:dio/dio.dart';
import 'package:photo_like_test/model/remote_photo.dart';

class UnsplashClient {
  static const accessKey = 'aLGWek8XebKFtHnrVWiznOIKp5lB6p2jPkDP1EvbMmo';
  static const baseUrl = 'https://api.unsplash.com/';
  final Dio dio;

  UnsplashClient(this.dio);

  Future<List<RemotePhoto>> downloadPhotos(int page) async {
    final _data = <String, dynamic>{};
    final queryParameters = <String, dynamic>{'page': page, 'per_page': 10};
    final Response<List<dynamic>> _result = await dio.requestUri(
        Uri(
          path: '/photos',
        ),
        options: RequestOptions(
            method: 'GET',
            headers: <String, dynamic>{'Authorization': 'Client-ID $accessKey'},
            queryParameters: queryParameters,
            baseUrl: baseUrl),
        data: _data);
    final value = _result.data.map((i) => RemotePhoto.fromJson(i)).toList();
    return Future.value(value);
  }
}
