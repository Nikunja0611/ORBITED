import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefService {
  static const String isLoggedInKey = "isLoggedIn";
  static const String usernameKey = "username";
  static const String passwordKey = "password"; // Not recommended for security reasons

  // Save login state
  static Future<void> setLoginStatus(bool status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(isLoggedInKey, status);
  }

  // Retrieve login state
  static Future<bool> getLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(isLoggedInKey) ?? false; // Default: false
  }

  // Save username and password (for demo purposes only, avoid storing passwords in plain text)
  static Future<void> saveCredentials(String username, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(usernameKey, username);
    await prefs.setString(passwordKey, password); // Encrypt in real applications
  }

  // Retrieve username
  static Future<String?> getUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(usernameKey);
  }

  // Retrieve password (for testing only, avoid in real apps)
  static Future<String?> getPassword() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(passwordKey);
  }

  // Logout and clear login data
  static Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(isLoggedInKey);
    await prefs.remove(usernameKey);
    await prefs.remove(passwordKey);
  }
}
