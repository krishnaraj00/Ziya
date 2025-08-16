import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ziya/model/password%20_change.dart';

import 'package:ziya/view/social_screen.dart';
import 'package:ziya/view/Register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isPhoneLogin = false;

  final TextEditingController _email = TextEditingController();
  final TextEditingController _pwd = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _otp = TextEditingController();

  String? verificationId;
  bool showOtpField = false;
  bool isVerifying = false;

  Future<void> _sendOtp() async {
    if (_phone.text.trim().length != 10) {
      _showSnackBar("Enter valid 10-digit mobile number");
      return;
    }
    setState(() {
      isVerifying = true;
      showOtpField = false;
    });

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: "+91${_phone.text.trim()}",
      verificationCompleted: (_) {},
      verificationFailed: (e) => _showSnackBar(e.message ?? "OTP verification failed"),
      codeSent: (String verId, int? resendToken) {
        setState(() {
          verificationId = verId;
          showOtpField = true;
          isVerifying = false;
        });
        _showSnackBar("OTP sent successfully");
      },
      codeAutoRetrievalTimeout: (String verId) {
        verificationId = verId;
      },
    );
  }

  Future<void> _verifyAndLoginWithOtp() async {
    if (_otp.text.trim().isEmpty || verificationId == null) {
      _showSnackBar("Please enter a valid OTP");
      return;
    }

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId!,
        smsCode: _otp.text.trim(),
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SocialFollowPage()),
      );
    } catch (_) {
      _showSnackBar("Invalid OTP");
    }
  }

  Future<void> _loginWithEmail() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email.text.trim(),
        password: _pwd.text.trim(),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const SocialFollowPage()),
      );
    } catch (e) {
      _showSnackBar('Login failed: ${e.toString()}');
    }
  }

  Future<void> _forgotPasswordDialog() async {
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController otpController = TextEditingController();
    String? verificationId;
    bool otpSent = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Reset Password via Phone"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: "Phone Number",
                      prefixIcon: Icon(Icons.phone),
                    ),
                  ),
                  if (otpSent) ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: otpController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Enter OTP",
                        prefixIcon: Icon(Icons.lock_open),
                      ),
                    ),
                  ]
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () async {
                    if (!otpSent) {
                      if (phoneController.text.trim().length == 10) {
                        await FirebaseAuth.instance.verifyPhoneNumber(
                          phoneNumber: '+91${phoneController.text.trim()}',
                          verificationCompleted: (_) {},
                          verificationFailed: (e) => _showSnackBar(e.message ?? 'Verification Failed'),
                          codeSent: (verId, _) {
                            setState(() {
                              verificationId = verId;
                              otpSent = true;
                            });
                            _showSnackBar('OTP sent');
                          },
                          codeAutoRetrievalTimeout: (verId) {
                            verificationId = verId;
                          },
                        );
                      } else {
                        _showSnackBar('Enter valid 10-digit number');
                      }
                    } else {
                      if (verificationId != null && otpController.text.isNotEmpty) {
                        try {
                          final credential = PhoneAuthProvider.credential(
                            verificationId: verificationId!,
                            smsCode: otpController.text.trim(),
                          );
                          await FirebaseAuth.instance.signInWithCredential(credential);

                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
                          );
                        } catch (e) {
                          _showSnackBar("Invalid OTP or Verification Failed");
                        }
                      }
                    }
                  },
                  child: Text(otpSent ? "Verify OTP" : "Send OTP"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB2EBF2), Color(0xFF81D4FA)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Container(
              width: 380,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 18,
                    spreadRadius: 6,
                    offset: Offset(4, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(
                    child: Text(
                      "Login",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Use "),
                      DropdownButton<bool>(
                        value: isPhoneLogin,
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(value: false, child: Text("Email")),
                          DropdownMenuItem(value: true, child: Text("Phone")),
                        ],
                        onChanged: (val) {
                          setState(() {
                            isPhoneLogin = val!;
                            showOtpField = false;
                          });
                        },
                      ),
                      const Text(" to login"),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Email Login
                  if (!isPhoneLogin) ...[
                    TextFormField(
                      controller: _email,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _pwd,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _forgotPasswordDialog,
                        child: const Text("Forgot Password?"),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _loginWithEmail,
                      child: const Text('Login'),
                    ),
                  ],

                  // Phone Login
                  if (isPhoneLogin) ...[
                    TextFormField(
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Mobile Number',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (showOtpField)
                      TextFormField(
                        controller: _otp,
                        decoration: InputDecoration(
                          labelText: 'Enter OTP',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ElevatedButton(
                      onPressed: showOtpField ? _verifyAndLoginWithOtp : _sendOtp,
                      child: Text(showOtpField ? 'Verify OTP & Login' : 'Send OTP'),
                    ),
                  ],

                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?"),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const RegisterPage()),
                          );
                        },
                        child: const Text('Sign Up'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
