import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'dart:math';
import 'package:flutter/services.dart';

class Pic {
  String author;
  String url;

  Pic({this.author, this.url});

  toJson() {
    return {"author": this.author, "url": this.url};
  }

  factory Pic.fromJson(json) {
    return Pic(author: json['author'], url: json['download_url']);
  }
}

Future<List<Pic>> getPics() async {
  final response = await http.get('https://picsum.photos/v2/list');
  if (response.statusCode == 200) {
    final resData = json.decode(response.body);
    List<Pic> pics = [];
    resData.forEach((p) {
      final Pic pic = Pic.fromJson(p);
      pics.add(pic);
    });
    return pics;
  } else {
    throw Exception("Failed to load pics");
  }
}

void main() => runApp(MyApp(pics: getPics()));

class MyApp extends StatelessWidget {
  final Future<List<Pic>> pics;

  MyApp({this.pics});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.white,
      ),
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pinterest',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Icon(
                Icons.search,
                color: Colors.grey,
                size: 40.0,
              ),
              Container(
                width: 160.0,
                child: Image.asset('assets/images/pinterest-logo.png'),
                decoration: BoxDecoration(
                    border: Border(
                        bottom:
                            BorderSide(width: 3.0, color: Colors.red[800]))),
              ),
              Icon(
                Icons.account_circle,
                color: Colors.grey,
                size: 40.0,
              )
            ],
          ),
        ),
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          color: Colors.grey[400],
          child: FutureBuilder(
            future: pics,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return StaggeredGridView.countBuilder(
                  crossAxisCount: 4,
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    return PicCard(item: snapshot.data[index]);
                  },
                  staggeredTileBuilder: (index) {
                    return StaggeredTile.count(2, index.isEven ? 2 : 5);
                  },
                  mainAxisSpacing: 4.0,
                  crossAxisSpacing: 4.0,
                );
              } else if (snapshot.hasError) {
                return Text(snapshot.error);
              }
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.red[800]),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class PicCard extends StatelessWidget {
  final Pic item;
  final _random = Random();

  PicCard({this.item});

  int randomInt(int min, int max) => min * _random.nextInt(max - min);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 3.0,
      child: Container(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(2.5)),
                    image: DecorationImage(
                        image: NetworkImage(item.url), fit: BoxFit.cover)),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 12.0,
              ),
              child: Column(
                children: <Widget>[
                  Text(item.author,
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 16.0,
                      )),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
