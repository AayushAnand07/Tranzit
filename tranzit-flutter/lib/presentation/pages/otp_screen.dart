import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:tranzit/infrastructure/providers/Auth.Providers/auth.provider.dart';
import 'package:tranzit/presentation/pages/login_screen.dart';

class OtpScreen extends StatefulWidget {
  final String verificationId;
  const OtpScreen({super.key, required this.verificationId});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {


  @override
  Widget build(BuildContext context) {
    final themeTeal = const Color(0xFF004751);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<LoginAuthenticationProvider>(
        builder: (context, provider, _) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                IconButton(
                  icon: Icon(Icons.arrow_back, color: themeTeal),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginSignupScreen()),
                    );
                    provider.resetOtpState();
                  },
                ),
                const SizedBox(height: 16),

                const Text(
                  'Verify with OTP',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),


                const Text(
                  'Sent via SMS to 9012345678',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 32),


                Center(
                  child: Pinput(
                    length: 6,
                    controller: provider.otpController,
                    defaultPinTheme: PinTheme(
                      width: 56,
                      height: 56,
                      textStyle: const TextStyle(
                        fontSize: 24,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    focusedPinTheme: PinTheme(
                      width: 56,
                      height: 56,
                      textStyle: const TextStyle(
                        fontSize: 24,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: themeTeal, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    cursor: Container(
                      width: 2,
                      height: 24,
                      color: themeTeal,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  provider.replace
                      ? "Try fill yourself"
                      : 'Trying to auto-fill OTP 00:${provider.secondsLeft.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 32),

                Center(
                  child: provider.isLoading
                      ? const CircularProgressIndicator(color: Color(0xFF0E4546))
                      : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding:
                        const EdgeInsets.symmetric(vertical: 20),
                        backgroundColor: provider.isOtpComplete
                            ? themeTeal
                            : Colors.grey,
                      ),
                      onPressed: provider.isOtpComplete
                          ? () => provider.verifyOtp(
                          provider.otpController.text, context)
                          : null,
                      child: const Text(
                        'CONTINUE',
                        style: TextStyle(
                            fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                Center(
                  child: Text.rich(
                    TextSpan(
                      text: 'Having trouble logging in? ',
                      style:
                      const TextStyle(fontSize: 14, color: Colors.black54),
                      children: [
                        TextSpan(
                          text: 'Get Help',
                          style: TextStyle(
                            color: themeTeal,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
