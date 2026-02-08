import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rodb_delivery_app/app/pages/auth-gate-page/auth_gate_page.dart';
import 'firebase_options_prod.dart' as firebase_prod;
import 'firebase_options_uat.dart' as firebase_uat;

const String environment = String.fromEnvironment('ENV', defaultValue: 'uat');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Select Options based on ENV
  final firebaseOptions = environment == 'prod'
      ? firebase_prod.DefaultFirebaseOptions.currentPlatform
      : firebase_uat.DefaultFirebaseOptions.currentPlatform;

  await Firebase.initializeApp(options: firebaseOptions);
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
      home: const AuthGatePage(),
    );
  }
}
