import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:vibration/vibration.dart';

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

  late Color col = Colors.green;

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

                  if (gas > 450)
                  {
                    Vibration.vibrate(pattern: [100, 200, 400], repeat: 1);
                    col = Colors.red;
                  }
                  else
                  {
                    Vibration.cancel();
                    col = Colors.green;
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
    return Stack(
      textDirection: TextDirection.rtl,
      alignment: AlignmentDirectional.topCenter,
      children: <Widget>[
        Container(
          
            child: Column(children: [
          connected
              ? Text("\nمتصل به دستگاه"+ "\n", style: TextStyle(
                fontFamily: 'iransans',
                fontSize: 14.0,
              ),)
              : Text("\n!اتصال به دستگاه برقرار نیست" + "\n", style: TextStyle(
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
                    child:Text("دما: " + temperature.toString() + "\n" + "رطوبت: " + humidity.toString(), style: TextStyle(
                fontFamily: 'iransans',
                fontSize: 15.0,
              )))),
          // Text("دما: " + temperature.toString()),
          // Text("رطوبت: " + humidity.toString()),
          Container(
          margin: EdgeInsets.all(100.0),
          padding: EdgeInsets.all(50),
          child: Text(gas.toString(), style: TextStyle(
                fontFamily: 'iransans',
                fontSize: 15.0,
              )),
          decoration: BoxDecoration(
            color: col,
            shape: BoxShape.circle
          ),),
         
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
            // child: TextButton(
            //   style: flatButtonStyle,
            //   child: Text(buttontext),
            //   onPressed: () => {
            //     if (buttontext == "توقف")
            //       {
            //         sendcmd("stop"),
            //       }
            //     else
            //       {
            //         sendcmd("start"),
            //       },
            //     _ChangeName()
            //   },
            // ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("دریافت اطلاعات", style: TextStyle(
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
