import 'package:flutter/material.dart';
import 'dart:math';

//Model for the card
class CardModel{
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

  @override
  void initState() {
    super.initState();
    _initializeCards();
  }


  void _initializeCards() {
    //Duplicate and shuffle the images for the game
    final allImages = [...widget.images, ...widget.images];
    allImages.shuffle(Random());

    cards = allImages.map((image) => CardModel(image: image)).toList();
  }

  void _onCardTap(CardModel card) {
    if (firstSelectedCard == null) {
      //first card selection
      setState(() {
        card.isFlipped = true;
        firstSelectedCard = card;
      });
    } else if (secondSelectedCard == null && card != firstSelectedCard) {
      //Second card selection
      setState(() {
        card.isFlipped = true;
        secondSelectedCard = card;

        //Check for match
        if (firstSelectedCard!.image == secondSelectedCard!.image) {
          firstSelectedCard!.isMatched = true;
          secondSelectedCard!.isMatched = true;
          matchesFound++;

          //Reset selection
          firstSelectedCard = null;
          secondSelectedCard = null;
        } else {
          //Flip back after a delay
          Future.delayed(Duration(seconds: 1), () {
            setState(() {
              firstSelectedCard!.isFlipped = false;
              secondSelectedCard!.isFlipped = false;
              firstSelectedCard = null;
              secondSelectedCard = null;
            });
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Level ${widget.level}")),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1,
        ),
        itemCount: cards.length,
        itemBuilder: (context, index) {
          final card = cards[index];
          return GestureDetector(
            onTap: () => _onCardTap(card),
            child: Card(
              elevation: 4,
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                child: card.isFlipped || card.isMatched
                    ? Image.asset(
                  card.image,
                  key: ValueKey(card.image),
                  fit: BoxFit.cover,
                )
                    : Container(
                  color: Color(0xFF4F5464),
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
    );
  }

}
