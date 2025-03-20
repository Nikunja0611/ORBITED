import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';


void main() {
  runApp(WordWizardApp2());
}


class WordWizardApp2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Word Wizard',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        fontFamily: 'Quicksand',
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
      home: WordGameScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}


class AnimatedBackground extends StatefulWidget {
  final Widget child;


  AnimatedBackground({required this.child});


  @override
  _AnimatedBackgroundState createState() => _AnimatedBackgroundState();
}


class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Bubble> bubbles;


  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 10),
    )..repeat();


    // Create random bubbles
    bubbles = List.generate(
      15,
      (index) => Bubble(
        position: Offset(
          Random().nextDouble() * 400,
          Random().nextDouble() * 800,
        ),
        size: Random().nextDouble() * 60 + 20,
        speed: Random().nextDouble() * 2 + 0.5,
        color: Colors.purple.withOpacity(0.1 + Random().nextDouble() * 0.1),
      ),
    );
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Animated background
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: BubblePainter(
                bubbles: bubbles,
                animation: _controller,
              ),
              child: Container(),
            );
          },
        ),
        // Main content
        widget.child,
      ],
    );
  }
}


class Bubble {
  Offset position;
  double size;
  double speed;
  Color color;


  Bubble({
    required this.position,
    required this.size,
    required this.speed,
    required this.color,
  });
}


class BubblePainter extends CustomPainter {
  final List<Bubble> bubbles;
  final Animation<double> animation;


  BubblePainter({
    required this.bubbles,
    required this.animation,
  }) : super(repaint: animation);


  @override
  void paint(Canvas canvas, Size size) {
    for (var bubble in bubbles) {
      final paint = Paint()
        ..color = bubble.color
        ..style = PaintingStyle.fill;


      // Move the bubble upward based on animation value and adapt to screen size
      double yOffset =
          (animation.value * bubble.speed * size.height * 0.5) % size.height;
      double xPos = bubble.position.dx % size.width;
      final position = Offset(
        xPos,
        (bubble.position.dy - yOffset) % size.height,
      );


      canvas.drawCircle(position, bubble.size * (size.width / 400), paint);
    }
  }


  @override
  bool shouldRepaint(BubblePainter oldDelegate) => true;
}


class WordWithClue {
  final String word;
  final String clue;


  WordWithClue(this.word, this.clue);
}


class WordGameScreen extends StatefulWidget {
  @override
  _WordGameScreenState createState() => _WordGameScreenState();
}


