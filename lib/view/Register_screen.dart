import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ziya/controller/fire_auth.dart';
import 'package:ziya/view/sign_up.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _username = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();

  bool _showPassword = false;
  bool _showConfirmPassword = false;

  final _formKey = GlobalKey<FormState>();

  void _registerUser() async {
    if (_formKey.currentState!.validate()) {
      if (_password.text != _confirmPassword.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Passwords do not match")),
        );
        return;
      }

      try {
        final cred = await AuthService.registerWithEmail(
          _email.text.trim(),
          _password.text.trim(),
        );

        // Navigate to detailed registration screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => RegistrationScreen()),
        );
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Signup failed')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                const Text("Register", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Image.asset("assets/image/photo_2025-07-09_13-34-29.jpg", width: 100, height: 100),
                const SizedBox(height: 12),
                const Text("Pulse Post", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text("Please enter your details below", style: TextStyle(color: Colors.grey)),

                const SizedBox(height: 30),
                _buildTextField("User Name", _username),
                _buildTextField("Email Address", _email, keyboardType: TextInputType.emailAddress, isEmail: true),
                _buildPasswordField("Password", _password, _showPassword, () {
                  setState(() => _showPassword = !_showPassword);
                }),
                _buildPasswordField("Confirm Password", _confirmPassword, _showConfirmPassword, () {
                  setState(() => _showConfirmPassword = !_showConfirmPassword);
                }),

                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _registerUser,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    child: const Text("Sign Up", style: TextStyle(fontSize: 16)),
                  ),
                ),

                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account? "),
                    GestureDetector(
                      onTap: () {
                        // TODO: Navigate to Login
                      },
                      child: const Text("Login", style: TextStyle(color: Colors.blue)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text, bool isEmail = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: "Enter your $label",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return 'Required';
          if (isEmail && !value.contains('@')) return 'Invalid email';
          return null;
        },
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller, bool isVisible, VoidCallback toggle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        obscureText: !isVisible,
        decoration: InputDecoration(
          labelText: label,
          hintText: "Enter your $label",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          suffixIcon: IconButton(
            icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off),
            onPressed: toggle,
          ),
        ),
        validator: (value) {
          if (value == null || value.length < 6) return 'Minimum 6 characters';
          return null;
        },
      ),
    );
  }
}
