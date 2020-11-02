import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_like_test/bloc/photos_cubit.dart';
import 'package:photo_like_test/model/photo.dart';

import '../photo_page.dart';

class PhotoCard extends StatelessWidget {
  final Photo photo;

  const PhotoCard({Key key, this.photo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PhotoPage(
                    photo: photo,
                  )),
        );
      },
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            child: Card(
              child: Image.network(
                photo.remotePhoto.urls.thumb,
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration:
                    BoxDecoration(shape: BoxShape.circle, color: Colors.blue),
                width: 32,
                height: 32,
                child: Center(
                  child: IconButton(
                    iconSize: 16,
                    icon: Icon(
                      photo.isLiked ? Icons.favorite : Icons.favorite_border,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      BlocProvider.of<PhotosCubit>(context).likeClicked(photo);
                    },
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
