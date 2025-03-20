import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:lottie/lottie.dart';

void main() {
  runApp(MathFrenzyApp3());
}

class MathFrenzyApp3 extends StatelessWidget {
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
      'addition',
      'subtraction',
      'multiplication',
      'division'
    ];

    currentQuestionType = questionTypes[_random.nextInt(questionTypes.length)];

    switch (currentQuestionType) {
      case 'addition':
        generateAdditionQuestion();
        break;
      case 'subtraction':
        generateSubtractionQuestion();
        break;
      case 'multiplication':
        generateMultiplicationQuestion();
        break;
      case 'division':
        generateDivisionQuestion();
        break;
    }

    setState(() {});
  }

  // Generate addition word problem
  void generateAdditionQuestion() {
    int type = _random.nextInt(3);

    if (type == 0) {
      // Food-related addition
      List<String> foods = [
        'apples',
        'oranges',
        'candies',
        'cookies',
        'bananas'
      ];
      String food = foods[_random.nextInt(foods.length)];
      int amount1 = _random.nextInt(20) + 5;
      int amount2 = _random.nextInt(15) + 5;

      currentQuestion =
          "Sara has $amount1 $food. Her friend gives her $amount2 more $food. How many $food does Sara have now?";
      correctAnswer = (amount1 + amount2).toString();
    } else if (type == 1) {
      // Money-related addition
      int dollars1 = _random.nextInt(50) + 10;
      int dollars2 = _random.nextInt(30) + 5;

      currentQuestion =
          "Tom has \$$dollars1 in his piggy bank. He receives \$$dollars2 for his birthday. How much money does Tom have now?";
      correctAnswer = (dollars1 + dollars2).toString();
    } else {
      // Collection-related addition
      List<String> items = [
        'stickers',
        'marbles',
        'trading cards',
        'toy cars',
        'buttons'
      ];
      String item = items[_random.nextInt(items.length)];
      int count1 = _random.nextInt(30) + 10;
      int count2 = _random.nextInt(20) + 5;

      currentQuestion =
          "Max has $count1 $item in his collection. He finds $count2 more $item. How many $item does he have in total?";
      correctAnswer = (count1 + count2).toString();
    }
  }

  // Generate subtraction word problem
  void generateSubtractionQuestion() {
    int type = _random.nextInt(3);

    if (type == 0) {
      // Food-related subtraction
      List<String> foods = [
        'candies',
        'chocolates',
        'grapes',
        'strawberries',
        'peanuts'
      ];
      String food = foods[_random.nextInt(foods.length)];
      int total = _random.nextInt(30) + 20;
      int eaten = _random.nextInt(15) + 5;

      currentQuestion =
          "Emily has $total $food. She eats $eaten of them. How many $food does she have left?";
      correctAnswer = (total - eaten).toString();
    } else if (type == 1) {
      // Money-related subtraction
      int dollars1 = _random.nextInt(50) + 30;
      int dollars2 = _random.nextInt(25) + 5;
      while (dollars2 > dollars1) {
        dollars2 = _random.nextInt(25) + 5;
      }

      currentQuestion =
          "Dad has \$$dollars1. He spends \$$dollars2 at the store. How much money does he have left?";
      correctAnswer = (dollars1 - dollars2).toString();
    } else {
      // Collection-related subtraction
      List<String> items = ['marbles', 'crayons', 'pencils', 'books', 'toys'];
      String item = items[_random.nextInt(items.length)];
      int total = _random.nextInt(40) + 15;
      int given = _random.nextInt(14) + 5;
      while (given > total) {
        given = _random.nextInt(14) + 5;
      }

      currentQuestion =
          "Lily has $total $item. She gives $given $item to her friend. How many $item does she have left?";
      correctAnswer = (total - given).toString();
    }
  }

  // Generate multiplication word problem
  void generateMultiplicationQuestion() {
    int type = _random.nextInt(3);

    if (type == 0) {
      // Group-related multiplication
      int groups = _random.nextInt(7) + 2;
      int itemsPerGroup = _random.nextInt(8) + 2;
      List<String> contexts = [
        'baskets',
        'boxes',
        'bags',
        'containers',
        'packages'
      ];
      String context = contexts[_random.nextInt(contexts.length)];
      List<String> items = [
        'pencils',
        'markers',
        'stickers',
        'erasers',
        'candies'
      ];
      String item = items[_random.nextInt(items.length)];

      currentQuestion =
          "There are $groups $context with $itemsPerGroup $item in each $context. How many $item are there in total?";
      correctAnswer = (groups * itemsPerGroup).toString();
    } else if (type == 1) {
      // Repeated addition context
      int price = _random.nextInt(10) + 1;
      int quantity = _random.nextInt(7) + 2;
      List<String> items = [
        'notebooks',
        'toy cars',
        'cupcakes',
        'juice boxes',
        'stickers'
      ];
      String item = items[_random.nextInt(items.length)];

      currentQuestion =
          "Each $item costs \$$price. If you buy $quantity $item, how much will you spend in total?";
      correctAnswer = (price * quantity).toString();
    } else {
      // Array model
      int rows = _random.nextInt(5) + 2;
      int columns = _random.nextInt(6) + 2;
      List<String> contexts = [
        'garden',
        'classroom',
        'parking lot',
        'theater',
        'orchard'
      ];
      String context = contexts[_random.nextInt(contexts.length)];

      currentQuestion =
          "In a $context, chairs are arranged in $rows rows with $columns chairs in each row. How many chairs are there in total?";
      correctAnswer = (rows * columns).toString();
    }
  }

  // Generate division word problem
  void generateDivisionQuestion() {
    int type = _random.nextInt(3);

    if (type == 0) {
      // Sharing equally
      int divisor = _random.nextInt(6) + 2;
      int total = divisor * (_random.nextInt(8) + 2);
      List<String> items = [
        'cookies',
        'stickers',
        'marbles',
        'candies',
        'oranges'
      ];
      String item = items[_random.nextInt(items.length)];

      currentQuestion =
          "Alex has $total $item and wants to share them equally among $divisor friends. How many $item will each friend get?";
      correctAnswer = (total ~/ divisor).toString();
    } else if (type == 1) {
      // Grouping
      int groupSize = _random.nextInt(5) + 2;
      int total = groupSize * (_random.nextInt(6) + 2);
      List<String> items = ['pencils', 'books', 'toys', 'balloons', 'cookies'];
      String item = items[_random.nextInt(items.length)];

      currentQuestion =
          "There are $total $item. If we put $groupSize $item in each box, how many boxes will we need?";
      correctAnswer = (total ~/ groupSize).toString();
    } else {
      // Repeated subtraction
      int divisor = _random.nextInt(5) + 2;
      int total = divisor * (_random.nextInt(7) + 3);
      List<String> contexts = [
        'garden',
        'classroom',
        'playground',
        'park',
        'farm'
      ];
      String context = contexts[_random.nextInt(contexts.length)];

      currentQuestion =
          "There are $total trees in a $context. If they are planted in $divisor equal rows, how many trees are in each row?";
      correctAnswer = (total ~/ divisor).toString();
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
      case 'multiplication':
        return Colors.purple;
      case 'division':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }
}