import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:ziya/controller/progress_indicator.dart';
import 'package:ziya/view/map.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  String? gender;
  File? profilePic;

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _dob = TextEditingController();
  final _age = TextEditingController();
  final _location = TextEditingController();
  final _address = TextEditingController();
  final _occupation = TextEditingController();
  final _referral = TextEditingController();
  final _phone = TextEditingController();
  final _otp = TextEditingController();

  String? selectedQualification;
  String? customQualification;
  bool isTermsAccepted = false;
  bool isFormValid = false;
  bool isOTPSent = false;
  bool isPhoneVerified = false;
  String? _verificationId;

  void _checkFormValidity() {
    final filled = _name.text.isNotEmpty &&
        _email.text.isNotEmpty &&
        _password.text.isNotEmpty &&
        _dob.text.isNotEmpty &&
        _age.text.isNotEmpty &&
        _location.text.isNotEmpty &&
        _address.text.isNotEmpty &&
        _occupation.text.isNotEmpty &&
        _phone.text.isNotEmpty &&
        isPhoneVerified &&
        selectedQualification != null &&
        (selectedQualification != 'Other' || (customQualification?.isNotEmpty ?? false)) &&
        gender != null;

    setState(() {
      isFormValid = filled;
      if (!filled) isTermsAccepted = false;
    });
  }

  Future<void> pickImage() async {
    final img = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (img != null) setState(() => profilePic = File(img.path));
  }

  void _onDOBChanged(DateTime d) {
    final now = DateTime.now();
    int years = now.year - d.year - ((now.month < d.month || (now.month == d.month && now.day < d.day)) ? 1 : 0);

    if (years < 16) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You must be at least 16 years old")),
      );
      _dob.clear();
      _age.clear();
      return;
    }

    setState(() {
      _dob.text = DateFormat('yyyy-MM-dd').format(d);
      _age.text = years.toString();
    });
    _checkFormValidity();
  }

  Future<void> _openMapAndFillLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DummyMapScreen()),
    );

    if (result != null && result is Map<String, String>) {
      setState(() {
        _location.text = result['location'] ?? '';
      });
      _checkFormValidity();
    }
  }

  Future<void> sendOTP() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: _phone.text.trim(),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await FirebaseAuth.instance.signInWithCredential(credential);
        setState(() {
          isPhoneVerified = true;
          isOTPSent = true;
        });
        _checkFormValidity();
      },
      verificationFailed: (FirebaseAuthException e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Verification Failed: ${e.message}")));
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
          isOTPSent = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("OTP sent to your number")));
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  Future<void> verifyOTP() async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _otp.text.trim(),
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      setState(() {
        isPhoneVerified = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("OTP number verified")));
      _checkFormValidity();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Invalid OTP")));
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || gender == null || !isPhoneVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields and verify phone")),
      );
      return;
    }

    if (!isTermsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You must accept the terms and conditions")),
      );
      return;
    }

    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text.trim(),
      );

      final uid = cred.user!.uid;
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': _name.text.trim(),
        'email': _email.text.trim(),
        'dob': _dob.text.trim(),
        'age': int.tryParse(_age.text.trim()),
        'gender': gender,
        'phone': _phone.text.trim(),
        'location': _location.text.trim(),
        'address': _address.text.trim(),
        'qualification': selectedQualification == 'Other' ? customQualification : selectedQualification,
        'occupation': _occupation.text.trim(),
        'referral': _referral.text.trim(),
        'photoUrl': '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      Navigator.pushNamed(context, '/interests');
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Registration failed')),
      );
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool readOnly = false, TextInputType keyboard = TextInputType.text, Widget? suffixIcon, bool required = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: keyboard,
        onChanged: (_) => _checkFormValidity(),
        decoration: _inputDecoration(label).copyWith(suffixIcon: suffixIcon),
        validator: required ? (v) => v == null || v.isEmpty ? 'Required' : null : null,
      ),
    );
  }

  Widget _buildGenderSelector() {
    final genderOptions = ['Male', 'Female', 'Other'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Gender", style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 20,
          children: genderOptions.map((g) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Radio<String>(
                  value: g,
                  groupValue: gender,
                  onChanged: (val) {
                    setState(() => gender = val);
                    _checkFormValidity();
                  },
                ),
                Text(g),
              ],
            );
          }).toList(),
        ),
        if (gender == null)
          const Padding(
            padding: EdgeInsets.only(top: 4, left: 4),
            child: Text('Required', style: TextStyle(color: Colors.red)),
          ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildDOBPicker() {
    return _buildTextField(
      "Date of Birth",
      _dob,
      readOnly: true,
      suffixIcon: IconButton(
        icon: const Icon(Icons.calendar_today),
        onPressed: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime(2000),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
          );
          if (picked != null) _onDOBChanged(picked);
        },
      ),
    );
  }

  Widget _buildQualificationDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          decoration: _inputDecoration("Qualification"),
          value: selectedQualification,
          items: ['10', '12', 'Diploma', 'Degree', 'Master Degree', 'Other']
              .map((q) => DropdownMenuItem(value: q, child: Text(q)))
              .toList(),
          onChanged: (val) {
            setState(() {
              selectedQualification = val;
              if (val != 'Other') customQualification = null;
              _checkFormValidity();
            });
          },
          validator: (val) => val == null || val.isEmpty ? 'Required' : null,
        ),
        if (selectedQualification == 'Other')
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: TextFormField(
              decoration: _inputDecoration("Enter Other Qualification"),
              onChanged: (value) {
                customQualification = value;
                _checkFormValidity();
              },
              validator: (value) {
                if (selectedQualification == 'Other' && (value == null || value.isEmpty)) {
                  return 'Please enter your qualification';
                }
                return null;
              },
            ),
          ),
      ],
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: isTermsAccepted,
          onChanged: isFormValid ? (val) => setState(() => isTermsAccepted = val ?? false) : null,
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Terms & Conditions"),
                  content: const Text("You must accept the terms and conditions to register."),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("OK"),
                    ),
                  ],
                ),
              );
            },
            child: const Text.rich(
              TextSpan(
                text: 'I accept the ',
                children: [
                  TextSpan(
                    text: 'Terms & Conditions',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registration")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              StepProgressHeader(
                currentStep: 0,
                onStepTap: (index) {
                  if (index == 1) Navigator.pushNamed(context, '/interests');
                },
              ),
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: profilePic != null ? FileImage(profilePic!) : null,
                    child: profilePic == null ? const Icon(Icons.person, size: 50) : null,
                  ),
                  IconButton(icon: const Icon(Icons.edit), onPressed: pickImage),
                ],
              ),
              const SizedBox(height: 20),
              _buildTextField("Full Name", _name),
              _buildTextField("Email", _email, keyboard: TextInputType.emailAddress),
              _buildTextField("Password", _password, keyboard: TextInputType.visiblePassword),
              _buildDOBPicker(),
              _buildTextField("Age", _age, readOnly: true),
              _buildGenderSelector(),
              _buildTextField("Phone Number", _phone, keyboard: TextInputType.phone),
              if (!isPhoneVerified)
                ElevatedButton(
                  onPressed: _phone.text.isNotEmpty ? sendOTP : null,
                  child: const Text("Send OTP"),
                ),
              if (isOTPSent && !isPhoneVerified)
                Row(
                  children: [
                    Expanded(child: _buildTextField("Enter OTP", _otp, keyboard: TextInputType.number)),
                    ElevatedButton(
                      onPressed: _otp.text.isNotEmpty ? verifyOTP : null,
                      child: const Text("Verify"),
                    ),
                  ],
                ),
              _buildTextField(
                "Location",
                _location,
                readOnly: true,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.location_on),
                  onPressed: _openMapAndFillLocation,
                ),
              ),
              _buildTextField("Address", _address),
              _buildQualificationDropdown(),
              _buildTextField("Occupation", _occupation),
              _buildTextField("Referral Code", _referral, required: false),
              _buildTermsCheckbox(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isFormValid && isTermsAccepted ? _submitForm : null,
                child: const Text("Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
