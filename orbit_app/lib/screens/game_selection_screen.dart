import 'package:flutter/material.dart';

class GameSelectionScreen extends StatelessWidget {
  const GameSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String ageGroup = ModalRoute.of(context)!.settings.arguments as String;
    Map<String, List<String>> games = {
      "4-6": ["Shape Sorter", "Color Match"],
      "6-8": ["Math Ninjas", "Word Puzzle"],
      "8-10": ["Memory Challenge", "Sudoku"],
      "10-12": ["Code Quest", "Brain Teasers"],
    };

    return Scaffold(
      appBar: AppBar(title: Text("Games for Age $ageGroup")),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: games[ageGroup]?.length ?? 0,
        itemBuilder: (context, index) {
          return ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/play', arguments: games[ageGroup]![index]);
            },
            child: Text(games[ageGroup]![index]),
          );
        },
      ),
    );
  }
}
