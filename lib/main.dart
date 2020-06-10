import 'dart:async';
import 'dart:convert';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:http/http.dart' as http;
import 'package:kiatsu/model/weather_model.dart';
import 'package:kiatsu/settingPage.dart';
import 'package:share/share.dart';
import 'const/constant.dart' as Constant;

void main() {
  // デバッグ中もクラッシュ情報収集できる
  Crashlytics.instance.enableInDevMode = true;
  // 以下 6 行 Firebase Crashlytics用のおまじない
  FlutterError.onError = Crashlytics.instance.recordFlutterError;
  // runeZonedGuardedに包むことによってFlutter起動中のエラーを非同期的に全部拾ってくれる(らしい)
  runZonedGuarded(() async {
      runApp(MyApp(
          ));
    }, (e, s) => Crashlytics.instance.recordError(e, s));
  }

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // API Key呼び出し
  String a = Constant.key;

  // 以下 2 つ Wiredash 用のストリング
  // String b = Constant.projectId;
  // String c = Constant.secret;
  
  Future<WeatherClass> weather;


  static const String _res2 = "ちんちん";

  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    weather = getWeather();
  }

  get value => null;

  // Future _onRefresher() async {
  //   _getchuWeather();
  //   print("どうよ？");
  // }

  /**
   * Get Weather
   * ! This is a test purpose only comment using Better Comments
   * ? Question version
   */
  Future<WeatherClass> getWeather() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.medium);
    String url = 'http://api.openweathermap.org/data/2.5/weather?lat=' +
        position.latitude.toString() +
        '&lon=' +
        position.longitude.toString() +
        '&APPID=$a';
    final response = await http.get(url);
    return WeatherClass.fromJson(json.decode(response.body));
  }

//  void queryForecast() async {
//    List<Weather> f = await ws.fiveDayForecast();
//    setState(() {
//      _res = f.toString();
//    });
//  }

//  void queryWeather() async {
////    Weather w = await ws.currentWeather(latitude, longitude);
//    Weather w = (await getWeather()) as Weather;
//    setState(() {
//      _res = w.toString();
//      print('weather api test*****************************');
//      print(_res);
//    });
//  }

//  void queryBarometer() async {
//    Weather w2 = await ws.currentWeather(latitude, longtitude);
//    double pressure = w2.pressure.toDouble();
//    setState(() {
//      _res2 = w2.toString();
//      res_p = pressure.toInt();
//      print('pressure *****************');
//      print(w2);
//      print('pressure *****************');
//      print(pressure);
//    });
//  }
  // void _getchuWeather() async {
  //   WeatherClass bitch = await getWeather();
  //   setState(() {
  //     weather = bitch;
  //   });

  // }
    _refresher() async {
      setState(() {
        weather = getWeather();
      });
    }

    // _showWiredash() {
    //   setState(() {
    //     Wiredash.of(context).show();
    //   });
    // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
        // initialRoute: '/a',
        routes: {
          '/a': (BuildContext context) => SettingPage(),
        },
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: GradientAppBar(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [const Color(0xFFc423ba), const Color(0xFF00d5bf)],
                tileMode: TileMode.repeated),
            centerTitle: true,
            title: const Text(
              "THE KIATSU",
            ),
            actions: <Widget>[
              /** Builder がないと「Navigatorを含むコンテクストが必要」って怒られる */
              Builder(
                builder: (context) => IconButton(icon: const Icon(Icons.settings), onPressed: () {
                  Navigator.of(context).pushNamed('/a');
                }),
              )
            ],
          ),
          body: FutureBuilder<WeatherClass>(
              future: getWeather(),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return Center(
                      child: Center(
                        child: Text('読み込み中...'),
                      ));
                }
                if (snapshot.hasError) print(snapshot.error);
                if (snapshot.hasData) {
                  return Container(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFFc423ba),
                              const Color(0xFF00d5bf)
                            ],
                            tileMode: TileMode.repeated)),
                    // color: Colors.black,
                    key: GlobalKey(),
                    child: RefreshIndicator(
                      onRefresh: () {
                        return _refresher();
                      },
                      child: ListView(
                        children: <Widget>[
                          Center(
                            child: Container(
                              padding: EdgeInsets.all(10.0),
                              margin: EdgeInsets.all(10.0),
                              child: const Text(
                                '---pressure status---',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w100,
                                    fontSize: 18.0),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 24.0,
                          ),
                          Center(
                            child: Text(
                              snapshot.data.main.pressure.toString() + ' hPa',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w100,
                                  fontSize: 99.0),
                            ),
                          ),
                          Container(
                            height: 10,
                            alignment: Alignment.centerRight,
                            child:
                              Image.network(
                                'http://openweathermap.org/img/wn/' + 
                                snapshot.data.weather[0].icon + 
                                '.png',
                                // height: 200,
                                // width: 150,
                                // fit: BoxFit.fitHeight,
                                ),
                          ),
                          SizedBox(height: 60.0),
                          Center(
                            child: const Text(
                              '---weather status---',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w100,
                                  fontSize: 18.0),
                            ),
                          ),
                          SizedBox(
                            height: 24.0,
                          ),
                          Center(
                            child: const Text(_res2,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w100)),
                          ),
                          Center(
                            child: Text(
                              '＾ｑ＾',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w100),
                            ),
                          ),
                          Center(
                            child: const Text(
                              'にゃーん',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w100),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                } else {
                  return Center(
                    child: Text('データが存在しません'),
                  );
                }
              }),
          floatingActionButton: FutureBuilder<WeatherClass>(
            future: getWeather(),
            builder: (context, snapshot) {
              return FloatingActionButton(
                  backgroundColor: Colors.pinkAccent,
                  child: Icon(Icons.share),
                  onPressed: () {
                    // sns share button
                    // https://qiita.com/shimopata/items/142b39bab6176b6a5da9
                    Share.share(snapshot.data.main.pressure.toString() + 'hPa is 低気圧しんどいぴえん🥺️');
                    // Wiredash.of(context).show();
                  });
            }
          ),
        ));
  }
}
