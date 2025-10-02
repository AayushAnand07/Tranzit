import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tranzit/infrastructure/providers/Auth.Providers/auth.provider.dart';
import 'package:tranzit/presentation/pages/otp_screen.dart';

class LoginSignupScreen extends StatefulWidget {
  const LoginSignupScreen({super.key});

  @override
  State<LoginSignupScreen> createState() => _LoginSignupScreenState();
}

class _LoginSignupScreenState extends State<LoginSignupScreen> {

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _verificationId = '';
  bool _inProgress=false;
  Future<void> sendOtp(String phoneNumber) async {
    setState(() {
      _inProgress=true;
    });

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: "+91$phoneNumber",
      verificationCompleted: (PhoneAuthCredential credential) async {
        await FirebaseAuth.instance.signInWithCredential(credential);
        print("Phone verified automatically");
      },
      verificationFailed: (FirebaseAuthException e) {
        print("Verification failed: ${e.message}");
      },
      codeSent: (verificationId, int? resendToken) {
        _verificationId = verificationId;
        print("OTP sent. Verification ID saved: $_verificationId");

        setState(() {
          _inProgress=false;
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpScreen(verificationId: _verificationId,mobileNumber: phoneNumber,),
          ),
        );
      },
      codeAutoRetrievalTimeout: (verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  void sendTestOtp(String phoneNumber) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: '+91'+phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) {
        print("Auto verification completed");
      },
      verificationFailed: (FirebaseAuthException e) {
        print("Verification failed: ${e.message}");
      },
      codeSent: (String verificationId, int? resendToken) {
        print("OTP code sent! Verification ID: $verificationId");
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        print("Auto retrieval timeout");
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children:  [
                  Text(
                    'Login',
                    style: TextStyle(
                      fontFamily: 'Ubuntu',
                      fontWeight: FontWeight.w600,
                      fontSize: 28,
                      color: Color(0xff004751)
                    ),
                  ),
                  SizedBox(width: 5),
                  Text(
                    'or',
                    style: TextStyle(
                      fontFamily: 'Source Sans Pro',
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(width: 5),
                  Text(
                    'Signup',
                    style: TextStyle(
                      fontFamily: 'Ubuntu',
                        fontWeight: FontWeight.w600,
                        fontSize: 28,
                        color: Color(0xff004751)
                    ),
                  ),
                ],
              ),

              SizedBox(height: 24),
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                decoration: InputDecoration(
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(left: 16, right: 8),
                    child: Text(
                      '+91',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 18,
                      ),
                    ),
                  ),
                  prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                  label: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "Mobile number",
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 18,
                          ),
                        ),
                        TextSpan(
                          text: ' *',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  counterText: '',

                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.grey[400]!,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.teal,
                      width: 2,
                    ),
                  ),
                  // Add these to keep same style on error
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.grey[400]!,
                      width: 1.5,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.teal,
                      width: 2,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 22, horizontal: 16),
                ),

                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter mobile number';
                  }
                  if (value.length != 10) {
                    return 'Mobile number must be 10 digits';
                  }
                  if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                    return 'Mobile number must contain only digits';
                  }
                  return null;
                },
              ),
            ),

              const SizedBox(height: 16),
              // Terms and privacy
              RichText(
                text: TextSpan(
                    style: TextStyle(color: Colors.black87),
                    children: [
                   const   TextSpan(
                          text: 'By continuing, I agree to the '
                      ),
                      TextSpan(
                        text: 'Terms of Use ',
                        style: TextStyle(
                            color: Colors.blue[800],
                            decoration: TextDecoration.underline
                        ),
                        // You can add gesture recognizer here.
                      ),
                     const  TextSpan(text: '& '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(
                            color: Colors.blue[800],
                            decoration: TextDecoration.underline
                        ),
                      )
                    ]
                ),
              ),
              SizedBox(height: 24),
              Consumer<LoginAuthenticationProvider> (
              builder: (context, snapshot,_) {
                 return (snapshot.isLoading)?CircularProgressIndicator(color: Color(0xFF0E4546),):SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 18),
                        backgroundColor: Color(0xFF0E4546),
                      ),
                      onPressed: () async{
                        if (_formKey.currentState!.validate()) {
                          snapshot.sendOtp(_phoneController.text, context);
                        }
                      },
                      child: Text(
                        'CONTINUE',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  );
               }
             ),
              SizedBox(height: 18),
              Text.rich(
                TextSpan(
                  text: 'Having trouble logging in? ',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                  children: [
                    TextSpan(
                      text: 'Get Help',
                      style: TextStyle(
                        color: Colors.teal,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
