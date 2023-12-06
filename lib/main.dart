import 'package:detector/i.dart';
import 'package:detector/loading.dart';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'infos.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    
  //   Vibration.vibrate(duration: 2000);
  //   Future.delayed(const Duration(seconds: 2), () {
  //   Vibration.vibrate(duration: 4000);
  // });
    // Vibration.vibrate(duration: 2000);
    // Vibration.vibrate(duration: 2000);
    return MaterialApp(
      
      debugShowCheckedModeBanner: false,
      home: LogoScreen(),
    );
  }
}