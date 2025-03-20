import 'package:flutter/material.dart';
import 'package:orbit_app/screens/ar.dart';
import 'package:orbit_app/screens/mathfrenzy_10-12.dart';
import 'package:orbit_app/screens/mathfrenzy_6-8.dart';
import 'package:orbit_app/screens/mathfrenzy_8-10.dart';
import 'package:orbit_app/screens/mathfrenzy_4-6.dart';
import 'package:orbit_app/screens/number_ninjas_4-6.dart';
import 'package:orbit_app/screens/number_ninjas_6-8.dart';
import 'package:orbit_app/screens/number_ninjas_8-10.dart';
import 'package:orbit_app/screens/story_6-8_1.dart';
import 'package:orbit_app/screens/story_8-10.dart';
import 'package:orbit_app/screens/word_wizard_4-6.dart';
import 'package:orbit_app/screens/word_wizard_6-8.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:orbit_app/screens/number_ninjas_4-6.dart';
import 'package:orbit_app/screens/number_ninjas_6-8.dart';
import 'package:orbit_app/screens/number_ninjas_8-10.dart';
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
    final Size screenSize = MediaQuery.of(context).size;
    final bool isLargeScreen = screenSize.width > 900;
    final bool isMediumScreen = screenSize.width > 600 && screenSize.width <= 900;
    final bool isSmallScreen = screenSize.width <= 600;
    final bool isTinyScreen = screenSize.width < 350;
    final bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    
    return Scaffold(
      appBar: _buildAppBar(isSmallScreen, isTinyScreen),
      drawer: isSmallScreen ? _buildDrawer() : null,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            "assets/background.jpeg", 
            fit: isLandscape ? BoxFit.fitWidth : BoxFit.cover
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isLargeScreen ? 32 : (isMediumScreen ? 24 : 16),
                  vertical: isLargeScreen ? 32 : (isMediumScreen ? 24 : 16),
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: screenSize.height - (isSmallScreen ? 100 : 120),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Age Group Selection
                      if (selectedAgeGroup == null) 
                        _buildSimpleAgeSelection(isLargeScreen, isMediumScreen, isSmallScreen, isTinyScreen, isLandscape),

                      // Game Selection for Selected Age Group
                      if (selectedAgeGroup != null) 
                        _buildSimpleGameSelection(isLargeScreen, isMediumScreen, isSmallScreen, isTinyScreen, isLandscape),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: isSmallScreen && isLandscape ? _buildBottomNav() : null,
    );
  }

  /// Custom App Bar
  PreferredSizeWidget _buildAppBar(bool isSmallScreen, bool isTinyScreen) {
    return AppBar(
      backgroundColor: Colors.deepPurple.withOpacity(0.85),
      elevation: 2,
      toolbarHeight: isSmallScreen ? 50 : 56,
      title: Row(
        children: [
          Image.asset(
            "assets/logo.jpeg", 
            height: isSmallScreen ? 28 : 32,
          ),
          const SizedBox(width: 8),
          Text(
            "ORBITED",
            style: GoogleFonts.orbitron(
              textStyle: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
      leading: isSmallScreen ? null : const SizedBox(),
      actions: isSmallScreen
          ? [_buildAuthTab(isSmallScreen)]
          : [
              _buildNavTab("Dashboard", Icons.dashboard, isActive: true, isSmallScreen: isSmallScreen),
              _buildNavTab("Progress", Icons.bar_chart, isSmallScreen: isSmallScreen),
              _buildNavTab("AI Tutor", Icons.psychology, isSmallScreen: isSmallScreen),
              _buildAuthTab(isSmallScreen),
            ],
    );
  }

  /// Drawer for small screens
  Widget _buildDrawer() {
    // Drawer implementation unchanged
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.deepPurple.shade300, Colors.indigo.shade900],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade700,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/logo.jpeg",
                      height: 60,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "ORBITED",
                      style: GoogleFonts.orbitron(
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _buildDrawerItem("Dashboard", Icons.dashboard, isActive: true),
              _buildDrawerItem("Progress", Icons.bar_chart),
              _buildDrawerItem("AI Tutor", Icons.psychology),
              const Divider(color: Colors.white30),
              _buildDrawerItem(
                widget.isLoggedIn ? "Logout" : "Login", 
                widget.isLoggedIn ? Icons.logout : Icons.login,
                onTap: () async {
                  if (widget.isLoggedIn) {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    await prefs.setBool("isLoggedIn", false);
                    widget.updateLoginStatus(false);
                    setState(() {
                      selectedAgeGroup = null;
                    });
                  } else {
                    Navigator.pushNamed(context, '/login');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper method to build drawer items
  Widget _buildDrawerItem(String title, IconData icon, {bool isActive = false, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(
        icon,
        color: isActive ? Colors.amber : Colors.white,
        size: 24,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isActive ? Colors.amber : Colors.white,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: onTap ?? () {
        Navigator.pop(context);
      },
      selectedTileColor: Colors.white.withOpacity(0.1),
      selected: isActive,
    );
  }

  /// Bottom navigation 
  Widget _buildBottomNav() {
    return BottomNavigationBar(
      backgroundColor: Colors.deepPurple.withOpacity(0.85),
      selectedItemColor: Colors.amber,
      unselectedItemColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: "Dashboard",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart),
          label: "Progress",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.psychology),
          label: "AI Tutor",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle),
          label: "Account",
        ),
      ],
      currentIndex: 0,
      onTap: (index) {
        // Navigation logic would go here
      },
    );
  }

  /// Helper method to build navigation tabs
  Widget _buildNavTab(String label, IconData icon, {bool isActive = false, required bool isSmallScreen}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: TextButton.icon(
        onPressed: () {
          // Navigation logic here
        },
        icon: Icon(
          icon,
          color: isActive ? Colors.amber : Colors.white,
          size: isSmallScreen ? 16 : 20,
        ),
        label: Text(
          label,
          style: TextStyle(
            fontSize: isSmallScreen ? 10 : 12,
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
      padding: const EdgeInsets.only(right: 12, left: 2),
      child: TextButton.icon(
        onPressed: () async {
          if (widget.isLoggedIn) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setBool("isLoggedIn", false);
            widget.updateLoginStatus(false);
            setState(() {
              selectedAgeGroup = null;
            });
          } else {
            Navigator.pushNamed(context, '/login');
          }
        },
        icon: Icon(
          widget.isLoggedIn ? Icons.logout : Icons.login,
          color: Colors.white,
          size: isSmallScreen ? 16 : 20,
        ),
        label: Text(
          widget.isLoggedIn ? "Logout" : "Login",
          style: TextStyle(
            color: Colors.white,
            fontSize: isSmallScreen ? 10 : 12,
          ),
        ),
      ),
    );
  }

  /// Simplified Age Group Selection with just images as buttons
  Widget _buildSimpleAgeSelection(bool isLargeScreen, bool isMediumScreen, bool isSmallScreen, bool isTinyScreen, bool isLandscape) {
    List<String> ageGroups = ["4-6", "6-8", "8-10", "10-12"];
    
    int gridCrossAxisCount = isLargeScreen 
        ? 4 
        : (isMediumScreen 
            ? 4 
            : (isLandscape ? 4 : 2));
    
    double headerFontSize = isLargeScreen ? 24 : (isMediumScreen ? 20 : (isSmallScreen ? 16 : 14));
    
    return Column(
      children: [
        Text(
          "Select Your Age Group:", 
          style: TextStyle(
            fontSize: headerFontSize,
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
        SizedBox(height: isSmallScreen ? 16 : 24),
        
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: gridCrossAxisCount,
            childAspectRatio: 1.0,
            crossAxisSpacing: isSmallScreen ? 12 : 16,
            mainAxisSpacing: isSmallScreen ? 12 : 16,
          ),
          itemCount: ageGroups.length,
          itemBuilder: (context, index) {
            // Simple image button for age selection
            return GestureDetector(
              onTap: () {
                if (!widget.isLoggedIn) {
                  Navigator.pushNamed(context, '/login');
                } else {
                  setState(() {
                    selectedAgeGroup = ageGroups[index];
                  });
                }
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(isSmallScreen ? 15 : 18),
                child: Stack(
                  children: [
                    // Use a placeholder image (replace with actual age group images)
                    Image.asset(
                      "assets/age_${ageGroups[index]}.jpeg", // Replace with actual images
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback for missing images
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Colors.deepPurple.shade400, Colors.indigo.shade700],
                            ),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.child_care,
                                  size: isLargeScreen ? 48 : (isMediumScreen ? 40 : 32),
                                  color: Colors.white,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "AGE\n${ageGroups[index]}",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: isLargeScreen ? 18 : (isMediumScreen ? 16 : 14),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    // Overlay text for clarity
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.6),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      left: 0,
                      right: 0,
                      child: Text(
                        "AGE ${ageGroups[index]}",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isLargeScreen ? 18 : (isMediumScreen ? 16 : 14),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: const Offset(1, 1),
                              blurRadius: 2,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  /// Simplified Game Selection with just images as buttons
  Widget _buildSimpleGameSelection(bool isLargeScreen, bool isMediumScreen, bool isSmallScreen, bool isTinyScreen, bool isLandscape) {
    List<Map<String, dynamic>> games = [];

    if (selectedAgeGroup == "4-6") {
      games = [
        {"title": "STORY PUZZLE", "image": "assets/story_puzzle_logo.jpeg", "screen": StoryPuzzleLevel1()},
        {"title": "NUMBER NINJA", "image": "assets/number_ninja_logo.jpeg", "screen": NumberNinjas1(ageGroup: selectedAgeGroup!)},
        {"title": "MATH FRENZY", "image": "assets/math_frenzy_logo.png", "screen": MathFrenzyApp1()},       
        {"title": "WORD WIZARD", "image": "assets/word_wizard_logo.png", "screen": WordWizardApp1()},
        {"title": "Phantom Spellers", "image": "assets/ar_logo.png", "screen": ARWordHuntGame()},
      ];
    } else if (selectedAgeGroup == "6-8") {
      games = [
        {"title": "STORY PUZZLE", "image": "assets/story_puzzle_logo.jpeg", "screen": StoryPuzzelApp2_1()},
        {"title": "NUMBER NINJA", "image": "assets/number_ninja_logo.jpeg", "screen": NumberNinjas2(ageGroup: selectedAgeGroup!)},
        {"title": "MATH FRENZY", "image": "assets/math_frenzy_logo.png", "screen": MathFrenzyApp2()},
        {"title": "WORD WIZARD", "image": "assets/word_wizard_logo.png", "screen": WordWizardApp2()},
        {"title": "Phantom Spellers", "image": "assets/ar_logo.png", "screen": ARWordHuntGame()},
      ];
    } else if (selectedAgeGroup == "8-10") {
      games = [
        {"title": "STORY PUZZLE", "image": "assets/story_puzzle_logo.jpeg", "screen": StoryPuzzleApp3()},
        {"title": "NUMBER NINJA", "image": "assets/number_ninja_logo.jpeg", "screen": NumberNinjas3(ageGroup: selectedAgeGroup!)},
        {"title": "MATH FRENZY", "image": "assets/math_frenzy_logo.png", "screen": MathFrenzyApp3()},
        {"title": "PHANTOM SPELLERS", "image": "assets/ar_logo.png", "screen": ARWordHuntGame()},
      ];
    } else if (selectedAgeGroup == "10-12") {
      games = [
        {"title": "STORY PUZZLE", "image": "assets/story_puzzle_logo.jpeg", "screen": StoryPuzzleLevel1()},
        {"title": "NUMBER NINJA", "image": "assets/number_ninja_logo.jpeg", "screen": NumberNinjas3(ageGroup: selectedAgeGroup!)},
        {"title": "MATH FRENZY", "image": "assets/math_frenzy_logo.png", "screen": MathFrenzyApp4()},
        {"title": "PHANTOM SPELLERS", "image": "assets/ar_logo.png", "screen": ARWordHuntGame()},
      ];
    }

    bool useGridLayout = isSmallScreen && !isLandscape && games.length > 2;
    int gridCrossAxisCount = isLargeScreen ? 3 : (isMediumScreen ? 2 : (isLandscape ? 3 : 2));
    double headerFontSize = isLargeScreen ? 24 : (isMediumScreen ? 20 : 16);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                setState(() {
                  selectedAgeGroup = null;
                });
              },
            ),
            Text(
              "Games for Ages $selectedAgeGroup", 
              style: TextStyle(
                fontSize: headerFontSize,
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
          ],
        ),
        SizedBox(height: isSmallScreen ? 16 : 24),
        
        // Use grid for game images
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: gridCrossAxisCount,
            childAspectRatio: 1.0,
            crossAxisSpacing: isSmallScreen ? 12 : 16,
            mainAxisSpacing: isSmallScreen ? 12 : 16,
          ),
          itemCount: games.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => games[index]["screen"]),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    // Game image
                    Image.asset(
                      games[index]["image"],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                    // Darkened overlay with text
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Game title
                    Positioned(
                      bottom: 12,
                      left: 0,
                      right: 0,
                      child: Text(
                        games[index]["title"],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isLargeScreen ? 18 : (isMediumScreen ? 16 : 14),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: const Offset(1, 1),
                              blurRadius: 2,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Play icon overlay
                    Positioned.fill(
                      child: Center(
                        child: Icon(
                          Icons.play_circle_fill,
                          size: isLargeScreen ? 60 : (isMediumScreen ? 50 : 40),
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}