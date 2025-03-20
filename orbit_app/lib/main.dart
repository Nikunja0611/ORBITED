import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/dashboard_screen.dart';
import 'screens/login_screen.dart';
import 'screens/game_screen.dart';
import 'screens/story_puzzle_level1.dart';
import 'screens/story_puzzle_level2.dart';
import 'screens/splash_screen.dart'; // Import the splash screen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoggedIn = prefs.getBool("isLoggedIn") ?? false;
    });
  }

  void _updateLoginStatus(bool status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isLoggedIn", status);
    setState(() {
      isLoggedIn = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kids Learning App',
      theme: ThemeData(primarySwatch: Colors.orange),
      
      // Changed initialRoute to use splash screen
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => SplashScreen(isLoggedIn: isLoggedIn, updateLoginStatus: _updateLoginStatus),
        '/': (context) => DashboardScreen(isLoggedIn: isLoggedIn, updateLoginStatus: _updateLoginStatus),
        '/dashboard': (context) => DashboardScreen(isLoggedIn: isLoggedIn, updateLoginStatus: _updateLoginStatus),
        '/login': (context) => LoginScreen(updateLoginStatus: _updateLoginStatus),
        '/games': (context) => const GamesScreen(),
        '/storyPuzzle1': (context) => StoryPuzzleLevel1(),
        '/storyPuzzle2': (context) => StoryPuzzleLevel2(),
      },
    );
  }
}