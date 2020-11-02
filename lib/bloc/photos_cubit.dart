import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:photo_like_test/api/unsplash_client.dart';
import 'package:photo_like_test/bloc/photos_state.dart';
import 'package:photo_like_test/model/photo.dart';

class PhotosCubit extends Cubit<PhotosState> {
  final UnsplashClient client;
  final Box photoBox;

  PhotosCubit(this.client, this.photoBox) : super(InitialPhotosLoading());

  loadInitialPhotos() async {
    emit(InitialPhotosLoading());
    try {
      final photos = await _getPhotosWithLikes(1);
      emit(PhotosLoaded(photos, false, 1));
    } catch (err) {
      emit(InitialPhotosLoadingFailed());
    }
  }

  loadMorePhotos() async {
    final loadedState = state as PhotosLoaded;
    emit(loadedState.copyWith(loadingNew: true, loadingFailed: false));
    try {
      final photos = await _getPhotosWithLikes(loadedState.page + 1);
      emit(loadedState.copyWith(
          page: loadedState.page + 1,
          photos: loadedState.photos + photos,
          loadingNew: false,
          loadingFailed: false));
    } catch (err) {
      emit(loadedState.copyWith(loadingFailed: true, loadingNew: false));
      return;
    }
  }

  likeClicked(Photo photo) {
    final likeState = !photo.isLiked;
    final photoId = photo.remotePhoto.id;
    photoBox.put(photoId, likeState);
    final loadedState = state as PhotosLoaded;
    emit(loadedState.copyWith(
        photos: loadedState.photos
            .map((photo) => photo.remotePhoto.id == photoId
                ? Photo(photo.remotePhoto, likeState)
                : photo)
            .toList()));
  }

  Future<List<Photo>> _getPhotosWithLikes(int page) async {
    final remotePhotos = await client.downloadPhotos(page);
    return remotePhotos
        .map((remotePhoto) => Photo(
            remotePhoto, photoBox.get(remotePhoto.id, defaultValue: false)))
        .toList();
  }
}
