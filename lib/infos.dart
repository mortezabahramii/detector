import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
// import 'package:flutter_sound/flutter_sound.dart';
// import 'package:flutter_sound/public/flutter_sound_player.dart';
// import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:web_socket_channel/io.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:vibration/vibration.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class connection_GetData extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WebSocketDHT(),
    );
  }
}

//apply this class on home: attribute at MaterialApp()
class WebSocketDHT extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _WebSocketDHT();
  }
}

class _WebSocketDHT extends State<WebSocketDHT> {
  String buttontext = "توقف";
  void _ChangeName() {
    setState(() {
      buttontext = "از سر گیری";
    });
  }

  late double temperature; //variable for temperature
  late double humidity; //variable for humidity
  late double gas; //variable for heatindex
  // FlutterSoundPlayer audioPlayer = FlutterSoundPlayer();

  late Color col = Colors.green;
  late bool TT = false;
  late bool T = true;
  late int aaa = 0;

  AssetsAudioPlayer audioPlayer = AssetsAudioPlayer();

  late IOWebSocketChannel channel;
  late bool connected; //boolean value to track if WebSocket is connected

  late bool permissionGranted = false;

  @override
  void dispose() {
    // _timer.cancel();
    super.dispose();
  }

  @override
  void initState() {
    connected = false; //initially connection status is "NO" so its FALSE

    temperature = 0; //initial value of temperature
    humidity = 0; //initial value of humidity
    gas = 0; //initial value of heatindex

    Future.delayed(Duration.zero, () async {
      channelconnect(); //connect to WebSocket wth NodeMCU
    });
    super.initState();
  }

  channelconnect() {
    if (true) {
      //function to connect
      try {
        channel = IOWebSocketChannel.connect(
            "ws://192.168.0.1:81"); //channel IP : Port

        print("********");
        print(channel.ready);
        channel.stream.listen(
          (message) {
            print(message);
            // showmessage(message);
            setState(() {
              if (message == "connected") {
                connected = true; //message is "connected" from NodeMCU
              } else if (message.substring(0, 10) == "{'voltage-") {
                //check if the resonse has {'temp on it
                message = message.replaceAll(RegExp("'"), '"');
                Map<String, dynamic> jsondata =
                    json.decode(message); //decode json to array
                setState(() {
                  temperature =
                      double.parse(jsondata["voltage-R"]); //temperature value
                  humidity =
                      double.parse(jsondata["voltage-G"]); //humidity value
                  gas = double.parse(jsondata["voltage-B"]); //heatindex value
                  if (gas >= 450 && T) {
                    // aaa +=1;
                    // TT = true;
                    // if(aaa == 1)
                    // {
                    audioPlayer.open(
                        Audio(
                            'assets/music/alarm.mp3'), // Replace with the path to your audio file
                        loopMode: LoopMode.single,
                        volume: 100 // Loop indefinitely
                        );

                    _showMyDialog();
                    T = false;
                    // TT = false;
                    // }
                  } else {
                    
                    // T = false;
                    // audioPlayer.stop();
                    // aaa = 0;
                  }
                  if (gas >= 450) {
                    Vibration.vibrate(pattern: [100, 200, 400], repeat: 1);
                    col = Colors.red;
                    // TT = true;
//                     Timer.periodic(Duration(milliseconds: 26000), (timer) {
//   if (!audioPlayer.isStopped) {
//     audioPlayer.stopPlayer();
//     audioPlayer.startPlayer(
//       fromURI: 'assets/sound.mp3', // Replace with the path to your audio file
//       codec: Codec.mp3,
//       whenFinished: () {
//         // Handle loop completion or other events if needed.
//       },
//     );
//   }
// });
                    // player.loop("assets/music/alarm.mp3");
                    // player.
                    // if(TT)
                    // {
                    //   audioPlayer.open(
                    //   Audio(

                    //       'assets/music/alarm.mp3'), // Replace with the path to your audio file
                    //   loopMode: LoopMode.single,
                    //   volume: 100 // Loop indefinitely
                    // );
                    // TT = false;
                    // }
                    // player.play(AssetSource("assets/music/alarm.mp3"));
                    // Alarm.set(alarmSettings: alarmSettings)
                    // FlutterRingtonePlayer.play(fromAsset: "assets/music/alarm.mp3");
                  } else {
                    Vibration.cancel();
                    col = Colors.green;
                    // audioPlayer.stopPlayer();
                    // audioPlayer.stop();

                    // player.stop();
                    // FlutterRingtonePlayer.stop();
                  }
                });
              }
            });
          },
          onDone: () {
            //if WebSocket is disconnected
            showmessage("Web socket is closed");
            setState(() {
              connected = false;
            });
          },
          onError: (error) {
            showmessage(error.toString());
          },
        );
      } catch (_) {
        showmessage("error on connecting to websocket.");
      }
    }
  }

