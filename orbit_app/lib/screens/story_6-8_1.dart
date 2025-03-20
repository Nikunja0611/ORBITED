import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import 'package:orbit_app/screens/story_6-8_2.dart';

class StoryPuzzelApp2_1 extends StatefulWidget {
  @override
  _StoryPuzzleLevel1State createState() => _StoryPuzzleLevel1State();
}

class _StoryPuzzleLevel1State extends State<StoryPuzzelApp2_1> {
  FlutterTts flutterTts = FlutterTts();
  List<String> fullStory = [
    "Astro landed on Mars.",
    "The sky was red.",
    "He found strange rocks.",
    "His oxygen was low.",
    "Astro sent a signal.",
    "The ship responded quickly.",
    "He collected alien samples.",
    "The mission was successful.",
    "Astro returned to ship.",
    "Earth was waiting eagerly."
  ];

  int currentPage = 0;
  List<String?> sentence = [null, null, null, null];
  List<String> wordOptions = [];
  late ConfettiController _confettiController;
  bool storyCompleted = false;
  int highlightedIndex = -1; // Keeps track of the sentence being read

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: Duration(seconds: 2));
    loadPage();
  }

  void loadPage() {
    // Get the correct words for this sentence
    List<String> correctWords = fullStory[currentPage].split(" ");

    // Create sentence slots (4 slots for each sentence)
    setState(() {
      sentence = List.filled(4, null);

      // Create 5 word options (4 correct + 1 wrong)
      wordOptions = List.from(correctWords);

      // Add an extra wrong word
      List<String> extraWords = [
        "galaxy",
        "planet",
        "space",
        "rocket",
        "stars",
        "moon",
        "alien",
        "cosmic",
        "solar",
        "mission",
        "astronaut",
        "shuttle",
        "gravity",
        "orbit",
        "satellite"
      ];

      // Find a word that's not already in our correct words
      String extraWord = extraWords.firstWhere(
          (word) => !correctWords.contains(word),
          orElse: () => "nebula");

      wordOptions.add(extraWord);
      wordOptions.shuffle();
    });
  }

  void speakText(String text, int index) async {
    setState(() {
      highlightedIndex = index;
    });
    await flutterTts.speak(text);
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      highlightedIndex = -1;
    });
  }

  void checkAnswer() {
    // Get the correct words for the current sentence
    List<String> correctWords = fullStory[currentPage].split(" ");

    // Check if all filled slots have correct words
    bool allCorrect = true;
    List<String> selectedWords = [];

    for (String? word in sentence) {
      if (word == null) {
        allCorrect = false;
        break;
      }
      selectedWords.add(word);
    }

    // Check if selected words match correct words (ignoring order)
    if (allCorrect) {
      // Sort both lists to compare content regardless of order
      correctWords.sort();
      selectedWords.sort();

      allCorrect = true;
      for (int i = 0; i < correctWords.length; i++) {
        if (i >= selectedWords.length || correctWords[i] != selectedWords[i]) {
          allCorrect = false;
          break;
        }
      }
    }

    if (allCorrect) {
      _confettiController.play();
      speakText("Correct! Great job, space explorer!", -1);
      Future.delayed(Duration(seconds: 2), () {
        if (currentPage < fullStory.length - 1) {
          setState(() {
            currentPage++;
            loadPage();
          });
        } else {
          setState(() {
            storyCompleted = true;
          });
          _readStoryAndRedirect();
        }
      });
    } else {
      speakText("Wrong combination. Try again, astronaut!", -1);
    }
  }

  Future<void> _readStoryAndRedirect() async {
    for (int i = 0; i < fullStory.length; i++) {
      speakText(fullStory[i], i);
      await Future.delayed(Duration(seconds: 3));
    }

    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => WelcomeToLevel2Screen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: Text("Space Mission: Level 1"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/astronaut.png', fit: BoxFit.cover),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(screenSize.width * 0.04),
                      margin: EdgeInsets.all(screenSize.width * 0.04),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.purple, Colors.deepPurple],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "Choose 4 correct words to form the sentence",
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 16 : 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: screenSize.width * 0.04),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: wordOptions.map((word) {
                          return Draggable<String>(
                            data: word,
                            feedback: Material(
                              color: Colors.transparent,
                              child: Text(
                                word,
                                style: TextStyle(
                                    fontSize: isSmallScreen ? 18 : 22,
                                    backgroundColor: Colors.purpleAccent),
                              ),
                            ),
                            childWhenDragging: Opacity(
                                opacity: 0.5,
                                child: _wordContainer(word, isSmallScreen)),
                            child: _wordContainer(word, isSmallScreen),
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(height: 20),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: _buildDropTargets(isSmallScreen),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: checkAnswer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        padding: EdgeInsets.symmetric(
                          horizontal: screenSize.width * 0.07,
                          vertical: screenSize.height * 0.015,
                        ),
                      ),
                      child: Text(
                        "Check Answer",
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (storyCompleted)
                      Container(
                        padding: EdgeInsets.all(screenSize.width * 0.04),
                        margin: EdgeInsets.all(screenSize.width * 0.04),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            Text(
                              "Mission Log:",
                              style: GoogleFonts.poppins(
                                fontSize: isSmallScreen ? 18 : 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Column(
                              children: fullStory.asMap().entries.map((entry) {
                                int idx = entry.key;
                                String sentence = entry.value;
                                return Text(
                                  sentence,
                                  style: GoogleFonts.poppins(
                                    fontSize: isSmallScreen ? 16 : 18,
                                    fontWeight: FontWeight.bold,
                                    color: highlightedIndex == idx
                                        ? Colors.red
                                        : Colors.black,
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: [
                  Colors.purple,
                  Colors.blue,
                  Colors.pink,
                  Colors.orange
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDropTargets(bool isSmallScreen) {
    return List.generate(4, (index) {
      return DragTarget<String>(
        onAccept: (receivedWord) {
          setState(() {
            sentence[index] = receivedWord;
          });
        },
        builder: (context, candidateData, rejectedData) {
          return GestureDetector(
            onTap: () {
              if (sentence[index] != null) {
                setState(() {
                  sentence[index] = null;
                });
              }
            },
            child: Container(
              margin: EdgeInsets.all(8),
              padding: EdgeInsets.all(isSmallScreen ? 8 : 16),
              // Increased height and width to prevent words from being cut off
              height: isSmallScreen ? 80 : 90, // Increased from 60/70
              width: isSmallScreen ? 110 : 130, // Increased from 80/100
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade100,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.deepPurple, width: 2),
              ),
              child: Center(
                child: Text(
                  sentence[index] ?? "",
                  style: TextStyle(
                    fontSize: isSmallScreen ? 18 : 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _wordContainer(String word, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade400,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        word,
        style:
            TextStyle(fontSize: isSmallScreen ? 16 : 18, color: Colors.white),
      ),
    );
  }
}

class WelcomeToLevel2Screen extends StatefulWidget {
  @override
  _WelcomeToLevel2ScreenState createState() => _WelcomeToLevel2ScreenState();
}

class _WelcomeToLevel2ScreenState extends State<WelcomeToLevel2Screen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  FlutterTts flutterTts = FlutterTts();
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    _confettiController = ConfettiController(duration: Duration(seconds: 3));

    // Start animations after a short delay
    Future.delayed(Duration(milliseconds: 300), () {
      _animationController.forward();
      _confettiController.play();
      flutterTts.speak("Congratulations! Welcome to Level 2!");
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: Text("Level 2 Adventure"),
        backgroundColor: Colors.indigo.shade900,
        automaticallyImplyLeading: false, // Remove back button
      ),
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.indigo.shade900, Colors.deepPurple.shade900],
              ),
            ),
          ),

          // Background Decorations
          Positioned.fill(
            child: Opacity(
              opacity: 0.2,
              child: Image.asset(
                'assets/story2.png',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: screenSize.width * (isSmallScreen ? 0.9 : 0.8),
                    padding: EdgeInsets.all(screenSize.width * 0.05),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 15,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Space Emoji
                        Icon(
                          Icons.rocket_launch,
                          size: isSmallScreen ? 60 : 80,
                          color: Colors.deepPurple,
                        ),
                        SizedBox(height: screenSize.height * 0.02),

                        // Level 2 Text
                        Text(
                          "MISSION UPGRADE",
                          style: GoogleFonts.poppins(
                            fontSize: isSmallScreen ? 16 : 20,
                            color: Colors.grey.shade800,
                            letterSpacing: 2.0,
                          ),
                        ),
                        Text(
                          "LEVEL 2",
                          style: GoogleFonts.poppins(
                            fontSize: isSmallScreen ? 32 : 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple.shade800,
                            letterSpacing: 2.0,
                          ),
                        ),
                        SizedBox(height: screenSize.height * 0.02),

                        // Divider
                        Container(
                          height: 4,
                          width: 60,
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        SizedBox(height: screenSize.height * 0.02),

                        // Description
                        Text(
                          "Time for deep space exploration!",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: isSmallScreen ? 14 : 16,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        SizedBox(height: screenSize.height * 0.03),

                        // Button
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => StoryPuzzelApp2_2()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple.shade600,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: screenSize.width * 0.08,
                              vertical: screenSize.height * 0.02,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 5,
                          ),
                          child: Text(
                            "BEGIN EXPLORATION",
                            style: TextStyle(
                              fontSize: isSmallScreen ? 16 : 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Confetti
          Positioned.fill(
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              particleDrag: 0.05,
              emissionFrequency: 0.05,
              numberOfParticles: 30,
              gravity: 0.1,
              shouldLoop: false,
              colors: [
                Colors.purple,
                Colors.blue,
                Colors.indigo,
                Colors.pink,
                Colors.teal,
                Colors.deepPurple,
              ],
            ),
          ),
        ],
      ),
    );
  }
}