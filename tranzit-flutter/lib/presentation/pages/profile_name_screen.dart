import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tranzit/home_screen.dart';
import 'package:tranzit/presentation/pages/NewHomeScreen.dart';

import '../../infrastructure/providers/Auth.Providers/profile.provider.dart';

class FirstTimeRegistrationScreen extends StatefulWidget {
  const FirstTimeRegistrationScreen({Key? key}) : super(key: key);

  @override
  State<FirstTimeRegistrationScreen> createState() => _FirstTimeRegistrationScreenState();
}

class _FirstTimeRegistrationScreenState extends State<FirstTimeRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
 String uid = FirebaseAuth.instance.currentUser!.uid;

void _submit(BuildContext context) async {
  if (_formKey.currentState?.validate() ?? false) {
    final name = _nameController.text;

    final provider = Provider.of<CreateProfileProvider>(context, listen: false);
    await provider.postProfile(uid, name);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', name);

    if (!provider.isLoading && provider.error.isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Welcome, $name! Registration complete.')),
      );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>NewHomeScreen()),
          );

    } else if (provider.error.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error)),
      );
    }
  }
}
  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CreateProfileProvider>(context);
    final primaryColor = Colors.teal.shade700;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 0),
          child: Column(
                mainAxisAlignment: MainAxisAlignment.center ,
            children: [
              Icon(Icons.person_outline, size: 100, color: primaryColor.withOpacity(0.7)),
              const SizedBox(height: 24),
              Text(
                "Welcome!",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Let us know your name",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 40),
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Enter your name',
                    labelStyle: TextStyle(fontWeight: FontWeight.w800),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.edit, color: primaryColor),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your name';
                    }
                    if (value.trim().length < 2) {
                      return 'Name should be at least 2 characters';
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(context),
                ),
              ),
              const SizedBox(height: 40),
              (provider.isLoading)?CircularProgressIndicator(backgroundColor: primaryColor,):SizedBox(
                width: screenWidth,
                child: ElevatedButton(
                  onPressed:() async {
                    if (_formKey.currentState?.validate() ?? false) {
                   _submit(context);
                  }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
