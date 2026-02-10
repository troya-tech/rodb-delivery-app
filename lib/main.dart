import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'firebase_options_prod.dart' as firebase_prod;
import 'firebase_options_uat.dart' as firebase_uat;
import 'app/routing/app_router.dart';
import 'app/routing/app_routes.dart';

const String environment = String.fromEnvironment('ENV', defaultValue: 'uat');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Select environment config
  final isProd = environment == 'prod';
  final firebaseOptions = isProd
      ? firebase_prod.DefaultFirebaseOptions.currentPlatform
      : firebase_uat.DefaultFirebaseOptions.currentPlatform;
  final webClientId = isProd
      ? firebase_prod.DefaultFirebaseOptions.webClientId
      : firebase_uat.DefaultFirebaseOptions.webClientId;

  await Firebase.initializeApp(options: firebaseOptions);
  
  // Initialize Google Sign-In v7 (required before usage)
  await GoogleSignIn.instance.initialize(
    serverClientId: webClientId,
    // Add scopes if needed, e.g., scopes: ['email'],
  );

  runApp(const ProviderScope(child: MyApp()));
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RODB Delivery App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: AppRoutes.authGate,
    );
  }
}

