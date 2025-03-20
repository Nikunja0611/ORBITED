import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';

class StoryPuzzelApp2_2 extends StatefulWidget {
  @override
  _StoryPuzzleLevel2State createState() => _StoryPuzzleLevel2State();
}

class _StoryPuzzleLevel2State extends State<StoryPuzzelApp2_2> {
  FlutterTts flutterTts = FlutterTts();
  List<String> fullStory = [
    "Explorer discovered ancient portal",
    "Wormhole opened between galaxies",
    "Strange creatures welcomed humans",
    "Cosmic knowledge was shared"
  ];

  int currentPage = 0;
  List<String?> sentence = [null, null, null, null];
  List<String> wordOptions = [];
  late ConfettiController _confettiController;
  bool storyCompleted = false;
  int highlightedIndex = -1; // Keeps track of the sentence being read
  int incorrectAttempts = 0;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: Duration(seconds: 2));
    loadPage();
    _configureTextToSpeech();
  }

  Future<void> _configureTextToSpeech() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
  }

  void loadPage() {
    // Get the correct words for this sentence
    List<String> correctWords = fullStory[currentPage].split(" ");

    // Create sentence slots
    setState(() {
      sentence = List.filled(correctWords.length, null);
      incorrectAttempts = 0;

      // Create word options (all correct + 1 wrong)
      wordOptions = List.from(correctWords);

      // Add an extra wrong word
      List<String> extraWords = [
        "nebula",
        "spacecraft",
        "constellation",
        "supernova",
        "interstellar",
        "universe",
        "asteroid",
        "quantum",
        "planet",
        "dimension",
        "teleport",
        "vortex",
        "hyperspace",
        "comet",
        "stellar"
      ];

      // Find a word that's not already in our correct words
      String extraWord = extraWords.firstWhere(
          (word) => !correctWords.contains(word),
          orElse: () => "alien");

      wordOptions.add(extraWord);
      wordOptions.shuffle();
    });
  }

  Future<void> speakText(String text, int index) async {
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
      List<String> sortedCorrectWords = List.from(correctWords)..sort();
      List<String> sortedSelectedWords = List.from(selectedWords)..sort();

      allCorrect = true;
      for (int i = 0; i < sortedCorrectWords.length; i++) {
        if (i >= sortedSelectedWords.length ||
            sortedCorrectWords[i] != sortedSelectedWords[i]) {
          allCorrect = false;
          break;
        }
      }
    }

    if (allCorrect) {
      _confettiController.play();
      speakText("Correct! Your space exploration continues!", -1);
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
          _readStoryAndCelebrate();
        }
      });
    } else {
      setState(() {
        incorrectAttempts++;
      });
      if (incorrectAttempts >= 2) {
        speakText(
            "Wrong combination. The correct words are: ${correctWords.join(", ")}",
            -1);
      } else {
        speakText("Wrong combination. Try again, space explorer!", -1);
      }
    }
  }

  Future<void> _readStoryAndCelebrate() async {
    _confettiController.play();

    for (int i = 0; i < fullStory.length; i++) {
      await speakText(fullStory[i], i);
      await Future.delayed(Duration(seconds: 3));
    }

    speakText("Congratulations! You've completed your cosmic journey!", -1);
  }

  @override
  void dispose() {
    _confettiController.dispose();
    flutterTts.stop();
    super.dispose();
  }

  Widget _wordContainer(String word, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade700, Colors.indigo],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 2),
            blurRadius: 4,
          )
        ],
      ),
      child: Text(
        word,
        style: GoogleFonts.poppins(
          fontSize: isSmallScreen ? 14 : 16,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  List<Widget> _buildDropTargets(bool isSmallScreen) {
    List<Widget> dropTargets = [];
    for (int i = 0; i < sentence.length; i++) {
      dropTargets.add(
        DragTarget<String>(
          builder: (context, candidateData, rejectedData) {
            return Container(
              width: isSmallScreen ? 100 : 120,
              height: isSmallScreen ? 50 : 60,
              margin: EdgeInsets.all(4),
              decoration: BoxDecoration(
                gradient: sentence[i] != null
                    ? LinearGradient(
                        colors: [Colors.blue.shade700, Colors.teal],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: sentence[i] == null ? Colors.white24 : null,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: highlightedIndex == currentPage
                      ? Colors.yellow
                      : Colors.white38,
                  width: highlightedIndex == currentPage ? 3 : 1,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                sentence[i] ?? "Drop here",
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 14 : 16,
                  color: sentence[i] != null ? Colors.white : Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            );
          },
          onWillAccept: (data) => true,
          onAccept: (word) {
            setState(() {
              sentence[i] = word;
            });
          },
        ),
      );
    }
    return dropTargets;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: Text("Deep Space: Level 2"),
        backgroundColor: Colors.indigo,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          // Use image background instead of custom gradient with stars
          Positioned.fill(
            child: Image.asset(
              'assets/space_explorer.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!storyCompleted) ...[
                      Container(
                        padding: EdgeInsets.all(screenSize.width * 0.04),
                        margin: EdgeInsets.all(screenSize.width * 0.04),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.indigo, Colors.blue.shade900],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black38,
                              offset: Offset(0, 4),
                              blurRadius: 8,
                            )
                          ],
                        ),
                        child: Text(
                          "Choose the correct words to form the sentence (${currentPage + 1}/${fullStory.length})",
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
                                elevation: 5,
                                child: _wordContainer(word, isSmallScreen),
                              ),
                              childWhenDragging: Opacity(
                                  opacity: 0.5,
                                  child: _wordContainer(word, isSmallScreen)),
                              child: _wordContainer(word, isSmallScreen),
                            );
                          }).toList(),
                        ),
                      ),
                      SizedBox(height: screenSize.height * 0.02),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        runSpacing: 8,
                        children: _buildDropTargets(isSmallScreen),
                      ),
                      SizedBox(height: screenSize.height * 0.02),
                      ElevatedButton(
                        onPressed: checkAnswer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
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
                    ],
                    if (storyCompleted)
                      Container(
                        width: screenSize.width * 0.9,
                        padding: EdgeInsets.all(screenSize.width * 0.04),
                        margin: EdgeInsets.all(screenSize.width * 0.04),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              offset: Offset(0, 4),
                              blurRadius: 8,
                            )
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              "Explorer's Log",
                              style: GoogleFonts.poppins(
                                fontSize: isSmallScreen ? 20 : 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 16),
                            ...fullStory.asMap().entries.map((entry) {
                              int idx = entry.key;
                              String line = entry.value;
                              return Container(
                                margin: EdgeInsets.only(bottom: 16),
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: highlightedIndex == idx
                                      ? Colors.blue.withOpacity(0.2)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: highlightedIndex == idx
                                        ? Colors.blue
                                        : Colors.grey.shade300,
                                    width: highlightedIndex == idx ? 2 : 1,
                                  ),
                                ),
                                child: Text(
                                  line,
                                  style: GoogleFonts.poppins(
                                    fontSize: isSmallScreen ? 16 : 18,
                                    fontWeight: highlightedIndex == idx
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              );
                            }).toList(),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenSize.width * 0.07,
                                  vertical: screenSize.height * 0.015,
                                ),
                              ),
                              child: Text(
                                "Return to Galaxy Map",
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 16 : 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          // Confetti animation at the top center
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              particleDrag: 0.05,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.2,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
                Colors.yellow,
              ],
            ),
          ),
        ],
      ),
    );
  }
}