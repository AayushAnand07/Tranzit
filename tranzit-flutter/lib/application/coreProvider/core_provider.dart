import 'package:provider/provider.dart';

import '../../infrastructure/providers/Auth.Providers/auth.provider.dart';



List<ChangeNotifierProvider> providers =[

  ChangeNotifierProvider<LoginAuthenticationProvider>(create: (_)=>LoginAuthenticationProvider()),

];