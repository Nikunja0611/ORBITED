import 'package:flutter/material.dart';
import 'dart:math';

class NumberNinjas extends StatefulWidget {
  final String ageGroup;
  NumberNinjas({required this.ageGroup});

  @override
  _NumberNinjasState createState() => _NumberNinjasState();
}

class _NumberNinjasState extends State<NumberNinjas> {
  int lives = 3;
  int score = 0;
  int correctStreak = 0;
  int num1 = 0;
  int num2 = 0;
  String operator = '+';
  int correctAnswer = 0;
  String feedbackEmoji = '';
  List<Widget> heartIcons = [Icon(Icons.favorite, color: Colors.red, size: 30)];
  TextEditingController answerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    generateQuestion();
  }

  void generateQuestion() {
    Random random = Random();

    if (widget.ageGroup == "4-6") {
      num1 = random.nextInt(5) + 1; // Numbers between 1-5
      num2 = random.nextInt(5) + 1;
      operator = '+'; // Only addition
    } else if (widget.ageGroup == "6-8") {
      num1 = random.nextInt(10) + 1; // Numbers between 1-10
      num2 = random.nextInt(10) + 1;
      List<String> operators = ['+', '-']; // Addition & Subtraction
      operator = operators[random.nextInt(operators.length)];
    }

    switch (operator) {
      case '+':
        correctAnswer = num1 + num2;
        break;
      case '-':
        correctAnswer = num1 - num2;
        break;
    }
    setState(() {});
  }

  void checkAnswer() {
    if (answerController.text.isEmpty) return;
    int userAnswer = int.tryParse(answerController.text) ?? 0;
    if (userAnswer == correctAnswer) {
      score += 10;
      correctStreak++;
      feedbackEmoji = '✅';
      if (correctStreak == 3) {
        lives++;
        heartIcons.add(Icon(Icons.favorite, color: Colors.red, size: 30));
        correctStreak = 0;
        showHeartAnimation(true);
      }
    } else {
      lives--;
      correctStreak = 0;
      feedbackEmoji = '❌';
      if (heartIcons.isNotEmpty) {
        heartIcons.removeLast();
      }
      showHeartAnimation(false);
    }
    answerController.clear();
    if (lives > 0) {
      generateQuestion();
    } else {
      showGameOverDialog();
    }
  }

  void showHeartAnimation(bool gained) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: Text(
          gained ? '❤️' : '💔',
          style: TextStyle(fontSize: 50),
          textAlign: TextAlign.center,
        ),
      ),
    );
    Future.delayed(Duration(seconds: 1), () => Navigator.of(context).pop());
  }

  void showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text("Game Over"),
        content: Text("Your score: $score"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              resetGame();
            },
            child: Text("Restart"),
          ),
        ],
      ),
    );
  }

  void resetGame() {
    setState(() {
      lives = 3;
      score = 0;
      correctStreak = 0;
      heartIcons = [Icon(Icons.favorite, color: Colors.red, size: 30)];
      generateQuestion();
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Number Ninjas 🥷🔢 (${widget.ageGroup})"),
        backgroundColor: Colors.deepPurple,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: screenWidth,
            height: screenHeight,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: screenHeight * 0.02),
                // Lives and Score
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: heartIcons,
                ),
                SizedBox(height: screenHeight * 0.02),
                Text(
                  "Lives: $lives",
                  style: TextStyle(fontSize: screenWidth * 0.06, color: Colors.white),
                ),
                Text(
                  "Score: $score",
                  style: TextStyle(fontSize: screenWidth * 0.06, color: Colors.white),
                ),
                SizedBox(height: screenHeight * 0.03),

                // Question Display
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _numberCard("$num1", Colors.blueAccent, screenWidth),
                    _numberCard("$operator", Colors.green, screenWidth),
                    _numberCard("$num2", Colors.blueAccent, screenWidth),
                  ],
                ),
                SizedBox(height: screenHeight * 0.03),

                // Answer Input
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                  child: TextField(
                    controller: answerController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Enter answer",
                      fillColor: Colors.white,
                      filled: true,
                    ),
                    style: TextStyle(fontSize: screenWidth * 0.05),
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),

                // Submit Button
                SizedBox(
                  width: screenWidth * 0.5,
                  height: screenHeight * 0.07,
                  child: ElevatedButton(
                    onPressed: checkAnswer,
                    child: Text("Submit", style: TextStyle(fontSize: screenWidth * 0.05)),
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),

                // Feedback Emoji
                Text(feedbackEmoji, style: TextStyle(fontSize: screenWidth * 0.12)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _numberCard(String value, Color color, double screenWidth) {
    return Card(
      color: color,
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Text(
          value,
          style: TextStyle(fontSize: screenWidth * 0.08, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}
