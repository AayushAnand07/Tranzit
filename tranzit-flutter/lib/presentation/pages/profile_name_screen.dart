import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<CreateProfileProvider>(context, listen: false);
      provider.clearError(); 
    });
  }

  Future<void> _submit(BuildContext context) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final name = _nameController.text.trim();
    final provider = Provider.of<CreateProfileProvider>(context, listen: false);

    try {

      provider.clearError();

      await provider.postProfile(uid, name);


      if (!provider.isLoading && provider.error.isEmpty) {
        await _handleSuccessfulRegistration(name);
      } else if (provider.error.isNotEmpty) {
        _showErrorSnackBar(provider.error);
      }
    } catch (e) {
      _showErrorSnackBar('An unexpected error occurred. Please try again.');
    }
  }

  Future<void> _handleSuccessfulRegistration(String name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', name);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome, $name! Registration complete.'),
            backgroundColor: Colors.green,
          ),
        );


        await Future.delayed(const Duration(milliseconds: 500));

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => NewHomeScreen()),
          );
        }
      }
    } catch (e) {
      _showErrorSnackBar('Registration successful but navigation failed. Please restart the app.');
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Dismiss',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
  }

  void _clearErrorAndRetry() {
    final provider = Provider.of<CreateProfileProvider>(context, listen: false);
    provider.clearError();
    setState(() {}); // Refresh the UI
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CreateProfileProvider>(
      builder: (context, provider, child) {
        final primaryColor = Theme.of(context).primaryColor;
        final screenWidth = MediaQuery.of(context).size.width;

        return Scaffold(
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                      Icons.person_outline,
                      size: 100,
                      color: primaryColor.withOpacity(0.7)
                  ),
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
                  const Text(
                    "Let us know your name",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 40),

                  if (provider.error.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        border: Border.all(color: Colors.red.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              provider.error,
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: _clearErrorAndRetry,
                            icon: Icon(Icons.close, color: Colors.red.shade700, size: 18),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                  ],

                  Form(
                    key: _formKey,
                    child: TextFormField(
                      controller: _nameController,
                      enabled: !provider.isLoading, // Disable during loading
                      decoration: InputDecoration(
                        labelText: 'Enter your name',
                        labelStyle: const TextStyle(fontWeight: FontWeight.w800),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)
                        ),
                        prefixIcon: Icon(Icons.edit, color: primaryColor),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.red.shade400),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your name';
                        }
                        if (value.trim().length < 2) {
                          return 'Name should be at least 2 characters';
                        }
                        if (value.trim().length > 50) {
                          return 'Name should be less than 50 characters';
                        }
                        return null;
                      },
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: provider.isLoading ? null : (_) => _submit(context),
                      onChanged: (_) {

                        if (provider.error.isNotEmpty) {
                          provider.clearError();
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 40),

                  SizedBox(
                    width: screenWidth,
                    child: provider.isLoading
                        ? Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: primaryColor,
                          strokeWidth: 2,
                        ),
                      ),
                    )
                        : ElevatedButton(
                      onPressed: () => _submit(context),
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
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white
                        ),
                      ),
                    ),
                  ),

                  // Add retry button if there's an error
                  if (provider.error.isNotEmpty && !provider.isLoading) ...[
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _clearErrorAndRetry,
                      child: Text(
                        'Try Again',
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}