import 'package:flutter/material.dart' ;
import 'package:matchinggcard/level_screen.dart';
import 'package:matchinggcard/main.dart';

class Splash extends StatefulWidget {
   Splash({super.key});

  @override
  State<Splash> createState() => _splashState();
}

class _splashState extends State<Splash> {
  @override
  void initState(){
    super.initState();
    Future.delayed(const Duration(seconds: 3), (){
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LevelScreen() ),
      );
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset('assets/splash.jpg'),
      ),
    );
  }
}

