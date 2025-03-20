import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';

class StoryPuzzleLevel2 extends StatefulWidget {
  @override
  _StoryPuzzleLevel2State createState() => _StoryPuzzleLevel2State();
}

class _StoryPuzzleLevel2State extends State<StoryPuzzleLevel2> {
  FlutterTts flutterTts = FlutterTts();
  List<String> fullStory = [
    "A boy was lost",
    "He saw a deer",
    "The deer was friendly",
    "They walked together home"
  ];
  
  int currentPage = 0;
  List<String?> sentence = [];
  List<String> shuffledWords = [];
  late ConfettiController _confettiController;
  bool storyCompleted = false;
  int highlightedIndex = -1; // Keeps track of the sentence being read
  int incorrectAttempts = 0;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: Duration(seconds: 2));
    loadPage();
  }

  void loadPage() {
    setState(() {
      sentence = List.filled(fullStory[currentPage].split(" ").length, null);
      shuffledWords = fullStory[currentPage].split(" ")..shuffle();
      incorrectAttempts = 0;
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
    if (sentence.join(" ") == fullStory[currentPage]) {
      _confettiController.play();
      speakText("Great job! You formed the correct sentence.", -1);
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
      incorrectAttempts++;
      if (incorrectAttempts == 2) {
        speakText("Try again! The correct sentence is: ${fullStory[currentPage]}", -1);
      } else {
        speakText("Oops! Try again.", -1);
      }
    }
  }

  Future<void> _readStoryAndCelebrate() async {
    _confettiController.play();
    
    for (int i = 0; i < fullStory.length; i++) {
      await speakText(fullStory[i], i);
      await Future.delayed(Duration(seconds: 3));
    }
    
    speakText("Congratulations! You've completed Level 2!", -1);
    
    // You can navigate to the next level here if needed
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    final isMediumScreen = screenSize.width >= 600 && screenSize.width < 900;
    
    return Scaffold(
      appBar: AppBar(
        title: Text("Story Puzzle Level 2"),
        backgroundColor: Colors.teal,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/story2.png',
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
                            colors: [Colors.green, Colors.teal],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "Arrange the words to form a sentence",
                          style: GoogleFonts.poppins(
                            fontSize: isSmallScreen ? 16 : 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.04),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: shuffledWords.map((word) {
                            return Draggable<String>(
                              data: word,
                              feedback: Material(
                                color: Colors.transparent,
                                elevation: 5,
                                child: _wordContainer(word, isSmallScreen),
                              ),
                              childWhenDragging: Opacity(opacity: 0.5, child: _wordContainer(word, isSmallScreen)),
                              child: _wordContainer(word, isSmallScreen),
                            );
                          }).toList(),
                        ),
                      ),
                      SizedBox(height: screenSize.height * 0.02),
                      isSmallScreen || sentence.length > 4
                          ? Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 8,
                              runSpacing: 8,
                              children: _buildDropTargets(isSmallScreen),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: _buildDropTargets(isSmallScreen),
                            ),
                      SizedBox(height: screenSize.height * 0.02),
                      ElevatedButton(
                        onPressed: checkAnswer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
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
                              "Reading Story...",
                              style: GoogleFonts.poppins(
                                fontSize: isSmallScreen ? 20 : 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: screenSize.height * 0.02),
                            Column(
                              children: fullStory.asMap().entries.map((entry) {
                                int idx = entry.key;
                                String sentence = entry.value;
                                return Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    sentence,
                                    style: GoogleFonts.poppins(
                                      fontSize: isSmallScreen ? 18 : 20,
                                      fontWeight: FontWeight.bold,
                                      color: highlightedIndex == idx ? Colors.red : Colors.black,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              }).toList(),
                            ),
                            SizedBox(height: screenSize.height * 0.02),
                            Text(
                              "🎉 Level 2 Completed! 🎉",
                              style: GoogleFonts.poppins(
                                fontSize: isSmallScreen ? 20 : 24, 
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                              textAlign: TextAlign.center,
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
                colors: [Colors.red, Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.yellow],
                numberOfParticles: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDropTargets(bool isSmallScreen) {
    return List.generate(fullStory[currentPage].split(" ").length, (index) {
      return DragTarget<String>(
        onAccept: (receivedWord) {
          setState(() {
            if (!sentence.contains(receivedWord)) {
              sentence[index] = receivedWord;
              shuffledWords.remove(receivedWord);
            }
          });
        },
        builder: (context, candidateData, rejectedData) {
          return GestureDetector(
            onTap: () {
              setState(() {
                if (sentence[index] != null) {
                  shuffledWords.add(sentence[index]!);
                  sentence[index] = null;
                }
              });
            },
            child: Container(
              margin: EdgeInsets.all(8),
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 8 : 16,
                vertical: isSmallScreen ? 8 : 16,
              ),
              height: isSmallScreen ? 60 : 70,
              width: isSmallScreen ? 80 : 100,
              decoration: BoxDecoration(
                color: Colors.brown.shade300,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.green, width: 2),
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
        color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        word,
        style: TextStyle(
          fontSize: isSmallScreen ? 16 : 18,
          color: Colors.white,
        ),
      ),
    );
  }
}