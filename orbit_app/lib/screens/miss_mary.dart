import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:lottie/lottie.dart';
import 'dart:async';

class MissMary extends StatefulWidget {
  const MissMary({Key? key}) : super(key: key);

  @override
  State<MissMary> createState() => _MissMaryState();
}

class _MissMaryState extends State<MissMary> with TickerProviderStateMixin {
  // Text-to-speech
  final FlutterTts flutterTts = FlutterTts();

  // Speech-to-text
  final stt.SpeechToText speech = stt.SpeechToText();

  // Animation controller for Lottie animation
  late AnimationController _lottieController;

  // State variables
  String text = "Hello! I'm Mr. Xavier. How can I help you today?";
  bool isListening = false;
  bool isSpeaking = false;
  bool showBlackboard = false;
  String blackboardText = "";
  bool inQuizMode = false;
  String currentQuizTopic = "";
  List<Map<String, String>> quizQuestions = [];
  int currentQuestionIndex = 0;
  String userInput = "";
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Initialize Lottie animation controller
    _lottieController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    // Initialize TTS
    _initTts();

    // Initialize STT
    _initSpeech();

    // Initial greeting
    Future.delayed(const Duration(seconds: 1), () {
      speak("Hello! I'm Mr. Xavier. How can I help you today?");
    });
  }

  @override
  void dispose() {
    flutterTts.stop();
    _lottieController.dispose();
    _textController.dispose();
    super.dispose();
  }

  // Initialize text-to-speech
  Future<void> _initTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.2); // Slightly higher pitch for female voice
    await flutterTts.setSpeechRate(0.5); // Normal speaking rate
    await flutterTts.setVolume(1.0); // Full volume

    flutterTts.setCompletionHandler(() {
      setState(() {
        isSpeaking = false;
        _lottieController.stop();
      });
    });
  }

  // Initialize speech-to-text
  Future<void> _initSpeech() async {
    await speech.initialize(
      onStatus: (status) {
        if (status == 'done') {
          setState(() {
            isListening = false;
          });
        }
      },
      onError: (error) {
        setState(() {
          isListening = false;
        });
      },
    );
  }

  // Function to speak text
  Future<void> speak(String message) async {
    setState(() {
      text = message;
      isSpeaking = true;
    });

    // Start the Lottie animation when speaking starts
    _lottieController.reset();
    _lottieController.repeat();

    await flutterTts.speak(message);

    // Fallback in case completion handler doesn't fire
    Future.delayed(Duration(milliseconds: message.length * 80), () {
      setState(() {
        isSpeaking = false;
        _lottieController.stop();
      });
    });
  }

  // Toggle listening state
  void toggleListening() async {
    if (!isListening) {
      bool available = await speech.initialize();
      if (available) {
        setState(() {
          isListening = true;
        });

        speech.listen(
          onResult: (result) {
            if (result.finalResult) {
              setState(() {
                isListening = false;
                userInput = result.recognizedWords;
                _textController.text = userInput;
              });
              processInput(userInput.toLowerCase());
            }
          },
        );
      } else {
        // Fallback for when speech recognition isn't available
        setState(() {
          isListening = true;
        });

        // Simulate listening for demo
        Future.delayed(const Duration(seconds: 2), () {
          setState(() {
            isListening = false;
          });
          processInput(_textController.text.toLowerCase());
        });
      }
    } else {
      setState(() {
        isListening = false;
        speech.stop();
      });
    }
  }

  // Process user input (speech or text)
  void processInput(String input) {
    // If in quiz mode, process answers
    if (inQuizMode) {
      processQuizResponse(input);
      return;
    }

    // Regular conversation mode
    if (input.contains("exam tomorrow") ||
        input.contains("have exam") ||
        input.contains("test tomorrow")) {
      speak(
          "I can help you prepare for your exam. What subject would you like to practice?");
    } else if (input.contains("math") || input.contains("maths")) {
      speak(
          "Let's practice some math problems. Tell me if you want to focus on addition, subtraction, multiplication, or division.");
      setState(() {
        currentQuizTopic = "math";
      });
    } else if (input.contains("science")) {
      speak(
          "I'd be happy to help you with science. Would you like to focus on biology, chemistry, or physics?");
      setState(() {
        currentQuizTopic = "science";
      });
    } else if (input.contains("addition")) {
      startQuiz("math_addition");
    } else if (input.contains("subtraction")) {
      startQuiz("math_subtraction");
    } else if (input.contains("multiplication")) {
      startQuiz("math_multiplication");
    } else if (input.contains("division")) {
      startQuiz("math_division");
    } else if (input.contains("biology")) {
      startQuiz("science_biology");
    } else if (input.contains("chemistry")) {
      startQuiz("science_chemistry");
    } else if (input.contains("physics")) {
      startQuiz("science_physics");
    } else if (input.contains("grammar")) {
      speak(
          "Let's learn about grammar. I can help with nouns, verbs, adjectives, and more. What would you like to focus on?");
      setState(() {
        currentQuizTopic = "grammar";
      });
    } else if (input.contains("noun")) {
      speak(
          "Nouns are words that name a person, place, thing, or idea. For example: teacher, school, book, and knowledge.");
      setState(() {
        blackboardText =
            "Nouns: person, place, thing, or idea\n\nExamples:\n- Person: teacher, student\n- Place: school, home\n- Thing: book, pen\n- Idea: knowledge, friendship";
        showBlackboard = true;
      });
    } else if (input.contains("verb")) {
      speak(
          "Verbs are action words that tell what someone or something does. For example: run, write, teach, and learn.");
      setState(() {
        blackboardText =
            "Verbs: action words\n\nExamples:\n- run, jump, walk\n- write, read, speak\n- teach, learn, study";
        showBlackboard = true;
      });
    } else if (input.contains("adjective")) {
      speak(
          "Adjectives are words that describe or modify nouns. They tell us more about the qualities of people, places, or things.");
      setState(() {
        blackboardText =
            "Adjectives: describe nouns\n\nExamples:\n- happy student\n- tall building\n- red apple\n- beautiful painting";
        showBlackboard = true;
      });
    } else if (input.contains("doubt") ||
        input.contains("question") ||
        input.contains("confused")) {
      speak(
          "What's your question? I'm here to help you understand. Don't worry, there are no silly questions in my classroom.");
      setState(() {
        showBlackboard = false;
      });
    } else if (input.contains("thank you") || input.contains("thanks")) {
      speak(
          "You're very welcome! I'm always happy to help my students. Is there anything else you'd like to learn today?");
      setState(() {
        showBlackboard = false;
      });
    } else if (input.contains("bye") || input.contains("goodbye")) {
      speak(
          "Goodbye! Remember to practice what we've learned. I'll be here when you need help again. Have a wonderful day!");
      setState(() {
        showBlackboard = false;
      });
    } else {
      speak(
          "I'm here to help you with your studies. You can ask me about different subjects, tell me if you have an exam, or ask for help with specific topics.");
      setState(() {
        showBlackboard = false;
      });
    }
  }

  // Start a quiz on a specific topic
  void startQuiz(String topic) {
    setState(() {
      inQuizMode = true;
      currentQuizTopic = topic;
      currentQuestionIndex = 0;
    });

    // Generate questions based on topic
    generateQuestions(topic);
  }

  // Generate quiz questions based on topic
  void generateQuestions(String topic) {
    List<Map<String, String>> questions = [];

    if (topic == "math_addition") {
      speak("Let's practice addition problems. I'll ask you 5 questions.");
      questions = [
        {"question": "What is 5 + 3?", "answer": "8"},
        {"question": "What is 12 + 7?", "answer": "19"},
        {"question": "What is 24 + 16?", "answer": "40"},
        {"question": "What is 35 + 27?", "answer": "62"},
        {"question": "What is 123 + 45?", "answer": "168"},
      ];
    } else if (topic == "math_subtraction") {
      speak("Let's practice subtraction problems. I'll ask you 5 questions.");
      questions = [
        {"question": "What is 10 - 4?", "answer": "6"},
        {"question": "What is 25 - 12?", "answer": "13"},
        {"question": "What is 50 - 23?", "answer": "27"},
        {"question": "What is 100 - 37?", "answer": "63"},
        {"question": "What is 200 - 75?", "answer": "125"},
      ];
    } else if (topic == "math_multiplication") {
      speak(
          "Let's practice multiplication problems. I'll ask you 5 questions.");
      questions = [
        {"question": "What is 4 × 3?", "answer": "12"},
        {"question": "What is 6 × 7?", "answer": "42"},
        {"question": "What is 9 × 8?", "answer": "72"},
        {"question": "What is 12 × 5?", "answer": "60"},
        {"question": "What is 11 × 11?", "answer": "121"},
      ];
    } else if (topic == "science_biology") {
      speak("Let's practice some biology questions. I'll ask you 5 questions.");
      questions = [
        {"question": "What is the basic unit of life?", "answer": "cell"},
        {
          "question": "What process do plants use to make their food?",
          "answer": "photosynthesis"
        },
        {"question": "What organ pumps blood in our body?", "answer": "heart"},
        {
          "question": "What is the largest organ in the human body?",
          "answer": "skin"
        },
        {
          "question": "What do we call animals that eat both plants and meat?",
          "answer": "omnivores"
        },
      ];
    }

    setState(() {
      quizQuestions = questions;
    });

    // Ask first question after a small delay
    Future.delayed(const Duration(seconds: 3), () {
      askCurrentQuestion();
    });
  }

  // Ask the current question
  void askCurrentQuestion() {
    if (currentQuestionIndex < quizQuestions.length) {
      final question = quizQuestions[currentQuestionIndex]["question"]!;
      speak("Question ${currentQuestionIndex + 1}: $question");
      setState(() {
        blackboardText = "Question ${currentQuestionIndex + 1}: $question";
        showBlackboard = true;
      });
    } else {
      speak(
          "Great job! You've completed all the questions. Would you like to try another subject?");
      setState(() {
        inQuizMode = false;
        showBlackboard = false;
      });
    }
  }

  // Process user's answer during quiz
  void processQuizResponse(String input) {
    if (currentQuestionIndex < quizQuestions.length) {
      final correctAnswer = quizQuestions[currentQuestionIndex]["answer"]!;

      // Clean up user input and correct answer for comparison
      final cleanInput = input.trim().toLowerCase();
      final cleanAnswer = correctAnswer.toLowerCase();

      if (cleanInput.contains(cleanAnswer)) {
        speak("Correct! Well done.");
        setState(() {
          currentQuestionIndex++;
        });

        // Short delay before next question
        Future.delayed(const Duration(seconds: 2), () {
          askCurrentQuestion();
        });
      } else {
        speak(
            "That's not quite right. Let's try again. ${quizQuestions[currentQuestionIndex]["question"]}");
      }
    }
  }

  // Handle form submission
  void handleSubmit() {
    processInput(_textController.text.toLowerCase());
    _textController.clear();
  }

  // Build subject button
  Widget buildSubjectButton(String subject, IconData icon) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 16),
      label: Text(subject,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      onPressed: () => processInput(subject.toLowerCase()),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.purple[800],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 3,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue[900]!,
              Colors.blue[800]!,
              Colors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Header
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: Colors.purple[700],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Mr. Xavier - AI Tutor',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.info, color: Colors.white),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ),

              // Background icons
              Positioned(
                top: 70,
                right: 40,
                child: Opacity(
                  opacity: 0.2,
                  child: Icon(Icons.book, size: 40, color: Colors.white),
                ),
              ),
              Positioned(
                bottom: 160,
                left: 40,
                child: Opacity(
                  opacity: 0.2,
                  child: Icon(Icons.book, size: 40, color: Colors.white),
                ),
              ),
              Positioned(
                top: 160,
                left: 40,
                child: Opacity(
                  opacity: 0.2,
                  child: Icon(Icons.edit, size: 40, color: Colors.white),
                ),
              ),

              // Blackboard (conditional)
              if (showBlackboard)
                Positioned(
                  top: 80,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.green[900],
                      border: Border.all(
                        color: const Color(0xFFB27300), // amber-800
                        width: 4,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.4,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Blackboard text with line breaks
                          Text(
                            blackboardText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'monospace',
                              fontSize: 16,
                              height: 1.5,
                              shadows: [
                                Shadow(
                                  color: Colors.black45,
                                  offset: Offset(1, 1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                          ),

                          // Quiz mode indicator
                          if (inQuizMode)
                            Container(
                              margin: const EdgeInsets.only(top: 16),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.yellow[600]!.withOpacity(0.3),
                                border: Border.all(
                                  color: Colors.yellow[500]!,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Type your answer below',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFFFEF9C3), // yellow-200
                                  fontWeight: FontWeight.w600,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Miss Mary Avatar with Lottie Animation
              Positioned.fill(
                child: Center(
                  child: Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.purple[400]!.withOpacity(0.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 15,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Stack(
                        children: [
                          // Lottie animation
                          Lottie.asset(
                            'assets/miss_mary_talking.json',
                            controller: _lottieController,
                            fit: BoxFit.cover,
                            width: 240,
                            height: 240,
                          ),

                          // Speaking indicator
                          if (isSpeaking)
                            Positioned(
                              top: -20,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.purple[600],
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: const Text(
                                    'Speaking...',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Text bubble
              Positioned(
                bottom: 120,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.purple[300]!,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.purple[900],
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              // Subject buttons
              Positioned(
                bottom: 80,
                left: 0,
                right: 0,
                child: Container(
                  height: 45,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      buildSubjectButton("Math", Icons.calculate),
                      const SizedBox(width: 8),
                      buildSubjectButton("Science", Icons.science),
                      const SizedBox(width: 8),
                      buildSubjectButton("Grammar", Icons.menu_book),
                      const SizedBox(width: 8),
                      buildSubjectButton("Quiz", Icons.quiz),
                    ],
                  ),
                ),
              ),

              // Input area
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(30),
                                bottomLeft: Radius.circular(30),
                              ),
                              border: Border.all(
                                color: Colors.purple[400]!,
                                width: 2,
                              ),
                            ),
                            child: TextField(
                              controller: _textController,
                              decoration: const InputDecoration(
                                hintText: 'Type your message or question...',
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                border: InputBorder.none,
                              ),
                              onSubmitted: (_) => handleSubmit(),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: toggleListening,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color:
                                  isListening ? Colors.red : Colors.purple[600],
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(30),
                                bottomRight: Radius.circular(30),
                              ),
                            ),
                            child: Icon(
                              isListening ? Icons.mic : Icons.mic_off,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Listening indicator
                    if (isListening)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red[100],
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Text(
                          'Listening...',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
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
    );
  }
}