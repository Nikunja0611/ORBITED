import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:lottie/lottie.dart';

void main() {
  runApp(MathFrenzyApp2());
}

class MathFrenzyApp2 extends StatelessWidget {
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
    List<String> questionTypes = ['addition', 'subtraction', 'counting'];

    currentQuestionType = questionTypes[_random.nextInt(questionTypes.length)];

    switch (currentQuestionType) {
      case 'addition':
        generateAdditionQuestion();
        break;
      case 'subtraction':
        generateSubtractionQuestion();
        break;
      case 'counting':
        generateCountingQuestion();
        break;
    }

    setState(() {});
  }

  // Generate basic addition word problem
  void generateAdditionQuestion() {
    int type = _random.nextInt(3);

    if (type == 0) {
      // Simple addition with small numbers
      int num1 = _random.nextInt(5) + 1;
      int num2 = _random.nextInt(5) + 1;

      currentQuestion =
          "Sam has $num1 apple${num1 > 1 ? 's' : ''}. Mom gives him $num2 more apple${num2 > 1 ? 's' : ''}. How many apples does Sam have now?";
      correctAnswer = (num1 + num2).toString();
    } else if (type == 1) {
      // Addition with toy context
      int num1 = _random.nextInt(5) + 1;
      int num2 = _random.nextInt(5) + 1;

      currentQuestion =
          "Emma has $num1 toy car${num1 > 1 ? 's' : ''}. Her friend gives her $num2 more toy car${num2 > 1 ? 's' : ''}. How many toy cars does Emma have now?";
      correctAnswer = (num1 + num2).toString();
    } else {
      // Addition with classroom context
      int num1 = _random.nextInt(6) + 1;
      int num2 = _random.nextInt(4) + 1;

      currentQuestion =
          "There are $num1 kid${num1 > 1 ? 's' : ''} drawing. $num2 more kid${num2 > 1 ? 's join' : ' joins'} them. How many kids are drawing now?";
      correctAnswer = (num1 + num2).toString();
    }
  }

  // Generate basic subtraction word problem
  void generateSubtractionQuestion() {
    int type = _random.nextInt(3);

    if (type == 0) {
      // Simple subtraction with small numbers
      int total = _random.nextInt(6) + 5; // 5-10
      int taken = _random.nextInt(total - 1) +
          1; // Ensure we don't take more than we have

      currentQuestion =
          "Tim has $total cookie${total > 1 ? 's' : ''}. He eats $taken of them. How many cookies does Tim have left?";
      correctAnswer = (total - taken).toString();
    } else if (type == 1) {
      // Subtraction with animal context
      int total = _random.nextInt(7) + 4; // 4-10
      int gone = _random.nextInt(total - 1) +
          1; // Ensure we don't take more than we have

      currentQuestion =
          "There are $total bird${total > 1 ? 's' : ''} in a tree. $gone bird${gone > 1 ? 's fly' : ' flies'} away. How many birds are left in the tree?";
      correctAnswer = (total - gone).toString();
    } else {
      // Subtraction with toy context
      int total = _random.nextInt(8) + 3; // 3-10
      int given = _random.nextInt(total - 1) +
          1; // Ensure we don't give more than we have

      currentQuestion =
          "Lisa has $total balloon${total > 1 ? 's' : ''}. She gives $given to her brother. How many balloons does Lisa have now?";
      correctAnswer = (total - given).toString();
    }
  }

  // Generate counting objects question
  void generateCountingQuestion() {
    int type = _random.nextInt(3);

    if (type == 0) {
      // Counting different objects
      List<String> objects = ['apples', 'oranges', 'bananas'];

      int appleCount = _random.nextInt(5) + 1;
      int orangeCount = _random.nextInt(5) + 1;
      int bananaCount = _random.nextInt(5) + 1;

      int totalFruit = appleCount + orangeCount + bananaCount;

      currentQuestion =
          "Billy has $appleCount ${objects[0]}, $orangeCount ${objects[1]}, and $bananaCount ${objects[2]}. How many pieces of fruit does Billy have in total?";
      correctAnswer = totalFruit.toString();
    } else if (type == 1) {
      // Counting in a scene
      int animals = _random.nextInt(4) + 2; // 2-5
      int people = _random.nextInt(3) + 1; // 1-3

      currentQuestion =
          "On a farm there are $animals chicken${animals > 1 ? 's' : ''} and $people person${people > 1 ? 's' : ''}. How many living things are there in total?";
      correctAnswer = (animals + people).toString();
    } else {
      // Simple counting of objects
      int rows = _random.nextInt(3) + 1; // 1-3
      int itemsPerRow = _random.nextInt(3) + 2; // 2-4
      int totalItems = rows * itemsPerRow;

      currentQuestion =
          "There are $rows row${rows > 1 ? 's' : ''} of flower${rows > 1 ? 's' : ''}. Each row has $itemsPerRow flower${itemsPerRow > 1 ? 's' : ''}. How many flowers are there in total?";
      correctAnswer = totalItems.toString();
    }
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
                            fontSize: 18,
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
      case 'addition':
        return Colors.green;
      case 'subtraction':
        return Colors.red;
      case 'counting':
        return Colors.purple;
      default:
        return Colors.blue;
    }
  }
}