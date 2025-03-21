import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/dashboard_screen.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyCuQ4AsN7NUdMdluhLfuHzYPlK7qCqcuTA",
      appId: "1:177992848215:android:1b0cf16029cf097faee412",
      messagingSenderId: "177992848215",
      projectId: "orbit-app-85564",
      // Add other platform-specific values as needed
    ),
  );
  runApp(MyApp());
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
      initialRoute: '/splash',
      routes: {
        '/splash': (context) =>
            SplashScreen(isLoggedIn: isLoggedIn, updateLoginStatus: _updateLoginStatus),
        '/dashboard': (context) =>
            DashboardScreen(isLoggedIn: isLoggedIn, updateLoginStatus: _updateLoginStatus),
        '/login': (context) => LoginScreen(updateLoginStatus: _updateLoginStatus),
      },
    );
  }
}
