import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'database_helper.dart';


int _start = 60;
late Timer _gameTimer;
bool _isGameOver = false;
bool _timerStarted = false;
bool _isPaused = false;
AudioPlayer audioPlayer = AudioPlayer();
bool _canFlip = true;

class CardModel {
  final String image;
  bool isFlipped;
  bool isMatched;

  CardModel({required this.image, this.isFlipped = false, this.isMatched = false});
}

class MainPage extends StatefulWidget {
  final int level;
  final List<String> images;

  MainPage({required this.level, required this.images});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<CardModel> cards = [];
  CardModel? firstSelectedCard;
  CardModel? secondSelectedCard;
  int matchesFound = 0;
  Map<int, bool> levelCompletionStatus = {};
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _initializeCards();
    _loadLevelStatus(); // Load completion data on game start

  }



  void _loadLevelStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    for (int i = 1; i <= 10; i++) { // Assuming 10 levels
      // Only unlock level 1 initially, lock all others
      levelCompletionStatus[i] = prefs.getBool('level_$i') ?? (i == 1);
    }
    setState(() {}); // Refresh UI with loaded data
  }


  Future<void> unlockNextLevel(int completedLevel) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('level_$completedLevel', true); // Mark current level as completed
    levelCompletionStatus[completedLevel] = true;

    // Unlock the next level if it exists
    if (levelCompletionStatus.containsKey(completedLevel + 1)) {
      await prefs.setBool('level_${completedLevel + 1}', true); // Unlock the next level
      levelCompletionStatus[completedLevel + 1] = true;
    }

    setState(() {}); // Refresh UI with updated data
  }



  int getTimeForLevel(int level) {
    if (level == 1) return 60;
    if (level == 2) return 45;
    if (level <= 9) return 30;
    return 20; // For level 10
  }

  void _initializeCards() {
    final allImages = [...widget.images, ...widget.images];
    allImages.shuffle(Random());

    setState(() {
      cards = allImages.map((image) => CardModel(image: image)).toList();
      firstSelectedCard = null;
      secondSelectedCard = null;
      matchesFound = 0;
      _isGameOver = false;
      _isPaused = false;
      _start = getTimeForLevel(widget.level); // Set the time based on level
      _timerStarted = false;
    });
  }



  void _onCardTap(CardModel card) {
    if (_isPaused || _isGameOver || card.isFlipped || card.isMatched || !_canFlip) return;

    if (!_timerStarted) {
      _startTimer();
      _timerStarted = true;
    }

    setState(() {
      card.isFlipped = true;
    });

    if (firstSelectedCard == null) {
      firstSelectedCard = card;
    } else if (secondSelectedCard == null && card != firstSelectedCard) {
      secondSelectedCard = card;
      _canFlip = false;

      if (firstSelectedCard!.image == secondSelectedCard!.image) {
        setState(() {
          firstSelectedCard!.isMatched = true;
          secondSelectedCard!.isMatched = true;
          matchesFound++;

          firstSelectedCard = null;
          secondSelectedCard = null;
          _canFlip = true;

          if (matchesFound == widget.images.length) {
            _gameTimer.cancel();
            _isGameOver = true;
            _showPerformanceDialog();
          }
        });
      } else {
        Future.delayed(Duration(seconds: 1), () {
          setState(() {
            firstSelectedCard!.isFlipped = false;
            secondSelectedCard!.isFlipped = false;
            firstSelectedCard = null;
            secondSelectedCard = null;
            _canFlip = true;
          });
        });
      }
    }
  }

  void _startTimer() {
    _gameTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() {
          _isGameOver = true;
          _gameTimer.cancel();
          _showGameOverDialog();
        });
      } else {
        if (!_isPaused) {
          setState(() {
            _start--;
          });
        }
      }
    });
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Game Over"),
          content: Text("Time's up! Better luck next time."),
          actions: <Widget>[
            TextButton(
              child: Text("Restart"),
              onPressed: () {
                Navigator.of(context).pop();
                _restartGame();
              },


            ),

          ],
        );
      },
    );
  }

  void _restartGame() {
    _gameTimer.cancel();
    _initializeCards();
    _startTimer();
  }

  Future<bool> _onWillPop() async {
    _pauseGame();
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Pause Menu"),
        content: Text("Game is paused. What would you like to do?"),
        actions: <Widget>[
          TextButton(
            child: Text("Resume"),
            onPressed: () {
              Navigator.of(context).pop(false);
              _resumeGame();
            },
          ),
          TextButton(
            child: Text("Restart"),
            onPressed: () {
              Navigator.of(context).pop(false);
              _restartGame();
            },
          ),
          TextButton(
            child: Text("Exit"),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              Navigator.of(context).pop(true); // Navigate back to level screen
            },
          ),
        ],
      ),
    ) ?? false;
  }

  void _pauseGame() {
    setState(() {
      _isPaused = true;
      _gameTimer.cancel(); // Stop the timer when paused
    });
  }

  // Resume the game
  void _resumeGame() {
    setState(() {
      _gameTimer.cancel();
      _isPaused = false;
      _startTimer(); // Restart the timer
    });
  }

  // Show the pause dialog when the user clicks the pause button
  void _showPauseDialog() {
    _pauseGame(); // Pause the game
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Pause Menu"),
          content: Text("Game is paused. What would you like to do?"),
          actions: <Widget>[
            TextButton(
              child: Text("Resume"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _resumeGame(); // Resume the game
              },
            ),
            TextButton(
              child: Text("Restart"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _restartGame(); // Restart the game
              },
            ),
            TextButton(
              child: Text("Exit"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pop(false); // Navigate back to level screen
              },
            ),
          ],
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    // Get the screen width to adjust card size dynamically
    double screenWidth = MediaQuery.of(context).size.width;

    // Set crossAxisCount and aspectRatio based on screen width and card count
    int crossAxisCount;
    double aspectRatio;


    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Stack(
          children: [
            // Background image (placed behind everything else)
            Positioned.fill(
              child: Image.asset(
                'assets/level_background1.jpg', // Replace with your background image path
                fit: BoxFit.cover, // Make sure the image covers the screen
              ),
            ),
            // Your original UI elements go here
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 40.0, bottom: 8.0),
                  child: Center(
                    child: Text(
                      'Level: ${widget.level}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 10.0,
                            color: Colors.black,
                            offset: Offset(2.0, 2.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Time: $_start',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.pause, color: Colors.white),
                        onPressed: _showPauseDialog, // Show pause dialog
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Center( // Center the grid to align visually
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0),
                      constraints: BoxConstraints(maxWidth: 600), // Limit max width for consistent look
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.8,
                          crossAxisSpacing: 8.0,
                          mainAxisSpacing: 8.0,
                        ),
                        itemCount: cards.length,
                        itemBuilder: (context, index) {
                          final card = cards[index];
                          return GestureDetector(
                            onTap: () {
                              _onCardTap(card);
                            },
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: AnimatedSwitcher(
                                duration: Duration(milliseconds: 300),
                                child: card.isFlipped || card.isMatched
                                    ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.asset(
                                    card.image,
                                    key: ValueKey(card.image),
                                    fit: BoxFit.cover, // Ensures image fills the card completely
                                  ),
                                )
                                    : Container(
                                  decoration: BoxDecoration(
                                    color: Color(0xFF4F5464),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  key: ValueKey('hidden-$index'),
                                  child: Center(
                                    child: Text(
                                      '?',
                                      style: TextStyle(fontSize: 24, color: Color(0xFFFEFCF6)),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }



  void _showPerformanceDialog() {
    int stars = _calculateStars();
    unlockNextLevel(widget.level);

    //save star rating to database
    DatabaseHelper.instance.updateStars(widget.level, stars);


    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Performance"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("You earned $stars star${stars > 1 ? 's' : ''}!"),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return Icon(
                    index < stars ? Icons.star : Icons.star_border,
                    color: Colors.yellow,
                    size: 30,
                  );
                }),
              ),
            ],
          ),
          actions: <Widget>[


            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pop(true); // Navigate back to level screen
              },
            ),

            TextButton(
              child: Text("Restart"),
              onPressed: () {
                Navigator.of(context).pop(false);
                _restartGame();
              },
            ),

          ],
        );
      },
    );
  }

  int _calculateStars() {
    if (_start > 30) {
      return 3;
    } else if (_start > 15) {
      return 2;
    } else {
      return 1;
    }
  }
}
