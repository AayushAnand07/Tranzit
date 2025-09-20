import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:tranzit/application/coreProvider/core_provider.dart';
import 'package:tranzit/presentation/pages/NewHomeScreen.dart';
import 'firebase_options.dart';
import 'presentation/pages/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    return MultiProvider(
      providers: providers,
        child:ScreenUtilInit(
            designSize: const Size(360, 690),
            minTextAdapt: true,
            splitScreenMode: true,
          builder: (context,child) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Tranzit',
              theme: ThemeData(

               colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF0E4546)),
                useMaterial3: true,
              ),
              home:(user!=null)? NewHomeScreen():LoginSignupScreen()
            );
          }
        ),

    );
  }
}
