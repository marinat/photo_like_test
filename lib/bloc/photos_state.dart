import 'package:equatable/equatable.dart';
import 'package:photo_like_test/model/photo.dart';

abstract class PhotosState extends Equatable {
  const PhotosState();

  @override
  List<Object> get props => [];
}

class InitialPhotosLoading extends PhotosState {}

class InitialPhotosLoadingFailed extends PhotosState {}

class PhotosLoaded extends PhotosState {
  final List<Photo> photos;
  final bool loadingNew;
  final bool loadingFailed;
  final int page;

  PhotosLoaded(this.photos, this.loadingNew, this.page,
      {this.loadingFailed = false});

  @override
  List<Object> get props => [photos, loadingNew, loadingFailed];

  PhotosLoaded copyWith(
      {List<Photo> photos, bool loadingNew, bool loadingFailed, int page}) {
    return PhotosLoaded(
        photos ?? this.photos, loadingNew ?? this.loadingNew, page ?? this.page,
        loadingFailed: loadingFailed ?? this.loadingFailed);
  }
}
