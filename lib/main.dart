import 'package:flutter/material.dart';
import 'package:matchinggcard/splash.dart';
import 'level_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Splash(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: ElevatedButton(onPressed: (){
          //Navigate to the LevelScreen
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LevelScreen()),
          );
        }, child: const Text('Go to Levels'),
        ),
      ),
    );
  }
}

