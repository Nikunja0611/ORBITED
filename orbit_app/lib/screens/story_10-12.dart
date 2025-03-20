import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';

class StoryPuzzleApp4 extends StatefulWidget {
  @override
  _WordChallengeLevel1State createState() => _WordChallengeLevel1State();
}

class _WordChallengeLevel1State extends State<StoryPuzzleApp4> {
  FlutterTts flutterTts = FlutterTts();
  late ConfettiController _confettiController;
  
  // Game data
  List<Map<String, dynamic>> challenges = [
    {
      "topic": "Ancient Egypt",
      "sentence": "The pyramids were built as tombs for the powerful pharaohs of Egypt.",
      "hint": "This sentence is about ancient structures in Egypt.",
      "fact": "The Great Pyramid of Giza was the tallest man-made structure in the world for more than 3,800 years!",
      "difficulty": 1
    },
    {
      "topic": "Space Exploration",
      "sentence": "Astronauts on the International Space Station experience weightlessness due to constant free-fall.",
      "hint": "This sentence explains why people float in space.",
      "fact": "The International Space Station travels at approximately 28,000 kilometers per hour!",
      "difficulty": 2
    },
    {
      "topic": "Environmental Science",
      "sentence": "Renewable energy sources like solar and wind power help reduce greenhouse gas emissions.",
      "hint": "This sentence is about sustainable power sources.",
      "fact": "Solar panels can still generate electricity even on cloudy days, though less efficiently than on sunny days.",
      "difficulty": 1
    },
    {
      "topic": "Human Body",
      "sentence": "The human brain contains approximately one hundred billion neurons that process information.",
      "hint": "This sentence is about the organ that controls your body.",
      "fact": "Your brain uses about 20% of your body's total energy, despite being only 2% of your body weight!",
      "difficulty": 2
    },
    {
      "topic": "World Geography",
      "sentence": "The Amazon Rainforest produces about twenty percent of Earth's oxygen through photosynthesis.",
      "hint": "This sentence is about a large forest that helps us breathe.",
      "fact": "The Amazon River is home to electric eels that can generate shocks of up to 600 volts!",
      "difficulty": 2
    },
  ];
  
  int currentChallengeIndex = 0;
  List<String?> answer = [];
  List<String> shuffledWords = [];
  bool showHint = false;
  bool challengeCompleted = false;
  int score = 0;
  int timeRemaining = 60;
  bool timerActive = false;
  int timeBonus = 0;
  String feedbackMessage = "";
  bool showFeedback = false;
  Color feedbackColor = Colors.black;
  int hintPenalty = 5;
  
