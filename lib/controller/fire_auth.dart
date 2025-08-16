import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Register a new user with email and password
  static Future<UserCredential> registerWithEmail(String email, String password) {
    return _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Login existing user with email and password
  static Future<UserCredential> loginWithEmail(String email, String password) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    await _saveLoginFlag(true); // Save login state
    return userCredential;
  }

  /// Send a password reset email
  static Future<void> sendPasswordReset(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  /// Logout the current user and clear login flag
  static Future<void> logout() async {
    await _auth.signOut();
    await _saveLoginFlag(false); // Clear login state
  }

  /// Save login flag to SharedPreferences
  static Future<void> _saveLoginFlag(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', isLoggedIn);
  }

  /// Get login flag from SharedPreferences
  static Future<bool> getLoginFlag() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }
}
