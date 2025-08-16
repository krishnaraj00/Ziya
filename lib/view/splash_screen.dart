import 'dart:async';
import 'package:flutter/material.dart';
import 'login.dart'; // or your main/home/login page

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Wait for 3 seconds and navigate
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()), // Update to your main screen
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Or any background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/image/photo_2025-07-09_13-34-29.jpg', width: 150), // Add your app logo
            const SizedBox(height: 20),
            const CircularProgressIndicator(color: Colors.blue), // Optional loading
          ],
        ),
      ),
    );
  }
}
