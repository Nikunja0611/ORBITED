import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:lottie/lottie.dart';

void main() {
  runApp(MathFrenzyApp4());
}

class MathFrenzyApp4 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Math Frenzy',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Quicksand',
      ),
      home: MathFrenzy(),
    );
  }
}

class MathFrenzy extends StatefulWidget {
  @override
  _MathFrenzyState createState() => _MathFrenzyState();
}

class _MathFrenzyState extends State<MathFrenzy> {
  // Game state variables
  int score = 0;
  int lives = 3;
  String currentQuestion = "";
  String currentQuestionType = "";
  dynamic correctAnswer;
  TextEditingController answerController = TextEditingController();
  bool isAnswerCorrect = false;
  bool isAnswerWrong = false;
  bool showCelebration = false;

  // Confetti controller
  late ConfettiController _confettiController;

  // Random number generator
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: Duration(seconds: 5));
    generateNewQuestion();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    answerController.dispose();
    super.dispose();
  }

  // Generate a random question
  void generateNewQuestion() {
    // Reset the text field
    answerController.clear();

    // Reset feedback states
    isAnswerCorrect = false;
    isAnswerWrong = false;

    // Determine question type
    List<String> questionTypes = [
      'fractions',
      'weight',
      'counting',
      'patterns'
    ];

    currentQuestionType = questionTypes[_random.nextInt(questionTypes.length)];

    switch (currentQuestionType) {
      case 'fractions':
        generateFractionQuestion();
        break;
      case 'weight':
        generateWeightQuestion();
        break;
      case 'counting':
        generateCountingQuestion();
        break;
      case 'patterns':
        generatePatternQuestion();
        break;
    }

    setState(() {});
  }

  // Generate fraction-related question
  void generateFractionQuestion() {
    int type = _random.nextInt(3);

    if (type == 0) {
      // Simple fraction addition
      int denominator = _random.nextInt(10) + 2;
      int numerator1 = _random.nextInt(denominator);
      int numerator2 = _random.nextInt(denominator);

      currentQuestion =
          "What is $numerator1/$denominator + $numerator2/$denominator?";

      // Calculate correct answer
      int resultNumerator = numerator1 + numerator2;
      int gcd = _calculateGCD(resultNumerator, denominator);

      if (resultNumerator % denominator == 0) {
        correctAnswer = (resultNumerator ~/ denominator).toString();
      } else {
        if (gcd > 1) {
          correctAnswer = "${resultNumerator ~/ gcd}/${denominator ~/ gcd}";
        } else {
          correctAnswer = "$resultNumerator/$denominator";
        }
      }
    } else if (type == 1) {
      // Fraction to decimal
      int denominator = [2, 4, 5, 10, 20, 25, 50, 100][_random.nextInt(8)];
      int numerator = _random.nextInt(denominator) + 1;

      currentQuestion = "Convert $numerator/$denominator to a decimal.";

      // Calculate correct answer with precision to 2 decimal places
      double result = numerator / denominator;
      correctAnswer = result.toStringAsFixed(2);

      // Remove trailing zeros
      if (correctAnswer.endsWith('0')) {
        if (correctAnswer.endsWith('00')) {
          correctAnswer = correctAnswer.substring(0, correctAnswer.length - 3);
        } else {
          correctAnswer = correctAnswer.substring(0, correctAnswer.length - 1);
        }
      }
    } else {
      // Comparing fractions
      int denominator1 = _random.nextInt(10) + 2;
      int denominator2 = _random.nextInt(10) + 2;
      int numerator1 = _random.nextInt(denominator1) + 1;
      int numerator2 = _random.nextInt(denominator2) + 1;

      currentQuestion =
          "Which fraction is larger: $numerator1/$denominator1 or $numerator2/$denominator2? Enter the larger fraction.";

      // Calculate and compare
      double fraction1 = numerator1 / denominator1;
      double fraction2 = numerator2 / denominator2;

      if (fraction1 > fraction2) {
        correctAnswer = "$numerator1/$denominator1";
      } else {
        correctAnswer = "$numerator2/$denominator2";
      }
    }
  }

  // Generate weight-related question
  void generateWeightQuestion() {
    int type = _random.nextInt(3);

    if (type == 0) {
      // Kilograms to grams
      int kg = _random.nextInt(10) + 1;

      currentQuestion = "Convert $kg kilograms to grams.";
      correctAnswer = (kg * 1000).toString();
    } else if (type == 1) {
      // Grams to kilograms
      int grams = (_random.nextInt(10) + 1) * 100;

      currentQuestion = "Convert $grams grams to kilograms.";
      correctAnswer = (grams / 1000).toString();
    } else {
      // Weight comparison
      int weight1 = _random.nextInt(10) + 1;
      int weight2 = _random.nextInt(10) + 1;

      currentQuestion =
          "If a package weighs $weight1 kg and another weighs $weight2 kg, what is their total weight in kg?";
      correctAnswer = (weight1 + weight2).toString();
    }
  }

  // Generate counting-related question
  void generateCountingQuestion() {
    int type = _random.nextInt(3);

    if (type == 0) {
      // Simple counting
      int start = _random.nextInt(50);
      int step = _random.nextInt(5) + 2;
      List<int> sequence = List.generate(4, (index) => start + index * step);

      currentQuestion =
          "What comes next in the sequence: ${sequence.join(', ')}, ...?";
      correctAnswer = (sequence.last + step).toString();
    } else if (type == 1) {
      // Counting backwards
      int start = _random.nextInt(50) + 50;
      int step = _random.nextInt(5) + 2;
      List<int> sequence = List.generate(4, (index) => start - index * step);

      currentQuestion =
          "What comes next in the sequence: ${sequence.join(', ')}, ...?";
      correctAnswer = (sequence.last - step).toString();
    } else {
      // Skip counting
      int groups = _random.nextInt(5) + 2;
      int itemsPerGroup = _random.nextInt(5) + 2;

      currentQuestion =
          "If there are $groups groups with $itemsPerGroup items in each group, how many items are there in total?";
      correctAnswer = (groups * itemsPerGroup).toString();
    }
  }

  // Generate pattern-related question
  void generatePatternQuestion() {
    int type = _random.nextInt(3);

    if (type == 0) {
      // Arithmetic sequence
      int start = _random.nextInt(10) + 1;
      int difference = _random.nextInt(5) + 1;

      List<int> sequence =
          List.generate(4, (index) => start + index * difference);

      currentQuestion =
          "Find the next number in the pattern: ${sequence.join(', ')}, ...";
      correctAnswer = (sequence.last + difference).toString();
    } else if (type == 1) {
      // Geometric sequence
      int start = _random.nextInt(5) + 1;
      int ratio = _random.nextInt(3) + 2;

      List<int> sequence =
          List.generate(4, (index) => start * pow(ratio, index).toInt());

      currentQuestion =
          "Find the next number in the pattern: ${sequence.join(', ')}, ...";
      correctAnswer = (sequence.last * ratio).toString();
    } else {
      // Alternating pattern
      int value1 = _random.nextInt(10) + 1;
      int value2 = _random.nextInt(10) + 1;

      while (value1 == value2) {
        value2 = _random.nextInt(10) + 1;
      }

      List<int> sequence = [];
      for (int i = 0; i < 5; i++) {
        sequence.add(i % 2 == 0 ? value1 : value2);
      }

      currentQuestion =
          "Find the next number in the pattern: ${sequence.take(4).join(', ')}, ...";
      correctAnswer = sequence[4].toString();
    }
  }

  // Calculate GCD (Greatest Common Divisor)
  int _calculateGCD(int a, int b) {
    while (b != 0) {
      int t = b;
      b = a % b;
      a = t;
    }
    return a;
  }

  // Check the user's answer
  void checkAnswer() {
    String userAnswer = answerController.text.trim();

    // Handle empty answers
    if (userAnswer.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Please enter an answer")));
      return;
    }

    // Remove any spaces from the user's answer
    userAnswer = userAnswer.replaceAll(' ', '');

    // Compare with the correct answer
    if (userAnswer.toLowerCase() == correctAnswer.toString().toLowerCase()) {
      // Correct answer
      setState(() {
        score += 10;
        isAnswerCorrect = true;
        isAnswerWrong = false;
      });

      // Check if score is a multiple of 100
      if (score % 100 == 0) {
        showCelebration = true;
        _confettiController.play();

        // Hide celebration after 3 seconds
        Future.delayed(Duration(seconds: 3), () {
          setState(() {
            showCelebration = false;
          });

          // Generate next question
          generateNewQuestion();
        });
      } else {
        // Generate next question after a short delay
        Future.delayed(Duration(milliseconds: 800), () {
          generateNewQuestion();
        });
      }
    } else {
      // Wrong answer
      setState(() {
        lives--;
        isAnswerCorrect = false;
        isAnswerWrong = true;
      });

      if (lives <= 0) {
        // Game over
        _showGameOverDialog();
      } else {
        // Show feedback briefly
        Future.delayed(Duration(milliseconds: 800), () {
          setState(() {
            isAnswerWrong = false;
          });
        });
      }
    }
  }

  // Show game over dialog
  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Game Over"),
          content: Text("Your final score is $score."),
          actions: [
            TextButton(
              child: Text("Play Again"),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  score = 0;
                  lives = 3;
                  generateNewQuestion();
                });
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bg_level2.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Game content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Score and lives
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Score
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "Score: $score",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),

                      // Lives
                      Row(
                        children: List.generate(
                          3,
                          (index) => Padding(
                            padding: EdgeInsets.only(left: 4),
                            child: Icon(
                              Icons.favorite,
                              color: index < lives ? Colors.red : Colors.grey,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 30),

                  // Question card
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Question type indicator
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: _getQuestionTypeColor(),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            currentQuestionType.toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        SizedBox(height: 20),

                        // Question text
                        Text(
                          currentQuestion,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        SizedBox(height: 30),

                        // Answer input
                        TextField(
                          controller: answerController,
                          decoration: InputDecoration(
                            hintText: "Your answer",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(Icons.check_circle),
                              onPressed: checkAnswer,
                              color: Colors.blue,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: isAnswerCorrect
                                    ? Colors.green
                                    : isAnswerWrong
                                        ? Colors.red
                                        : Colors.blue,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => checkAnswer(),
                        ),

                        SizedBox(height: 20),

                        // Feedback
                        AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          height: isAnswerCorrect || isAnswerWrong ? 50 : 0,
                          child: Center(
                            child: Text(
                              isAnswerCorrect
                                  ? "Correct! 🎉"
                                  : isAnswerWrong
                                      ? "Wrong! The answer is $correctAnswer"
                                      : "",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color:
                                    isAnswerCorrect ? Colors.green : Colors.red,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(child: SizedBox()),

                  // Submit button
                  ElevatedButton(
                    onPressed: checkAnswer,
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        "Submit Answer",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Confetti animation
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              particleDrag: 0.05,
              emissionFrequency: 0.05,
              numberOfParticles: 50,
              gravity: 0.1,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
                Colors.red,
              ],
            ),
          ),

          // Celebration animation
          if (showCelebration)
            Center(
              child: Lottie.asset(
                'assets/celebration.json',
                width: 300,
                height: 300,
                fit: BoxFit.contain,
              ),
            ),
        ],
      ),
    );
  }

  // Get color for question type
  Color _getQuestionTypeColor() {
    switch (currentQuestionType) {
      case 'fractions':
        return Colors.purple;
      case 'weight':
        return Colors.orange;
      case 'counting':
        return Colors.teal;
      case 'patterns':
        return Colors.indigo;
      default:
        return Colors.blue;
    }
  }
}