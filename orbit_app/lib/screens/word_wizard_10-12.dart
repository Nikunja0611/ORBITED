import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const WordWizardApp4());
}

class WordWizardApp4 extends StatelessWidget {
  const WordWizardApp4({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Word Wizard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const WordWizardGame(),
    );
  }
}

class WordWizardGame extends StatefulWidget {
  const WordWizardGame({Key? key}) : super(key: key);

  @override
  _WordWizardGameState createState() => _WordWizardGameState();
}

class WordData {
  final String word;
  final String hint;

  WordData(this.word, this.hint);
}

class LetterTile {
  final String letter;
  bool isSelected;
  final int id; // Unique ID for each tile

  LetterTile(this.letter, this.isSelected, this.id);
}

class _WordWizardGameState extends State<WordWizardGame> {
  final List<WordData> wordsList = [
    WordData('FLUTTER', 'A framework used for multi-platform app development'),
    WordData('DART', 'Programming language used by Flutter'),
    WordData('MOBILE', 'Type of device you can hold in your hand'),
    WordData('DEVELOPER', 'Person who writes code for software'),
    WordData('WIZARD', 'A person with magical powers'),
    WordData('MIGRANT', 'A person who travels away from home permanently'),
    WordData('ALGORITHM', 'A step-by-step procedure for solving a problem'),
    WordData('QUANTUM', 'The smallest discrete unit of a phenomenon'),
    WordData('COGNITION', 'The mental action of acquiring knowledge'),
    WordData('EPHEMERAL', 'Lasting for a very short time'),
    WordData('PRAGMATIC', 'Dealing with things sensibly and realistically'),
    WordData('AMBIGUOUS', 'Open to more than one interpretation'),
    WordData('RESILIENT', 'Able to recover quickly from difficulties'),
    WordData(
        'SYNTHESIS', 'Combination of components to form a connected whole'),
    WordData('PARADIGM', 'A typical example or pattern of something'),
    WordData('VERBOSE', 'Using more words than needed; wordy'),
    WordData('ANOMALY', 'Something that deviates from what is standard'),
    WordData('EMPATHY', 'The ability to understand feelings of another'),
    WordData('NOSTALGIA', 'A sentimental longing for the past'),
    WordData('DILIGENT', 'Having or showing care in one\'s work'),
    WordData('LETTER', 'A character representing one or more sounds'),
    WordData('BOOKKEEPER', 'Someone who records financial transactions'),
    WordData('BALLOON', 'An inflatable rubber bag often used at parties'),
    WordData('CLASSROOM', 'A room where students are taught'),
    WordData('FOOTBALL', 'A popular sport played with a ball'),
  ];

