


import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tranzit/home_screen.dart';

import '../../../presentation/pages/login_screen.dart';
import '../../../presentation/pages/otp_screen.dart';
import '../../../presentation/components/custom_snackbar.dart';
import '../../../presentation/pages/profile_name_screen.dart';

class LoginAuthenticationProvider with ChangeNotifier{

  bool _isLoading= false;
  bool get isLoading => _isLoading;

  String _verificationId='';
  String get verificationId => _verificationId;



  int _secondsLeft = 14;
  int get secondsLeft => _secondsLeft;

  bool _replace = false;
  bool get replace => _replace;


  bool _isOtpComplete = false;
  bool get isOtpComplete => _isOtpComplete;

  Timer? _timer;

  final TextEditingController otpController = TextEditingController();

  LoginAuthenticationProvider() {
    // Listen for OTP input changes
    otpController.addListener(() {
      _isOtpComplete = otpController.text.length == 6;
      notifyListeners();
    });
  }

  void startTimer() {
    _secondsLeft = 14;
    _replace = false;
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (_secondsLeft > 0) {
        _secondsLeft--;
      } else {
        t.cancel();
        _replace = true;
      }
      notifyListeners();
    });
  }

  void resetOtpState() {
    _isOtpComplete = false;
    _secondsLeft = 14;
    _replace = false;
    otpController.clear();
    _timer?.cancel();
    notifyListeners();
  }







  @override
  void dispose() {
    otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }






  Future<void> sendOtp(String phoneNumber, BuildContext ctx) async {
    _isLoading = true;
    notifyListeners();

    try{
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: "+91$phoneNumber",
        verificationCompleted: (PhoneAuthCredential credential) async {
          final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
          final bool isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
          print("this is new user $isNewUser");
          print("this is new user $userCredential");
          if(isNewUser){
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setBool('isFirstLogin', true);
          }else{
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setBool('isFirstLogin', false);
          }
          print("Phone verified automatically");
        },
        verificationFailed: (FirebaseAuthException e) {
          throw FirebaseAuthException(message: "Verification Failed ${e.message}",code: "404");
        },
        codeSent: (verificationId, int? resendToken) {
          _verificationId = verificationId;
          print("OTP sent. Verification ID saved: $_verificationId");
          _isLoading = false; // reset immediately

          notifyListeners();
          Navigator.pushReplacement(
            ctx,
            MaterialPageRoute(
              builder: (context) => OtpScreen(verificationId: _verificationId),
            ),
          );
        },

        codeAutoRetrievalTimeout: (verificationId) {
          _verificationId = verificationId;
        },
      );
      startTimer();
    }
    catch (e) {
      _handleError(ctx, e);
    }
  }



  Future<void> verifyOtp(String otp, BuildContext ctx) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    _isLoading = true;
    notifyListeners();

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: otp,
      );

      final UserCredential userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);


      bool? isFirstLogin = prefs.getBool('isFirstLogin');
      if (isFirstLogin == null) {
        final bool newUser = userCredential.additionalUserInfo?.isNewUser ?? false;
        await prefs.setBool('isFirstLogin', newUser);
        isFirstLogin = newUser;
      }

      // Reset OTP state
      _timer?.cancel();
      otpController.clear();
      _isOtpComplete = false;
      _secondsLeft = 14;
      _replace = false;

      // Navigate depending on first login
      if (isFirstLogin) {
        Navigator.pushReplacement(
          ctx,
          MaterialPageRoute(
            builder: (context) => FirstTimeRegistrationScreen(),
          ),
        );
      } else {
        Navigator.pushReplacement(
          ctx,
          MaterialPageRoute(
            builder: (context) => HomeScreen(),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      _handleError(ctx, e);
    } catch (e) {
      _handleError(ctx, e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }




  void _handleError(BuildContext ctx, dynamic e) {
    _isLoading = false;
    notifyListeners();

    ScaffoldMessenger.of(ctx).hideCurrentSnackBar();

    if (e is TimeoutException) {
      SnackbarHelper.showSnackbar(
        ctx,
        title: "Timeout Error",
        message:
        "Login took too long than expected. Please try again later",
        icon: Icons.error_outline,
        color: Colors.red,
      );
    } else if (e is SocketException) {
      SnackbarHelper.showSnackbar(
        ctx,
        title: "Connection Error",
        message:
        "Couldn't connect to the server. Please check your connection and try again.",
        icon: Icons.error_outline,
        color: Colors.red,
      );
    } else if (e is FirebaseAuthException) {
      SnackbarHelper.showSnackbar(
        ctx,
        title: "Auth Error",
        message: e.message ?? "Authentication failed",
        icon: Icons.error_outline,
        color: Colors.red,
      );
    } else {
      SnackbarHelper.showSnackbar(
        ctx,
        title: "Error Occurred",
        message: "$e",
        icon: Icons.error_outline,
        color: Colors.red,
      );
    }
  }

}