import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:tranzit/application/coreProvider/core_provider.dart';
import 'package:tranzit/presentation/pages/NewHomeScreen.dart';
import 'firebase_options.dart';
import 'infrastructure/services/notification.service.dart';
import 'presentation/pages/AdminScreen.dart';
import 'presentation/pages/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService.initialize();
  runApp(const MyApp());
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});
  ThemeData get appTheme => ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF0E4546)),
    useMaterial3: true,
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return Color(0xFF0E4546);
        }
        return Colors.grey;
      }),
      trackColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return Color(0xFF0E4546).withOpacity(0.54);
        }
        return Colors.grey.withOpacity(0.38);
      }),
    ),
  );

  @override
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return MultiProvider(
      providers: providers,
      child: ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          if (user == null) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: appTheme, // Add theme here
              home: LoginSignupScreen(),
            );
          } else {
            return FutureBuilder<IdTokenResult>(
              future: user.getIdTokenResult(true),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return MaterialApp(
                    theme: appTheme,
                    debugShowCheckedModeBanner: false,
                    home: Scaffold(
                      backgroundColor: Colors.white,
                      body: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Failed to get user role.'));
                }
                final role = snapshot.data!.claims!['role'] ?? 'USER';

                return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  title: 'Tranzit',
                  theme: appTheme,     
                  home: role == 'admin' ? const AdminScreen() : NewHomeScreen(),
                );
              },
            );
          }
        },
      ),
    );
  }
}