  late WordData currentWordData;
  late List<LetterTile> shuffledLetterTiles;
  List<int> selectedTileIds = []; // Store IDs of selected tiles
  List<String> guessedLetters = [];
  int score = 0;
  int hintPenalty = 10;
  bool isCorrect = false;
  bool showResult = false;
  String resultMessage = "";

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    final random = Random();
    currentWordData = wordsList[random.nextInt(wordsList.length)];
    shuffledLetterTiles = _createShuffledLetterTiles(currentWordData.word);
    selectedTileIds = [];
    guessedLetters = [];
    showResult = false;
    isCorrect = false;
    setState(() {});
  }

  List<LetterTile> _createShuffledLetterTiles(String word) {
    List<String> letters = word.split('');
    letters.shuffle();

    // Create letter tiles with unique IDs
    List<LetterTile> tiles = [];
    for (int i = 0; i < letters.length; i++) {
      tiles.add(LetterTile(letters[i], false, i));
    }

    return tiles;
  }

  void _getLetterHint() {
    // Find a letter in the word that hasn't been guessed yet
    List<String> wordLetters = currentWordData.word.split('');

    for (int i = 0; i < wordLetters.length; i++) {
      if (i >= guessedLetters.length || wordLetters[i] != guessedLetters[i]) {
        // Find an unused tile with this letter
        for (int j = 0; j < shuffledLetterTiles.length; j++) {
          if (!shuffledLetterTiles[j].isSelected &&
              shuffledLetterTiles[j].letter == wordLetters[i]) {
            setState(() {
              score = score > hintPenalty ? score - hintPenalty : 0;
              _selectTile(shuffledLetterTiles[j]);
              showResult = false;
            });
            return;
          }
        }
      }
    }
  }

  void _selectTile(LetterTile tile) {
    if (!tile.isSelected &&
        guessedLetters.length < currentWordData.word.length) {
      setState(() {
        tile.isSelected = true;
        selectedTileIds.add(tile.id);
        guessedLetters.add(tile.letter);
        showResult = false;
      });
    }
  }

  void _unselectLastTile() {
    if (selectedTileIds.isNotEmpty) {
      setState(() {
        int lastTileId = selectedTileIds.removeLast();
        for (var tile in shuffledLetterTiles) {
          if (tile.id == lastTileId) {
            tile.isSelected = false;
            break;
          }
        }
        guessedLetters.removeLast();
        showResult = false;
      });
    }
  }

  void _checkAnswer() {
    String guessedWord = guessedLetters.join();
    isCorrect = guessedWord == currentWordData.word;
    showResult = true;

    setState(() {
      if (isCorrect) {
        resultMessage = "Correct! Great job!";
        score += 100;
        // Delay starting a new game to show the correct result
        Future.delayed(const Duration(seconds: 2), () {
          _startNewGame();
        });
      } else {
        resultMessage = "Incorrect. Try again!";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsiveness
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 400;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Word Wizard'),
      ),
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          // Determine the appropriate size for letter tiles
          final tileSize = isSmallScreen ? 40.0 : 50.0;
          final fontSize = isSmallScreen ? 20.0 : 24.0;
          final letterBoxWidth = isSmallScreen ? 25.0 : 30.0;

          return Column(
            children: [
              // Score Display
              Container(
                margin: EdgeInsets.all(isSmallScreen ? 5 : 10),
                padding: EdgeInsets.all(isSmallScreen ? 10 : 15),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Score: $score',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Hint Display
              Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 10 : 20,
                    vertical: isSmallScreen ? 5 : 10),
                padding: EdgeInsets.all(isSmallScreen ? 10 : 15),
                decoration: BoxDecoration(
                  color: Colors.purple.shade100,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 3,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Hint:',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 3 : 5),
                    Text(
                      currentWordData.hint,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                      ),
                    ),
                  ],
                ),
              ),

              // Result Message (when shown)
              if (showResult)
                Container(
                  margin: EdgeInsets.symmetric(
                      vertical: isSmallScreen ? 5 : 10,
                      horizontal: isSmallScreen ? 10 : 20),
                  padding: EdgeInsets.all(isSmallScreen ? 5 : 10),
                  decoration: BoxDecoration(
                    color:
                        isCorrect ? Colors.green.shade100 : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    resultMessage,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 16 : 18,
                      fontWeight: FontWeight.bold,
                      color: isCorrect
                          ? Colors.green.shade800
                          : Colors.red.shade800,
                    ),
                  ),
                ),

              // Guessed Letters
              Container(
                margin: EdgeInsets.all(isSmallScreen ? 5 : 10),
                padding: EdgeInsets.all(isSmallScreen ? 10 : 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      currentWordData.word.length,
                      (index) => Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 3 : 5),
                        width: letterBoxWidth,
                        height: letterBoxWidth * 4 / 3,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          color: guessedLetters.length > index
                              ? Colors.lightBlue
                              : Colors.white,
                        ),
                        child: Text(
                          guessedLetters.length > index
                              ? guessedLetters[index]
                              : '',
                          style: TextStyle(
                              fontSize: isSmallScreen ? 16 : 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Shuffled Letters
              Expanded(
                child: Container(
                  margin: EdgeInsets.all(isSmallScreen ? 10 : 20),
                  child: SingleChildScrollView(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: isSmallScreen ? 5 : 10,
                      runSpacing: isSmallScreen ? 5 : 10,
                      children: shuffledLetterTiles.map((tile) {
                        return GestureDetector(
                          onTap: () {
                            if (!tile.isSelected &&
                                guessedLetters.length <
                                    currentWordData.word.length) {
                              _selectTile(tile);
                            }
                          },
                          child: Container(
                            width: tileSize,
                            height: tileSize,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color:
                                  tile.isSelected ? Colors.grey : Colors.amber,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              tile.letter,
                              style: TextStyle(
                                fontSize: fontSize,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),

              // Controls
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (guessedLetters.isNotEmpty) {
                          _unselectLastTile();
                        }
                      },
                      child: Row(
                        children: [
                          Icon(Icons.backspace, size: isSmallScreen ? 16 : 24),
                          SizedBox(width: isSmallScreen ? 3 : 5),
                          Text(
                            'Delete',
                            style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 5),
                    ElevatedButton(
                      onPressed: _getLetterHint,
                      child: Row(
                        children: [
                          Icon(Icons.lightbulb_outline,
                              size: isSmallScreen ? 16 : 24),
                          SizedBox(width: isSmallScreen ? 3 : 5),
                          Text(
                            'Hint',
                            style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 5),
                    // Check Answer Button
                    ElevatedButton(
                      onPressed:
                          guessedLetters.length == currentWordData.word.length
                              ? _checkAnswer
                              : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_outline,
                              size: isSmallScreen ? 16 : 24),
                          SizedBox(width: isSmallScreen ? 3 : 5),
                          Text(
                            'Check',
                            style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 5),
                    ElevatedButton(
                      onPressed: _startNewGame,
                      child: Row(
                        children: [
                          Icon(Icons.refresh, size: isSmallScreen ? 16 : 24),
                          SizedBox(width: isSmallScreen ? 3 : 5),
                          Text(
                            'New',
                            style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: isSmallScreen ? 10 : 20),
            ],
          );
        }),
      ),
    );
  }
}