import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_tts/flutter_tts.dart';


void main() {
  runApp(const WordWizardApp1());
}


class WordWizardApp1 extends StatelessWidget {
  const WordWizardApp1({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Word Wizard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const WordWizardGame(),
      debugShowCheckedModeBanner: false,
    );
  }
}


class WordWizardGame extends StatefulWidget {
  const WordWizardGame({Key? key}) : super(key: key);


  @override
  _WordWizardGameState createState() => _WordWizardGameState();
}


class _WordWizardGameState extends State<WordWizardGame> {
  int level = 1;
  int correctAnswers = 0;
  String currentWord = '';
  List<String> displayedLetters = [];
  List<String> selectedLetters = [];
  bool isGameOver = false;
  late FlutterTts flutterTts;


  final List<String> level1Words = ['cat', 'dog', 'sun', 'hat', 'bat'];
  final List<String> level2Words = ['frog', 'star', 'fish', 'bear'];


  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    flutterTts.setLanguage("en-US");
    startNewGame();
  }


  void startNewGame() {
    setState(() {
      level = 1;
      correctAnswers = 0;
      isGameOver = false;
      pickNewWord();
    });
  }


  void pickNewWord() {
    final random = Random();
    currentWord = (level == 1)
        ? level1Words[random.nextInt(level1Words.length)]
        : level2Words[random.nextInt(level2Words.length)];


    selectedLetters = List.filled(currentWord.length, '');
    displayedLetters = currentWord.split('')..shuffle();


    // Add a few extra random letters to make the game more challenging
    if (!isGameOver) {
      final extraLetters = ['a', 'e', 'i', 'o', 'u', 'b', 'c', 'd', 'f', 'g'];
      final numberOfExtras = level == 1 ? 2 : 4;


      for (int i = 0; i < numberOfExtras; i++) {
        displayedLetters.add(extraLetters[random.nextInt(extraLetters.length)]);
      }
      displayedLetters.shuffle();
    }
  }


  void speakWord(String word) async {
    await flutterTts.speak(word);
    await Future.delayed(Duration(milliseconds: 800));
    for (int i = 0; i < word.length; i++) {
      await flutterTts.speak(word[i]);
      await Future.delayed(Duration(milliseconds: 600));
    }
  }


  void selectLetter(String letter, int index) {
    if (isGameOver) return;


    setState(() {
      int emptyIndex = selectedLetters.indexOf('');
      if (emptyIndex != -1) {
        selectedLetters[emptyIndex] = letter;
        displayedLetters[index] = '';


        // Check if all displayed letters are used (check correctly for empty strings)
        bool anyLettersRemain = false;
        for (String letter in displayedLetters) {
          if (letter.isNotEmpty) {
            anyLettersRemain = true;
            break;
          }
        }


        if (!anyLettersRemain && selectedLetters.contains('')) {
          // All letters are used but word is incomplete
          setState(() {
            isGameOver = true;
            flutterTts.speak("Game over! No more letters available.");
          });
        }


        // Check if word is complete
        if (!selectedLetters.contains('')) {
          checkAnswer();
        }
      }
    });
  }


  void unselectLetter(int index) {
    if (isGameOver) return;
    if (selectedLetters[index] == '') return;


    setState(() {
      String letter = selectedLetters[index];
      // Find first empty slot in displayed letters
      int emptyIndex = displayedLetters.indexOf('');
      if (emptyIndex != -1) {
        displayedLetters[emptyIndex] = letter;
      } else {
        displayedLetters.add(letter);
      }
      selectedLetters[index] = '';
    });
  }


  void checkAnswer() {
    if (selectedLetters.contains('')) return;


    if (selectedLetters.join() == currentWord) {
      setState(() {
        correctAnswers++;
      });
      flutterTts.speak("Correct! Great job!");
      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          if (correctAnswers >= 5) {
            level = level < 2 ? 2 : level;
            correctAnswers = 0;
          }
          pickNewWord();
        });
      });
    } else {
      flutterTts.speak("Try again!");
      // Don't clear selected letters, let the user manually unselect them
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Word Wizard')),
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  'Level $level',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Words: $correctAnswers/5',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => speakWord(currentWord),
                  icon: Icon(Icons.volume_up),
                  label: Text("Spell the word"),
                ),
                SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: startNewGame,
                  icon: Icon(Icons.refresh),
                  label: Text("Restart"),
                ),
              ],
            ),
            SizedBox(height: 30),
            if (isGameOver)
              Container(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                color: Colors.amber[100],
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Game Over!',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Text('The word was: $currentWord'),
                    Text('You completed $correctAnswers words'),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: startNewGame,
                      child: Text('Start New Game'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ],
                ),
              )
            else
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      currentWord.length,
                      (index) => GestureDetector(
                        onTap: () => unselectLetter(index),
                        child: Container(
                          width: 50,
                          height: 50,
                          margin: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.blue, width: 2),
                            borderRadius: BorderRadius.circular(8),
                            color: selectedLetters[index].isNotEmpty
                                ? Colors.lightBlue[50]
                                : Colors.white,
                          ),
                          child: Center(
                            child: Text(
                              selectedLetters[index],
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text('Available Letters:'),
                ],
              ),
            Expanded(
              child: !isGameOver
                  ? GridView.builder(
                      padding: EdgeInsets.all(10),
                      itemCount: displayedLetters.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        childAspectRatio: 1.5,
                      ),
                      itemBuilder: (context, index) {
                        return displayedLetters[index].isEmpty
                            ? Container()
                            : GestureDetector(
                                onTap: () => selectLetter(
                                    displayedLetters[index], index),
                                child: Container(
                                  margin: EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black),
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.blue[100],
                                  ),
                                  child: Center(
                                    child: Text(
                                      displayedLetters[index],
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                      },
                    )
                  : Container(),
            ),
          ],
        ),
      ),
    );
  }
}