import 'package:provider/provider.dart';

import '../../infrastructure/providers/Auth.Providers/auth.provider.dart';
import '../../infrastructure/providers/Auth.Providers/booking.provider.dart';
import '../../infrastructure/providers/Auth.Providers/profile.provider.dart';
import '../../infrastructure/providers/Auth.Providers/route.provider.dart';
import '../../infrastructure/providers/speech.provider.dart';



List<ChangeNotifierProvider> providers =[

  ChangeNotifierProvider<LoginAuthenticationProvider>(create: (_)=>LoginAuthenticationProvider()),
  ChangeNotifierProvider<CreateProfileProvider>(create: (_)=>CreateProfileProvider()),
  ChangeNotifierProvider<RouteProvider>(create: (_)=>RouteProvider()),
  ChangeNotifierProvider<BookingProvider>(create: (_)=>BookingProvider()),
  ChangeNotifierProvider<SpeechProvider>(create: (_)=>SpeechProvider()),

];