class _WordGameScreenState extends State<WordGameScreen>
    with TickerProviderStateMixin {
  // Word list with clues
  final List<WordWithClue> wordsWithClues = [
    WordWithClue(
        'table', 'You place dishes and food on this piece of furniture.'),
    WordWithClue('apple', 'A red or green fruit that keeps the doctor away.'),
    WordWithClue('grape', 'A small, sweet fruit that grows in bunches.'),
    WordWithClue('chair', 'A piece of furniture designed for sitting.'),
    WordWithClue('light', 'It helps you see in the dark.'),
    WordWithClue('dance', 'Moving your body to music is called this.'),
    WordWithClue('music', 'Sounds organized to create melody and harmony.'),
    WordWithClue('brain', 'The organ in your head that helps you think.'),
    WordWithClue('heart', 'This organ pumps blood through your body.'),
    WordWithClue('shirt', 'A piece of clothing worn on the upper body.'),
    WordWithClue(
        'ocean', 'A vast body of saltwater that covers much of Earth.'),
    WordWithClue('paper', 'Material made from wood pulp that we write on.'),
    WordWithClue('smile', 'Your face does this when you are happy.'),
    WordWithClue('cloud',
        'A white or gray formation in the sky made of water droplets.'),
    WordWithClue('snake', 'A long reptile that slithers on the ground.')
  ];


  String currentWord = '';
  String currentClue = '';
  List<String> displayedLetters = [];
  List<String?> selectedLetters = [];
  Set<int> prefilledIndexes = {};
  String bonusLetter = '';
  String trapLetter = '';
  int score = 0;
  int level = 1;
  bool showLevelCompleteDialog = false;
  FlutterTts flutterTts = FlutterTts();
  late AnimationController _shakeController;
  late AnimationController _scaleController;
  late AnimationController _clueController;
  bool isClueVisible = true;


  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _scaleController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _clueController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    pickNewWord();
    initTts();
  }


  @override
  void dispose() {
    _shakeController.dispose();
    _scaleController.dispose();
    _clueController.dispose();
    flutterTts.stop();
    super.dispose();
  }


  Future<void> initTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
  }


  void pickNewWord() {
    final random = Random();
    // Select a random word with its clue
    final wordWithClue = wordsWithClues[random.nextInt(wordsWithClues.length)];
    currentWord = wordWithClue.word;
    currentClue = wordWithClue.clue;


    selectedLetters = List.filled(currentWord.length, null);
    displayedLetters = List.from(currentWord.split(''));


    // Generate pre-filled indexes
    prefilledIndexes.clear();
    while (prefilledIndexes.length < 2) {
      prefilledIndexes.add(random.nextInt(currentWord.length));
    }


    // Fill pre-filled letters
    for (int index in prefilledIndexes) {
      selectedLetters[index] = currentWord[index];
    }


    // Generate Bonus and Trap Letters
    bonusLetter = displayedLetters[random.nextInt(displayedLetters.length)];
    trapLetter = getSimilarLetter(bonusLetter);


    // Add extra letters
    while (displayedLetters.length < 10) {
      String randomLetter = String.fromCharCode(97 + random.nextInt(26));
      if (!displayedLetters.contains(randomLetter)) {
        displayedLetters.add(randomLetter);
      }
    }


    displayedLetters.shuffle();


    // Animate clue appearance
    setState(() {
      isClueVisible = true;
    });
    _clueController.reset();
    _clueController.forward();
  }


  String getSimilarLetter(String correctLetter) {
    Map<String, String> similarLetters = {
      'b': 'd',
      'd': 'b',
      'p': 'q',
      'q': 'p',
      'm': 'n',
      'n': 'm',
      'g': 'q',
      'v': 'w',
      'i': 'l',
      'l': 'i',
    };
    return similarLetters[correctLetter] ??
        String.fromCharCode(97 + Random().nextInt(26));
  }


  void selectLetter(String letter) {
    for (int i = 0; i < selectedLetters.length; i++) {
      if (selectedLetters[i] == null && !prefilledIndexes.contains(i)) {
        setState(() {
          selectedLetters[i] = letter;
        });
        _scaleController.forward().then((_) => _scaleController.reverse());
        break;
      }
    }
  }


  void checkAnswer() {
    String userAnswer = selectedLetters.map((e) => e ?? '').join();


    if (userAnswer == currentWord) {
      // Correct answer
      int pointsEarned = 10;
      score += pointsEarned;
      speak("Correct! You earned $pointsEarned points.");


      // Check if level completed
      if (score >= 50) {
        setState(() {
          showLevelCompleteDialog = true;
        });
        showLevelCompletePopup();
        speak("Congratulations! You have completed this level!");
      } else {
        pickNewWord();
      }
    } else {
      // Wrong answer
      _shakeController.forward().then((_) => _shakeController.reset());
      if (selectedLetters.contains(trapLetter)) {
        score = score > 0 ? score - 5 : 0;
        speak("Oops! You picked a trap letter. Minus 5 points.");
      } else {
        speak("Try again.");
      }


      setState(() {
        selectedLetters = List.filled(currentWord.length, null);
        for (int index in prefilledIndexes) {
          selectedLetters[index] = currentWord[index];
        }
      });
    }
  }


  void nextLevel() {
    setState(() {
      level++;
      score = 0;
      showLevelCompleteDialog = false;
    });
    pickNewWord();
  }


  void speak(String text) async {
    await flutterTts.speak(text);
  }


  void speakClue() async {
    await flutterTts.speak(currentClue);
  }


  void showLevelCompletePopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          "Level Complete!",
          style:
              TextStyle(color: Colors.purple[800], fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.emoji_events,
              color: Colors.amber,
              size: 80,
            ),
            SizedBox(height: 16),
            Text(
              "Congratulations! You've reached 50 points and completed Level $level!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        actions: [
          Center(
            child: ElevatedButton.icon(
              icon: Icon(Icons.arrow_forward),
              label: Text("Next Level"),
              onPressed: () {
                Navigator.pop(context);
                nextLevel();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple[700],
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget buildLetterTile(String letter, double tileSize) {
    bool isBonus = letter == bonusLetter;
    bool isTrap = letter == trapLetter;


    return GestureDetector(
      onTap: () => selectLetter(letter),
      child: Container(
        margin: EdgeInsets.all(4),
        width: tileSize,
        height: tileSize,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isBonus
                ? [Colors.greenAccent, Colors.green[700]!]
                : (isTrap
                    ? [Colors.redAccent, Colors.red[900]!]
                    : [Colors.blue[300]!, Colors.blue[700]!]),
          ),
          boxShadow: [
            BoxShadow(
              color: isBonus ? Colors.yellow.withOpacity(0.6) : Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 3),
            )
          ],
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          letter.toUpperCase(),
          style: TextStyle(
            fontSize: tileSize * 0.5,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double screenHeight = size.height;
    final double screenWidth = size.width;


    // Responsive sizing
    final double tileFontSize = screenWidth < 360 ? 18 : 24;
    final double tileSize = screenWidth < 360 ? 40 : 50;
    final double wordTileSize = screenWidth < 360 ? 40 : 50;
    final double padding = screenWidth < 360 ? 8 : 16;


    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: LayoutBuilder(builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: padding),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // App Bar Replacement
                      Container(
                        padding: EdgeInsets.all(padding),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Word Wizard',
                              style: TextStyle(
                                fontSize: screenWidth < 360 ? 24 : 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple[800],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: padding,
                                vertical: padding / 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.purple[100],
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                'Level $level',
                                style: TextStyle(
                                  fontSize: screenWidth < 360 ? 14 : 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple[800],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),


                      SizedBox(height: padding),


                      // Score Display
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: padding * 1.5, vertical: padding),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.purple[400]!, Colors.purple[700]!],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.stars_rounded,
                              color: Colors.yellow,
                              size: screenWidth < 360 ? 20 : 28,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Score: $score / 50',
                              style: TextStyle(
                                fontSize: screenWidth < 360 ? 18 : 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),


                      SizedBox(height: padding),


                      // Clue Card
                      AnimatedBuilder(
                          animation: _clueController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: Tween<double>(begin: 0.9, end: 1.0)
                                  .animate(CurvedAnimation(
                                      parent: _clueController,
                                      curve: Curves.elasticOut))
                                  .value,
                              child: Card(
                                margin:
                                    EdgeInsets.symmetric(vertical: padding / 2),
                                elevation: 4,
                                color: Colors.amber[50],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side:
                                      BorderSide(color: Colors.amber, width: 2),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(padding),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'CLUE:',
                                            style: TextStyle(
                                              fontSize:
                                                  screenWidth < 360 ? 14 : 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.amber[800],
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.volume_up,
                                                color: Colors.amber[800],
                                                size: screenWidth < 360
                                                    ? 18
                                                    : 24),
                                            onPressed: speakClue,
                                            tooltip: 'Speak Clue',
                                            padding: EdgeInsets.zero,
                                            constraints: BoxConstraints(),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        currentClue,
                                        style: TextStyle(
                                          fontSize: screenWidth < 360 ? 14 : 16,
                                          color: Colors.black87,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),


                      SizedBox(height: padding),


                      // Word Display Section
                      ShakeTransition(
                        controller: _shakeController,
                        child: Card(
                          margin: EdgeInsets.symmetric(vertical: padding / 2),
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(padding),
                            child: Column(
                              children: [
                                Text(
                                  'Form the correct word:',
                                  style: TextStyle(
                                    fontSize: screenWidth < 360 ? 16 : 18,
                                    color: Colors.purple[800],
                                  ),
                                ),
                                SizedBox(height: padding),
                                ScaleTransition(
                                  scale: Tween<double>(begin: 1.0, end: 1.1)
                                      .animate(_scaleController),
                                  child: Wrap(
                                    spacing: screenWidth < 360 ? 6 : 10,
                                    runSpacing: screenWidth < 360 ? 6 : 10,
                                    alignment: WrapAlignment.center,
                                    children: List.generate(
                                        selectedLetters.length, (index) {
                                      return Container(
                                        width: wordTileSize,
                                        height: wordTileSize,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color:
                                              prefilledIndexes.contains(index)
                                                  ? Colors.lightGreenAccent
                                                  : Colors.grey[200],
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                            color: Colors.purple[700]!,
                                            width: 2,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black12,
                                              blurRadius: 4,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          selectedLetters[index]
                                                  ?.toUpperCase() ??
                                              '',
                                          style: TextStyle(
                                            fontSize: tileFontSize,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.purple[800],
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),


                      SizedBox(height: padding),


                      // Letter Options
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Container(
                          width: screenWidth,
                          child: Wrap(
                            spacing: screenWidth < 360 ? 4 : 8,
                            runSpacing: screenWidth < 360 ? 4 : 8,
                            alignment: WrapAlignment.center,
                            children: displayedLetters.map((letter) {
                              return buildLetterTile(letter, tileSize);
                            }).toList(),
                          ),
                        ),
                      ),


                      SizedBox(height: padding),


                      // Check Answer Button
                      ElevatedButton.icon(
                        onPressed: checkAnswer,
                        icon: Icon(Icons.check_circle_outline,
                            size: screenWidth < 360 ? 18 : 24),
                        label: Text(
                          'Check Answer',
                          style:
                              TextStyle(fontSize: screenWidth < 360 ? 16 : 20),
                        ),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.purple[700],
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth < 360 ? 16 : 24,
                              vertical: screenWidth < 360 ? 8 : 12),
                        ),
                      ),


                      // Add extra padding at the bottom to ensure all content is visible
                      SizedBox(height: padding * 4),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),


      // Help Button
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: Padding(
        padding: EdgeInsets.only(top: 8),
        child: FloatingActionButton(
          mini: MediaQuery.of(context).size.width < 360,
          onPressed: () {
            // Show game rules
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text("How to Play"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("• Read the clue to guess the correct word"),
                    Text("• Arrange letters to form the word"),
                    Text("• Get 10 points for each correct word"),
                    Text("• Green tiles are bonus letters"),
                    Text("• Red tiles are trap letters that deduct 5 points"),
                    Text("• Reach 50 points to complete the level"),
                    Text("• Tap the speaker icon to hear the clue"),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Got it!"),
                  ),
                ],
              ),
            );
          },
          backgroundColor: Colors.purple[700],
          child: Icon(Icons.info_outline),
        ),
      ),
    );
  }
}


class ShakeTransition extends StatelessWidget {
  final Widget child;
  final AnimationController controller;


  ShakeTransition({required this.child, required this.controller});


  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final sineValue = sin(controller.value * 10 * pi);
        return Transform.translate(
          offset: Offset(sineValue * 10, 0),
          child: this.child,
        );
      },
    );
  }
}