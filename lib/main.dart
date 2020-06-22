import 'dart:async';
import 'dart:convert';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
// import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:http/http.dart' as http;
import 'package:kiatsu/model/weather_model.dart';
import 'package:kiatsu/settingPage.dart';
import 'package:neumorphic/neumorphic.dart';
import 'package:share/share.dart';
import 'package:weather/weather_library.dart';
import 'const/constant.dart' as Constant;
import 'package:timeago/timeago.dart' as timeago;

void main() {
  // デバッグ中もクラッシュ情報収集できる
  Crashlytics.instance.enableInDevMode = true;
  // 以下 6 行 Firebase Crashlytics用のおまじない
  FlutterError.onError = Crashlytics.instance.recordFlutterError;
  // runeZonedGuardedに包むことによってFlutter起動中のエラーを非同期的に全部拾ってくれる(らしい)
  runZonedGuarded(() async {
      runApp(NeuApp(
        home: MyApp(
            ),
      ));
    }, (e, s) => Crashlytics.instance.recordError(e, s));
  }
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // API Key呼び出し
  static const String a = Constant.key;

  static String fine = '元気すぎわろた＾ｑ＾';
  static String pien = '低気圧つらすぎぴえん🥺';

  List<String> items = [pien, fine];
  DateTime updatedAt = new DateTime.now();
  Weather w;
  // _MyAppState({this.remoteConfig});

  // final RemoteConfig remoteConfig;

  // 以下 2 つ Wiredash 用のストリング
  // String b = Constant.projectId;
  // String c = Constant.secret;
  
  Future<WeatherClass> weather;

  WeatherStation ws = new WeatherStation(a);

  final _navigatorKey = GlobalKey<NavigatorState>();
  String _res2 = '';

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


  // Future で 5日分の天気取得
 Future<void> queryForecast() async {
   // 位置情報取得
  Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.medium);
        // Weather クラスに 5日分の天気情報格納
   List<Weather> f = await ws.fiveDayForecast(position.latitude.toDouble(), position.longitude.toDouble());
   setState(() {
     // "_res2" の Text を List "f" にぶっこむ
     _res2 = f.toString();
   });
 }



    // ListView 更新
    Future<void> _refresher() async {
      setState(() {
        weather = getWeather();
        
        updatedAt = new DateTime.now();
        // 引っ張ったときに5日分の天気データ取得する
        // queryForecast();
      });
    }
    

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
          appBar: NeuAppBar(
              title: const NeuText(
                "THE KIATSU",
              ),
            ),
          body: FutureBuilder<WeatherClass>(
              future: getWeather(),
              builder: (context, snapshot) {
                // if (snapshot.connectionState != ConnectionState.done) {
                //   return Center(
                //     child: Text('読み込み中...'),
                //   );
                // }
                if (snapshot.hasError) print(snapshot.error);
                if (snapshot.hasData) {
                  return Container(
                    child: RefreshIndicator(
                      onRefresh: () {
                        return _refresher();
                      },
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: <Widget>[
                          Center(
                            child: Container(
                              padding: EdgeInsets.all(10.0),
                              margin: EdgeInsets.all(10.0),
                              child: const NeuText(
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
                            child: Container(
                              // color: Colors.amber,
                              padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                              height: 220,
                              width: double.maxFinite,
                              child: Card(
                                color: Colors.transparent,
                                elevation: 5,
                                child: NeuText(
                                  snapshot.data.main.pressure.toString() + ' hPa',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w100,
                                      fontSize: 70.0),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            height: 100,
                            alignment: Alignment.center,
                            child: NeuText('test'),
                          ),
                          Container(
                            // constraints: BoxConstraints.expand(),
                            height: 100,
                            // width: 50,
                            alignment: Alignment.center,
                            child:
                            snapshot.data.weather[0].main == 'clouds' ?
                            NeuText('Cloudy',
                            style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w100,
                                  fontSize: 70.0),)
                            : snapshot.data.weather[0].main.toString() == 'Clear Sky' ?
                            NeuText('Sunny',
                            style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w100,
                                  fontSize: 70.0),)
                            : snapshot.data.weather[0].main.toString() == 'Rain' ?
                            NeuText('Rainy',
                            style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w100,
                                  fontSize: 70.0),)
                            
                             : NeuText(snapshot.data.weather[0].main.toString(),
                             style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w100,
                                  fontSize: 30,
                                  ),),
                          ),
                          SizedBox(height: 60.0),
                          Center(


                            child:
                            snapshot.data.main.pressure < 1008 ? 
                            NeuText('今日は地獄です',



                              style: TextStyle(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.w100,
                                  fontSize: 18.0),
                            )
                            : Center(child: Text('今日は天国です',style: TextStyle(
                              color: Colors.black,
                            ),)),
                          ),
                          SizedBox(
                            height: 24.0,
                          ),
                          Center(
                            // 5日分の天気データ
                            child: Text(_res2,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w100)),
                          ),
                          Center(
                            child: Text(
                              "最終更新 - " + timeago.format(updatedAt).toString(),
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w100),
                            ),
                          ),
                          Center(
                            child: NeuText(
                              _res2,
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
                    child: const NeuText('データが存在しません'),
                  );
                }
              }),
          floatingActionButton: FutureBuilder<WeatherClass>(
            future: getWeather(),
            builder: (context, snapshot) {
              return NeuBackButton(
                  // child: Icon(Icons.share),
                  onPressed: () {
                    // sns share button
                    // https://qiita.com/shimopata/items/142b39bab6176b6a5da9
                    Share.share(snapshot.data.main.pressure.toString() + 'hPa is 低気圧しんどいぴえん🥺️ #thekiatsu');
                    // Wiredash.of(context).show();
                  });
            }
          ),
        ));
  }
}
