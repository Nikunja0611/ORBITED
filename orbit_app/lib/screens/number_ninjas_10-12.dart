import 'package:flutter/material.dart';
import 'dart:math';

class NumberNinjas4 extends StatefulWidget {
  final String ageGroup;
  const NumberNinjas4({Key? key, required this.ageGroup}) : super(key: key);

  @override
  _NumberNinjasState createState() => _NumberNinjasState();
}

class _NumberNinjasState extends State<NumberNinjas4>
    with SingleTickerProviderStateMixin {
  int lives = 3;
  int score = 0;
  int correctStreak = 0;
  int num1 = 0;
  int num2 = 0;
  int num3 = 0; // Added for complex operations
  String operation = ''; // Will store the entire operation string
  int correctAnswer = 0;
  String feedbackEmoji = '';
  List<Widget> heartIcons = [];
  TextEditingController answerController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool isAnswerCorrect = false;
  int currentQuestionIndex = 0;
  List<Map<String, dynamic>> predefinedQuestions = [];

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    // Initialize heart icons
    heartIcons = [];
    for (int i = 0; i < lives; i++) {
      heartIcons.add(const Icon(Icons.favorite, color: Colors.red, size: 30));
    }

    // Setup animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );

    // Initialize the predefined questions based on age group
    _initializePredefinedQuestions();

    // Load the first question
    loadQuestion();
  }

  void _initializePredefinedQuestions() {
    // Clear any existing questions
    predefinedQuestions = [];

    // Create 4 fraction questions
    _addFractionQuestions();

    // Create 16 mixed operation questions
    _addMixedOperationQuestions();

    // Shuffle the questions for randomness
    predefinedQuestions.shuffle(Random());
  }

  void _addFractionQuestions() {
    // 4 fraction questions (displayed as division)
    predefinedQuestions
        .add({'operation': '8 ÷ 2', 'answer': 4, 'type': 'fraction'});

    predefinedQuestions
        .add({'operation': '10 ÷ 5', 'answer': 2, 'type': 'fraction'});

    predefinedQuestions
        .add({'operation': '12 ÷ 3', 'answer': 4, 'type': 'fraction'});

    predefinedQuestions
        .add({'operation': '15 ÷ 3', 'answer': 5, 'type': 'fraction'});
  }

  void _addMixedOperationQuestions() {
    // 16 mixed operation questions that combine addition, subtraction, and multiplication

    // Addition + Subtraction combinations
    predefinedQuestions
        .add({'operation': '5 + 3 - 2', 'answer': 6, 'type': 'mixed'});

    predefinedQuestions
        .add({'operation': '10 - 4 + 7', 'answer': 13, 'type': 'mixed'});

    predefinedQuestions
        .add({'operation': '8 + 4 - 5', 'answer': 7, 'type': 'mixed'});

    // Addition + Multiplication combinations
    predefinedQuestions
        .add({'operation': '3 + 2 × 4', 'answer': 11, 'type': 'mixed'});

    predefinedQuestions
        .add({'operation': '2 × 3 + 5', 'answer': 11, 'type': 'mixed'});

    predefinedQuestions
        .add({'operation': '4 + 3 × 2', 'answer': 10, 'type': 'mixed'});

    // Subtraction + Multiplication combinations
    predefinedQuestions
        .add({'operation': '10 - 2 × 3', 'answer': 4, 'type': 'mixed'});

    predefinedQuestions
        .add({'operation': '15 - 3 × 2', 'answer': 9, 'type': 'mixed'});

    predefinedQuestions
        .add({'operation': '2 × 4 - 3', 'answer': 5, 'type': 'mixed'});

    // All three operations combined
    predefinedQuestions
        .add({'operation': '2 × 3 + 4 - 1', 'answer': 9, 'type': 'mixed'});

    predefinedQuestions
        .add({'operation': '5 + 2 × 3 - 4', 'answer': 7, 'type': 'mixed'});

    predefinedQuestions
        .add({'operation': '10 - 2 + 3 × 2', 'answer': 14, 'type': 'mixed'});

    predefinedQuestions
        .add({'operation': '3 × 2 - 1 + 4', 'answer': 9, 'type': 'mixed'});

    predefinedQuestions
        .add({'operation': '4 + 3 × 2 - 5', 'answer': 5, 'type': 'mixed'});

    predefinedQuestions
        .add({'operation': '8 - 2 × 3 + 5', 'answer': 7, 'type': 'mixed'});

    predefinedQuestions
        .add({'operation': '2 × (3 + 1)', 'answer': 8, 'type': 'mixed'});
  }

  @override
  void dispose() {
    answerController.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void loadQuestion() {
    if (currentQuestionIndex >= predefinedQuestions.length) {
      // If we've gone through all questions, shuffle and start over
      predefinedQuestions.shuffle(Random());
      currentQuestionIndex = 0;
    }

    // Get the current question
    Map<String, dynamic> question = predefinedQuestions[currentQuestionIndex];

    setState(() {
      operation = question['operation'];
      correctAnswer = question['answer'];
    });

    // Increment for next question
    currentQuestionIndex++;
  }

  void checkAnswer() {
    if (answerController.text.isEmpty) return;

    int userAnswer = int.tryParse(answerController.text) ?? 0;
    isAnswerCorrect = userAnswer == correctAnswer;

    if (isAnswerCorrect) {
      setState(() {
        // Award points
        if (operation.contains('×') || operation.contains('÷')) {
          score += 15; // More points for harder operations
        } else {
          score += 10; // Standard points for addition/subtraction
        }

        correctStreak++;
        feedbackEmoji = '✅';

        if (correctStreak == 3) {
          lives = lives < 5 ? lives + 1 : lives; // Cap at 5 lives max
          if (heartIcons.length < 5) {
            heartIcons.add(_buildHeartWithAnimation());
          }
          correctStreak = 0;
          showHeartAnimation(true);
        }
      });
    } else {
      setState(() {
        lives--;
        correctStreak = 0;
        feedbackEmoji = '❌';

        if (heartIcons.isNotEmpty) {
          heartIcons.removeLast();
        }
      });
      showHeartAnimation(false);
    }

    // Animate the question
    _animationController.reset();
    _animationController.forward();

    answerController.clear();

    if (lives > 0) {
      loadQuestion();
    } else {
      showGameOverDialog();
    }

    _focusNode.requestFocus();
  }

  Widget _buildHeartWithAnimation() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_animation.value * 0.5),
          child: const Icon(Icons.favorite, color: Colors.red, size: 30),
        );
      },
    );
  }

  void showHeartAnimation(bool gained) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform.scale(
              scale: 0.5 + _animation.value,
              child: Text(
                gained ? '❤️' : '💔',
                style: const TextStyle(fontSize: 60),
                textAlign: TextAlign.center,
              ),
            );
          },
        ),
      ),
    );

    _animationController.reset();
    _animationController.forward();

    Future.delayed(const Duration(milliseconds: 800), () {
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  void showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.deepPurple.shade900,
        title: const Text(
          "Game Over",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, color: Colors.amber, size: 60),
            const SizedBox(height: 16),
            Text(
              "Your score: $score",
              style: const TextStyle(fontSize: 22, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text("Play Again", style: TextStyle(fontSize: 16)),
              onPressed: () {
                Navigator.of(context).pop();
                resetGame();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void resetGame() {
    setState(() {
      lives = 3;
      score = 0;
      correctStreak = 0;
      feedbackEmoji = '';
      heartIcons = List.generate(lives,
          (index) => const Icon(Icons.favorite, color: Colors.red, size: 30));
      answerController.clear();

      // Shuffle questions for a new game
      predefinedQuestions.shuffle(Random());
      currentQuestionIndex = 0;
      loadQuestion();
    });
  }

  Color getOperatorColor(String op) {
    if (op.contains('+')) return Colors.green.shade400;
    if (op.contains('-')) return Colors.red.shade400;
    if (op.contains('×')) return Colors.orange.shade400;
    if (op.contains('÷')) return Colors.blue.shade400;
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    final isLandscape = mediaQuery.orientation == Orientation.landscape;

    // Theme variables
    final Color primaryColor = Colors.deepPurple.shade800;
    final Color accentColor = Colors.amber;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          "Number Ninjas 🥷🔢 (${widget.ageGroup})",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        actions: [
          // Add a restart button in the AppBar
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Restart Game',
            onPressed: resetGame,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [primaryColor, Colors.black],
          ),
        ),
        child: SafeArea(
          child: isLandscape
              ? _buildLandscapeLayout(size, primaryColor, accentColor)
              : _buildPortraitLayout(size, primaryColor, accentColor),
        ),
      ),
    );
  }

  Widget _buildPortraitLayout(
      Size size, Color primaryColor, Color accentColor) {
    // Responsive sizing
    final double cardSize = min(size.width * 0.8, 320.0);
    final double fontSize = min(size.width * 0.06, 32.0);
    final double buttonHeight = min(size.height * 0.07, 60.0);

    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: size.height -
              AppBar().preferredSize.height -
              MediaQuery.of(context).padding.top,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top section with score
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: accentColor, width: 2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Lives
                    Row(
                      children: heartIcons,
                    ),
                    // Score
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Text(
                        "Score: $score",
                        style: TextStyle(
                          fontSize: min(fontSize * 0.7, 22.0),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: size.height * 0.05),

              // Question container - modified to show the entire operation
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: isAnswerCorrect
                        ? 1.0 + (_animation.value * 0.1)
                        : 1.0 -
                            (_animation.value * 0.05) +
                            (_animation.value * _animation.value * 0.05),
                    child: child,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: primaryColor, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      operation,
                      style: TextStyle(
                        fontSize: min(fontSize * 1.5, 48.0),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: size.height * 0.05),

              // Feedback emoji
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  feedbackEmoji,
                  key: ValueKey<String>(feedbackEmoji),
                  style: TextStyle(fontSize: min(fontSize * 2, 64.0)),
                ),
              ),

              SizedBox(height: size.height * 0.05),

              // Answer input
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: answerController,
                  focusNode: _focusNode,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => checkAnswer(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: min(fontSize, 32.0),
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    hintText: "Your answer",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),

              // Submit button
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                width: size.width * 0.7,
                height: buttonHeight,
                child: ElevatedButton(
                  onPressed: checkAnswer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.black,
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    "Check Answer",
                    style: TextStyle(
                      fontSize: min(fontSize * 0.8, 24.0),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLandscapeLayout(
      Size size, Color primaryColor, Color accentColor) {
    // Responsive sizing for landscape - adjustable based on screen size
    final double fontSize =
        min(min(size.height * 0.05, size.width * 0.028), 24.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Adjust layout based on available width
        final bool isWideScreen = constraints.maxWidth > 900;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left panel (score and lives)
            Expanded(
              flex: isWideScreen ? 3 : 2,
              child: Container(
                margin: EdgeInsets.all(constraints.maxHeight * 0.03),
                padding: EdgeInsets.all(constraints.maxHeight * 0.03),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: accentColor, width: 2),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Lives
                    Text(
                      "Lives",
                      style: TextStyle(
                        fontSize: fontSize * 0.8,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: constraints.maxHeight * 0.02),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 5,
                      children: heartIcons,
                    ),
                    SizedBox(height: constraints.maxHeight * 0.04),

                    // Score
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: constraints.maxWidth * 0.02,
                        vertical: constraints.maxHeight * 0.02,
                      ),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            "Score",
                            style: TextStyle(
                              fontSize: fontSize * 0.7,
                              color: Colors.white70,
                            ),
                          ),
                          Text(
                            "$score",
                            style: TextStyle(
                              fontSize: fontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: constraints.maxHeight * 0.04),

                    // Feedback emoji
                    Expanded(
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            feedbackEmoji,
                            key: ValueKey<String>(feedbackEmoji),
                            style: TextStyle(fontSize: fontSize * 2),
                          ),
                        ),
                      ),
                    ),

                    // Add restart button at the bottom on the stats panel
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: const Text("Restart Game"),
                        onPressed: resetGame,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Middle - Question (modified for mixed operations)
            Expanded(
              flex: isWideScreen ? 4 : 3,
              child: Center(
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: isAnswerCorrect
                          ? 1.0 + (_animation.value * 0.1)
                          : 1.0 -
                              (_animation.value * 0.05) +
                              (_animation.value * _animation.value * 0.05),
                      child: child,
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(constraints.maxHeight * 0.03),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: primaryColor, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Text(
                      operation,
                      style: TextStyle(
                        fontSize: fontSize * 1.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Right - Answer input
            Expanded(
              flex: isWideScreen ? 4 : 3,
              child: Padding(
                padding: EdgeInsets.all(constraints.maxHeight * 0.03),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: constraints.maxWidth * 0.25,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: answerController,
                        focusNode: _focusNode,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => checkAnswer(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          hintText: "Your answer",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: constraints.maxHeight * 0.03,
                            horizontal: constraints.maxWidth * 0.01,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: constraints.maxHeight * 0.04),
                    SizedBox(
                      width: constraints.maxWidth * 0.2,
                      height: constraints.maxHeight * 0.15,
                      child: ElevatedButton(
                        onPressed: checkAnswer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          foregroundColor: Colors.black,
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          "Check\nAnswer",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: fontSize * 0.8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}