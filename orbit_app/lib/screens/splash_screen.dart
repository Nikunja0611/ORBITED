import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  final bool isLoggedIn;
  final Function(bool) updateLoginStatus;
  
  const SplashScreen({
    super.key, 
    required this.isLoggedIn, 
    required this.updateLoginStatus
  });

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    // Initialize video player
    _controller = VideoPlayerController.asset('assets/Intro_video.mp4')
    ..initialize().then((_) {
    if (mounted) {
      setState(() {
        _isVideoInitialized = true;
        _controller.play();
      });

      // Ensure the video is looping or handled properly
      _controller.setLooping(false);
      _controller.addListener(() {
      if (_controller.value.position >= _controller.value.duration) {
          _navigateToDashboard();
        }
      });

      // Fallback timer in case video doesn't play
      Timer(const Duration(seconds: 10), () {
        if (mounted) {
          _navigateToDashboard();
        }
      });
    }
  }).catchError((error) {
    debugPrint("Error initializing video: $error");
    _navigateToDashboard();

        
        // Navigate to dashboard after video ends
        _controller.addListener(() {
          if (_controller.value.position >= _controller.value.duration) {
            _navigateToDashboard();
          }
        });
        
        // Fallback timer in case video doesn't play correctly
        Timer(const Duration(seconds: 10), () {
          if (mounted) {
            _navigateToDashboard();
          }
        });
      });
  }
  
  void _navigateToDashboard() {
    if (mounted) {
      Navigator.pushReplacementNamed(
        context, 
        '/dashboard', 
        arguments: {
          'isLoggedIn': widget.isLoggedIn, 
          'updateLoginStatus': widget.updateLoginStatus
        }
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: _isVideoInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/logo.jpeg", height: 120),
                  const SizedBox(height: 20),
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "ORBITED",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}