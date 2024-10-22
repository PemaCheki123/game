import 'package:flutter/material.dart';

import 'main_page.dart';


class LevelScreen extends StatelessWidget{
   LevelScreen({super.key});

  final List<Map<String, dynamic>> levels = [
    {
      'level' : 1,
      'numPairs' : 4,
      'images' : ['assets/Rat.jpg','assets/Gorila.jpg','assets/Elephant.jpg','assets/Dog.jpg'],
    },
    {
      'level' : 2,
      'numPairs' : 6,
      'images' : ['assets/Rat.jpg','assets/Gorila.jpg','assets/Elephant.jpg','assets/Dog.jpg','assets/Bird.jpg','assets/cactus.jpg'],
    },
  ];

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Levels'),
        actions: [
         IconButton(
             icon: const Icon(Icons.settings),
          onPressed: (){
           Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingScreen())
           );
         },
         ),

        ],
      ),
      body: ListView(

        padding: const EdgeInsets.all(16.0),
        children: List.generate(levels.length, (index){
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ElevatedButton(
              onPressed: (){
               //Navigate to the main page
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MainPage(
                        level : levels[index]['level'],
                    images: levels[index]['images'],
                    ),
                    ),
                );

              },
              child: Text('Level ${levels[index]['level']}'),
            ),
          );
        }),
      ),

    );
  }

}

class SettingScreen extends StatelessWidget{
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setting'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),

        children: [
          ListTile(
            title: const Text('Option 1'),
            onTap: (){
              //Handle option 1 action
            },
          ),
          ListTile(
            title: const Text('Options 2'),
            onTap: (){
              //handle option 2 action
            },
          ),
          ListTile(
            title: const Text('Option 3'),
            onTap: (){
              //Handle option 3 action
            },
          )
        ],
      ),
    );
  }
}