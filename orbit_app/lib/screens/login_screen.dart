import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  final Function(bool) updateLoginStatus;

  const LoginScreen({super.key, required this.updateLoginStatus});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController regNameController = TextEditingController();
  TextEditingController regEmailController = TextEditingController();
  TextEditingController regPasswordController = TextEditingController();
  TextEditingController regConfirmPasswordController = TextEditingController();
  
  bool isRegistering = false;
  bool isLoading = false;
  String errorMessage = '';
  
  // Firebase Auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive layout
    final Size screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 600;
    
    // Calculate login box size - much smaller than before
    final double formWidth = isSmallScreen 
        ? screenSize.width * 0.8  // 80% of screen width on small screens
        : 320;                    // Fixed smaller width on larger screens
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        elevation: 4,
        title: Row(
          children: [
            // Logo
            Image.asset(
              "assets/logo.jpeg", 
              height: isSmallScreen ? 36 : 40,
            ),
            const SizedBox(width: 12),
            // App name with custom font
            Text(
              "ORBITED",
              style: GoogleFonts.orbitron(
                textStyle: TextStyle(
                  fontSize: isSmallScreen ? 18 : 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset(
            "assets/background.jpeg",
            fit: BoxFit.cover,
          ),

          // Centered Auth Form with SingleChildScrollView for keyboard handling
          Center(
            child: SingleChildScrollView(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: formWidth,
                padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                decoration: BoxDecoration(
                  color: Colors.blue.shade700.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Error message display
                    if (errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            errorMessage,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      
                    isRegistering 
                      ? _buildRegisterForm(isSmallScreen) 
                      : _buildLoginForm(isSmallScreen),
                      
                    // Loading indicator
                    if (isLoading)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Login Form Widget
  Widget _buildLoginForm(bool isSmallScreen) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Form Title
        Text(
          "Player Login",
          style: TextStyle(
            fontSize: isSmallScreen ? 20 : 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        
        SizedBox(height: isSmallScreen ? 16 : 20),

        // Email Field (changed from Player Name)
        _buildTextField(
          nameController, 
          "Email",
          prefixIcon: Icons.email,
          keyboardType: TextInputType.emailAddress,
          isSmallScreen: isSmallScreen
        ),

        // Password Field
        _buildTextField(
          passwordController, 
          "Password", 
          isPassword: true,
          prefixIcon: Icons.lock,
          isSmallScreen: isSmallScreen
        ),

        SizedBox(height: isSmallScreen ? 20 : 24),

        // Login Button with responsive sizing
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isLoading ? null : _signInWithEmailAndPassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: EdgeInsets.symmetric(
                vertical: isSmallScreen ? 12 : 15
              ),
              elevation: 5,
            ),
            child: Text(
              "LOGIN", 
              style: TextStyle(
                fontSize: isSmallScreen ? 16 : 18, 
                fontWeight: FontWeight.bold,
                color: Colors.white
              ),
            ),
          ),
        ),

        SizedBox(height: isSmallScreen ? 16 : 20),
        
        // Register Link
        TextButton(
          onPressed: isLoading 
            ? null 
            : () {
              setState(() {
                isRegistering = true;
                errorMessage = '';
              });
            },
          child: const Text(
            "Not a player already? Register here",
            style: TextStyle(
              color: Colors.white,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  /// Registration Form Widget
  Widget _buildRegisterForm(bool isSmallScreen) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Form Title
        Text(
          "Player Registration",
          style: TextStyle(
            fontSize: isSmallScreen ? 20 : 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        
        SizedBox(height: isSmallScreen ? 16 : 20),

        // Player Name Field
        _buildTextField(
          regNameController, 
          "Player Name",
          prefixIcon: Icons.person,
          isSmallScreen: isSmallScreen
        ),

        // Email Field
        _buildTextField(
          regEmailController, 
          "Email Address",
          prefixIcon: Icons.email,
          keyboardType: TextInputType.emailAddress,
          isSmallScreen: isSmallScreen
        ),

        // Password Field
        _buildTextField(
          regPasswordController, 
          "Password", 
          isPassword: true,
          prefixIcon: Icons.lock,
          isSmallScreen: isSmallScreen
        ),

        // Confirm Password Field
        _buildTextField(
          regConfirmPasswordController, 
          "Confirm Password", 
          isPassword: true,
          prefixIcon: Icons.lock_outline,
          isSmallScreen: isSmallScreen
        ),

        SizedBox(height: isSmallScreen ? 20 : 24),

        // Register Button with responsive sizing
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isLoading ? null : _registerWithEmailAndPassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: EdgeInsets.symmetric(
                vertical: isSmallScreen ? 12 : 15
              ),
              elevation: 5,
            ),
            child: Text(
              "REGISTER", 
              style: TextStyle(
                fontSize: isSmallScreen ? 16 : 18, 
                fontWeight: FontWeight.bold,
                color: Colors.white
              ),
            ),
          ),
        ),

        SizedBox(height: isSmallScreen ? 16 : 20),
        
        // Login Link
        TextButton(
          onPressed: isLoading 
            ? null 
            : () {
              setState(() {
                isRegistering = false;
                errorMessage = '';
              });
            },
          child: const Text(
            "Already registered? Login here",
            style: TextStyle(
              color: Colors.white,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  /// Reusable TextField Widget with improved design
  Widget _buildTextField(
    TextEditingController controller, 
    String label, 
    {bool isPassword = false, 
    TextInputType keyboardType = TextInputType.text,
    IconData? prefixIcon,
    bool isSmallScreen = false}
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white),
          prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Colors.white70) : null,
          filled: true,
          fillColor: Colors.blue.shade800.withOpacity(0.6),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10), 
            borderSide: BorderSide.none
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: prefixIcon != null ? 0 : 16, 
            vertical: isSmallScreen ? 10 : 12
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.white, width: 1),
          ),
        ),
      ),
    );
  }
  
  // Firebase Authentication methods
  
  /// Sign in with email and password
  Future<void> _signInWithEmailAndPassword() async {
    // Validate input
    if (nameController.text.isEmpty || passwordController.text.isEmpty) {
      setState(() {
        errorMessage = 'Please enter both email and password';
      });
      return;
    }
    
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    
    try {
      // Attempt to sign in
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: nameController.text.trim(),
        password: passwordController.text,
      );
      
      // Update login status in SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool("isLoggedIn", true);
      widget.updateLoginStatus(true);
      
      // Navigate back (or to dashboard)
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'user-not-found') {
          errorMessage = 'No user found with this email';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Wrong password provided';
        } else {
          errorMessage = 'Login failed: ${e.message}';
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Login failed: $e';
        isLoading = false;
      });
    }
  }
  
  /// Register with email and password
  Future<void> _registerWithEmailAndPassword() async {
    // Input validation
    if (regNameController.text.isEmpty || 
        regEmailController.text.isEmpty || 
        regPasswordController.text.isEmpty) {
      setState(() {
        errorMessage = 'Please fill all fields';
      });
      return;
    }
    
    if (regPasswordController.text != regConfirmPasswordController.text) {
      setState(() {
        errorMessage = 'Passwords don\'t match';
      });
      return;
    }
    
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    
    try {
      // Create user with email and password
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: regEmailController.text.trim(),
        password: regPasswordController.text,
      );
      
      // Update user profile with display name
      await userCredential.user?.updateDisplayName(regNameController.text);
      
      // Registration successful notification
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registration successful! Please login."))
      );
      
      // Reset form and switch to login
      setState(() {
        isRegistering = false;
        isLoading = false;
        nameController.text = regEmailController.text;
        passwordController.text = "";
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'weak-password') {
          errorMessage = 'The password is too weak';
        } else if (e.code == 'email-already-in-use') {
          errorMessage = 'An account already exists for this email';
        } else {
          errorMessage = 'Registration failed: ${e.message}';
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Registration failed: $e';
        isLoading = false;
      });
    }
  }
}