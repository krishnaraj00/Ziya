import 'package:flutter/material.dart';
import 'package:ziya/controller/progress_indicator.dart';
import 'package:ziya/view/login.dart';

import 'package:flutter/material.dart';
import 'package:ziya/controller/progress_indicator.dart';

class InterestsScreen extends StatefulWidget {
  const InterestsScreen({super.key});

  @override
  State<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends State<InterestsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign Up"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: BackButton(onPressed: () => Navigator.pop(context)),
      ),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StepProgressHeader(
              currentStep: 1,
              onStepTap: (index) {
                if (index == 0) Navigator.pop(context); // Back to profile
                if (index == 2) Navigator.pushNamed(context, '/verify');
              },
            ),
            const Text("Select Your Interests", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            const Text("🔧 Work In Progress..."),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/verify'),
                child: const Text("Continue to Verify"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



class VerifyScreen extends StatefulWidget {
  const VerifyScreen({super.key});

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign Up"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: BackButton(onPressed: () => Navigator.pop(context)),
      ),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StepProgressHeader(
              currentStep: 2,
              onStepTap: (index) {
                if (index == 0) Navigator.popUntil(context, ModalRoute.withName('/login'));
                if (index == 1) Navigator.pop(context); // Back to Interests
              },
            ),
            const Text("Verification", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            const Text("🔒 Verification screen content here..."),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: const Text("Next Page"),
            ),
          ],
        ),
      ),
    );
  }
}
