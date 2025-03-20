import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

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
                child: isRegistering ? _buildRegisterForm(isSmallScreen) : _buildLoginForm(isSmallScreen),
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

        // Player Name Field
        _buildTextField(
          nameController, 
          "Player Name",
          prefixIcon: Icons.person,
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
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setBool("isLoggedIn", true);
              widget.updateLoginStatus(true);

              Navigator.pop(context); // Go back to Dashboard
            },
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
          onPressed: () {
            setState(() {
              isRegistering = true;
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
            onPressed: () {
              // Simple validation
              if (regPasswordController.text != regConfirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Passwords don't match!"))
                );
                return;
              }
              
              if (regNameController.text.isEmpty || 
                  regEmailController.text.isEmpty || 
                  regPasswordController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please fill all fields!"))
                );
                return;
              }
              
              // Registration successful
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Registration successful! Please login."))
              );
              
              // Reset form and switch to login
              setState(() {
                isRegistering = false;
                nameController.text = regNameController.text;
                passwordController.text = "";
              });
            },
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
          onPressed: () {
            setState(() {
              isRegistering = false;
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
}