  final ButtonStyle flatButtonStyle = TextButton.styleFrom(
    foregroundColor: Colors.black87,
    minimumSize: Size(88, 36),
    padding: EdgeInsets.symmetric(horizontal: 16.0),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(2.0)),
    ),
  );

  void showmessage(String T) {
    Fluttertoast.showToast(
        msg: T,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 10,
        backgroundColor: Colors.blue,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('خطر'),
            content: const SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('اعلام وضعیت خطر'),
                  Text('لطفا سریعا اقدامات ایمنی لازم را انجام دهید'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('متوجه شدم'),
                onPressed: () {
                  audioPlayer.stop();
                  T = true;
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  Future<void> sendcmd(String cmd) async {
    if (connected == true) {
      channel.sink.add(cmd); //sending Command to NodeMCU
      //send command to NodeMCU
    } else {
      channelconnect();
      showmessage("Websocket is not connected.");
    }
  }

  double Calculate_A(double V, double V0) {
    return log(num.parse((V0 / V).toString()));
  }

  Widget _buildBody() {
    // audioPlayer.startPlayer(
    //   fromURI: 'assets/music/alarm.mp3', // Replace with the path to your audio file
    //   codec: Codec.mp3,
    //   whenFinished: () {
    //     // Handle loop completion or other events if needed.
    //   },);
    //   Timer.periodic(Duration(milliseconds: 26000), (timer) {
    // if (!audioPlayer.isStopped) {
    //   audioPlayer.stopPlayer();
    //   audioPlayer.startPlayer(
    //     fromURI: 'assets/music/alarm.mp3', // Replace with the path to your audio file
    //     codec: Codec.mp3,
    //     whenFinished: () {
    //       // Handle loop completion or other events if needed.
    //     },
    //   );
    // }
// });
    // audioPlayer.open(
    //                   Audio(
    //                       'assets/music/alarm.mp3'), // Replace with the path to your audio file
    //                   loopMode: LoopMode.single, // Loop indefinitely
    //                 );
    return Scaffold(
        body: SafeArea(
            child: Observer(
                builder: (_) => Stack(children: <Widget>[
                      Image(
                        image: AssetImage("assets/images/helal.png"),
                        height: 20,
                        width: 40,
                        fit: BoxFit.cover,
                      ),
                    ]))));

    return Stack(
      textDirection: TextDirection.rtl,
      alignment: AlignmentDirectional.topCenter,
      children: <Widget>[
        Container(
            child: Column(children: [
          connected
              ? Text(
                  "\nمتصل به دستگاه" + "\n",
                  style: TextStyle(
                    fontFamily: 'iransans',
                    fontSize: 14.0,
                  ),
                )
              : Text("\n!اتصال به دستگاه برقرار نیست" + "\n",
                  style: TextStyle(
                    fontFamily: 'iransans',
                    fontSize: 14.0,
                  )),
          Card(
              margin: EdgeInsets.all(5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              elevation: 2,
              child: Container(
                  padding: EdgeInsets.all(10),
                  child: Text(
                      "دما: " +
                          temperature.toString() +
                          "\n" +
                          "رطوبت: " +
                          humidity.toString(),
                      style: TextStyle(
                        fontFamily: 'iransans',
                        fontSize: 15.0,
                      )))),
          // Text("دما: " + temperature.toString()),
          // Text("رطوبت: " + humidity.toString()),
          Container(
            margin: EdgeInsets.all(100.0),
            padding: EdgeInsets.all(50),
            child: Text(gas.toString(),
                style: TextStyle(
                  fontFamily: 'iransans',
                  fontSize: 15.0,
                )),
            decoration: BoxDecoration(color: col, shape: BoxShape.circle),
          ),

          // Text("گاز: " + gas.toString()),
        ])),
        // Container(
        //   child: ,
        // ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            width: double.infinity,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // audioPlayer.open(
    //   Audio(
    //       'assets/music/alarm.mp3'), // Replace with the path to your audio file
    //   loopMode: LoopMode.single, // Loop indefinitely
    // );
    // audioPlayer.openPlayer();
    // audioPlayer.startPlayer(
    //   fromURI: 'assets/music/alarm.mp3', // Replace with the path to your audio file
    //   codec: Codec.mp3,
    //   whenFinished: () {
    //     // Handle loop completion or other events if needed.
    //   },);
    return Scaffold(
        body: SafeArea(
            child: Observer(
                builder: (_) => Stack(children: <Widget>[
                      Image(
                        image: AssetImage("assets/images/header.png"),
                        height: 250,
                        width: double.maxFinite,
                        fit: BoxFit.cover,
                      ),
                      SingleChildScrollView(
                        child: Container(
                          padding: EdgeInsets.only(top: 200),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  SizedBox(width: 10),
                                ],
                              ),
                              // SizedBox(height: 16),
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    color:
                                        const Color.fromARGB(255, 6, 64, 111),
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(24),
                                        topRight: Radius.circular(24))),
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      padding: EdgeInsets.all(16),
                                      child: Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(0, 16, 16, 16),
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: <Widget>[
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                // SizedBox(width: 16),
                                                ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                    child: connected
                                                        ? Text(
                                                            "\nمتصل به دستگاه" +
                                                                "\n",
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'iransans',
                                                              fontSize: 14.0,
                                                            ),
                                                          )
                                                        : Text(
                                                            "!اتصال به دستگاه برقرار نیست",
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'iransans',
                                                                fontSize: 14.0,
                                                                color: Colors
                                                                    .white),
                                                          )),
                                                SizedBox(width: 24),
                                                Container(
                                                    child: connected
                                                        ? Image(
                                                            image: AssetImage(
                                                                "assets/images/connected.png"),
                                                            width: 40,
                                                            height: 40,
                                                          )
                                                        : Image(
                                                            image: AssetImage(
                                                                "assets/images/disconnected.png"),
                                                            width: 40,
                                                            height: 40)),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: double.maxFinite,
                                      decoration: BoxDecoration(
                                          color: Colors.amber,
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(24),
                                              topRight: Radius.circular(24))),
                                      child: Container(
                                        width: double.maxFinite,
                                        height: 120,
                                        alignment: Alignment.topLeft,
                                        padding: EdgeInsets.all(20),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                        "دما: " +
                                                            temperature
                                                                .toString(),
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'iransans',
                                                            fontSize: 15.0)),
                                                    Image(
                                                      image: AssetImage(
                                                          "assets/images/temperature.png"),
                                                      height: 35,
                                                      width: 35,
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                        "رطوبت: " +
                                                            humidity.toString(),
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'iransans',
                                                            fontSize: 15.0)),
                                                    Image(
                                                      image: AssetImage(
                                                          "assets/images/humidity.png"),
                                                      height: 35,
                                                      width: 35,
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    // Container(
                                    //   color: Colors.white,
                                    //   margin: EdgeInsets.all(100.0),
                                    //   padding: EdgeInsets.all(50),
                                    //   child: Text(gas.toString(),
                                    //       style: TextStyle(
                                    //         fontFamily: 'iransans',
                                    //         fontSize: 15.0,
                                    //       )),
                                    //   decoration: BoxDecoration(
                                    //       color: col, shape: BoxShape.circle),
                                    // ),

                                    // Text("گاز: " + gas.toString()),
                                  ],
                                ),
                              ),
                              // Container(
                              //         color: Colors.white,
                              //         margin: EdgeInsets.all(100.0),
                              //         padding: EdgeInsets.all(50),
                              //         child: Text(gas.toString(),
                              //             style: TextStyle(
                              //               fontFamily: 'iransans',
                              //               fontSize: 15.0,
                              //             )),
                              //         decoration: BoxDecoration(
                              //             color: col, shape: BoxShape.circle),
                              //       ),
                            ],
                          ),
                        ),
                      ),
                      // Container(
                      //   child: Text("gas.toString()",
                      //       style: TextStyle(
                      //         color: Colors.red,
                      //         fontFamily: 'iransans',
                      //         fontSize: 15.0,
                      //       )),
                      // )
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          margin: EdgeInsets.all(100.0),
                          // padding: EdgeInsets.all(20),
                          alignment: Alignment.center,
                          width: double.maxFinite,
                          height: 100,
                          decoration:
                              BoxDecoration(color: col, shape: BoxShape.circle),
                          child: Text(gas.toString()),
                        ),
                      )
                    ]))));
    return Scaffold(
      appBar: AppBar(
        title: Text("دریافت اطلاعات",
            style: TextStyle(
              fontFamily: 'iransans',
            )),
        centerTitle: true,
        // actions: [
        //   IconButton(
        //     onPressed: () {
        //     },
        //     icon: Icon(Icons.download),
        //   )
        // ],
      ),
      body: _buildBody(),
    );
  }
}
