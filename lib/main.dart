import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ziya/controller/fire_auth.dart';


import 'package:firebase_auth/firebase_auth.dart';
import 'package:ziya/view/Register_screen.dart';
import 'package:ziya/view/interst_verify_screen.dart';
import 'package:ziya/view/login.dart';
import 'package:ziya/view/sign_up.dart';
import 'package:ziya/view/splash_screen.dart';
import 'package:ziya/view/welcome.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final isLoggedIn = await AuthService.getLoginFlag();
  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatefulWidget {
  final bool isLoggedIn;
  const MyApp({required this.isLoggedIn, super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool showHome = false;

  @override
  void initState() {
    super.initState();
    showHome = widget.isLoggedIn;
    FirebaseAuth.instance.authStateChanges().listen((user) {
      setState(() {
        showHome = widget.isLoggedIn && user != null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ziya Project',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: showHome ?  DashboardScreen() :  SplashScreen(),
      routes: {
        '/login': (_) =>  LoginScreen(),
        '/signup': (_) =>  RegisterPage(),
        '/home': (_) =>  DashboardScreen(),
    '/interests': (_) => InterestsScreen(),
    '/verify': (_) => VerifyScreen(),
      },
    );
  }
}