  // Player stats
  int hintsUsed = 0;
  int challengesCompleted = 0;
  
  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: Duration(seconds: 3));
    loadChallenge();
    startTimer();
  }
  
  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }
  
  void startTimer() {
    setState(() {
      timerActive = true;
    });
    
    Future.delayed(Duration(seconds: 1), () {
      if (mounted && timerActive) {
        setState(() {
          if (timeRemaining > 0) {
            timeRemaining--;
          } else {
            // Time's up
            timerActive = false;
            if (!challengeCompleted) {
              showFeedbackMessage("Time's up! Try again.", Colors.red);
              resetChallenge();
            }
          }
        });
        if (timerActive) {
          startTimer();
        }
      }
    });
  }
  
  void loadChallenge() {
    setState(() {
      challengeCompleted = false;
      showHint = false;
      
      // Fixed: Convert difficulty to int before calculation
      int difficulty = challenges[currentChallengeIndex]["difficulty"] as int;
      timeRemaining = 60 + (difficulty * 30); // More time for harder challenges
      timerActive = true;
      
      String sentence = challenges[currentChallengeIndex]["sentence"];
      answer = List.filled(sentence.split(" ").length, null);
      shuffledWords = sentence.split(" ")..shuffle();
      
      // Add some decoy words for extra challenge
      List<String> decoyWords = getDecoyWords(currentChallengeIndex);
      shuffledWords.addAll(decoyWords);
      shuffledWords.shuffle();
    });
  }
  
  List<String> getDecoyWords(int challengeIndex) {
    Map<String, List<String>> decoys = {
      "Ancient Egypt": ["mummies", "sand", "ancient", "treasure", "discovered"],
      "Space Exploration": ["planets", "gravity", "rocket", "universe", "orbit"],
      "Environmental Science": ["pollution", "climate", "ocean", "recycling", "sustainable"],
      "Human Body": ["cells", "blood", "oxygen", "heart", "muscles"],
      "World Geography": ["rivers", "mountains", "continents", "oceans", "countries"],
    };
    
    String topic = challenges[challengeIndex]["topic"];
    return decoys[topic] ?? ["extra", "word", "challenge", "difficult"];
  }
  
  void showFeedbackMessage(String message, Color color) {
    setState(() {
      feedbackMessage = message;
      feedbackColor = color;
      showFeedback = true;
    });
    
    Future.delayed(Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          showFeedback = false;
        });
      }
    });
  }
  
  void checkAnswer() {
    // Check if all slots are filled
    if (answer.contains(null)) {
      showFeedbackMessage("Fill all the blanks first!", Colors.orange);
      return;
    }
    
    String submittedAnswer = answer.join(" ");
    String correctAnswer = challenges[currentChallengeIndex]["sentence"];
    
    if (submittedAnswer == correctAnswer) {
      // Correct answer
      setState(() {
        challengeCompleted = true;
        timerActive = false;
        challengesCompleted++;
      });
      
      // Fixed: Convert difficulty to int before calculation
      int difficulty = challenges[currentChallengeIndex]["difficulty"] as int;
      timeBonus = timeRemaining * (difficulty + 1);
      int challengeScore = 100 + timeBonus - (hintsUsed * hintPenalty);
      score += challengeScore;
      
      _confettiController.play();
      flutterTts.speak("Great job! Challenge completed!");
      showFeedbackMessage("Correct! +$challengeScore points", Colors.green);
      
      // Speak the fact
      Future.delayed(Duration(seconds: 2), () {
        if (mounted) {
          flutterTts.speak(challenges[currentChallengeIndex]["fact"]);
        }
      });
      
    } else {
      // Incorrect answer
      showFeedbackMessage("Not quite right. Try again!", Colors.red);
      flutterTts.speak("Try again!");
    }
  }
  
  void useHint() {
    setState(() {
      showHint = true;
      hintsUsed++;
    });
    flutterTts.speak(challenges[currentChallengeIndex]["hint"]);
  }
  
  void nextChallenge() {
    if (currentChallengeIndex < challenges.length - 1) {
      setState(() {
        currentChallengeIndex++;
        loadChallenge();
      });
    } else {
      // Game completed
      showGameCompleted();
    }
  }
  
  void resetChallenge() {
    setState(() {
      answer = List.filled(challenges[currentChallengeIndex]["sentence"].split(" ").length, null);
      loadChallenge();
    });
  }
  
  void showGameCompleted() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Game Completed!"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Final Score: $score points"),
              SizedBox(height: 10),
              Text("Challenges Completed: $challengesCompleted"),
              SizedBox(height: 10),
              Text("Hints Used: $hintsUsed"),
              SizedBox(height: 20),
              Text("Great job! You've completed all the word challenges."),
            ],
          ),
          actions: [
            TextButton(
              child: Text("Play Again"),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  currentChallengeIndex = 0;
                  score = 0;
                  hintsUsed = 0;
                  challengesCompleted = 0;
                  loadChallenge();
                });
              },
            ),
            TextButton(
              child: Text("Next Level"),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WordChallengeLevel2()),
                );
              },
            ),
          ],
        );
      },
    );
  }
  
  void resetWordPosition(int index) {
    setState(() {
      // Add the word back to shuffled words
      if (answer[index] != null) {
        shuffledWords.add(answer[index]!);
        answer[index] = null;
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    
    return Scaffold(
      appBar: AppBar(
        title: Text("Word Challenge - Level 1"),
        backgroundColor: Colors.indigo,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                "Score: $score",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.indigo.shade300, Colors.indigo.shade700],
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // Timer and topic
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Timer
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: timeRemaining > 10 ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.timer, color: Colors.white),
                            SizedBox(width: 5),
                            Text(
                              "$timeRemaining s",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Topic
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          "Topic: ${challenges[currentChallengeIndex]["topic"]}",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Hint button and hint text
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: showHint ? null : useHint,
                        icon: Icon(Icons.lightbulb_outline),
                        label: Text("Hint (-$hintPenalty pts)"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      SizedBox(width: 10),
                      if (showHint)
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.yellow.shade100,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.orange),
                            ),
                            child: Text(
                              challenges[currentChallengeIndex]["hint"],
                              style: TextStyle(
                                color: Colors.orange.shade800,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                
                // Main content - Expanded for flexibility
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        // Answer area
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 16),
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                offset: Offset(0, 3),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: List.generate(answer.length, (index) {
                              return GestureDetector(
                                onTap: () => resetWordPosition(index),
                                child: Container(
                                  height: 50,
                                  constraints: BoxConstraints(
                                    minWidth: 80,
                                  ),
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: answer[index] != null 
                                        ? Colors.indigo.shade100 
                                        : Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: answer[index] != null 
                                          ? Colors.indigo 
                                          : Colors.grey,
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      answer[index] ?? "_____",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: answer[index] != null 
                                            ? Colors.black 
                                            : Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                        
                        // Available words
                        Container(
                          margin: EdgeInsets.only(bottom: 16),
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.indigo.shade100,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: shuffledWords.map((word) {
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    // Find first empty position
                                    int emptyPos = answer.indexOf(null);
                                    if (emptyPos != -1) {
                                      answer[emptyPos] = word;
                                      shuffledWords.remove(word);
                                    }
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.indigo.shade600,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        offset: Offset(0, 2),
                                        blurRadius: 3,
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    word,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        
                        // Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: resetChallenge,
                              icon: Icon(Icons.refresh),
                              label: Text("Reset"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                            ),
                            SizedBox(width: 16),
                            ElevatedButton.icon(
                              onPressed: checkAnswer,
                              icon: Icon(Icons.check_circle),
                              label: Text("Check Answer"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        SizedBox(height: 16),
                        
                        // Next challenge button (only visible when completed)
                        if (challengeCompleted)
                          Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(color: Colors.green),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        "Did you know?",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green.shade800,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        challenges[currentChallengeIndex]["fact"],
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontStyle: FontStyle.italic,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Column(
                                            children: [
                                              Text("Time Bonus",
                                                  style: TextStyle(fontWeight: FontWeight.bold)),
                                              Text("+$timeBonus", 
                                                  style: TextStyle(color: Colors.green)),
                                            ],
                                          ),
                                          SizedBox(width: 30),
                                          Column(
                                            children: [
                                              Text("Hint Penalty",
                                                  style: TextStyle(fontWeight: FontWeight.bold)),
                                              Text("-${hintsUsed * hintPenalty}", 
                                                  style: TextStyle(color: Colors.red)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: nextChallenge,
                                icon: Icon(Icons.arrow_forward),
                                label: Text("Next Challenge"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Feedback message
          if (showFeedback)
            Positioned(
              top: 100,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Text(
                    feedbackMessage,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: feedbackColor,
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
              numberOfParticles: 20,
              gravity: 0.1,
              colors: [
                Colors.red,
                Colors.green,
                Colors.blue,
                Colors.yellow,
                Colors.purple,
                Colors.orange,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Level 2 would have more advanced challenges and features
class WordChallengeLevel2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Word Challenge - Level 2"),
        backgroundColor: Colors.purple,
      ),
      body: Center(
        child: Text("Level 2 - Coming Soon!"),
      ),
    );
  }
}