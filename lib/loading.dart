import 'package:detector/infos.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LogoScreen(),
    );
  }
}

class LogoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 5), () {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => connection_GetData(), // صفحه جدید
      ));
    });
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/images/helal.png',height: 400.0), // جایگزین 'assets/logo.png' با مسیر فایل لوگو شما
            // SizedBox(height: 50.0),
            Text(
              'هلال، نشان امید',
              style: TextStyle(fontSize: 50.0, fontFamily: "irannastaliq"),
            ),
          ],
        ),
      ),
    );
  }
}
