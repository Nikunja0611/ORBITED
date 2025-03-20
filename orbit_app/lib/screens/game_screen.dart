import 'package:flutter/material.dart';

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String ageGroup = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        title: Text("Games for Age $ageGroup"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/game_background.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Show only Story Puzzle & Number Ninja for 4-6 and 6-8
                if (ageGroup == "4-6" || ageGroup == "6-8") ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _gameButton(context, "Story Puzzle", "assets/story_puzzle.png", "/storyPuzzle1"),
                      const SizedBox(width: 20),
                      _gameButton(context, "Number Ninja", "assets/number_ninja.png", "/numberNinja"),
                    ],
                  ),
                ] else ...[
                  // Show all games for other age groups
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _gameButton(context, "Story Puzzle", "assets/story_puzzle.png", "/storyPuzzle1"),
                      _gameButton(context, "Word Hunt", "assets/word_hunt.png", "/wordHunt"),
                      _gameButton(context, "Math Frenzy", "assets/math_frenzy.png", "/mathFrenzy"),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _gameButton(context, "Phantom Spellers", "assets/phantom_spellers.png", "/phantomSpellers"),
                      _gameButton(context, "Number Ninja", "assets/number_ninja.png", "/numberNinja"),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _gameButton(BuildContext context, String title, String imagePath, String route) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, route);
      },
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(2, 4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
