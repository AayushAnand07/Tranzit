import 'package:firebase_auth/firebase_auth.dart';


class FirebaseJwtHelper{

  FirebaseJwtHelper._();

  static Future<String?> getJwtToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if  (user != null) {
      final idToken = await user.getIdToken(true);
      return idToken;
    }
    return null;
  }
}