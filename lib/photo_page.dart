import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_like_test/model/photo.dart';
import 'package:photo_view/photo_view.dart';

import 'bloc/photos_cubit.dart';
import 'bloc/photos_state.dart';

class PhotoPage extends StatelessWidget {
  final Photo photo;

  const PhotoPage({Key key, this.photo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          heroTag: photo.remotePhoto.id,
          child: BlocBuilder<PhotosCubit, PhotosState>(
            builder: (context, state) {
              if (state is PhotosLoaded) {
                return Icon(state.photos
                        .firstWhere((photo) =>
                            photo.remotePhoto.id == this.photo.remotePhoto.id)
                        .isLiked
                    ? Icons.favorite
                    : Icons.favorite_border);
              }
              return Container();
            },
          ),
          onPressed: () {
            BlocProvider.of<PhotosCubit>(context).likeClicked(photo);
          },
        ),
        appBar: AppBar(
          title: Text('Photo'),
        ),
        body: PhotoView(
          imageProvider: NetworkImage(photo.remotePhoto.urls.full),
          loadingBuilder: (context, event) => Center(
              child: Container(
            width: 20.0,
            height: 20.0,
            child: CircularProgressIndicator(
              value: event == null
                  ? 0
                  : event.cumulativeBytesLoaded / event.expectedTotalBytes,
            ),
          )),
        ));
  }
}
