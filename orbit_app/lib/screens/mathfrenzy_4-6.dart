import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:lottie/lottie.dart';

void main() {
  runApp(MathFrenzyApp1());
}

class MathFrenzyApp1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Counting Fun',
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

  // Variables for visual counting
  List<IconData> itemIcons = [];
  List<Color> itemColors = [];
  String currentCountingObject = "";

  // Define icon mappings for various objects
  final Map<String, IconData> animalIcons = {
    'dog': Icons.pets,
    'cat': Icons.mood,
    'bird': Icons.flutter_dash,
    'fish': Icons.water,
    'bunny': Icons.cruelty_free,
  };

  final Map<String, IconData> fruitIcons = {
    'apple': Icons.apple,
    'banana': Icons.lunch_dining,
    'orange': Icons.circle,
    'strawberry': Icons.eco,
    'grape': Icons.grain,
  };

  final Map<String, IconData> toyIcons = {
    'ball': Icons.sports_baseball,
    'block': Icons.crop_square,
    'car': Icons.directions_car,
    'doll': Icons.person_outline,
    'teddy': Icons.plumbing,
  };

  final Map<String, IconData> shapeIcons = {
    'star': Icons.star,
    'heart': Icons.favorite,
    'circle': Icons.circle,
    'flower': Icons.local_florist,
    'balloon': Icons.airline_stops,
  };

  final Map<String, IconData> peopleIcons = {
    'child': Icons.child_care,
    'friend': Icons.person,
    'boy': Icons.boy,
    'girl': Icons.girl,
    'baby': Icons.child_friendly,
  };

  final Map<String, Color> colorMap = {
    'red': Colors.red,
    'blue': Colors.blue,
    'green': Colors.green,
    'yellow': Colors.amber,
    'purple': Colors.purple,
  };

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

    // Reset visual elements
    itemIcons = [];
    itemColors = [];

    // For young children, we'll only use counting questions
    currentQuestionType = "counting";

    // Select a random question type
    int questionType = _random.nextInt(5);

    switch (questionType) {
      case 0:
        generateAnimalCountingQuestion();
        break;
      case 1:
        generateFruitCountingQuestion();
        break;
      case 2:
        generateToyCountingQuestion();
        break;
      case 3:
        generateColorCountingQuestion();
        break;
      case 4:
        generatePeopleCountingQuestion();
        break;
    }

    setState(() {});
  }

  // Generate animal counting question
  void generateAnimalCountingQuestion() {
    List<String> animals = ['dog', 'cat', 'bird', 'fish', 'bunny'];
    String animal = animals[_random.nextInt(animals.length)];
    int count = _random.nextInt(5) + 1; // 1-5 animals

    currentCountingObject = animal;

    // Create icons to count
    IconData animalIcon = animalIcons[animal] ?? Icons.pets;
    itemIcons = List.generate(count, (_) => animalIcon);
    itemColors = List.generate(count, (_) => Colors.brown);

    currentQuestion =
        "How many ${count > 1 ? "${animal}s" : animal} can you see?";
    correctAnswer = count.toString();
  }

  // Generate fruit counting question
  void generateFruitCountingQuestion() {
    List<String> fruits = ['apple', 'banana', 'orange', 'strawberry', 'grape'];
    String fruit = fruits[_random.nextInt(fruits.length)];
    int count = _random.nextInt(5) + 1; // 1-5 fruits

    currentCountingObject = fruit;

    // Create icons to count
    IconData fruitIcon = fruitIcons[fruit] ?? Icons.apple;

    // Set appropriate colors
    Color fruitColor = Colors.red;
    if (fruit == 'banana')
      fruitColor = Colors.yellow;
    else if (fruit == 'orange')
      fruitColor = Colors.orange;
    else if (fruit == 'grape')
      fruitColor = Colors.purple;
    else if (fruit == 'strawberry') fruitColor = Colors.red;

    itemIcons = List.generate(count, (_) => fruitIcon);
    itemColors = List.generate(count, (_) => fruitColor);

    // Special case for irregular plurals
    String fruitPlural = fruit == 'strawberry' ? 'strawberries' : "${fruit}s";

    currentQuestion =
        "Count the ${count > 1 ? fruitPlural : fruit}. How many are there?";
    correctAnswer = count.toString();
  }

  // Generate toy counting question
  void generateToyCountingQuestion() {
    List<String> toys = ['ball', 'block', 'car', 'doll', 'teddy'];
    String toy = toys[_random.nextInt(toys.length)];
    int count = _random.nextInt(5) + 1; // 1-5 toys

    currentCountingObject = toy;

    // Create icons to count
    IconData toyIcon = toyIcons[toy] ?? Icons.toys;

    // Assign random bright colors to toys
    List<Color> toyColors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.pink,
    ];

    itemIcons = List.generate(count, (_) => toyIcon);
    itemColors = List.generate(
        count, (_) => toyColors[_random.nextInt(toyColors.length)]);

    currentQuestion =
        "Count the ${count > 1 ? "${toy}s" : toy}. How many do you see?";
    correctAnswer = count.toString();
  }

  // Generate color counting question
  void generateColorCountingQuestion() {
    List<String> colors = ['red', 'blue', 'green', 'yellow', 'purple'];
    String color = colors[_random.nextInt(colors.length)];

    List<String> objects = ['star', 'heart', 'circle', 'flower', 'balloon'];
    String object = objects[_random.nextInt(objects.length)];

    int count = _random.nextInt(5) + 1; // 1-5 objects

    currentCountingObject = "$color $object";

    // Create icons to count
    IconData shapeIcon = shapeIcons[object] ?? Icons.star;
    Color shapeColor = colorMap[color] ?? Colors.blue;

    // For this question, we'll generate colored shapes plus some distractors in different colors
    itemIcons = [];
    itemColors = [];

    // Add the shapes with the correct color
    for (int i = 0; i < count; i++) {
      itemIcons.add(shapeIcon);
      itemColors.add(shapeColor);
    }

    // Add 1-3 distractor items with the same shape but different colors
    if (count < 5) {
      int distractors = _random.nextInt(3) + 1;
      distractors =
          min(distractors, 5 - count); // Make sure we don't add too many

      List<Color> otherColors =
          colorMap.values.where((c) => c != shapeColor).toList();

      for (int i = 0; i < distractors; i++) {
        itemIcons.add(shapeIcon);
        itemColors.add(otherColors[_random.nextInt(otherColors.length)]);
      }
    }

    // Shuffle the arrays to randomize the order
    List<int> indices = List.generate(itemIcons.length, (index) => index);
    indices.shuffle();

    List<IconData> tempIcons = [];
    List<Color> tempColors = [];

    for (int i = 0; i < indices.length; i++) {
      tempIcons.add(itemIcons[indices[i]]);
      tempColors.add(itemColors[indices[i]]);
    }

    itemIcons = tempIcons;
    itemColors = tempColors;

    currentQuestion =
        "How many $color ${count > 1 ? "${object}s" : object} can you count?";
    correctAnswer = count.toString();
  }

  // Generate people counting question
  void generatePeopleCountingQuestion() {
    List<String> people = ['child', 'friend', 'boy', 'girl', 'baby'];
    String person = people[_random.nextInt(people.length)];
    int count = _random.nextInt(5) + 1; // 1-5 people

    currentCountingObject = person;

    // Create icons to count
    IconData personIcon = peopleIcons[person] ?? Icons.person;

    // Assign random colors to people for variety
    List<Color> personColors = [
      Colors.pink.shade800,
      Colors.blue.shade800,
      Colors.green.shade800,
      Colors.purple.shade800,
      Colors.orange.shade800,
    ];

    itemIcons = List.generate(count, (_) => personIcon);
    itemColors = List.generate(
        count, (_) => personColors[_random.nextInt(personColors.length)]);

    // Handle irregular plurals
    String personPlural = person == 'child'
        ? 'children'
        : person == 'baby'
            ? 'babies'
            : "${person}s";

    currentQuestion =
        "Count the ${count > 1 ? personPlural : person}. How many are there?";
    correctAnswer = count.toString();
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

      // Check if score is a multiple of 50 (lower threshold for young children)
      if (score % 50 == 0) {
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
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Great job counting!"),
              SizedBox(height: 10),
              Text("Your score is $score",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
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

  // Build the visual counting area with icons
  Widget _buildCountingVisuals() {
    if (itemIcons.isEmpty) {
      return SizedBox(height: 100);
    }

    return Container(
      height: 180,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300, width: 2),
      ),
      child:
          itemIcons.length <= 10 ? _buildGridLayout() : _buildWrappedLayout(),
    );
  }

  // Grid layout for up to 10 items
  Widget _buildGridLayout() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: itemIcons.length <= 6 ? 3 : 4,
        childAspectRatio: 1.0,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: itemIcons.length,
      itemBuilder: (context, index) {
        return _buildIconItem(index);
      },
    );
  }

  // Wrapped layout for more items
  Widget _buildWrappedLayout() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: List.generate(
        itemIcons.length,
        (index) => _buildIconItem(index),
      ),
    );
  }

  // Individual icon item
  Widget _buildIconItem(int index) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Icon(
          itemIcons[index],
          color: itemColors[index],
          size: 30,
        ),
      ),
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
                          "Stars: $score",
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

                  SizedBox(height: 20),

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
                            color: Colors.purple,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "COUNTING",
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
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        SizedBox(height: 15),

                        // Visual counting area - THIS IS NEW!
                        _buildCountingVisuals(),

                        SizedBox(height: 15),

                        // Answer input - Simplified for young children
                        TextField(
                          controller: answerController,
                          decoration: InputDecoration(
                            hintText: "Type the number",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(width: 3),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(Icons.check_circle, size: 30),
                              onPressed: checkAnswer,
                              color: Colors.green,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: isAnswerCorrect
                                    ? Colors.green
                                    : isAnswerWrong
                                        ? Colors.red
                                        : Colors.blue,
                                width: 3,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => checkAnswer(),
                          style: TextStyle(fontSize: 22),
                        ),

                        SizedBox(height: 15),

                        // Feedback
                        AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          height: isAnswerCorrect || isAnswerWrong ? 50 : 0,
                          child: Center(
                            child: Text(
                              isAnswerCorrect
                                  ? "Great job! 🎉"
                                  : isAnswerWrong
                                      ? "Try again! It's $correctAnswer"
                                      : "",
                              style: TextStyle(
                                fontSize: 20,
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

                  // Submit button - Made more colorful and kid-friendly
                  ElevatedButton(
                    onPressed: checkAnswer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        "Check My Answer",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
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
        ],
      ),
    );
  }
}