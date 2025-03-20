import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:orbit_app/screens/number_ninjas.dart';
import 'package:orbit_app/screens/story_puzzle_level1.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardScreen extends StatefulWidget {
  final bool isLoggedIn;
  final Function(bool) updateLoginStatus;

  const DashboardScreen({super.key, required this.isLoggedIn, required this.updateLoginStatus});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? selectedAgeGroup;

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive sizing
    final Size screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 600;
    final bool isTinyScreen = screenSize.width < 350;
    
    return Scaffold(
      appBar: _buildAppBar(isSmallScreen, isTinyScreen),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset("assets/background.jpeg", fit: BoxFit.cover),

          // Main content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 12 : 20,
                vertical: isSmallScreen ? 16 : 24,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Age Group Selection
                  if (selectedAgeGroup == null) _buildAgeSelection(isSmallScreen, isTinyScreen),

                  // Game Selection for Selected Age Group
                  if (selectedAgeGroup != null) _buildGameSelection(isSmallScreen, isTinyScreen),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Custom App Bar with responsive design
  PreferredSizeWidget _buildAppBar(bool isSmallScreen, bool isTinyScreen) {
    return AppBar(
      backgroundColor: Colors.deepPurple.withOpacity(0.85), // Changed to match the starry background
      elevation: 2,
      toolbarHeight: isSmallScreen ? 50 : 56, // Made navbar smaller
      title: Row(
        children: [
          // Logo
          Image.asset(
            "assets/logo.jpeg", 
            height: isSmallScreen ? 28 : 32, // Reduced logo size
          ),
          const SizedBox(width: 8), // Reduced spacing
          // App name with custom font
          Text(
            "ORBITED",
            style: GoogleFonts.orbitron(
              textStyle: TextStyle(
                fontSize: isSmallScreen ? 14 : 16, // Reduced font size
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2, // Reduced letter spacing
              ),
            ),
          ),
        ],
      ),
      actions: isTinyScreen
          ? [
              // On tiny screens, only show the auth button
              _buildAuthTab(isSmallScreen),
            ]
          : [
              // Dashboard Tab
              _buildNavTab("Dashboard", Icons.dashboard, isActive: true, isSmallScreen: isSmallScreen),
              
              // Progress Tab
              _buildNavTab("Progress", Icons.bar_chart, isSmallScreen: isSmallScreen),
              
              // AI Tutor Tab
              _buildNavTab("AI Tutor", Icons.psychology, isSmallScreen: isSmallScreen),
              
              // Login/Register Tab
              _buildAuthTab(isSmallScreen),
            ],
    );
  }

  /// Helper method to build navigation tabs
  Widget _buildNavTab(String label, IconData icon, {bool isActive = false, required bool isSmallScreen}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2), // Reduced padding
      child: TextButton.icon(
        onPressed: () {
          // Navigation logic here
        },
        icon: Icon(
          icon,
          color: isActive ? Colors.amber : Colors.white, // Changed to amber to match space theme
          size: isSmallScreen ? 16 : 20, // Reduced icon size
        ),
        label: Text(
          label,
          style: TextStyle(
            fontSize: isSmallScreen ? 10 : 12, // Reduced font size
            color: isActive ? Colors.amber : Colors.white,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  /// Helper method to build auth tab (login/logout)
  Widget _buildAuthTab(bool isSmallScreen) {
    return Padding(
      padding: const EdgeInsets.only(right: 12, left: 2), // Reduced padding
      child: TextButton.icon(
        onPressed: () async {
          if (widget.isLoggedIn) {
            // Logout logic
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setBool("isLoggedIn", false);
            widget.updateLoginStatus(false);
            setState(() {
              selectedAgeGroup = null;
            });
          } else {
            // Navigate to login
            Navigator.pushNamed(context, '/login');
          }
        },
        icon: Icon(
          widget.isLoggedIn ? Icons.logout : Icons.login,
          color: Colors.white,
          size: isSmallScreen ? 16 : 20, // Reduced icon size
        ),
        label: Text(
          widget.isLoggedIn ? "Logout" : "Login",
          style: TextStyle(
            color: Colors.white,
            fontSize: isSmallScreen ? 10 : 12, // Reduced font size
          ),
        ),
      ),
    );
  }

  /// Age Group Selection with attractive button UI
  Widget _buildAgeSelection(bool isSmallScreen, bool isTinyScreen) {
    List<String> ageGroups = ["4-6", "6-8", "8-10", "10-12"];
    
    return Column(
      children: [
        Text(
          "Select Your Age Group:", 
          style: TextStyle(
            fontSize: isSmallScreen ? 16 : 20, // Reduced font size
            fontWeight: FontWeight.bold, 
            color: Colors.white,
            shadows: [
              Shadow(
                offset: const Offset(1, 1),
                blurRadius: 3,
                color: Colors.black.withOpacity(0.5),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: isSmallScreen ? 16 : 24), // Reduced spacing
        
        // Wrap for responsive layout of age buttons
        Wrap(
          alignment: WrapAlignment.center,
          spacing: isSmallScreen ? 12 : 16, // Reduced spacing
          runSpacing: isSmallScreen ? 12 : 16,
          children: ageGroups.map((age) => _buildAttractiveAgeButton(age, isSmallScreen, isTinyScreen)).toList(),
        ),
      ],
    );
  }

  /// Create attractive button UI for age groups
  Widget _buildAttractiveAgeButton(String age, bool isSmallScreen, bool isTinyScreen) {
    final double buttonSize = isTinyScreen ? 85 : (isSmallScreen ? 95 : 110); // Reduced button sizes
    
    return Material(
      elevation: 6, // Reduced elevation
      borderRadius: BorderRadius.circular(isSmallScreen ? 15 : 18), // Reduced radius
      shadowColor: Colors.deepPurple.withOpacity(0.6), // Changed to deep purple to match theme
      child: InkWell(
        onTap: () {
          if (!widget.isLoggedIn) {
            Navigator.pushNamed(context, '/login');
          } else {
            setState(() {
              selectedAgeGroup = age;
            });
          }
        },
        borderRadius: BorderRadius.circular(isSmallScreen ? 15 : 18),
        splashColor: Colors.deepPurple.withOpacity(0.3), // Changed to deep purple
        child: Container(
          width: buttonSize,
          height: buttonSize,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.deepPurple.shade400, Colors.indigo.shade700], // Changed to match starry theme
            ),
            borderRadius: BorderRadius.circular(isSmallScreen ? 15 : 18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                offset: const Offset(0, 3), // Reduced offset
                blurRadius: 6, // Reduced blur
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.child_care,
                  size: isSmallScreen ? 32 : 40, // Reduced icon size
                  color: Colors.white,
                ),
                const SizedBox(height: 6), // Reduced spacing
                Text(
                  "AGE\n$age",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16, // Reduced font size
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: const Offset(1, 1),
                        blurRadius: 2,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Game Selection with responsiveness
  Widget _buildGameSelection(bool isSmallScreen, bool isTinyScreen) {
    List<Map<String, dynamic>> games = [];

    if (selectedAgeGroup == "4-6" || selectedAgeGroup == "6-8") {
      games = [
        {"title": "STORY PUZZLE", "image": "assets/story_puzzle_logo.jpeg", "screen": StoryPuzzleLevel1()},
        {"title": "NUMBER NINJA", "image": "assets/number_ninja_logo.jpeg", "screen": NumberNinjas(ageGroup: selectedAgeGroup!)},
      ];
    }

    return Column(
      children: [
        Text(
          "Select a Game:", 
          style: TextStyle(
            fontSize: isSmallScreen ? 16 : 20, // Reduced font size
            fontWeight: FontWeight.bold, 
            color: Colors.white,
            shadows: [
              Shadow(
                offset: const Offset(1, 1),
                blurRadius: 3,
                color: Colors.black.withOpacity(0.5),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: isSmallScreen ? 16 : 24), // Reduced spacing
        
        // Use LayoutBuilder to determine whether to use Row or Column based on width
        LayoutBuilder(
          builder: (context, constraints) {
            return constraints.maxWidth < 360 // Adjusted breakpoint
                ? Column(
                    children: games.map((game) => _buildGameCard(game, isSmallScreen, isTinyScreen)).toList(),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: games.map((game) => _buildGameCard(game, isSmallScreen, isTinyScreen)).toList(),
                  );
          },
        ),
      ],
    );
  }

  // Helper method to build game cards with consistent styling
  Widget _buildGameCard(Map<String, dynamic> game, bool isSmallScreen, bool isTinyScreen) {
    final double imageSize = isTinyScreen ? 70 : (isSmallScreen ? 80 : 100); // Reduced image sizes
    final double cardWidth = isTinyScreen ? 140 : (isSmallScreen ? 150 : 180); // Reduced card widths
    
    return Padding(
      padding: EdgeInsets.all(isSmallScreen ? 8 : 12), // Reduced padding
      child: Material(
        elevation: 6, // Reduced elevation
        borderRadius: BorderRadius.circular(12), // Reduced radius
        shadowColor: Colors.deepPurple.withOpacity(0.6), // Changed to deep purple
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => game["screen"]),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: cardWidth,
            padding: EdgeInsets.all(isSmallScreen ? 10 : 12), // Reduced padding
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.indigo.shade300, Colors.deepPurple.shade800], // Changed to match theme
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10), // Reduced radius
                  child: Image.asset(
                    game["image"], 
                    width: imageSize, 
                    height: imageSize,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 8 : 10), // Reduced spacing
                Text(
                  game["title"],
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16, // Reduced font size
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: const Offset(1, 1),
                        blurRadius: 2,
                        color: Colors.black.withOpacity(0.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}