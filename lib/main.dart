import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:photo_like_test/api/unsplash_client.dart';
import 'package:photo_like_test/bloc/photos_cubit.dart';
import 'package:photo_like_test/widgets/photo_card.dart';

import 'bloc/photos_state.dart';

void main() async {
  final dio = Dio();
  dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (Object object) {
        debugPrint(object.toString(), wrapWidth: 1024);
      }));
  final apiClient = UnsplashClient(dio);
  await Hive.initFlutter();
  final photoBox = await Hive.openBox('photoBox');
  runApp(BlocProvider<PhotosCubit>(
    create: (context) {
      return PhotosCubit(apiClient, photoBox)..loadInitialPhotos();
    },
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Photo gallery'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    _scrollController = new ScrollController(initialScrollOffset: 5.0)
      ..addListener(_scrollListener);
  }

  _scrollListener() async {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      await BlocProvider.of<PhotosCubit>(context).loadMorePhotos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: BlocConsumer<PhotosCubit, PhotosState>(
        listener: (context, state) {
          if (state is PhotosLoaded) {
            if (state.loadingFailed) {
              Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text("Photos loading failed"),
                  action: SnackBarAction(
                      textColor: Colors.red,
                      label: 'OK',
                      onPressed: Scaffold.of(context).hideCurrentSnackBar)));
            }
          }
        },
        builder: (context, state) {
          if (state is InitialPhotosLoading) {
            return Container(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(
                    height: 16,
                  ),
                  Text('Loading photos...')
                ],
              ),
            );
          }
          if (state is InitialPhotosLoadingFailed) {
            return Container(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Photos loading failed, please, try again later'),
                  SizedBox(
                    height: 16,
                  ),
                  FlatButton(
                      color: Colors.blue,
                      onPressed: () async {
                        await BlocProvider.of<PhotosCubit>(context)
                            .loadInitialPhotos();
                      },
                      child: Text('RETRY'))
                ],
              ),
            );
          }
          if (state is PhotosLoaded) {
            return Container(
              color: Color(0xff242527),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: OrientationBuilder(
                  builder: (context, orientation) {
                    return CustomScrollView(
                      controller: _scrollController,
                      slivers: [
                        SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount:
                                      (orientation == Orientation.portrait)
                                          ? 2
                                          : 3),
                          delegate: SliverChildBuilderDelegate(
                            (BuildContext context, int index) {
                              return PhotoCard(
                                photo: state.photos[index],
                              );
                            },
                            childCount: state.photos.length,
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: state.loadingNew
                              ? Center(
                                  child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  child: CircularProgressIndicator(),
                                ))
                              : Container(),
                        )
                      ],
                    );
                  },
                ),
              ),
            );
          }
          return Container();
        },
      ),
    );
  }
}
