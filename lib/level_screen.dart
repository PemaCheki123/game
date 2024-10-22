import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:share_plus/share_plus.dart';
import 'avatar_selection.dart';
import 'database_helper.dart';
import 'main_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LevelScreen extends StatefulWidget {
  late String nickname;
  late  String avatar;

  LevelScreen({
    super.key,
    required this.nickname,
    required this.avatar,
  });

  @override
  _LevelScreenState createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen> {
  final AudioPlayer audioPlayer = AudioPlayer();
  bool isSoundEnabled = true;
  Map<int, bool> levelCompletionStatus = {};
  Map<int, int> levelStars = {};



  final List<String> avatars = [
    'assets/avater1.gif',
    'assets/avater2.gif',
    'assets/avater3.gif',
    'assets/avater4.gif',
    'assets/avater5.gif',
    'assets/avater6.gif',
  ];


  final List<Map<String, dynamic>> levels = [
    {
      'level': 1,
      'numPairs': 4,
      'images': [
        'assets/card1.jpg',
        'assets/card2.jpg',
        'assets/card3.jpg',
        'assets/card4.jpg'
      ],
      'position': Offset(120, 1)
    },
    {
      'level': 2,
      'numPairs': 6,
      'images': [
        'assets/card1.jpg',
        'assets/card2.jpg',
        'assets/card3.jpg',
        'assets/card4.jpg',
        'assets/card5.jpg',
      ],
      'position': Offset(250, 70)
    },
    {
      'level': 3,
      'numPairs': 6,
      'images': [
        'assets/card1.jpg',
        'assets/card2.jpg',
        'assets/card3.jpg',
        'assets/card4.jpg',
        'assets/card5.jpg',
        'assets/card6.jpg'
      ],
      'position': Offset(220, 170)
    },
    {
      'level': 4,
      'numPairs': 6,
      'images': [
        'assets/card1.jpg',
        'assets/card2.jpg',
        'assets/card3.jpg',
        'assets/card4.jpg',
        'assets/card5.jpg',
        'assets/card6.jpg'
      ],
      'position': Offset(45, 290)
    },
    {
      'level': 5,
      'numPairs': 6,
      'images': [
        'assets/card1.jpg',
        'assets/card2.jpg',
        'assets/card3.jpg',
        'assets/card4.jpg',
        'assets/card5.jpg',
        'assets/card6.jpg'
      ],
      'position': Offset(260, 340)
    },
    {
      'level': 6,
      'numPairs': 6,
      'images': [
        'assets/card1.jpg',
        'assets/card2.jpg',
        'assets/card3.jpg',
        'assets/card4.jpg',
        'assets/card5.jpg',
        'assets/card6.jpg'
      ],
      'position': Offset(100, 440)
    },
  ];
  @override
  void initState() {
    super.initState();
    loadUserData();
    loadLevelStatus();
    DatabaseHelper.instance.initializeLevelStatus();
  }

  void showEditDialog() {
    TextEditingController nicknameController = TextEditingController(text: widget.nickname);
    String selectedAvatar = widget.avatar; // Temporary variable to hold the selected avatar
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFFBAD6EB),
          title: const Text('Edit Profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Avatar Selection
              Text(
                'Select an Avatar:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: avatars.map((avatar) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {

                          selectedAvatar = avatar; // Update the temporary avatar selection

                      });

                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: selectedAvatar == avatar
                              ? Colors.blueAccent
                              : Colors.transparent,
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Image.asset(
                        avatar,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              // Nickname Input
              TextField(
                controller: nicknameController,
                decoration: InputDecoration(
                  labelText: 'Enter Nickname',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (newNickname) {

                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Save the updated nickname and avatar to SQLite
                await DatabaseHelper.instance.updateUser({
                  DatabaseHelper.columnNickname: nicknameController.text,
                  DatabaseHelper.columnAvatar: selectedAvatar,
                });

                // Update the actual widget.nickname and widget.avatar only after save
                setState(() {
                  widget.nickname = nicknameController.text;
                  widget.avatar = selectedAvatar;
                });

                Navigator.of(context).pop();
                loadUserData();  // Reload the user data from the database
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
  // Load user data from SQLite
  Future<void> loadUserData() async {
    var userData = await DatabaseHelper.instance.queryAllRows();
    if (userData.isNotEmpty) {
      var user = userData.first; // Assuming there's only one user
      setState(() {
        widget.nickname = user[DatabaseHelper.columnNickname];
        widget.avatar = user[DatabaseHelper.columnAvatar];
      });
    }
  }

  // Load level status from SQLite
  Future<void> loadLevelStatus() async {
    for (var level in levels) {
      int levelNumber = level['level'];
      bool isUnlocked = await DatabaseHelper.instance.isLevelUnlocked(levelNumber);
      int stars = await DatabaseHelper.instance.getStars(levelNumber);
      setState(() {
        levelCompletionStatus[levelNumber] = isUnlocked;
        levelStars[levelNumber] = stars;
      });
    }
  }

  // Unlock the next level
  Future<void> unlockNextLevel(int currentLevel) async {
    int nextLevel = currentLevel + 1;
    await DatabaseHelper.instance.updateLevelStatus(nextLevel, true);

    setState(() {
      levelCompletionStatus[nextLevel] = true;
    });
  }

  void playBackgroundMusic() async {
    if (isSoundEnabled) {
      await audioPlayer.setReleaseMode(ReleaseMode.loop);
      await audioPlayer.play(AssetSource('background_music.mp3'));
    }
  }

  @override
  void dispose() {
    audioPlayer.stop();
    super.dispose();
  }
//showing the setting dialog
  void showSoundSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFFBAD6EB),
          title: const Text('Settings'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SwitchListTile(
                title: const Text('Enable Sound'),
                value: isSoundEnabled,
                onChanged: (value) {
                  setState(() {
                    isSoundEnabled = value;
                  });
                  // Update the sound settings in the main LevelScreen state
                  if (isSoundEnabled) {
                    playBackgroundMusic();
                  } else {
                    audioPlayer.stop();
                  }
                },
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void shareApp() {
    Share.share(
      'Check out this amazing game! Play now and join me in the fun!',
      subject: 'Amazing Game Recommendation',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Opacity(
              opacity: 1,
              child: Image.asset(
                'assets/level_background.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Main content
          Column(
            children: [
              // Add SizedBox to shift the container down
              SizedBox(height: 30),  // Adjust this value as needed to shift the content down

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 24),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                          decoration: BoxDecoration(
                            color: Color(0xFFCDB89D),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  widget.avatar,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 9),
                              Expanded(
                                child: Text(
                                  widget.nickname,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.white),
                                onPressed: showEditDialog,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0xFFCDB89D).withOpacity(0.8),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.settings, color: Colors.white),
                          onPressed: showSoundSettingsDialog,
                        ),
                      ),
                      const SizedBox(height: 8), // Spacing between icons
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0xFFBAD6EB).withOpacity(0.8),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.share, color: Colors.white),
                          onPressed: shareApp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Expanded(
                child: Stack(
                  children: levels.map((level) {
                    int levelNumber = level['level'];
                    Offset position = level['position'];

                    return Positioned(
                      left: position.dx,
                      top: position.dy,
                      child: Column(
                        children: [
                          ElevatedButton(
                            onPressed: levelCompletionStatus[levelNumber] == true
                                ? () async {
                              bool isCompleted = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MainPage(
                                    level: levelNumber,
                                    images: level['images'],
                                  ),
                                ),
                              );
                              if (isCompleted) {
                                await unlockNextLevel(levelNumber);
                                await loadLevelStatus();
                              }
                            }
                                : null,
                            child: Text(
                              'Level $levelNumber',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              shape: const CircleBorder(),
                              backgroundColor: Color(0xFFBAD6EB),
                              padding: const EdgeInsets.all(20),
                              shadowColor: Colors.black.withOpacity(0.4),
                              elevation: 10,
                              side: BorderSide(
                                color: Colors.white,
                                width: 3,
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              levelStars[levelNumber] ?? 0,
                                  (index) => Container(
                                margin: EdgeInsets.symmetric(horizontal: 1), // Space between stars
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Black outline star in the background
                                    Icon(
                                      Icons.star,
                                      color: Colors.black,
                                      size: 30, // Slightly larger for outline effect
                                    ),
                                    // Actual star icon in front
                                    Icon(
                                      Icons.star,
                                      color: Color(0xFFFFA500), // Bright color for visibility
                                      size: 24, // Smaller size to create the outline effect
                                      shadows: [
                                        Shadow(
                                          offset: Offset(2, 2),  // Slight offset for 3D effect
                                          blurRadius: 4,
                                          color: Colors.black.withOpacity(0.5), // Soft shadow for depth
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),


                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


}






























