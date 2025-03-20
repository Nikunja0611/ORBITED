import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:async';
import 'dart:math';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

class ARWordHuntGame extends StatefulWidget {
  @override
  _ARWordHuntGameState createState() => _ARWordHuntGameState();
}

class _ARWordHuntGameState extends State<ARWordHuntGame>
    with TickerProviderStateMixin {
  late CameraController _cameraController;
  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  late FlutterTts flutterTts;
  
  // Animation controllers
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;
  late AnimationController _scanAnimController;
  late Animation<double> _scanAnimation;
  
  // Game state tracking
  int _score = 0;
  int _level = 1;
  bool _isGameActive = false;
  String _lastDetectedObject = "";
  
  // Configure the image labeler with custom settings
  final ImageLabeler _imageLabeler = ImageLabeler(
    options: ImageLabelerOptions(confidenceThreshold: 0.7),
  );

  // Enhanced clues with more details and matching criteria
  final List<Map<String, dynamic>> clues = [
    {
      "description": "Find something round that starts with A",
      "letter": "A",
      "examples": "apple, alarm clock, avocado",
      "points": 10,
      "keywords": ["apple", "alarm", "avocado", "apricot", "anklet", "amethyst"],
    },
    {
      "description": "Find something soft that starts with B", 
      "letter": "B",
      "examples": "blanket, bed, bear, balloon",
      "points": 10,
      "keywords": ["blanket", "bed", "bear", "balloon", "bread", "button"],
    },
    {
      "description": "Find something electronic that starts with C",
      "letter": "C",
      "examples": "computer, camera, calculator",
      "points": 15,
      "keywords": ["computer", "camera", "calculator", "charger", "clock", "cable"],
    },
    {
      "description": "Find something you can drink from that starts with D",
      "letter": "D",
      "examples": "drink bottle, dish, decanter",
      "points": 15,
      "keywords": ["drink", "dish", "decanter", "demitasse", "dome", "drum"],
    },
    {
      "description": "Find something with a handle that starts with E",
      "letter": "E",
      "examples": "eraser, envelope, earphones",
      "points": 20,
      "keywords": ["eraser", "envelope", "earphones", "extension cord", "earrings"],
    },
    {
      "description": "Find something that can hold things that starts with F",
      "letter": "F",
      "examples": "folder, frame, fridge, fork",
      "points": 10,
      "keywords": ["folder", "frame", "fridge", "fork", "fan", "fruit"],
    },
    {
      "description": "Find something green that starts with G",
      "letter": "G",
      "examples": "grass, grapes, globe",
      "points": 15,
      "keywords": ["grass", "grapes", "globe", "glove", "glasses", "game"],
    },
    {
      "description": "Find something you wear that starts with H",
      "letter": "H",
      "examples": "hat, hoodie, headphones",
      "points": 15,
      "keywords": ["hat", "hoodie", "headphones", "handbag", "helmet"],
    },
    {
      "description": "Find something shiny that starts with M",
      "letter": "M",
      "examples": "mirror, metal, mug",
      "points": 10,
      "keywords": ["mirror", "metal", "mug", "mobile", "mouse", "medal"],
    },
  ];
  
  Map<String, dynamic> currentClueData = {};
  List<String> detectedObjects = [];
  Timer? _scanTimer;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _initializeCamera();
    _initializeAnimations();
    flutterTts = FlutterTts();
    _setupFlutterTts();
  }

  void _initializeAnimations() {
    // Main fade animation for intro screen
    _fadeController = AnimationController(
      vsync: this, 
      duration: const Duration(seconds: 2)
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController, 
      curve: Curves.easeIn
    );
    _fadeController.forward();
    
    // Bounce animation for UI elements
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _bounceAnimation = CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    );
    
    // Scanning animation
    _scanAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanAnimController, curve: Curves.easeInOut)
    );
  }

  void _setupFlutterTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
  }

  void _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.microphone,
    ].request();
    
    if (statuses[Permission.camera] != PermissionStatus.granted) {
      // Handle permission denied
      _showPermissionDeniedDialog();
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text("Camera Permission Required"),
          content: const Text(
            "This game needs camera access to scan objects. Please grant permission in settings."
          ),
          actions: [
            TextButton(
              onPressed: () {
                openAppSettings();
              },
              child: const Text("Open Settings"),
            ),
          ],
        );
      },
    );
  }

  void _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      // Handle no camera available
      return;
    }
    
    _cameraController = CameraController(
      cameras.first, 
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );
    
    try {
      await _cameraController.initialize();
      // Set auto focus mode
      await _cameraController.setFocusMode(FocusMode.auto);
      // Set auto exposure
      await _cameraController.setExposureMode(ExposureMode.auto);
      // Set flash mode to auto
      await _cameraController.setFlashMode(FlashMode.auto);
      
      setState(() => _isCameraInitialized = true);
    } catch (e) {
      print("Error initializing camera: $e");
    }
  }

  void _generateNewClue() {
    // Shuffle clues and select one
    final random = Random();
    final randomClue = clues[random.nextInt(clues.length)];
    
    setState(() {
      currentClueData = randomClue;
      _isGameActive = true;
      detectedObjects = [];  // Reset detected objects
    });
    
    // Speak the clue
    _speak("New challenge: ${randomClue["description"]}. Look for ${randomClue["examples"]}");
    
    // Start periodic scanning
    _startPeriodicScanning();
  }

  void _startPeriodicScanning() {
    // Cancel any existing timer
    _scanTimer?.cancel();
    
    // Set up periodic scanning every 2 seconds
    _scanTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      if (_isGameActive && !_isProcessing) {
        _captureAndDetect();
      }
    });
  }

  Future<void> _speak(String text) async {
    await flutterTts.speak(text);
  }

  Future<void> _captureAndDetect() async {
    if (!_isCameraInitialized || _isProcessing) return;
    
    setState(() => _isProcessing = true);
    
    try {
      // Start scan animation
      _scanAnimController.reset();
      _scanAnimController.forward();
      
      // Capture image
      final XFile image = await _cameraController.takePicture();
      final inputImage = InputImage.fromFilePath(image.path);
      
      // Process image with ML Kit
      final List<ImageLabel> labels = await _imageLabeler.processImage(inputImage);
      
      // Check results
      if (labels.isNotEmpty) {
        // Get all detected objects above a certain confidence threshold
        detectedObjects = labels
            .where((label) => label.confidence > 0.7)
            .map((label) => label.label.toLowerCase())
            .toList();
        
        // Check if any detected object matches the clue
        _checkScannedObjects(detectedObjects);
      }
    } catch (e) {
      print("Error in image detection: $e");
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _checkScannedObjects(List<String> objects) {
    if (objects.isEmpty) return;
    
    // Display the highest confidence object
    setState(() => _lastDetectedObject = objects.first);
    
    // Update UI to show what was detected
    String clueLetter = currentClueData["letter"];
    bool foundMatch = false;
    
    // Check if any detected object starts with the clue letter
    for (String object in objects) {
      // Check if object starts with the clue letter (case insensitive)
      if (object.toLowerCase().startsWith(clueLetter.toLowerCase())) {
        // Extra check for keywords to improve accuracy
        List<String> keywords = currentClueData["keywords"];
        bool isKeyword = keywords.any(
          (word) => object.toLowerCase().contains(word.toLowerCase())
        );
        
        if (isKeyword) {
          // We found a strong match
          foundMatch = true;
          _showSuccessAnimation(object);
          break;
        } else if (foundMatch == false) {
          // We found a partial match (starts with the letter)
          foundMatch = true;
          _showSuccessAnimation(object);
          break;
        }
      }
    }
    
    if (!foundMatch) {
      // Provide feedback on what was detected but not matched
      if (objects.isNotEmpty) {
        // Only show feedback if we're not constantly scanning
        if (_lastDetectedObject != objects.first) {
          _speak("I see a ${objects.first}, but I need something that starts with ${clueLetter}");
        }
      }
    }
  }

  void _showSuccessAnimation(String object) {
    // Increase score and potentially level
    setState(() {
      _score += (currentClueData["points"] as num).toInt();
      if (_score > _level * 50) {
        _level++;
      }
    });
    
    // Play success sound and speak
    _speak("Well done! You found a $object!");
    
    // Show success dialog with animations
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.purple[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "✨ Phantom is Impressed! ✨",
            style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated star
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 800),
                builder: (context, double value, child) {
                  return Transform.scale(
                    scale: value,
                    child: const Icon(
                      Icons.stars,
                      color: Colors.yellow,
                      size: 80,
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              Text(
                "You found a $object!",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                "+${currentClueData["points"]} points",
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 10,
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _generateNewClue();
                },
                child: const Text(
                  "Next Challenge 👻",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _scanTimer?.cancel();
    _cameraController.dispose();
    _imageLabeler.close();
    _fadeController.dispose();
    _bounceController.dispose();
    _scanAnimController.dispose();
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.deepPurple,
        colorScheme: ColorScheme.dark(
          primary: Colors.deepPurple,
          secondary: Colors.purple[300]!,
        ),
      ),
      home: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Background image with gradient overlay
            Image.asset(
              "assets/arbg1.png", // Your haunted/spooky background
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.deepPurple.withOpacity(0.5),
                  ],
                ),
              ),
            ),
            
            // Main content conditional on game state
            _isGameActive ? _buildGameScreen() : _buildIntroScreen(),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroScreen() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated title
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(seconds: 1),
              builder: (context, double value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: const Text(
                "👻 Phantom Spellers 👻",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.purpleAccent,
                      offset: Offset(2.0, 2.0),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 30),
            
            // Game description
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.purpleAccent,
                  width: 2,
                ),
              ),
              child: const Text(
                "Hunt for objects that begin with specific letters. The phantom will guide you through the challenges!",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 40),
            
            // Animated play button
            AnimatedBuilder(
              animation: _bounceAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (_bounceAnimation.value * 0.1),
                  child: child,
                );
              },
              child: ElevatedButton(
                onPressed: () {
                  _speak("Welcome to Phantom Spellers! Let's hunt for magical objects!");
                  _generateNewClue();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "🎮 Start Hunting",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            
            // Instructions note
            Text(
              "Make sure your camera has permission to identify objects!",
              style: TextStyle(
                color: Colors.yellow[200],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameScreen() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Camera preview 
        _isCameraInitialized
            ? ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  margin: const EdgeInsets.all(15),
                  child: CameraPreview(_cameraController),
                ),
              )
            : const Center(
                child: CircularProgressIndicator(
                  color: Colors.purpleAccent,
                ),
              ),
              
        // Scanning overlay animation
        if (_isProcessing)
          AnimatedBuilder(
            animation: _scanAnimation,
            builder: (context, child) {
              return Container(
                margin: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.purpleAccent.withOpacity(_scanAnimation.value),
                    width: 5,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
              );
            },
          ),
        
        // Game UI overlay
        Column(
          children: [
            // Game header with score and level
            Container(
              margin: const EdgeInsets.only(top: 40, left: 20, right: 20),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.purpleAccent),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Level indicator
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        "Level $_level",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                    ],
                  ),
                  
                  // Score indicator
                  Row(
                    children: [
                      const Icon(
                        Icons.catching_pokemon,
                        color: Colors.greenAccent,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        "Score: $_score",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.greenAccent,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Current challenge display
            Container(
              margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.8),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    "👻 Current Challenge 👻",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    currentClueData["description"] ?? "Loading...",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.yellow,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Examples: ${currentClueData["examples"] ?? ""}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const Spacer(),
            
            // Last detected object display
            if (_lastDetectedObject.isNotEmpty)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "I see: $_lastDetectedObject",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
            // Manual scan button
            Container(
              margin: const EdgeInsets.only(bottom: 30, top: 20),
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _captureAndDetect,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  disabledBackgroundColor: Colors.grey,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _isProcessing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.camera_alt),
                    const SizedBox(width: 10),
                    const Text(
                      "Scan Now",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}